Shader "Unlit/Shader1"
{
	Properties
	{
		// Input data
		// If you have properties in here so you must have variable in Shader code too
		_ColorA ("Color A", Color) = (1,1,1,1)
		_ColorB ("Color B", Color) = (1,1,1,1)
		_ColorStart ("Color Start", Range(0,1)) = 1
		_ColorEnd ("Color End", Range(0,1)) = 1
	}
		SubShader
	{
		// Subshader Tags
		Tags
		{
			// Define how this object should render
			"RenderType" = "Transparent" // Tag to inform the Render Pipeline of what type object is
			"RenderQueue" = "Transparent" // Change the render order
		}

		Pass
		{
			// Pass Tags
			
			Cull Off
			ZWrite Off
			ZTest LEqual 
			// LEqual is default: Render when not behind something
			// GEqual: Render when behind something
			// Always: Always Render
			Blend One One // Additive
			
			// Shader code HLSL
			CGPROGRAM // Unity originally used the CG language. Today, it is deprecated but keyword CG still there (cause of consistent and mess)
			#pragma vertex vert // Declare function name of vertex shader
			#pragma fragment frag // Declare function name of fragment shader

			// #include is take code from different file and pastes it into ur shader
			// UnityCG.cginc is just a library of build-in useful function things
			#include "UnityCG.cginc"

			// Constant thing
			#define TAU 6.28318530718

			// Variable 
			float4 _ColorA;
			float4 _ColorB;
			float _ColorStart;
			float _ColorEnd;
			
			// Default name is appdata but its dumb => meshData better
			// Automatically filled out by Unity
			// Define what input we want to take from the mesh
			struct MeshData
			{
				// per-vertex mesh data
				float4 vertex : POSITION; // vertex position - syntax mean POSITION data passed into vertex variable
				float3 normals : NORMAL; // local space normal direction
				float4 tangent : TANGENT; // Tangent direction (xyz) tangent sign (w)
				float4 color: COLOR; // RGBA | XYZW
				float2 uv0 : TEXCOORD0; // uv0 diffuse/normal map texture		
				float2 uv1 : TEXCOORD1; // uv1 coordinates lightmap coordinates
				float2 uv2 : TEXCOORD2; // uv2 coordinates lightmap coordinates
			};

			// Data passed from the vertex shader to the fragment shader
			// This will interpolate/blend across the triangle
			struct Interpolators
			{
				// data that get passed from vertex shader to fragment shader
				float4 vertex : SV_POSITION; // clip space position
				float3 normal : TEXCOORD0; // TEXCOORD0 is correspond to just one of the data stream that we pass from vertex shader to fragment shader
				float2 uv : TEXCOORD1; // // TEXCOORD1 is correspond to just one of the data stream that we pass from vertex shader to fragment shader
			};

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex); // Convert object local space to camera's clip space ( multiplying by mvp matrix )
				o.normal = UnityObjectToWorldNormal(v.normals); // Define what data was pass with stream TEXCOORD0 : Transforms normal from object to world space
				o.uv = v.uv0; // Pass through | Define what data was pass with stream TEXCOORD1
				return o;
			}


			float InverseLerp(float a, float b, float v){
				return (v-a)/(b-a);
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
				// float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x)) ; // saturate is something like Clamp
				// frac = v - floor(v)
				// t = frac(t);
				
				float xOffset = cos(i.uv.x * TAU * 8)*0.01;
				float t = sin((i.uv.y + xOffset - _Time.y*0.1) * TAU * 5)*0.5 + 0.5;
				t *= 1 - i.uv.y;
				float topBottomRemover = (abs(i.normal.y)<0.999);
				float waves = t * topBottomRemover;
				float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
				return gradient * waves;
				// Lerp blend between two color base on the x UV coor
				// float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);
				// SV_Target is output target to the frame buffer
			}
		ENDCG
	}
	}
}
