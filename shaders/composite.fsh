#version 120 // Или #version 330 compatibility

// !!!
// I've used AI to create explanations within every shader file, so any user can understand the code and feel empowered to modify everything to your liking! :3 - shrek
// !!!

// composite.fsh
// This is the fragment shader for the 'composite' pass (post-processing).
// It receives the fully rendered scene as a texture (colortex0) and applies
// screen-space effects based on 'MESS_INTENSITY'.

// Includes MESS_INTENSITY define
#include "settings.glsl" 

// --- Uniforms ---
uniform sampler2D colortex0; // Входная текстура сцены.
uniform float ftime; // Время.

// --- Varyings ---
varying vec2 texcoord; // Текстурные координаты, переданные из вершинного шейдера.

// --- Helper Functions ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void main() {
    float messFactor = MESS_INTENSITY / 100.0;
    messFactor = pow(messFactor, 2.0); // messFactor = ~0.5625

    // --- 1. Coordinate Distortion Mayhem ---
    vec2 distortedTexcoord = texcoord;

    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = center - texcoord;
    float distToCenter = length(toCenter);
    float angle = atan(toCenter.y, toCenter.x);
    float swirlAmount = sin(distToCenter * 20.0 - ftime * (5.0 + messFactor * 5.0)) * 0.3 * messFactor * 2.5;
    distortedTexcoord.x += cos(angle + ftime * 3.0) * swirlAmount;
    distortedTexcoord.y += sin(angle + ftime * 3.0) * swirlAmount;

    float waveStrength = 0.1 + messFactor * 0.2 * 2.5;
    distortedTexcoord.x += sin(texcoord.y * (35.0 + messFactor * 40.0) + ftime * (3.0 + messFactor * 5.0)) * waveStrength;
    distortedTexcoord.y += cos(texcoord.x * (35.0 + messFactor * 40.0) + ftime * (3.0 + messFactor * 5.0)) * waveStrength;

    vec4 originalColor = texture2D(colortex0, distortedTexcoord); // Используем texture2D для compatibility profile.

    // ВНИМАНИЕ: Если фон полностью черный, возможно, альфа-канал равен 0.0, и это отбрасывает цвет.
    // Убедимся, что это не происходит, если ожидается цветной фон.
    // Если небо все равно черное, попробуйте закомментировать этот if-блок.
    // if (originalColor.a == 0.0) {
    //     gl_FragColor = vec4(0.0);
    //     return;
    // }

    // --- 2. Psychedelic Color Transformation ---
    vec3 messyColor = originalColor.rgb;
    messyColor.r = abs(sin(texcoord.x * (30.0 + messFactor * 50.0) + ftime * (5.0 + messFactor * 8.0) + originalColor.g * 10.0));
    messyColor.g = abs(cos(texcoord.y * (30.0 + messFactor * 50.0) + ftime * (6.0 + messFactor * 7.0) + originalColor.b * 10.0));
    messyColor.b = abs(sin((texcoord.x + texcoord.y) * (25.0 + messFactor * 45.0) + ftime * (4.0 + messFactor * 9.0) + originalColor.r * 10.0));

    // --- 3. Glitchy Color Channel Swapping ---
    float timeSlice = floor(ftime * (10.0 + messFactor * 25.0));
    if (messFactor > 0.1) {
        if (mod(timeSlice, 3.0) == 0.0) {
            messyColor.rgb = messyColor.gbr;
        } else if (mod(timeSlice, 3.0) == 1.0) {
            messyColor.rgb = messyColor.brg;
        }
    }

    // --- 4. Scanline Overlay ---
    float scanlineEffect = sin(distortedTexcoord.y * (300.0 + messFactor * 500.0) - ftime * (70.0 + messFactor * 200.0)) * 0.1 * messFactor * 2.0;
    messyColor += scanlineEffect;

    // --- Final Output ---
    messyColor = clamp(messyColor, 0.0, 1.0);
    gl_FragColor = vec4(messyColor, originalColor.a); // Используем gl_FragColor для compatibility profile.
}