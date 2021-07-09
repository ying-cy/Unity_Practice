Shader "Unlit/Chapter12-BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", Float) = 1
        _Saturation ("Saturation", Float) = 1
        _Contrast ("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always 
            Cull Off 
            // 关闭深度写入，防止它“挡住”在其后面被渲染的物体。
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Brightness;
			half _Saturation;
			half _Contrast;

// 定义vs。屏幕特效使用的顶点着色器代码通常都比较简单：
// 1、进行必要的顶点坐标变换
// 2、将正确的纹理坐标传给片元着色器，然后对屏幕图像进行正确的采样。
// appdata_img -- unity内置的结构体作为输入
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture 
                // 对原屏幕图像（存储在_MainTex中）进行采样，将结果存储在renderTex中
                fixed4 renderTex = tex2D(_MainTex, i.uv);

                // Apply brightness
                // 用_Brightness属性来调整亮度
				fixed3 finalColor = renderTex.rgb * _Brightness;
				
				// Apply saturation 计算该像素对应的亮度值
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);
				
				// Apply contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
