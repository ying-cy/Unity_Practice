using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 此时应该继承后处理脚本的基类
public class BrightnessSaturationAndContrast : PostEffectsBase
{
    // 声明该效果需要的shader，并据此创建相应的材质
    public Shader briSatConShader; // 我们指定的shader，我们自己创建的shader
    private Material briSatConMaterial; // 创建的材质
    public Material material {
        get {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

// 在脚本中提供了调整亮度、饱和度和对比度的参数。
// Range属性为每个参数提供了合适的变化区间
    [Range(0.0f, 3.0f)]
	public float brightness = 1.0f;

	[Range(0.0f, 3.0f)]
	public float saturation = 1.0f;

	[Range(0.0f, 3.0f)]
	public float contrast = 1.0f;

    // 进行真正的特效处理
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null) {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(src, dest, material);
        } else {
            Graphics.Blit(src, dest);
        }
    }
}
