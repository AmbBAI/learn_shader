Shader "Custom/Skybox/TXSkyboxProcedural"
{
	Properties
	{
		_RayleighMap ("RayleighMap", 2D) = "black" {}
		_MieMap ("MieMap", 2D) = "white" {}
		_PartialRayleighInScattering ("_PartialRayleighInScattering", Color) = (1, 1, 1, 0.1)
		_PartialMieInScattering ("_PartialMieInScattering", Color) = (0.15, 0.15, 0.15, 0.8)
		_NightSkyColBase ("_NightSkyColBase", Color) = (0, 0.7, 1, 1)
		_NightSkyColDelta("_NightSkyColDelta", Color) = (0.6, 0.75, 0.82, 0.4)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				float3 localVertex : TEXCOORD1;
			};

			sampler2D _RayleighMap;
			sampler2D _MieMap;
			fixed4 _PartialRayleighInScattering;
			fixed4 _PartialMieInScattering;
			fixed4 _NightSkyColBase;
			fixed4 _NightSkyColDelta;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.localVertex = v.vertex.xyz;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 rayleigh = tex2D (_RayleighMap, i.uv);
				rayleigh.xyz = rayleigh.xyz * (rayleigh.w * rayleigh.w * _PartialRayleighInScattering.w);
				fixed4 mie = tex2D (_MieMap, i.uv);
				mie.xyz = mie.xyz * (mie.w * mie.w * _PartialRayleighInScattering.w);

				fixed3 viewDir = normalize(i.localVertex);
				fixed cosT = dot (-_WorldSpaceLightPos0.xyz, viewDir);
				fixed cosT2A1 = cosT * cosT + 1.0;

				fixed4 color;
				color.xyz = (rayleigh.xyz * _PartialRayleighInScattering.xyz) * (cosT2A1 * 0.75); // g = 0; F = 3/4 *(1 + cos(t)^2)
				color.xyz += (mie.xyz * _PartialMieInScattering.xyz) * (cosT2A1 * pow (1.0 + cosT, -1.5)); //

				fixed tmpvar_9 = saturate (viewDir.y * _NightSkyColBase.w + _NightSkyColDelta.w);
				color.xyz += _NightSkyColBase.xyz + _NightSkyColDelta.xyz * (tmpvar_9 * (2.0 - tmpvar_9));
				color.xyz = 1.0 - exp(-_PartialMieInScattering.w * color.xyz);
				color.w = 1.0;
				return color;
			}
			ENDCG
		}
	}
}
