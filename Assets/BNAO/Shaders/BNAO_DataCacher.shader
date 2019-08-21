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
				#pragma multi_compile MODE_BN MODE_AO MODE_CONVERSION

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

					fixed4 tex = float4(0, 0, 1, 1);
					if (_HasNormalTex == 1.0)
						tex = tex2D(_NormalTex, i.texcoord);

					#if MODE_CONVERSION
						fixed3 normal;
						if (_ConversionMode == 0.0)
						{
							fixed3 tNormal = UnpackNormal(tex);
							normal = mul(i.tangentToWorld, float4(tNormal, 0)); // Input is tangent space
						}
						else
						{
							fixed3 tNormal = tex.xyz*2-1;
							normal = mul(unity_ObjectToWorld, float4(tNormal, 0)); // Input is object space
						}
					#else
						fixed3 tNormal = UnpackNormal(tex);
						fixed3 normal = mul(i.tangentToWorld, float4(tNormal, 0));
					#endif
					
					o.position 	= float4(i.worldPos, 1);
					o.normal 	= float4(normalize(normal), 1);

					return o;
				}
			ENDCG 
		}
	} 	
}