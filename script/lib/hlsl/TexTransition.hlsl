//PS02 Default Shader
sampler sampler0_ : register(s0);
//THESE MUST BE POWERS OF 2
const float SCREEN_WIDTH = 1024;
const float SCREEN_HEIGHT = 512;
texture textureMask_;
sampler samplerMask_ = sampler_state
{ 
	Texture = <textureMask_>;
};

struct PS_INPUT
{
	float4 diffuse : COLOR0;
	float2 texCoord : TEXCOORD0;
	float2 vPos : VPOS;
};

struct PS_OUTPUT
{
    float4 color : COLOR0;
};

PS_OUTPUT PsMask( PS_INPUT In ) : COLOR0
{
	PS_OUTPUT Out;

	float4 colorTexture = tex2D(sampler0_, In.texCoord);

	float4 colorDiffuse = In.diffuse;

	float4 color = colorTexture * colorDiffuse;
	Out.color = color;
	if (color.a > 0)
	{
		float2 maskUV;

		maskUV.x = In.vPos.x / SCREEN_WIDTH;
		maskUV.y = In.vPos.y / SCREEN_HEIGHT;
		float4 colorMask = tex2D(samplerMask_, maskUV);

		Out.color.a = ( colorMask.r + colorMask.g + colorMask.b ) * 0.3333f * color.a;
	}


	return Out;
}

technique TecMask
{
	pass P0
	{
		PixelShader = compile ps_3_0 PsMask();
	}
}

