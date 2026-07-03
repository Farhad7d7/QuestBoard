extends Control

const Localization = preload("res://scripts/localization/localization.gd")

var localization := Localization.new()
var active_story := {}

var story_templates := [
	{
		"id": "starting_over",
		"title_key": "template.starting_over.title",
		"description_key": "template.starting_over.description",
		"suggested_path_keys": [
			"path.health_fitness",
			"path.learning",
			"path.income",
			"path.family",
			"path.creation",
			"path.rest"
		]
	},
	{
		"id": "build_my_first_product",
		"title_key": "template.build_my_first_product.title",
		"description_key": "template.build_my_first_product.description",
		"suggested_path_keys": [
			"path.product",
			"path.learning",
			"path.marketing",
			"path.income",
			"path.health_fitness",
			"path.rest"
		]
	},
	{
		"id": "health_reset",
		"title_key": "template.health_reset.title",
		"description_key": "template.health_reset.description",
		"suggested_path_keys": [
			"path.health_fitness",
			"path.nutrition",
			"path.sleep",
			"path.mindset",
			"path.rest"
		]
	},
	{
		"id": "learning_sprint",
		"title_key": "template.learning_sprint.title",
		"description_key": "template.learning_sprint.description",
		"suggested_path_keys": [
			"path.study",
			"path.practice",
			"path.projects",
			"path.review",
			"path.rest"
		]
	},
	{
		"id": "career_comeback",
		"title_key": "template.career_comeback.title",
		"description_key": "template.career_comeback.description",
		"suggested_path_keys": [
			"path.resume",
			"path.applications",
			"path.interview_practice",
			"path.learning",
			"path.income",
			"path.health_fitness"
		]
	}
]

@onready var screen_container: CenterContainer = $ScreenContainer
@onready var content_box: VBoxContainer = $ScreenContainer/ContentBox


func _ready() -> void:
	show_home()


func tr_text(key: String) -> String:
	return localization.text(key)


func clear_screen() -> void:
	for child in content_box.get_children():
		child.queue_free()


func apply_language_direction() -> void:
	if localization.is_rtl():
		content_box.layout_direction = Control.LAYOUT_DIRECTION_RTL
	else:
		content_box.layout_direction = Control.LAYOUT_DIRECTION_LTR


func add_label(label_name: String, label_text: String, font_size: int = 18) -> Label:
	var label := Label.new()
	label.name = label_name
	label.text = label_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	content_box.add_child(label)
	return label


func add_button(button_name: String, button_text: String, pressed_action: Callable) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = button_text
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size = Vector2(340, 44)
	button.pressed.connect(pressed_action)
	content_box.add_child(button)
	return button


func localized_story_title() -> String:
	if active_story.has("title_key"):
		return tr_text(active_story["title_key"])

	return active_story.get("title", "")


func localized_story_description() -> String:
	if active_story.has("description_key"):
		return tr_text(active_story["description_key"])

	return active_story.get("description", "")


func localized_path_name(path_data: Dictionary) -> String:
	if path_data.has("name_key"):
		return tr_text(path_data["name_key"])

	return path_data.get("name", "")


func has_path_name(path_name: String) -> bool:
	var clean_name := path_name.strip_edges().to_lower()
	for path_data in active_story.get("paths", []):
		if localized_path_name(path_data).strip_edges().to_lower() == clean_name:
			return true

	return false


func has_path_key(path_key: String) -> bool:
	for path_data in active_story.get("paths", []):
		if path_data.get("name_key", "") == path_key:
			return true

	return false


func add_custom_path(path_name: String, icon_text: String) -> bool:
	var clean_name := path_name.strip_edges()
	if clean_name.is_empty() or has_path_name(clean_name):
		return false

	active_story["paths"].append({
		"name": clean_name,
		"icon": icon_text.strip_edges()
	})
	return true


func add_suggested_path(path_key: String) -> bool:
	if has_path_key(path_key) or has_path_name(tr_text(path_key)):
		return false

	active_story["paths"].append({
		"name_key": path_key,
		"icon": ""
	})
	return true


func add_suggested_path_and_show_dashboard(path_key: String) -> void:
	add_suggested_path(path_key)
	show_story_dashboard()


func add_suggested_path_from_form(path_key: String, message_label: Label) -> void:
	if not add_suggested_path(path_key):
		message_label.text = tr_text("error.duplicate_path")
		return

	show_story_dashboard()


func show_home() -> void:
	clear_screen()
	apply_language_direction()

	add_label("TitleLabel", tr_text("app.title"), 32)

	if active_story.is_empty():
		add_label("EmptyStateLabel", tr_text("home.empty_message"), 16)
		add_button("CreateCustomStoryButton", tr_text("home.create_custom_story"), show_custom_story_form)
		add_button("StartFromTemplateButton", tr_text("home.start_from_template"), show_template_selection)
		add_button("SettingsButton", tr_text("home.settings"), show_settings)
	else:
		show_story_dashboard()


func show_custom_story_form() -> void:
	clear_screen()
	apply_language_direction()

	add_label("FormTitleLabel", tr_text("home.create_custom_story"), 28)

	var title_input := LineEdit.new()
	title_input.name = "StoryTitleInput"
	title_input.placeholder_text = tr_text("story.title_placeholder")
	title_input.custom_minimum_size = Vector2(360, 44)
	content_box.add_child(title_input)

	var description_input := TextEdit.new()
	description_input.name = "StoryDescriptionInput"
	description_input.placeholder_text = tr_text("story.description_placeholder")
	description_input.custom_minimum_size = Vector2(360, 110)
	content_box.add_child(description_input)

	var message_label := add_label("FormMessageLabel", "", 14)

	add_button(
		"CreateStoryButton",
		tr_text("story.create"),
		func() -> void:
			var title := title_input.text.strip_edges()
			if title.is_empty():
				message_label.text = tr_text("error.empty_story_title")
				return

			active_story = {
				"title": title,
				"description": description_input.text.strip_edges(),
				"suggested_path_keys": [],
				"paths": []
			}
			show_story_dashboard()
	)

	add_button("CancelButton", tr_text("common.cancel"), show_home)


func show_template_selection() -> void:
	clear_screen()
	apply_language_direction()

	add_label("TemplateTitleLabel", tr_text("template.choose"), 28)

	for story_template in story_templates:
		var template_button_text := "%s\n%s" % [
			tr_text(story_template["title_key"]),
			tr_text(story_template["description_key"])
		]
		add_button(
			"TemplateButton_%s" % story_template["id"],
			template_button_text,
			create_story_from_template.bind(story_template)
		)

	add_button("CancelButton", tr_text("common.cancel"), show_home)


func create_story_from_template(template_data: Dictionary) -> void:
	active_story = {
		"template_id": template_data["id"],
		"title_key": template_data["title_key"],
		"description_key": template_data["description_key"],
		"suggested_path_keys": template_data["suggested_path_keys"].duplicate(),
		"paths": []
	}
	show_story_dashboard()


func show_story_dashboard() -> void:
	clear_screen()
	apply_language_direction()

	add_label("StoryTitleLabel", localized_story_title(), 30)
	add_label("StoryDescriptionLabel", localized_story_description(), 16)
	add_label("CurrentPathsTitleLabel", tr_text("dashboard.current_paths"), 20)

	if active_story["paths"].is_empty():
		add_label("NoPathsLabel", tr_text("dashboard.no_paths"), 15)
	else:
		for path_data in active_story["paths"]:
			var icon_text := str(path_data.get("icon", ""))
			var path_text := localized_path_name(path_data)
			if not icon_text.is_empty():
				path_text = "%s %s" % [icon_text, path_text]
			add_label("PathLabel_%s" % path_text.replace(" ", "_"), "- %s" % path_text, 16)

	if not active_story["suggested_path_keys"].is_empty():
		add_label("SuggestedPathsTitleLabel", tr_text("dashboard.suggested_paths"), 20)
		for path_key in active_story["suggested_path_keys"]:
			if not has_path_key(path_key):
				add_button(
					"SuggestedPathButton_%s" % path_key.replace(".", "_"),
					tr_text(path_key),
					add_suggested_path_and_show_dashboard.bind(path_key)
				)

	add_button("AddPathButton", tr_text("dashboard.add_path"), show_add_path_form)
	add_button("BackToHomeButton", tr_text("common.back_to_home"), show_empty_home_without_story)


func show_add_path_form() -> void:
	clear_screen()
	apply_language_direction()

	add_label("AddPathTitleLabel", tr_text("dashboard.add_path"), 28)

	var path_name_input := LineEdit.new()
	path_name_input.name = "PathNameInput"
	path_name_input.placeholder_text = tr_text("path.name_placeholder")
	path_name_input.custom_minimum_size = Vector2(360, 44)
	content_box.add_child(path_name_input)

	var path_icon_input := LineEdit.new()
	path_icon_input.name = "PathIconInput"
	path_icon_input.placeholder_text = tr_text("path.icon_placeholder")
	path_icon_input.custom_minimum_size = Vector2(360, 44)
	content_box.add_child(path_icon_input)

	var message_label := add_label("PathFormMessageLabel", "", 14)

	add_button(
		"CreatePathButton",
		tr_text("path.create"),
		func() -> void:
			var path_name := path_name_input.text.strip_edges()
			if path_name.is_empty():
				message_label.text = tr_text("error.empty_path_name")
				return

			if not add_custom_path(path_name, path_icon_input.text):
				message_label.text = tr_text("error.duplicate_path")
				return

			show_story_dashboard()
	)

	if not active_story["suggested_path_keys"].is_empty():
		add_label("SuggestedPathFormTitleLabel", tr_text("path.add_from_suggestions"), 18)
		for path_key in active_story["suggested_path_keys"]:
			if not has_path_key(path_key):
				add_button(
					"SuggestedPathFormButton_%s" % path_key.replace(".", "_"),
					tr_text(path_key),
					add_suggested_path_from_form.bind(path_key, message_label)
				)

	add_button("CancelButton", tr_text("common.cancel"), show_story_dashboard)


func show_empty_home_without_story() -> void:
	active_story = {}
	show_home()


func show_settings() -> void:
	clear_screen()
	apply_language_direction()

	add_label("SettingsTitleLabel", tr_text("settings.title"), 28)
	add_label("LanguageLabel", tr_text("settings.language"), 18)

	var language_selector := OptionButton.new()
	language_selector.name = "LanguageSelector"
	language_selector.custom_minimum_size = Vector2(340, 44)
	language_selector.add_item(tr_text("settings.english"))
	language_selector.add_item(tr_text("settings.persian"))
	language_selector.selected = 1 if localization.get_language() == Localization.PERSIAN else 0
	language_selector.item_selected.connect(
		func(index: int) -> void:
			var next_language := Localization.PERSIAN if index == 1 else Localization.ENGLISH
			localization.set_language(next_language)
			show_settings()
	)
	content_box.add_child(language_selector)

	add_button("BackToHomeButton", tr_text("common.back_to_home"), show_home)
