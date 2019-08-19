Shader "Hidden/BNAO_Composite"
{
	SubShader
	{
		Pass
		{
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
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
					o.texcoord 	= v.texcoord;

					return o;
				}

				sampler2D _MainTex;

				fixed4 frag (v2f i) : SV_Target
				{
					return tex2D(_MainTex, i.texcoord);
				}
			ENDCG 
		}
	} 	
}