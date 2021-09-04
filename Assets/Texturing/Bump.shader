Shader "Unlit/Bump"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SpecTex ("Specular Texture", 2D) = "black" {}
        _Shininess ("Shininess", Float) = 20
        _NormalTex("Normal Texture", 2D) = "bump" {}
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
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform sampler2D _SpecTex;
            uniform float4 _SpecTex_ST;
            uniform half _Shininess;
            uniform sampler2D _NormalTex;
            uniform float4 _NormalTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 binormal : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                o.uv = v.uv;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.binormal = cross(o.normal, o.tangent) * v.tangent.w;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 normalTex = tex2D(_NormalTex, i.uv * _NormalTex_ST.xy + _NormalTex_ST.zw);

                #if defined(UNITY_NO_DXT5nm)
                    half3 tangentCoords = normalTex.rgb * 2.0 - 1.0;
                #else
                    half3 tangentCoords = float3(normalTex.ag * 2.0 - 1.0,0);
                    tangentCoords.z = sqrt(1.0 - dot(tangentCoords.xy, tangentCoords.xy));
                #endif
                half3 normal = normalize(mul(tangentCoords, float3x3(i.tangent,i.binormal,i.normal)));

                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                half3 halfDir = normalize(lightDir + viewDir);

                half NdotL = saturate(dot(normal, lightDir));
                half NdotH = saturate(dot(normal, halfDir));

                fixed4 mainTex = tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
                fixed3 diffuse = _LightColor0.rgb * mainTex.rgb * NdotL;

                fixed4 specTex = tex2D(_SpecTex, i.uv * _SpecTex_ST.xy + _SpecTex_ST.zw);
                fixed3 specular = _LightColor0.rgb * specTex.rgb * pow(NdotH, _Shininess) * specTex.a;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * mainTex.rgb;
                fixed4 color = fixed4(ambient + diffuse + specular, 1.0);
                return color;
            }
            ENDCG
        }
    }
}
