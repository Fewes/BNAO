// MIT License

// Copyright (c) 2019 Felix Westin

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
				#pragma multi_compile MODE_BN MODE_AO MODE_CONVERSION

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
				float _ConversionMode;

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
				sampler2D _NormalCache;

				float _AOBias;

				float4 frag (v2f i) : SV_Target
				{
					float4 color = tex2D(_MainTex, i.texcoord);
					
					#if MODE_AO
						color.rgb /= _AOBias;
					#elif MODE_BN
						// Normalize
						float3 bentNormal = normalize(color.rgb);
						
						if (_NormalsSpace == 0.0)
							bentNormal = mul(i.worldToTangent, float4(bentNormal, 0)).xyz; // To tangent space
						else
							bentNormal = mul(unity_WorldToObject, float4(bentNormal, 0)).xyz; // To object space

						// Pack
						bentNormal.xy = bentNormal.xy*0.5+0.5;
						color.rgb = bentNormal;
					#elif MODE_CONVERSION
						float3 worldNormal = tex2D(_NormalCache, i.texcoord);
						float3 outNormal;
						if (_ConversionMode == 0.0)
						{
							outNormal = mul(unity_WorldToObject, float4(worldNormal, 0)).xyz; // To object space
							outNormal.xyz = outNormal.xyz*0.5+0.5;
						}
						else
						{
							outNormal = mul(i.worldToTangent, float4(worldNormal, 0)).xyz; // To tangent space
							outNormal.xy = outNormal.xy*0.5+0.5;
						}
						
						color = float4(outNormal, 1);
					#endif
					
					return color;
				}
			ENDCG 
		}
	} 	
}