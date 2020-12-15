// Licensed under the MIT License. See LICENSE in the project root for license information.

Shader "Razeware/SonarTap"
{
	Properties
	{
		// Main knobs
		_Center ("Center", Vector) = (0, 0, 0, -1) // world space position
		_Radius ("Radius", Range(0, 10)) = 1 // grows the pulse

		// Pulse knobs
		_PulseColor ("Pulse Color", Color) = (0.5, .5, .5)
		_PulseWidth ("Pulse Width", Float) = 1

        // Discard pixels darker than this.
        _Cutoff ("Intensity Cutoff", Color) = (0.1, 0.1, 0.1)
	}
	
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Offset 50, 100

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			half _Radius;
			half3 _Center;
			half3 _PulseColor;
			half  _PulseWidth;
            half3 _Cutoff;

		    // http://www.iquilezles.org/www/articles/functions/functions.htm
			half cubicPulse(half c, half w, half x)
			{
				x = abs(x - c);
				if ( x > w )
					return 0;
				x /= w;
				return 1 - x * x * (3 - 2 * x);
			}

			struct v2f
			{
				half4 viewPos : SV_POSITION;
				half  pulse : COLOR;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				o.viewPos = UnityObjectToClipPos(v.vertex);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				half distToCenter = distance(_Center, worldPos.xyz);		
				half pulse = cubicPulse(_Radius, _PulseWidth, distToCenter);

				o.pulse = pulse;

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				half3 result = i.pulse * _PulseColor;
                // Don't fade to black, but instead discard pixels.
                if (result.x < _Cutoff.x && result.y < _Cutoff.y & result.z < _Cutoff.z) {
                    discard;
                }
				return half4(result, 1);
			}

			ENDCG
		}
	}
	
	FallBack "Diffuse"
}