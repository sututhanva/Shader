Shader "Unlit/Shader1"
{
	Properties
	{
		// Input data
		// If you have properties in here so you must have variable in Shader code too
		_MainTex ("Texture", 2D) = "white" {}
		_Value ("Value", Float) = 1.0;
	}
		SubShader
	{
		Tags
		{
			// Define how this object should render
			"RenderType" = "Opaque"
		}

		Pass
		{
			// Shader code HLSL
			CGPROGRAM // Unity originally used the CG language. Today, it is deprecated but keyword CG still there (cause of consistent and mess)
			#pragma vertex vert // Declare function name of vertex shader
			#pragma fragment frag // Declare function name of fragment shader

			// #include is take code from different file and pastes it into ur shader
			// UnityCG.cginc is just a library of build-in useful function things
			#include "UnityCG.cginc" 

			// Variable 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Value;
			
			// Default name is appdata but its dumb => meshData better
			// Automatically filled out by Unity
			struct MeshData
			{
				// per-vertex mesh data
				float4 vertex : POSITION; // vertex position - syntax mean POSITION data passed into vertex variable
				float3 normals : NORMAL; // three dimension => float3
				float4 tangent : TANGENT; // three dimension but has w component (sign/mirror) => float4
				float4 color: COLOR; // RGBA
				float2 uv0 : TEXCOORD0; // uv0 diffuse/normal map texture		
				float2 uv1 : TEXCOORD1; // uv1 coordinates lightmap coordinates
			};

			struct Interpolators
			{
				// data that get passed from vertex shader to fragment shader
				float2 uv : TEXCOORD0; // 
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION; // clip space position
			};

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex); // Convert local space to clip space ( multiplying by mvp matrix )
				return o;
			}

			// bool 0 1
			// int
			// float ( 32 bit float ) use float every where unless you really want optimize
			// half ( 16 bit float )
			// fixed ( lower precision ) -1 to 1
			// EX: float4 -> half4 -> fixed4
			// Matrix: float4x4 -> half4x4 -> fixed4x4

			float4 frag(Interpolators i) : SV_Target
			{
				// sample the texture
				float4 col = tex2D(_MainTex, i.uv);
			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);
			return float; // SV_Target is output target to the frame buffer
		}
		ENDCG
	}
	}
}
