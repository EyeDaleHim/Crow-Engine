package shaders;

import flixel.system.FlxAssets.FlxShader;

class OverlayShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec4 uBlendColor;

		vec3 blendLighten(vec3 base, vec3 blend) {
			return mix(1.0 - 2.0 * (1.0 - base) * (1.0 - blend), 2.0 * base * blend, step(base, vec3(0.5)));
		}

		void main()
		{
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);
			vec3 blended = blendLighten(base, uBlendColor);
			gl_FragColor = vec4(blended.r, blended.g, blended.b, uBlendColor.a);
		}')
	public function new()
	{
		super();
	}
}
