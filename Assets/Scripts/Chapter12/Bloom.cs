using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectsBase {
    public Shader bloomShader;
	private Material bloomMaterial = null;
	public Material material {  
		get {
			bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
			return bloomMaterial;
		}  
	}

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

// 控制提取较亮区域时使用的阈值大小。
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;

    void OnRenderImage (RenderTexture src, RenderTexture dest) {
        if (material != null) {
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

			int rtW = src.width/downSample;
			int rtH = src.height/downSample;
			
			RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer0.filterMode = FilterMode.Bilinear;

            // 使用shader中的第一个pass提取图像中的较亮区域，提取得到的较亮区域将存储在buffer0中。
            Graphics.Blit(src, buffer0, material, 0);

            // 进行和之前一样的高斯模糊处理。这些pass对应了shader的第二个和第三个pass
            for(int i = 0 ; i < iterations ; i++){
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
				
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				// Render the vertical pass
				Graphics.Blit(buffer0, buffer1, material, 1);
				
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				// Render the horizontal pass
				Graphics.Blit(buffer0, buffer1, material, 2);
				
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
            }

            // 模糊后的较亮区域会存储在buffer0中，将buffer0传递给材质中的_Bloom纹理属性
            material.SetTexture("_Bloom", buffer0);
            // 使用shader中的第四个pass来进行最后的混合，将结果存储在目标渲染纹理中
            Graphics.Blit(src, dest, material, 3);

            // 释放临时缓存
            RenderTexture.ReleaseTemporary(buffer0);
        }else{
            Graphics.Blit(src, dest);
        }
    }

}
