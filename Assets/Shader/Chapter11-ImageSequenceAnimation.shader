Shader "Unlit/Chapter11-ImageSequenceAnimation"
{
    Properties
    {
    // 声明相关属性，以设置该序列帧动画的参数
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}            //包含所有关键帧图像的纹理
        _HorizontalAmount ("Horiaontal Amount", Float) = 4   //该图像在水平方向上包含的关键帧图像的个数
        _VerticalAmount("Vertical Amount", Float) = 4          //在竖直方向上包含的关键帧图像的个数
        _Speed ("Speed", Range(1, 100)) = 30                    //用于控制序列帧动画的播放速度
    }
    SubShader
    {
        // 序列帧图像通常是透明纹理
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // vs的输入参数
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            // fs的输入参数
            struct v2f
            {
                float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;

            // vs
            v2f vert (appdata v)
            {
                v2f o;
                // 进行基本的顶点变换
                o.pos = UnityObjectToClipPos(v.vertex);
                // 将顶点的纹理坐标存储到v2f结构体中
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // fs
            fixed4 frag (v2f i) : SV_Target
            {
                // _Time.y表示的是该场景加载后所经过的时间。
                // floor函数对结果值取整数来得到整数时间time
                float time = floor(_Time.y * _Speed);
                // 计算当前对应的行索引
                float row = floor(time / _HorizontalAmount);
                // 计算当前对用的列索引
				float column = time - row * _HorizontalAmount;

            //  half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
			// 	uv.x += column / _HorizontalAmount;
			// 	uv.y -= row / _VerticalAmount;
				half2 uv = i.uv + half2(column, -row);
				uv.x /=  _HorizontalAmount;
				uv.y /= _VerticalAmount;
				
				fixed4 c = tex2D(_MainTex, uv);
				c.rgb *= _Color;
				
				return c;
                
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
