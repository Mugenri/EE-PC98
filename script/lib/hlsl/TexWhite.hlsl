//Thanks Natashi <3
sampler sampler0_ : register(s0);

float enable_;

struct PS_INPUT {
    float4 diffuse : COLOR0;  
    float2 texCoord : TEXCOORD0;
};

float4 PsWhite(PS_INPUT inPs) : COLOR0 {
    float4 color = tex2D(sampler0_, inPs.texCoord);
    
    color.rgb = lerp(color.rgb, (float3)1, enable_);
    
    return color * inPs.diffuse;
}

technique TecWhite {
    pass P0 {
        PixelShader = compile ps_2_0 PsWhite();
    }
}