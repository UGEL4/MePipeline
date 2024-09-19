// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MePipeline/Blinn-phong-1"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _NormalTex ("NormalTex", 2D) = "bump" {}
        _BumpScale ("BumpScale", Float) = 1
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

            sampler2D _MainTex;
            sampler2D _NormalTex;

            half _Glossiness;
            half _Metallic;
            fixed4 _Specular;
            float _BumpScale;

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
                float4 T2W0 : TEXCOORD1;
                float4 T2W1 : TEXCOORD2;
                float4 T2W2 : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //fixed3 worldNormal    = mul(v.normal, (float3x3)unity_WorldToObject);
                float3 worldPos      = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldNormal   = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent  = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                o.uv.xy = v.uv.xy;
                o.uv.zw = v.uv.xy;
                return o;
            }

            //Blinn-phong
            half4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
                half3 lightDir  = UnityWorldSpaceLightDir(worldPos);
                half3 viewDir   = UnityWorldSpaceViewDir(worldPos);

                half4 packedNormal = tex2D(_NormalTex, i.uv.zw);
                half3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                half3 albedo = tex2D(_MainTex, i.uv.xy);

                tangentNormal= normalize(half3(dot(i.T2W0.xyz, tangentNormal), dot(i.T2W1.xyz, tangentNormal), dot(i.T2W2.xyz, tangentNormal)));
                //half lambert
                half3 diffuse = _LightColor0.rgb * albedo * (0.5 * dot(tangentNormal, lightDir) + 0.5);

                half3 halfDir  = normalize(lightDir + viewDir);
                half3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Glossiness);

                return half4(ambient + diffuse + specular, 1.0);
            }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
