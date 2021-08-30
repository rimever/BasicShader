Shader "Unlit/Cook-Torrance"
{
    Properties
    {
        _Albedo("Albedo",Color) = (1,1,1,1)
        _Roughness("Roughness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #define PI 3.14159255359f

            uniform fixed4 _LightColor0;
            uniform fixed4 _Albedo;
            uniform half _Roughness;
            uniform half _Metallic;

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
                half3 halfDir = normalize(lightDir + viewDir);

                half NdotL = saturate(dot(normal, lightDir));
                half NdotV = saturate(dot(normal, viewDir));
                half NdotH = saturate(dot(normal, halfDir));
                half LdotH = saturate(dot(lightDir, halfDir));
                half NdotHSqr = NdotH * NdotH;

                half roughness = _Roughness * _Roughness;
                half roughnessSqr = roughness * roughness;

                half A = 1.0 - 0.5 * (roughnessSqr / (roughnessSqr + 0.33));
                half B = 0.45 * (roughnessSqr / (roughnessSqr + 0.09));
                half C = saturate(dot(normalize(viewDir - normal * NdotV), normalize(lightDir - normal * NdotL)));
                half angleL = acos(NdotL);
                half angleV = acos(NdotV);
                half alpha = max(angleL, angleV);
                half beta = min(angleL, angleV);
                fixed3 diffuse = _Albedo.rgb * (A + B * C * sin(alpha) * tan(beta)) * _LightColor0.rgb * NdotL;

                half D = roughnessSqr / (PI * pow(NdotHSqr * (roughnessSqr - 1.0) + 1.0, 2.0));
                half k = roughness * 0.5;
                half gl = NdotL / (NdotL * (1.0 - k) + k);
                half gv = NdotV / (NdotV * (1.0 - k) + k);
                half G = gl * gv;
                half F = _Metallic + (1.0 - _Metallic) * pow(1.0 - LdotH, 5.0);
                fixed specular = saturate((D * G * F) / (4.0 * NdotV)) * PI * _LightColor0.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Albedo.rgb;
                fixed4 color = fixed4(ambient + lerp(diffuse, specular, _Metallic),1.0);
                return color;
            }
            ENDCG
        }
    }
}
