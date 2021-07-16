// The purpose of this shader is to allow for 'extra 1' and 'extra 2' to serve as shift indecies for STEP_X and STEP_Y

sampler samp0_ : register(s0);

// The 4-by-4 matrix linked to WORLDVIEWPROJ semantic is provided by the engine.
// It is used to transform world coordinates to device coordinates.
float4x4 g_mWorldViewProj : WORLDVIEWPROJ : register(c0);

// STEP_X = width / maxWidth
// STEP_Y = height / maxHeight

float STEP_X = 1.0f;
float STEP_Y = 1.0f;

struct VS_INPUT {
	//Vertex data
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
	
	//Instance data
	float4 i_color	: COLOR1;
	float4 i_xyz_pos_x_scale 	: TEXCOORD1;	// Pack: (x pos, y pos, z pos, x scale)
	float4 i_yz_scale_xy_ang 	: TEXCOORD2;	// Pack: (y scale, z scale, x angle, y angle)
	float4 i_z_ang_extra		: TEXCOORD3;	// Pack: (z angle, extra 1, extra 2, extra 3)
};
struct PS_INPUT {
	float4 position : POSITION;
	float4 diffuse 	: COLOR0;
	float2 texCoord : TEXCOORD0;
};

PS_INPUT mainVS(VS_INPUT inVs) {
	PS_INPUT outVs;
	
	float3 t_scale = float3(inVs.i_xyz_pos_x_scale.w, inVs.i_yz_scale_xy_ang.xy);
	
	float2 ax = float2(sin(inVs.i_yz_scale_xy_ang.z), cos(inVs.i_yz_scale_xy_ang.z));
	float2 ay = float2(sin(inVs.i_yz_scale_xy_ang.w), cos(inVs.i_yz_scale_xy_ang.w));
	float2 az = float2(sin(inVs.i_z_ang_extra.x), cos(inVs.i_z_ang_extra.x));
	
	//Creates the transformation matrix.
	float4x4 matInstance = float4x4(
		float4(
			t_scale.x * ay.y * az.y - ax.x * ay.x * az.x,
			t_scale.y * -ax.y * az.x,
			t_scale.z * ay.x * az.y + ax.x * ay.y * az.x,
			0
		),
		float4(
			t_scale.x * ay.y * az.x + ax.x * ay.x * az.y,
			t_scale.y * ax.y * az.y,
			t_scale.z * ay.x * az.x - ax.x * ay.y * az.y,
			0
		),
		float4(
			t_scale.x * -ax.y * ay.x,
			t_scale.y * ax.x,
			t_scale.z * ax.y * ay.y,
			0
		),
		float4(inVs.i_xyz_pos_x_scale.xyz, 1)
	);

	outVs.diffuse = inVs.diffuse * inVs.i_color;
	outVs.texCoord = inVs.texCoord + float2(STEP_X * inVs.i_z_ang_extra.y, STEP_Y * inVs.i_z_ang_extra.z);
	outVs.position = mul(inVs.position, matInstance);
	outVs.position = mul(outVs.position, g_mWorldViewProj);
	outVs.position.z = 1.0f;

	return outVs;
}

float4 mainPS(PS_INPUT inPs) : COLOR0 {
	float4 color = tex2D(samp0_, inPs.texCoord) * inPs.diffuse;
	return color;
}

technique Render {
	pass P0 {
		VertexShader = compile vs_3_0 mainVS();
		PixelShader = compile ps_3_0 mainPS();
	}
}

