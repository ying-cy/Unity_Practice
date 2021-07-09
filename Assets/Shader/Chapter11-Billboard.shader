Shader "Unlit/Chapter11-Billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}  // 广告牌显示的透明纹理
        _Color ("Color Tint", Color) = (1, 1, 1, 1)  // 用于控制显示整体颜色
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1  // 用于调整是固定法线还是固定指向上的方向，即约束垂直方向的程度
    }
    SubShader
    {
        // 为透明效果设置合适的标签
        // DisableBatching --- 取消对该Shader的批处理操作
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" "DisableBatching" = "True" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

// 目的：为了让广告牌的每个面都能显示
            // 关闭深度写入
            ZWrite Off
            // 开启并设置了混合模式
            Blend SrcAlpha OneMinusSrcAlpha
            // 关闭剔除功能
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;

            v2f vert (appdata v)
            {
                v2f o;

            // 选择模型空间的原点作为广告牌的锚点
                float3 center = float3(0, 0, 0);
            // 利用内置变量获取模型空间下的视角位置
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

            // 开始计算3个正交矢量
                float3 normalDir = viewer - center;  // 目标法线方向
                normalDir.y =normalDir.y * _VerticalBillboarding;  // 控制垂直方向上的约束度
				normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);  // 得到粗略的上方向（防止法线方向和向上方向平行）
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));

            // 根据原始位置相对于锚点的偏移量以及3个正交基矢量，计算得到新的顶点位置。
                float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.vertex = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture 对纹理进行采样，再与颜色值相乘即可
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
