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

Shader "Hidden/BNAO_Depth"
{
	Properties
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			Cull [_Cull]
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex 	: SV_POSITION;
					float2 texcoord : TEXCOORD1;
				};

				v2f vert (appdata_full v)
				{
					v2f o;
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.vertex 	= UnityObjectToClipPos(v.vertex);

					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					return float4(0, 0, 0, 1);
				}
			ENDCG 
		}
	}
	Fallback "Diffuse"

	SubShader
	{
		Tags { "RenderType"="TransparentCutout" }
		Pass
		{
			Cull [_Cull]
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex 	: SV_POSITION;
					float2 texcoord : TEXCOORD1;
				};

				sampler2D 	_MainTex;
				float4 		_MainTex_ST;
				float 		_Cutoff;

				v2f vert (appdata_full v)
				{
					v2f o;
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.vertex 	= UnityObjectToClipPos(v.vertex);
					o.texcoord	= TRANSFORM_TEX(v.texcoord,_MainTex);

					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					float alpha = tex2D(_MainTex, i.texcoord).a;
					clip(alpha - _Cutoff);
					return float4(0, 0, 0, 1);
				}
			ENDCG 
		}
	}
	FallBack "Legacy Shaders/Transparent/Cutout/Diffuse"
}