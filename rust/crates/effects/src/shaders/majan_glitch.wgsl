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

fn hash(p: f32) -> f32 {
    return fract(sin(p * 127.1 + 311.7) * 43758.5453);
}

@fragment
fn fragment_main(input: VertexOutput) -> @location(0) vec4f {
    let amount = uniforms.scalars.x;
    let seed = uniforms.scalars.y;
    let slices = max(uniforms.scalars.z, 1.0);
    let rgb_shift = uniforms.scalars.w;
    var uv = input.tex_coord;

    // slice displacement
    let band = floor(uv.y * slices);
    let r1 = hash(band + floor(seed) * 7.13);
    let r2 = hash(band * 1.7 + floor(seed) * 3.1 + 5.0);
    let active = step(0.65, r1);
    uv.x = uv.x + (r2 - 0.5) * 2.0 * amount * 0.25 * active;

    // rgb channel split
    let shift = (rgb_shift / uniforms.resolution.x) * (0.5 + 0.5 * hash(floor(seed) + 42.0));
    let r = textureSample(input_texture, input_sampler, vec2f(uv.x + shift, uv.y)).r;
    let ga = textureSample(input_texture, input_sampler, uv);
    let b = textureSample(input_texture, input_sampler, vec2f(uv.x - shift, uv.y)).b;

    // scanlines
    let scan = 0.94 + 0.06 * step(1.5, input.position.y % 3.0);
    return vec4f(vec3f(r, ga.g, b) * scan, ga.a);
}
