using System;
using UnityEngine;
using UnityEditor;

public class StandardShaderGUI : ShaderGUI
{
    public enum BRDFMode
    {
        USE_BRDF1,
        USE_BRDF2,
        USE_BRDF3,
    }
    BRDFMode brdf = BRDFMode.USE_BRDF1;
    bool enableEnvIBL = true;

    public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] props)
    {
        Material material = materialEditor.target as Material;
        SetupBRDF(material);
        SetupEnvIBL(material);
        base.OnGUI(materialEditor, props);
    }

    void SetupBRDF(Material material)
    {
        if (material.IsKeywordEnabled("UNITY_PBS_USE_BRDF3"))
        {
            brdf = BRDFMode.USE_BRDF3;
        }
        else if (material.IsKeywordEnabled("UNITY_PBS_USE_BRDF2"))
        {
            brdf = BRDFMode.USE_BRDF2;
        }

        brdf = (BRDFMode)EditorGUILayout.EnumPopup(brdf);
        switch (brdf)
        {
            case BRDFMode.USE_BRDF1:
                material.EnableKeyword("UNITY_PBS_USE_BRDF1");
                material.DisableKeyword("UNITY_PBS_USE_BRDF2");
                material.DisableKeyword("UNITY_PBS_USE_BRDF3");
                break;
            case BRDFMode.USE_BRDF2:
                material.EnableKeyword("UNITY_PBS_USE_BRDF2");
                material.DisableKeyword("UNITY_PBS_USE_BRDF1");
                material.DisableKeyword("UNITY_PBS_USE_BRDF3");
                break;
            case BRDFMode.USE_BRDF3:
                material.EnableKeyword("UNITY_PBS_USE_BRDF3");
                material.DisableKeyword("UNITY_PBS_USE_BRDF1");
                material.DisableKeyword("UNITY_PBS_USE_BRDF2");
                break;
        }
    }

    void SetupEnvIBL(Material material)
    {
        enableEnvIBL = !material.IsKeywordEnabled("DISABLE_ENV_IBL");
        enableEnvIBL = EditorGUILayout.Toggle(enableEnvIBL);
        if (!enableEnvIBL)
        {
            material.EnableKeyword("DISABLE_ENV_IBL");
        }
        else
        {
            material.DisableKeyword("DISABLE_ENV_IBL");
        }
    }

}