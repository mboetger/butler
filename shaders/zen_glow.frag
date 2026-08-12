#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution;
    
    // Center coordinate
    vec2 center = vec2(0.5, 0.5);
    
    // Slow breathing effect
    float t = u_time * 0.3;
    
    // Generate some smooth waves
    float wave1 = sin(uv.x * 3.0 + t) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 2.0 - t * 0.8) * 0.5 + 0.5;
    float wave3 = sin((uv.x + uv.y) * 2.0 + t * 1.2) * 0.5 + 0.5;
    
    float combined = (wave1 + wave2 + wave3) / 3.0;
    
    // Base zen colors (soft dark blues, teal, purple)
    vec3 colorA = vec3(0.02, 0.05, 0.15); // Deep blue
    vec3 colorB = vec3(0.1, 0.25, 0.35);  // Soft teal
    vec3 colorC = vec3(0.15, 0.1, 0.25);  // Deep purple
    
    // Mix the colors based on the waves
    vec3 finalColor = mix(colorA, colorB, combined);
    finalColor = mix(finalColor, colorC, sin(t * 0.5) * 0.5 + 0.5);
    
    // Add a subtle glowing vignette from the center
    float dist = distance(uv, center);
    float vignette = smoothstep(1.0, 0.0, dist);
    
    finalColor += vec3(0.05, 0.1, 0.15) * vignette * (sin(t) * 0.5 + 0.5);
    
    fragColor = vec4(finalColor, 1.0);
}
