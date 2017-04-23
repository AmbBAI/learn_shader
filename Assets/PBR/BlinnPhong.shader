Shader "Custom/BlinnPhong" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SpecColor ("SpecColor", Color) = (0.2, 0.2, 0.2, 0.2)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_ParamTex ("Gloss, Specular, AO", 2D) = "white" {}
		_GlossScale ("Gloss Scale", Range(0,2)) = 1.0
		_SpecularScale ("Specular Scale", Range(0.1,15)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf BlinnPhongOverride
		#pragma target 3.0

		#include "Lighting.cginc"
		inline fixed4 LightingBlinnPhongOverride (SurfaceOutput s, half3 viewDir, UnityGI gi)
		{
			half3 normal = normalize(s.Normal);

			half3 h = normalize (gi.light.dir + viewDir);

			fixed diff = max (0, dot (normal, gi.light.dir));

			float nh = max (0, dot (normal, h));
			float spec = pow (nh, s.Specular*128.0) * s.Gloss;

			fixed4 c;
			c.rgb = s.Albedo * gi.light.color * diff + gi.light.color * _SpecColor.rgb * spec;
			c.a = s.Alpha;

			#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
				c.rgb += s.Albedo * gi.indirect.diffuse;
			#endif

			return c;
		}

		inline void LightingBlinnPhongOverride_GI (
			SurfaceOutput s,
			UnityGIInput data,
			inout UnityGI gi)
		{
			gi = UnityGI_Base(data, 1.0, s.Normal);
		}

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _ParamTex;
		fixed4 _Color;
		half _GlossScale;
		half _SpecularScale;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D (_NormalTex, IN.uv_MainTex));
			fixed3 p = tex2D (_ParamTex, IN.uv_MainTex);
			o.Gloss = _GlossScale * p.r;
			o.Specular = _SpecularScale * p.g;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
