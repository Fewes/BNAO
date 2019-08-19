Shader "Hidden/BNAO_PostProcess"
{
	SubShader
	{
		Pass
		{
			Cull Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile MODE_BN MODE_AO

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex 	: SV_POSITION;
					float3 normal 	: NORMAL;
					float2 texcoord : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float3x3 worldToTangent : TEXCOORD3;
				};

				float _UVChannel;
				float _NormalsSpace;
				float4x4 _WorldToObject;

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
					o.texcoord 	= uv;//v.texcoord;
					o.worldPos 	= mul(unity_ObjectToWorld, v.vertex).xyz;
					o.normal	= UnityObjectToWorldNormal(v.normal);

					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

					o.worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

					return o;
				}

				sampler2D _MainTex;

				float _AOBias;

				float4 frag (v2f i) : SV_Target
				{
					float4 color = tex2D(_MainTex, i.texcoord);
					
					#if MODE_AO
						// color.rgb = pow(color.rgb, _AOBias);
						// color.rgb *= 2;
						// color.rgb = saturate((color.rgb - 0.5) * 2);
						color.rgb /= _AOBias;
					#elif MODE_BN
						
						// Normalize
						float3 bentNormal = normalize(color.rgb);
						
						if (_NormalsSpace == 0.0)
							bentNormal = mul(i.worldToTangent, float4(bentNormal, 0)).xyz; // Tangent space
						else if (_NormalsSpace == 1.0)
							bentNormal = mul(_WorldToObject, float4(bentNormal, 0)).xyz; // Object space

						// Pack
						bentNormal.xy = bentNormal.xy*0.5+0.5;
						color.rgb = bentNormal;
						
						// color.rgb = color.rgb*0.5+0.5;
					#endif
					
					return color;
				}
			ENDCG 
		}
	} 	
}