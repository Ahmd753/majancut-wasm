struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) tex_coord: vec2f,
}

struct EffectUniforms {
    resolution: vec2f,
    direction: vec2f,
    scalars: vec4f,
}

@group(0) @binding(0) var input_texture: texture_2d<f32>;
@group(0) @binding(1) var input_sampler: sampler;
@group(1) @binding(0) var<uniform> uniforms: EffectUniforms;

@fragment
fn fragment_main(input: VertexOutput) -> @location(0) vec4f {
    let amount = uniforms.scalars.x;
    let softness = max(uniforms.scalars.y, 0.001);
    let c = textureSample(input_texture, input_sampler, input.tex_coord);
    let d = distance(input.tex_coord, vec2f(0.5, 0.5)) * 1.4142;
    let vig = 1.0 - amount * smoothstep(1.0 - softness, 1.0, d);
    return vec4f(c.rgb * vig, c.a);
}
