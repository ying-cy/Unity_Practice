using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 希望在编辑器状态下也可以执行该脚本来查看效果
[ExecuteInEditMode]
// 所有屏幕后处理效果都需要绑定在某个摄像机上
[RequireComponent (typeof(Camera))]

public class PostEffectsBase : MonoBehaviour
{
    // 提前检查各种资源和条件是否满足
    protected void CheckResources() {
        bool isSupported = CheckSupport();
        if (isSupported == false) {
            NotSupported();
        }
    }

    protected bool CheckSupport() {
		if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false) {
			Debug.LogWarning("This platform does not support image effects or render textures.");
			return false;
		}
		
		return true;
	}

    protected void NotSupported() {
		enabled = false;
	}


    // Start is called before the first frame update
    protected void Start()
    {
        CheckResources();
    }
    
    // Update is called once per frame
    protected void Update()
    {
        
    }

    // 由于每个屏幕后处理效果通常都需要指定一个Shader来创建一个用于处理渲染纹理的材质，因此基类也提供了这样的方法。。
    // shader --- 指定了该特效需要使用的Shader
    // material --- 用于后期处理的材质
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material) {
		if (shader == null) {
			return null;
		}
		
		if (shader.isSupported && material && material.shader == shader)
			return material;
		
		if (!shader.isSupported) {
			return null;
		}
		else {
			material = new Material(shader);
			material.hideFlags = HideFlags.DontSave;
			if (material)
				return material;
			else 
				return null;
		}
	}
}
