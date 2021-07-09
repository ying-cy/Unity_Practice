// 这个shader 的名字：Unlit/Chapter5-SimpleShader
Shader "Unlit/Chapter5-SimpleShader"
{
    // 需求：在材质面板显示一个颜色拾取器，从而可以直接控制模型在屏幕上显示的颜色
    Properties {
        // ① 声明color类型的属性
        // 名称为_Color，面板上的名字为Color Tint，类型是color，初始值是(1, 1, 1, 1)
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Pass {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            // ② 定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;
            
            // 使用结构体来定义顶点着色器的输入
            struct a2v {
                float4 vertex : POSITION;  // 模型空间的顶点坐标
                float3 normal : NORMAL;   // 模型空间的法线方向
                float4 texcoord : TEXCOORD0;  // 模型的第一套纹理坐标
            };

            // 使用一个结构体来定义顶点着色器的输出，片元着色器的输入
            // 涉及到两个着色器之间的通信过程，将模型的法线、纹理坐标等传递给片元。
            struct v2f {
                float4 pos : SV_POSITION;  // 顶点在裁剪空间中的位置信息
                fixed3 color : COLOR0;  // COLOR0可以用于存储颜色信息
            };
            
            // 顶点着色器：逐顶点执行
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
               return o;
            }
            
            // 片元着色器：逐片元调用
            fixed4 frag(v2f i) : SV_Target {
                // ③ 使用_Color属性来控制输出颜色
                fixed3 c = i.color;
                c *= _Color.rgb;

                return fixed4(c, 1.0);
            }
            
            ENDCG
        }
    }
}
