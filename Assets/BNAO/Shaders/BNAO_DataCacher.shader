Shader "Hidden/BNAO_DataCacher"
{
	Properties
	{
		[Normal] _NormalTex ("Normal Map", 2D) = "bump" {}
	}
	SubShader
	{
		Pass
		{
			Cull Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex 	: SV_POSITION;
					float3 normal 	: NORMAL;
					float2 texcoord : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float3x3 tangentToWorld : TEXCOORD3;
				};

				float _UVChannel;
				float _HasNormalTex;

				v2f vert (appdata_full v)
				{
					v2f o;

					float2 uv = v.texcoord.xy;
					if (_UVChannel == 1.0)
						uv = v.texcoord1.xy;
					else if (_UVChannel == 2.0)
						uv = v.texcoord2.xy;
					else if (_UVChannel == 3.0)
						uv = v.texcoord3.xy;

					o.vertex 	= float4((uv * 2 - 1) * float2(1, -1), 0.5, 1);
					o.texcoord 	= v.texcoord;
					o.worldPos 	= mul(unity_ObjectToWorld, v.vertex).xyz;
					o.normal	= UnityObjectToWorldNormal(v.normal);

					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

					o.tangentToWorld = transpose(float3x3(worldTangent, worldBinormal, worldNormal));

					return o;
				}

				struct FragmentOutput
				{
					float4 position : SV_Target0;
					float4 normal 	: SV_Target1;
				};

				sampler2D _NormalTex;

				FragmentOutput frag (v2f i) : SV_Target
				{
					FragmentOutput o;

					fixed3 tNormal = float3(0, 0, 1);
					if (_HasNormalTex == 1.0)
						tNormal = UnpackNormal(tex2D(_NormalTex, i.texcoord));

					fixed3 normal = mul(i.tangentToWorld, float4(tNormal, 0));

					// normal = i.normal;
					
					o.position 	= float4(i.worldPos, 1);
					o.normal 	= float4(normalize(normal), 1);

					return o;
				}
			ENDCG 
		}
	} 	
}