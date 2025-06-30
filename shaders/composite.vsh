#version 120

// composite.vsh (Standard, passes through)
// This vertex shader prepares the screen-filling quad for post-processing.
// It typically does not apply distortions itself, but calculates texture coordinates
// for the fragment shader to sample the rendered scene.

// --- Uniforms ---
uniform float ftime;

// --- Varyings ---
varying vec2 texcoord;

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;
}