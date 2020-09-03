Shader "FireShader"
{
    Properties
    {
      [HDR]_Color1 ("Color", Color) = (1.877862, 1.312719, 0.8316242, 0)
      _FireTexture ("FireTexture", 2D) = "white" {}          
      _Distortion("Distortion", Range(0,1)) = 0.5
         
       _NoiseTexture ( "Noise Texture" , 2D )="white"{}
       _NoiseSpeed ( "Noise Speed" , Range(0,1)) = 0.5
       _NoiseScale ( "Noise Scale" , Range(0,2)) = 1
       _NoiseWidth ( "Noise Width" , Range(0,2)) = 1
       _NoiseHeight ( "Noise Height" , Range(0,2)) = 1
        
       _DissolveTexture ( "Dissolve Texture ", 2D)="white"{}
       _DissolveSpeed ( "Dissolve Speed ", Range(0,1)) = 0.5
       _DissolveScale ( "Disolve Scale ", Range(0,2)) = 1
       _DissolveWidth ( "Dissolve Width" , Range(0,2)) = 1
       _DissolveHeight ( "Dissolve Height" , Range(0,2)) = 1
    }
    
    SubShader
    {   
      Tags { "Queue" = "Transparent" }
      Blend SrcAlpha OneMinusSrcAlpha
      
        Pass
        {       
            Cull Back
            ZTest LEqual
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
        
            struct inputData
               {
                float4 position: POSITION;
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
              };      
        
            struct outData
               {
                float4 position: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
             };
        
        
            outData vert (inputData IN)
            {
                inputData OUT;
                OUT.uv = IN.uv;
                OUT.position = UnityObjectToClipPos(IN.position);
                OUT.worldPos = mul(unity_ObjectToWorld, IN.position).xyw;
                return OUT;
            }
        
            float4 _Color1;
                   
            float _NoiseSpeed;
            float _NoiseScale;
            float _NoiseHeight;
            float _NoiseWidth;
                      
            float _DissolveSpeed;
            float _DissolveScale;
            float _DissolveHeight;
            float _DissolveWidth;
            
            float _Distortion;
                
            sampler2D _NoiseTexture;
            sampler2D _DissolveTexture;
            sampler2D _FireTexture;
        
            float4 frag(outData IN): SV_Target
            {      
                float2 uv = IN.uv;
                float2 worldPos = IN.worldPos.xy / IN.worldPos.z;
                             
                float2 noisePadding = _NoiseScale * float2(worldPos.x*_NoiseWidth, uv.y*_NoiseHeight);
                float noise = tex2Dlod(_NoiseTexture, float4(noisePadding.x, noisePadding.y-_Time.y*_NoiseSpeed, 0, 0));
          
                float2 dissolvePadding = _DissolveScale * float2(worldPos.x*_DissolveWidth, uv.y*_DissolveHeight);
                float4 dissolve = tex2Dlod(_DissolveTexture, float4(dissolvePadding.x, dissolvePadding.y -_Time.y * _DissolveSpeed, 0, 0));
          
                uv = lerp(uv, noise, _Distortion);
                float4 col = tex2D(_FireTexture, uv);
                float4 newColor = col * noise * dissolve * _Color1 * (1 - uv.y);
                                          
                return newColor;
            }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
