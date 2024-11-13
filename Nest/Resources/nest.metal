#include <SwiftUI/SwiftUI.h>
#include <metal_stdlib>

using namespace metal;

[[ stitchable ]]
half4 glow(
  float2 position,
  half4 color,
  float2 origin,
  float2 size
) {
    float2 uv_position = position / size;
    float2 uv_origin = origin / size;

    float distance = length(uv_position - uv_origin);

    float glowIntensity = exp(-distance * distance);
    glowIntensity *= smoothstep(0.0, 1.0, (1.0 - distance));

    return color * glowIntensity;
}
