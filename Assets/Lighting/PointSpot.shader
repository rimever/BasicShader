Shader "Unlit/PointSpot"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGINCLUDE
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
            float3 normal : NORMAL;
            float4 posWorld : TEXCOORD0;
        };
        v2f vert(appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.normal = normalize(mul(v.normal, unity_WorldToObject).xyz);
            o.posWorld = mul(unity_ObjectToWorld, v.vertex);
            return o;
        }
        fixed4 frag(v2f i) : SV_Target {
            float3 toLight = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;
            half atten = lerp(1.0,1.0/dot(toLight,toLight), _WorldSpaceLightPos0.w);
            half3 normal = normalize(i.normal);
            half3 lightDir = normalize(toLight);

            half NdotL = saturate(dot(normal, lightDir));

            fixed3 ambient = lerp(UNITY_LIGHTMODEL_AMBIENT.rgb * _DiffuseColor.rgb, 0, _WorldSpaceLightPos0.w);
            fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * NdotL * atten;
            fixed4 color = fixed4(ambient + diffuse, 1.0);
            return color;
        }
        ENDCG
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
