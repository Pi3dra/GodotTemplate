
extends Interface

@export var csv_path: String = "res://Credits.txt"
@export var category_font_size: float = 30.0
@export var line_font_size: float = 20.0
@export var description_delimiter: String = " - "
@export var scroll_duration: float = 10.0
@export var scroll: bool = true

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var container: VBoxContainer = $ScrollContainer/Container

var content: Array[PackedStringArray] = []
var categories: Array[String] = []


func _ready() -> void:
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	load_file()
	create_labels()

	if scroll:
		# Let Godot finish calculating the layout.
		await get_tree().process_frame
		await get_tree().process_frame
		scroll_credits()


func scroll_credits() -> void:
	var scrollbar := scroll_container.get_v_scroll_bar()
	var max_scroll := int(maxf(0.0, scrollbar.max_value - scrollbar.page))

	if max_scroll <= 0:
		return

	scroll_container.scroll_vertical = 0

	var tween := create_tween()
	tween.tween_property(
		scroll_container,
		"scroll_vertical",
		max_scroll,
		scroll_duration
	)


func load_file() -> void:
	var file := FileAccess.open(csv_path, FileAccess.READ)

	if file == null:
		push_error("Could not open credits file: " + csv_path)
		return

	# Skip the CSV header.
	file.get_csv_line(",")

	while file.get_position() < file.get_length():
		var line: PackedStringArray = file.get_csv_line(",")

		if line.size() < 4:
			continue

		if not line[2] in categories:
			categories.append(line[2])

		content.append(line)

	file.close()


func create_labels() -> void:
	var category_map: Dictionary[String, Label] = {}

	for category in categories:
		var label := create_category_label(category)
		category_map[category] = label
		container.add_child(label)

	for line in content:
		var label := create_line_label(line[0], line[1], line[3])
		category_map[line[2]].add_sibling(label)


func create_category_label(text: String) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	label.add_theme_font_size_override("font_size", int(category_font_size))
	label.size_flags_horizontal = Control.SIZE_FILL
	return label


func create_line_label(
	name: String,
	link: String,
	description: String
) -> RichTextLabel:
	var label := RichTextLabel.new()

	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_FILL
	label.add_theme_font_size_override(
		"normal_font_size",
		int(line_font_size)
	)

	var final_text := name

	if link != "":
		final_text = "[url=" + link + "]" + name + "[/url]"

		label.meta_clicked.connect(func(meta: Variant) -> void:
			var url := str(meta)

			if url.begins_with("https://") or url.begins_with("http://"):
				OS.shell_open(url)
		)

	if description != "":
		final_text += description_delimiter + description

	label.text = final_text
	return label
