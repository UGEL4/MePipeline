// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MePipeline/Blinn-phong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Glossiness ("Smoothness", Range(0,256)) = 16
    }
    SubShader
    {
        pass
        {
            CGPROGRAM
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag


            fixed4 _Diffuse;
            half _Glossiness;
            half _Metallic;
            fixed4 _Specular;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            //Blinn-phong
            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight  = normalize(_WorldSpaceLightPos0.xyz);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //half lambert
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 * dot(worldNormal, worldLight) + 0.5);

                float3 viewDir  = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 halfDir  = normalize(worldLight + viewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Glossiness);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
