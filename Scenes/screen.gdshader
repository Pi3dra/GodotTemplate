shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float brightness : hint_range(0.0, 2.0) = 1.;
uniform float contrast : hint_range(0.0, 2.0) = 1.;
uniform float saturation : hint_range(0.0, 2.0) = 1.;

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);

    // --------------------
    // Brightness
    // --------------------
    color.rgb *= brightness;


    // --------------------
    // Contrast
    // --------------------
    // Move around midpoint (0.5)
    color.rgb = (color.rgb - 0.5) * contrast + 0.5;


    // --------------------
    // Saturation
    // --------------------
    float gray = dot(
        color.rgb,
        vec3(0.299, 0.587, 0.114)
    );

    color.rgb = mix(
        vec3(gray),
        color.rgb,
        saturation
    );


    COLOR = color;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
