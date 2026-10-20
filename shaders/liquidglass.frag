#version 440
// Liquid Glass material.
//
// The effect item covers the glass shape plus a margin on every side, and so
// does the input texture (mipmapped backdrop capture). The margin is needed
// because the curved rim refracts content from *outside* the shape inwards.
//
// Pipeline per fragment:
//   1. rounded-rect SDF            -> shape mask, distance to the rim, outward normal
//   2. bezel height profile        -> refraction offset (strongest at the rim)
//   3. per-channel offset          -> chromatic dispersion
//   4. sharp/blur mix, vibrancy    -> frosted, saturated body (blur = mip level + tent)
//   5. Fresnel rim + specular      -> light catching the edge
//   6. pointer glow                -> reacts to interaction
//   7. drop shadow outside shape   -> lifts the glass off the backdrop

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 canvasSize;   // effect size in px (shape + 2 * margin)
    vec2 shapeSize;    // glass shape size in px
    float radius;      // corner radius in px
    float bezel;       // width of the curved rim in px
    float refraction;  // max displacement at the rim in px
    float dispersion;  // 0..1 chromatic spread of the displacement
    float frost;       // 0 = clear glass, 1 = fully blurred backdrop
    float blurRadius;  // frost blur radius in px
    float blurLod;     // mip level matching blurRadius
    float saturation;  // vibrancy boost of what is seen through the glass
    float specular;    // edge highlight strength
    float shadow;      // drop shadow strength
    vec2 lightDir;     // direction towards the light, screen space (y down)
    vec2 pointer;      // pointer in shape coords, negative = none
    vec4 tint;         // rgb tint, a = amount
};

layout(binding = 1) uniform sampler2D source;   // mipmapped backdrop capture

float sdRoundRect(vec2 p, vec2 halfSize, float r)
{
    vec2 q = abs(p) - halfSize + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// Blur without an extra pass: a biased lookup reads a pre-averaged mip level,
// and a 9-tap tent over it smooths away the blockiness.
vec3 blurred(vec2 uv)
{
    vec2 r = vec2(blurRadius) / canvasSize;
    vec3 c = texture(source, uv, blurLod).rgb * 4.0;
    c += (texture(source, uv + vec2(r.x, 0.0), blurLod).rgb
        + texture(source, uv - vec2(r.x, 0.0), blurLod).rgb
        + texture(source, uv + vec2(0.0, r.y), blurLod).rgb
        + texture(source, uv - vec2(0.0, r.y), blurLod).rgb) * 2.0;
    c += texture(source, uv + r, blurLod).rgb
       + texture(source, uv - r, blurLod).rgb
       + texture(source, uv + vec2(r.x, -r.y), blurLod).rgb
       + texture(source, uv + vec2(-r.x, r.y), blurLod).rgb;
    return c / 16.0;
}

vec3 backdrop(vec2 uv)
{
    return mix(texture(source, uv).rgb, blurred(uv), frost);
}

void main()
{
    vec2 px = qt_TexCoord0 * canvasSize;
    vec2 p = px - canvasSize * 0.5;
    vec2 halfSize = shapeSize * 0.5;
    float r = min(radius, min(halfSize.x, halfSize.y));
    float d = sdRoundRect(p, halfSize, r);   // < 0 inside the glass

    // Outward surface normal (2D) from the SDF gradient.
    vec2 e = vec2(0.5, 0.0);
    vec2 n = vec2(sdRoundRect(p + e.xy, halfSize, r) - sdRoundRect(p - e.xy, halfSize, r),
                  sdRoundRect(p + e.yx, halfSize, r) - sdRoundRect(p - e.yx, halfSize, r));
    n = dot(n, n) > 1e-8 ? normalize(n) : vec2(0.0);

    float inside = -d;
    float bz = max(min(bezel, min(halfSize.x, halfSize.y) * 0.9), 1.0);
    float edge = 1.0 - clamp(inside / bz, 0.0, 1.0);   // 1 at rim, 0 on the flat top

    // Circular bezel profile: flat in the middle, bending steeply at the rim.
    float bend = 1.0 - sqrt(max(1.0 - edge * edge, 0.0));
    vec2 offs = n * (refraction * bend) / canvasSize;   // sample outwards

    vec3 col;
    col.r = backdrop(qt_TexCoord0 + offs * (1.0 + dispersion)).r;
    col.g = backdrop(qt_TexCoord0 + offs).g;
    col.b = backdrop(qt_TexCoord0 + offs * (1.0 - dispersion)).b;

    // Vibrancy + tint.
    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));
    col = mix(vec3(luma), col, saturation);
    col = mix(col, tint.rgb, tint.a);

    // Fresnel rim and directional specular highlights.
    vec2 L = normalize(lightDir);
    float facing = dot(n, L);
    float rimLine = 1.0 - smoothstep(0.0, 2.0, inside);   // ~2px hairline
    float rimGlow = edge * edge * edge * edge;             // soft band over the bezel
    float spec = pow(max(facing, 0.0), 4.0) * (rimLine * 0.9 + rimGlow * 0.35)
               + pow(max(-facing, 0.0), 4.0) * (rimLine * 0.45 + rimGlow * 0.15)
               + rimLine * 0.15;
    col += specular * spec;

    // Pointer: soft light under the finger/cursor that also lights the rim.
    if (pointer.x >= 0.0) {
        vec2 dp = p - (pointer - halfSize);
        float glow = exp(-dot(dp, dp) / (2.0 * 45.0 * 45.0));
        col += glow * (0.06 + rimLine * 0.5 * specular);
    }

    float cover = clamp(0.5 - d, 0.0, 1.0);

    // Drop shadow, only outside the glass.
    float ds = sdRoundRect(p - vec2(0.0, 6.0), halfSize, r);
    float sh = shadow * exp(-max(ds, 0.0) / 9.0) * (1.0 - cover);

    // Premultiplied output: glass over shadow.
    fragColor = vec4(min(col, vec3(1.0)) * cover, cover + sh) * qt_Opacity;
}
