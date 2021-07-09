﻿Shader "Unlit/Chapter11-ScrollingBackground"
{
    Properties
    {
        // 第一层（较远）的背景纹理
		_MainTex ("Base Layer (RGB)", 2D) = "white" {}
        // 第二层（较近）的背景纹理
		_DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
        // 对应了上述纹理各自的水平滚动速度
		_ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
        // 用于控制纹理的整体亮度
		_Multiplier ("Layer Multiplier", Float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 计算了两层背景纹理的纹理坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 分别利用i.uv.xy和i.uv.zw对两张背景纹理进行采样
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				// 使用第二层纹理的透明通道来混合两张纹理
				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Multiplier;
				
				return c;
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}