Shader "Unlit/Chapter6-DiffuseVertexLevel"
{
    Properties
    {
    // 材质的漫反射颜色
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            // 指明该pass 的光照模式。只有定义了正确的LightMode才可以得到一些unity内置光照变量
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            // 为了使用unity的一些内置变量
            #include "Lighting.cginc"

            // 为了在shader中使用Properties语义块中声明的属性
            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            // 定义的是一个逐顶点的漫反射光照，漫反射部分的计算都在vs中进行。            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //获得ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 改变顶点法线的空间位置
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // 世界空间中的光源方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 计算diffuse项
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                o.color = ambient + diffuse;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
              // 输出顶点中的颜色即可
               return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
