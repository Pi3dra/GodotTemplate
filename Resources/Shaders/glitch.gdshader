shader_type canvas_item;

// Vibration strength
uniform float shake_power = 0.01;

// Chance that the glitch activates
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;

// Vibration speed
uniform float shake_speed = 5.0;

// Number of horizontal glitch blocks
uniform float shake_block_size = 30;

// RGB separation
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.01;


float random(float seed)
{
	return fract(
		543.2543 *
		sin(
			dot(
				vec2(seed, seed),
				vec2(3525.46, -54.3415)
			)
		)
	);
}


void fragment()
{
	float enable_shift = float(
		random(trunc(TIME * shake_speed)) < shake_rate
	);

	vec2 fixed_uv = UV;

	// Calculate which horizontal block we're in
	fixed_uv.x += (
		random(
			(trunc(UV.y * shake_block_size) / shake_block_size)
			+ TIME
		) - 0.5
	) * shake_power * enable_shift;


	// Sample the sprite itself
	vec4 pixel_color = texture(TEXTURE, fixed_uv);


	// RGB separation
	pixel_color.r = mix(
		pixel_color.r,
		texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0)).r,
		enable_shift
	);

	pixel_color.b = mix(
		pixel_color.b,
		texture(TEXTURE, fixed_uv - vec2(shake_color_rate, 0.0)).b,
		enable_shift
	);

	COLOR = pixel_color;
}