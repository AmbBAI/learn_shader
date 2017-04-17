// https://zhuanlan.zhihu.com/p/26383778

Shader "Custom/TerrainBlend" {
	Properties {
		_Layer0 ("Layer 0 (RGBA)", 2D) = "white" {}
		_Layer0Normal ("Layer 0 Normal", 2D) = "bump" {}
		_Layer1 ("Layer 1 (RGBA)", 2D) = "white" {}
		_Layer1Normal ("Layer 1 Normal", 2D) = "bump" {}
		_Layer2 ("Layer 2 (RGBA)", 2D) = "white" {}
		_Layer2Normal ("Layer 2 Normal", 2D) = "bump" {}
		_SplatMap ("SplatMap (RGB)", 2D) = "white" {}
		_Weight("Blend Weight" , Range(0.001,1)) = 0.2
	}

	SubShader {
		Tags
		{
			"RenderType"="Opaque"
			"Queue"="Geometry"
		}

		CGPROGRAM
		#pragma surface surf BlinnPhong
		#pragma target 3.0

		struct Input
		{
			float2 uv_SplatMap : TEXCOORD0;
			float2 uv_Layer0 : TEXCOORD1;
		};

		sampler2D _SplatMap;
		sampler2D _Layer0, _Layer1, _Layer2;
		sampler2D _Layer0Normal, _Layer1Normal, _Layer2Normal;
		float _Weight;

		inline half3 Blend(half high1 ,half high2,half high3, half3 splat)
		{
			half3 blend ;

			blend.r = high1 * splat.r;
			blend.g = high2 * splat.g;
			blend.b = high3 * splat.b;

			half ma = max(blend.r, max(blend.g, blend.b));
			blend = max(blend - ma +_Weight , 0) * splat;
			return blend / (blend.r + blend.g + blend.b);
		}

		void surf (Input IN, inout SurfaceOutput o) {
			half3 splat = tex2D (_SplatMap, IN.uv_SplatMap).rgb;

			half4 d0 = tex2D (_Layer0, IN.uv_Layer0);
			half4 d1 = tex2D (_Layer1, IN.uv_Layer0);
			half4 d2 = tex2D (_Layer2, IN.uv_Layer0);

			half3 n0 = UnpackNormal(tex2D (_Layer0Normal, IN.uv_Layer0));
			half3 n1 = UnpackNormal(tex2D (_Layer1Normal, IN.uv_Layer0));
			half3 n2 = UnpackNormal(tex2D (_Layer2Normal, IN.uv_Layer0));

			half3 blend = Blend(d0.a, d1.a, d2.a, splat);
			o.Alpha = 0.0;
			o.Albedo = blend.r * d0 + blend.g * d1 + blend.b * d2;
			o.Normal = blend.r * n0 + blend.g * n1 + blend.b * n2;
		}
		ENDCG
	}
	FallBack "Legacy Shaders/Bumped Specular"
}