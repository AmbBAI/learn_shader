Shader "Custom/Standard" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_ParamTex ("Smoothness, Metallic, AO", 2D) = "white" {}
		_SmoothnessScale ("Smoothness Scale", Range(0,1)) = 1.0
		_MetallicScale ("Metallic Scale", Range(0,1)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardOverride
		#pragma target 3.0

		#include "UnityPBSLighting.cginc"
		inline half4 LightingStandardOverride (SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			s.Normal = normalize(s.Normal);

			half oneMinusReflectivity;
			half3 specColor;
			s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

			// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
			// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
			half outputAlpha;
			s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

			half4 c = BRDF2_Unity_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
			c.a = outputAlpha;
			return c;
		}

		inline void LightingStandardOverride_GI (
			SurfaceOutputStandard s,
			UnityGIInput data,
			inout UnityGI gi)
		{
			gi = UnityGI_Base(data, s.Occlusion, s.Normal);
			Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
			gi.indirect.specular = unity_IndirectSpecColor.rgb * s.Occlusion;
		}

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
		}
		ENDCG
	}
	FallBack "Diffuse"
}
