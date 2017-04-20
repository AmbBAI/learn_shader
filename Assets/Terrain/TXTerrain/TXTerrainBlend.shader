Shader "Custom/TXTerrainBlend" {
	Properties {
		_MainTex ("MainTex", 2D) = "black" {}
		[NoScaleOffset]_NormalTex ("NormalTex", 2D) = "bump" {}
		[NoScaleOffset]_ParamTex ("ParamTex", 2D) = "white" {}
		_MetallicScale ("Metallic Scale", Range(0, 1)) = 1
		_SmoothnessScale ("Smoothness Scale", Range(0, 1)) = 1
		_IndexMap ("IndexMap", 2D) = "black" {}
		[NoScaleOffset]_BlendMap ("BlendMap", 2D) = "black" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _ParamTex;
		sampler2D _BlendMap;
		sampler2D _IndexMap;
		half _SmoothnessScale;
		half _MetallicScale;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BlendMap;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half4 _BlockShrinkage = half4(0.0078125, 0.234375, 0.25, 0.0078125); // 4 x 4
			half2 index = tex2D(_IndexMap, IN.uv_BlendMap).xy;
			half blend = tex2D(_BlendMap, IN.uv_BlendMap).z;
			half2 a = floor(index * 16.0);
			half2 b = floor(index * 256.0) - a * 16.0;
			half4 c = half4(b.x, a.x, b.y, a.y) * _BlockShrinkage.z;

			half2 tc = _BlockShrinkage.y * frac(IN.uv_MainTex) + _BlockShrinkage.x;
			half2 tc_ddx = min(_BlockShrinkage.y * ddx(IN.uv_MainTex), _BlockShrinkage.w);
			half2 tc_ddy = min(_BlockShrinkage.y * ddy(IN.uv_MainTex), _BlockShrinkage.w);

			half2 uv0 = tc + c.xy;
			half2 uv1 = tc + c.zw;
			uv0.y = 1 - uv0.y;
			uv1.y = 1 - uv1.y;

			fixed3 color0 = tex2D(_MainTex, uv0, tc_ddx, tc_ddy);
			fixed3 color1 = tex2D(_MainTex, uv1, tc_ddx, tc_ddy);

			fixed3 normal0 = UnpackNormal(tex2D(_NormalTex, uv0, tc_ddx, tc_ddy));
			fixed3 normal1 = UnpackNormal(tex2D(_NormalTex, uv1, tc_ddx, tc_ddy));

			fixed3 param0 = tex2D(_ParamTex, uv0, tc_ddx, tc_ddy);
			fixed3 param1 = tex2D(_ParamTex, uv1, tc_ddx, tc_ddy);

			o.Albedo = lerp(color1, color0, blend);
			o.Normal = lerp(normal1, normal0, blend);
			o.Smoothness = lerp(param1.r, param0.r, blend) * _SmoothnessScale;
			o.Metallic = lerp(param1.g, param0.g, blend) * _MetallicScale;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
