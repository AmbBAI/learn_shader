Shader "Custom/ShowWorldNormal" {
	Properties {
		_NormalTex ("Normal", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf ShowWorldNormal fullforwardshadows
		#pragma target 3.0

		#include "Lighting.cginc"
		#include "UnityPBSLighting.cginc"
		inline half4 LightingShowWorldNormal (SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			return half4(s.Normal * 0.5 + 0.5, 1);
		}

		inline void LightingShowWorldNormal_GI ( SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
		}

		sampler2D _NormalTex;

		struct Input {
			float2 uv_NormalTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Normal = UnpackNormal(tex2D (_NormalTex, IN.uv_NormalTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
