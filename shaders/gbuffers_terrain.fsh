#version 120

// !!!
// I've used AI to create explanations within every shader file, so any user can understand the code and feel empowered to modify everything to your liking! :3 - shrek
// !!!

// gbuffers_terrain.fsh
// This fragment shader runs for every pixel of the terrain geometry.
// It determines the final color and other properties (like depth) of terrain fragments.
// It applies NO color manipulation or fragment discarding, and ensures normal depth.

#include "settings.glsl"

// --- Uniforms ---
uniform sampler2D texture; // Основная текстура блоков.

// --- Varyings ---
varying vec2 v_texcoord; // Текстурные координаты (уже немного искаженные из вершинного шейдера).
varying vec3 v_normal;   // Нормаль.
varying vec4 v_color;    // Цвет вершины.

void main() {
    // Sample the diffuse texture using the received (possibly slightly distorted) texture coordinates.
    // Multiply by `v_color` which handles biome tinting.
    vec4 baseColor = texture2D(texture, v_texcoord) * v_color;

    // Все "Color Insanity", "Random Discard" (дыры), и "Depth Buffer Mayhem" (Z-файтинг) УДАЛЕНЫ.

    // --- Output to GBuffer ---
    /* DRAWBUFFERS:0 */ // Указание OptiFine на буфер вывода.
    gl_FragColor = baseColor; // Выводим базовый цвет (с искаженной текстурой).

    // --- Depth Buffer ---
    gl_FragDepth = gl_FragCoord.z; // Стандартное значение глубины, без Z-файтинга.
}