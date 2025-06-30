#version 120

// !!!
// I've used AI to create explanations within every shader file, so any user can understand the code and feel empowered to modify everything to your liking! :3 - shrek
// !!!

// gbuffers_terrain.vsh
// This vertex shader runs for every vertex of the terrain geometry.
// Its primary job is to calculate the final position of each vertex on the screen,
// and to pass data (like texture coordinates, normals, and colors) to the fragment shader.
// It applies a MINOR texture distortion to make blocks visible but "wavy".

#include "settings.glsl"

// --- Uniforms ---
uniform float ftime; // Time in seconds, provided by OptiFine/Iris, used for animation.

// --- Varyings ---
varying vec2 v_texcoord; // Passed to fragment shader for texture sampling.
varying vec3 v_normal;   // Passed to fragment shader for lighting calculations.
varying vec4 v_color;    // Passed to fragment shader for color tinting.

// --- Helper Functions ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void main() {
    // --- Mess Intensity Control ---
    float messFactor = MESS_INTENSITY / 100.0;
    // Снижаем эффект messFactor ещё сильнее для блоков, делая его очень слабым.
    messFactor = pow(messFactor, 2.0); // Или даже pow(messFactor, 3.0) если 2.0 ещё слишком сильно

    // --- Standard OpenGL Transformations ---
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    v_normal = normalize(gl_NormalMatrix * gl_Normal);
    v_color = gl_Color;

    // --- 1. Texcoord Distortion Mayhem (МИЗЕРНОЕ ИСКАЖЕНИЕ ТЕКСТУР) ---
    vec2 baseTexcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    if (messFactor > 0.001) { // Проверяем, что messFactor достаточно значим для эффекта
        // Уменьшаем амплитуду эффекта ещё больше, чтобы текстуры были более различимы.
        // Значения 0.001, 0.002 или 0.003 будут создавать очень тонкую рябь.
        float waveAmplitude = 0.001; // Уменьшено с 0.005 до 0.001
        float waveFrequency = 15.0 + messFactor * 10.0; // Частота волн
        float waveSpeed = 2.0 + messFactor * 1.0;      // Скорость волн

        float waveAmountX = sin(baseTexcoord.y * waveFrequency + ftime * waveSpeed) * waveAmplitude * messFactor;
        float waveAmountY = cos(baseTexcoord.x * waveFrequency + ftime * waveSpeed) * waveAmplitude * messFactor;

        v_texcoord = baseTexcoord + vec2(waveAmountX, waveAmountY);
    } else {
        v_texcoord = baseTexcoord; // Без искажений, если messFactor очень мал.
    }
}