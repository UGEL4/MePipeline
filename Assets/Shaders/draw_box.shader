Shader "MePipeline/draw_box"
{
    Properties
    {
        //_Color ("Color", Color) = (0,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        pass
        {
            Tags{"LightMode" = "ForwardBase"}
        CGPROGRAM
        #include "Lighting.cginc"
        #include "UnityCG.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma vertex vert
        #pragma fragment frag

        // Use shader model 3.0 target, to get nicer looking lighting
        //#pragma target 3.0

        //fixed4 _Color;
        sampler2D _MainTex;
        sampler2D sampler_NormalTex;

        half _Glossiness;
        half _Metallic;

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
            float3 lightDir : TEXCOORD1;
            float3 viewDir : TEXCOORD2;
        };

        v2f vert(appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.uv.xy;
            o.uv.zw = v.uv.xy;

            //副切线
            float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
            float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

            o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
            o.viewDir  = mul(rotation, ObjSpaceViewDir(v.vertex));

            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            float3 tangentLightDir = normalize(i.lightDir);
            float3 tangentViewDir  = normalize(i.viewDir);

            float4 packedNormal = tex2D(sampler_NormalTex, i.uv.zw);
            float3 tangentNormal = UnpackNormal(packedNormal);
            tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

            float3 albedo = tex2D(_MainTex, i.uv).rgb;
            float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
            float3 diffuse = float3(1, 1, 1) * albedo * max(0, dot(tangentNormal, tangentLightDir));
            //float halfDir = normalize(tangentViewDir + tangentLightDir);

            return fixed4(ambient + diffuse, 1.0);
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
