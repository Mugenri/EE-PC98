#define PI 3.14159265

texture textureWave;
sampler2D sampWave = sampler_state {
    Texture = <textureWave>;
    MinFilter = POINT;
    MagFilter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float len = 0;
float amp = 0;
float phase = 0;
float width = 256; // width of image
float height = 256; // height of image

struct PS_INPUT {
    float2 texCoord : TEXCOORD0;
    float2 screenPos : VPOS;
};

float4 Main(PS_INPUT input) : COLOR0 {
    float t = ((614.4 * input.screenPos.y / len) + phase) * (PI / 128.0);
    float2 uv = input.texCoord;
    uv.x += (amp * sin(t) / float2(width, height));
    return tex2D(sampWave, uv);
}

technique Render {
    pass P0 {
        PixelShader = compile ps_3_0 Main();
    }
}
