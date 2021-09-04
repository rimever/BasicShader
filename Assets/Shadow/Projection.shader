Shader "Unlit/Projection"
{
    Properties
    {
        _Intensity("Intensity", Range(0,1)) = 0.5
    }
    SubShader
    {
        // 0: Shade
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normal = normalize(i.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                half NdotL = saturate(dot(normal, lightDir));
                
                return fixed4(NdotL, NdotL, NdotL, 1.0);
            }
            ENDCG
        }
        // 1: Shadow
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Cull Off
            Offset -1,-1
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil {
                Ref 1
                Comp NotEqual
                Pass Replace
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform half _Intensity;

            float4 vert(float4 vertex : POSITION) : SV_POSITION {
                float4 posWorld = mul(unity_ObjectToWorld, vertex);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                posWorld.xyz += -lightDir * (posWorld.y / lightDir.y);

                return mul(UNITY_MATRIX_VP, posWorld);
            }

            fixed4 frag() : SV_Target {
                return fixed4(0,0,0,_Intensity);
            }
            ENDCG
        }
    }
}
