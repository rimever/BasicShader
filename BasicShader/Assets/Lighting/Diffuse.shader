Shader "Unlit/Diffuse"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _LightColor0;
            uniform fixed4 _DiffuseColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;             
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                half3 normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half NdotL = saturate(dot(normal, lightDir));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _DiffuseColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * NdotL;
                o.color = fixed4(ambient + diffuse, 1.0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
