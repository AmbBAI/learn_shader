Shader "Custom/ShowIndirectSpecular" {
	Properties {
		_ParamTex ("Smoothness, Metallic, AO", 2D) = "white" {}
		_SmoothnessScale ("Smoothness Scale", Range(0,1)) = 1.0
		_MetallicScale ("Metallic Scale", Range(0,1)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf ShowIndirectSpecular fullforwardshadows
		#pragma target 3.0

		#include "Lighting.cginc"
		#include "UnityPBSLighting.cginc"
		inline half4 LightingShowIndirectSpecular (SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			return half4(gi.indirect.specular, 1);
		}

		inline void LightingShowIndirectSpecular_GI ( SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
			gi.indirect.specular = UnityGI_IndirectSpecular(data, s.Occlusion, g);
		}

		sampler2D _ParamTex;
		half _SmoothnessScale;
		half _MetallicScale;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = 0;
			fixed3 p = tex2D (_ParamTex, IN.uv_MainTex);
			o.Smoothness = _SmoothnessScale * p.r;
			o.Metallic = _MetallicScale * p.g;
			o.Occlusion = p.b;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
