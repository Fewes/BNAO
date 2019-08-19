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

Shader "Hidden/BNAO_Dilate"
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
					float2 texcoord : TEXCOORD1;
				};

				v2f vert (appdata_full v)
				{
					v2f o;

					o.vertex 	= UnityObjectToClipPos(v.vertex);
					o.texcoord 	= v.texcoord;

					return o;
				}

				sampler2D _MainTex;
				float4 _MainTex_TexelSize;

				#define OFFSET_COUNT 8
				static const float2 offsets[OFFSET_COUNT] = {
					float2(-1,-1),
					float2( 0,-1),
					float2( 1,-1),
					float2(-1, 0),
					// float2( 0, 0),
					float2( 1, 0),
					float2(-1, 1),
					float2( 0, 1),
					float2( 1, 1)
				};

				float4 frag (v2f i) : SV_Target
				{
					float4 color = tex2D(_MainTex, i.texcoord);

					// Straight color
					#if MODE_BN
					if (color.a > 0.5 && dot(color.rgb, float3(1, 1, 1)) > 0.00001) // Also dilate black pixels (0 samples passed) to prevent artifacts
					#else
					if (color.a > 0.5)
					#endif
						return color;

					// Dilate
					float weight = 0;
					color = 0;
					for (int u = 0; u < OFFSET_COUNT; u++)
					{
						float2 uv = i.texcoord + _MainTex_TexelSize.xy * offsets[u];
						float4 tap = tex2D(_MainTex, uv);

						#if MODE_BN
						if (tap.a > 0.5 && dot(tap.rgb, float3(1, 1, 1)) > 0.00001)
						#else
						if (tap.a > 0.5)
						#endif
						{
							color += tap;
							weight += 1;
						}
					}

					if (weight > 0)
						return color / weight;
					else
						return 0;
				}
			ENDCG 
		}
	} 	
}