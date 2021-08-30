Shader "Unlit/Phong"
{
    Properties
    {
        _DiffuseColor ( "Diffuse Color", Color) = (1,1,1,1)
        _SpecularColor ( "Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess Color", Float) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _LightColor0;
            uniform fixed4 _DiffuseColor;
            uniform fixed4 _SpecularColor;
            uniform half _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 posWorld : TEXCOORD0;
            };
          
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                half3 reflectDir = reflect(-lightDir, normal);

                half NdotL = saturate(dot(normal, lightDir));
                half RdotV = saturate(dot(reflectDir, viewDir));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _DiffuseColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * NdotL;
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(RdotV, _Shininess);

                fixed4 color = fixed4(ambient + diffuse + specular, 1.0);
                
                return color;
            }
            ENDCG
        }
    }
}
