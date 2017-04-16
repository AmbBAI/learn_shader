Shader "Custom/Standard" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_ParamTex ("Smoothness, Metallic, AO", 2D) = "white" {}
		_SmoothnessScale ("Smoothness Scale", Range(0,1)) = 1.0
		_MetallicScale ("Metallic Scale", Range(0,1)) = 1.0
		_IndirectSpecularColor ("Indirect Specular Color", Color) = (0,0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM

		#pragma surface surf StandardOverride fullforwardshadows
		#pragma multi_compile _ UNITY_PBS_USE_BRDF2 UNITY_PBS_USE_BRDF3
		#pragma shader_feature DISABLE_ENV_IBL
		#pragma target 3.0

		#ifdef DISABLE_ENV_IBL
		half3 _IndirectSpecularColor;
		#endif
		#include "PBSLightingOverride.cginc"

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _ParamTex;
		fixed4 _Color;
		half _SmoothnessScale;
		half _MetallicScale;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D (_NormalTex, IN.uv_MainTex));
			fixed3 p = tex2D (_ParamTex, IN.uv_MainTex);
			o.Smoothness = _SmoothnessScale * p.r;
			o.Metallic = _MetallicScale * p.g;
			o.Occlusion = p.b;
			o.Alpha = c.a;
		}
		ENDCG
	}
	CustomEditor "StandardShaderGUI"
	FallBack "Diffuse"
}
