Shader "Hidden/BNAO_Depth_2Sided"
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
			Cull Off
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