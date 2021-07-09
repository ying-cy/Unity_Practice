using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    // 声明该效果需要的shader，并据此创建相应的材质
    public Shader edgeDetectShader; // 我们自己实现的shader
	private Material edgeDetectMaterial = null;
    public Material material {  
		get {
			edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
			return edgeDetectMaterial;
		}  
	}

// 用于调整边缘线强度
    [Range(0.0f, 1.0f)]
	public float edgesOnly = 0.0f;
// 描边颜色
	public Color edgeColor = Color.black;
// 背景颜色
	public Color backgroundColor = Color.white;

// 进行真正的特效处理
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_EdgeOnly", edgesOnly);
			material.SetColor("_EdgeColor", edgeColor);
			material.SetColor("_BackgroundColor", backgroundColor);

			Graphics.Blit(src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
