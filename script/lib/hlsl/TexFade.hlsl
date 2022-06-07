//Thanks Natashi <3
sampler samp0_ : register(s0);

texture textureMask_;
sampler sampMask_ = sampler_state {
	Texture = <textureMask_>;
	MagFilter = POINT;
};

float frame_;
float xWidth = 512; //width of image

struct PS_INPUT {
	float4 diffuse : COLOR0;
	float2 texCoord : TEXCOORD0;
};

float4 mainPS(PS_INPUT inPs) : COLOR0 {
	float2 texUV = inPs.texCoord;
	
	float2 maskUV = texUV * float2(xWidth, 256);

	maskUV.x = fmod(maskUV, 4) + frame_ * 4;
	maskUV /= float2(16, 4);

	float maskAlpha = tex2D(sampMask_, maskUV).a;
	
	float4 color = tex2D(samp0_, texUV);
	color.a = maskAlpha;
	
	return color;
}

technique Render {
	pass P0 {
		PixelShader = compile ps_3_0 mainPS();
	}
}