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

var sprint_templates := [
	{
		"id": "start",
		"title_key": "sprint_template.start.title",
		"subtitle_key": "sprint_template.start.subtitle",
		"suggested_name_key": "sprint_template.start.suggested_name",
		"duration_days": 2
	},
	{
		"id": "rising",
		"title_key": "sprint_template.rising.title",
		"subtitle_key": "sprint_template.rising.subtitle",
		"suggested_name_key": "sprint_template.rising.suggested_name",
		"duration_days": 2
	},
	{
		"id": "day_zero",
		"title_key": "sprint_template.day_zero.title",
		"subtitle_key": "sprint_template.day_zero.subtitle",
		"suggested_name_key": "sprint_template.day_zero.suggested_name",
		"duration_days": 2
	},
	{
		"id": "rhythm",
		"title_key": "sprint_template.rhythm.title",
		"subtitle_key": "sprint_template.rhythm.subtitle",
		"suggested_name_key": "sprint_template.rhythm.suggested_name",
		"duration_days": 3
	},
	{
		"id": "focus",
		"title_key": "sprint_template.focus.title",
		"subtitle_key": "sprint_template.focus.subtitle",
		"suggested_name_key": "sprint_template.focus.suggested_name",
		"duration_days": 3
	}
]

@onready var content_box: VBoxContainer = $ScreenContainer/ContentBox

@onready var home_screen: VBoxContainer = $ScreenContainer/ContentBox/HomeScreen
@onready var title_label: Label = $ScreenContainer/ContentBox/HomeScreen/TitleLabel
@onready var empty_state_label: Label = $ScreenContainer/ContentBox/HomeScreen/EmptyStateLabel
@onready var create_custom_story_button: Button = $ScreenContainer/ContentBox/HomeScreen/CreateCustomStoryButton
@onready var start_from_template_button: Button = $ScreenContainer/ContentBox/HomeScreen/StartFromTemplateButton
@onready var settings_button: Button = $ScreenContainer/ContentBox/HomeScreen/SettingsButton

@onready var custom_story_screen: VBoxContainer = $ScreenContainer/ContentBox/CustomStoryScreen
@onready var form_title_label: Label = $ScreenContainer/ContentBox/CustomStoryScreen/FormTitleLabel
@onready var story_title_input: LineEdit = $ScreenContainer/ContentBox/CustomStoryScreen/StoryTitleInput
@onready var story_description_input: TextEdit = $ScreenContainer/ContentBox/CustomStoryScreen/StoryDescriptionInput
@onready var form_message_label: Label = $ScreenContainer/ContentBox/CustomStoryScreen/FormMessageLabel
@onready var create_story_button: Button = $ScreenContainer/ContentBox/CustomStoryScreen/CreateStoryButton
@onready var cancel_custom_story_button: Button = $ScreenContainer/ContentBox/CustomStoryScreen/CancelCustomStoryButton

@onready var template_screen: VBoxContainer = $ScreenContainer/ContentBox/TemplateScreen
@onready var template_title_label: Label = $ScreenContainer/ContentBox/TemplateScreen/TemplateTitleLabel
@onready var template_buttons_container: VBoxContainer = $ScreenContainer/ContentBox/TemplateScreen/TemplateScrollContainer/TemplateButtonsContainer
@onready var cancel_template_button: Button = $ScreenContainer/ContentBox/TemplateScreen/CancelTemplateButton

@onready var dashboard_screen: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen
@onready var story_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryTitleLabel
@onready var story_description_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryDescriptionLabel
@onready var current_paths_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/CurrentPathsTitleLabel
@onready var current_paths_scroll_container: ScrollContainer = $ScreenContainer/ContentBox/DashboardScreen/CurrentPathsScrollContainer
@onready var current_paths_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/CurrentPathsScrollContainer/CurrentPathsList
@onready var no_paths_label: Label = $ScreenContainer/ContentBox/DashboardScreen/CurrentPathsScrollContainer/CurrentPathsList/NoPathsLabel
@onready var suggested_paths_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/SuggestedPathsTitleLabel
@onready var suggested_paths_scroll_container: ScrollContainer = $ScreenContainer/ContentBox/DashboardScreen/SuggestedPathsScrollContainer
@onready var suggested_paths_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/SuggestedPathsScrollContainer/SuggestedPathsList
@onready var sprints_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/SprintsTitleLabel
@onready var sprints_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/SprintsList
@onready var add_sprint_hint_label: Label = $ScreenContainer/ContentBox/DashboardScreen/AddSprintHintLabel
@onready var add_path_button: Button = $ScreenContainer/ContentBox/DashboardScreen/AddPathButton
@onready var add_sprint_button: Button = $ScreenContainer/ContentBox/DashboardScreen/AddSprintButton
@onready var back_to_home_button: Button = $ScreenContainer/ContentBox/DashboardScreen/BackToHomeButton

@onready var add_path_screen: VBoxContainer = $ScreenContainer/ContentBox/AddPathScreen
@onready var add_path_title_label: Label = $ScreenContainer/ContentBox/AddPathScreen/AddPathTitleLabel
@onready var path_name_input: LineEdit = $ScreenContainer/ContentBox/AddPathScreen/PathNameInput
@onready var path_icon_input: LineEdit = $ScreenContainer/ContentBox/AddPathScreen/PathIconInput
@onready var path_form_message_label: Label = $ScreenContainer/ContentBox/AddPathScreen/PathFormMessageLabel
@onready var create_path_button: Button = $ScreenContainer/ContentBox/AddPathScreen/CreatePathButton
@onready var suggested_path_form_title_label: Label = $ScreenContainer/ContentBox/AddPathScreen/SuggestedPathFormTitleLabel
@onready var path_form_suggested_scroll_container: ScrollContainer = $ScreenContainer/ContentBox/AddPathScreen/PathFormSuggestedScrollContainer
@onready var path_form_suggested_list: VBoxContainer = $ScreenContainer/ContentBox/AddPathScreen/PathFormSuggestedScrollContainer/PathFormSuggestedList
@onready var cancel_path_button: Button = $ScreenContainer/ContentBox/AddPathScreen/CancelPathButton

@onready var add_sprint_screen: VBoxContainer = $ScreenContainer/ContentBox/AddSprintScreen
@onready var add_sprint_title_label: Label = $ScreenContainer/ContentBox/AddSprintScreen/AddSprintTitleLabel
@onready var create_custom_sprint_label: Label = $ScreenContainer/ContentBox/AddSprintScreen/CreateCustomSprintLabel
@onready var sprint_title_input: LineEdit = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/SprintTitleInput
@onready var sprint_start_date_input: LineEdit = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/SprintStartDateInput
@onready var sprint_end_date_input: LineEdit = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/SprintEndDateInput
@onready var sprint_form_message_label: Label = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/SprintFormMessageLabel
@onready var create_sprint_button: Button = $ScreenContainer/ContentBox/AddSprintScreen/CreateSprintButton
@onready var start_from_sprint_template_label: Label = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/StartFromSprintTemplateLabel
@onready var sprint_templates_title_label: Label = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/VBoxContainer/SprintTemplatesTitleLabel
@onready var sprint_template_buttons_container: VBoxContainer = $ScreenContainer/ContentBox/AddSprintScreen/HBoxContainer/SprintTemplateScrollContainer/SprintTemplateButtonsContainer
@onready var cancel_sprint_button: Button = $ScreenContainer/ContentBox/AddSprintScreen/CancelSprintButton

@onready var settings_screen: VBoxContainer = $ScreenContainer/ContentBox/SettingsScreen
@onready var settings_title_label: Label = $ScreenContainer/ContentBox/SettingsScreen/SettingsTitleLabel
@onready var language_label: Label = $ScreenContainer/ContentBox/SettingsScreen/LanguageLabel
@onready var language_selector: OptionButton = $ScreenContainer/ContentBox/SettingsScreen/LanguageSelector
@onready var back_from_settings_button: Button = $ScreenContainer/ContentBox/SettingsScreen/BackFromSettingsButton


func _ready() -> void:
	connect_buttons()
	update_language_text()
	show_home()


func connect_buttons() -> void:
	create_custom_story_button.pressed.connect(show_custom_story_form)
	start_from_template_button.pressed.connect(show_template_selection)
	settings_button.pressed.connect(show_settings)
	create_story_button.pressed.connect(create_custom_story)
	cancel_custom_story_button.pressed.connect(show_home)
	cancel_template_button.pressed.connect(show_home)
	add_path_button.pressed.connect(show_add_path_form)
	add_sprint_button.pressed.connect(show_add_sprint_form)
	back_to_home_button.pressed.connect(show_empty_home_without_story)
	create_path_button.pressed.connect(create_custom_path)
	cancel_path_button.pressed.connect(show_story_dashboard)
	create_sprint_button.pressed.connect(create_sprint)
	cancel_sprint_button.pressed.connect(show_story_dashboard)
	back_from_settings_button.pressed.connect(show_home)
	language_selector.item_selected.connect(change_language)


func tr_text(key: String) -> String:
	return localization.text(key)


func show_screen(screen_to_show: Control) -> void:
	for screen in content_box.get_children():
		screen.visible = screen == screen_to_show
	apply_language_direction()


func apply_language_direction() -> void:
	var direction := Control.LAYOUT_DIRECTION_RTL if localization.is_rtl() else Control.LAYOUT_DIRECTION_LTR
	content_box.layout_direction = direction
	for screen in content_box.get_children():
		screen.layout_direction = direction


func clear_dynamic_children(container: Container) -> void:
	for child in container.get_children():
		if child.get_meta("dynamic_item", false):
			child.queue_free()


func make_list_label(label_text: String) -> Label:
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(320, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_meta("dynamic_item", true)
	return label


func make_list_button(button_text: String, pressed_action: Callable) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(340, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.set_meta("dynamic_item", true)
	button.pressed.connect(pressed_action)
	return button


func update_language_text() -> void:
	title_label.text = tr_text("app.title")
	empty_state_label.text = tr_text("home.empty_message")
	create_custom_story_button.text = tr_text("home.create_custom_story")
	start_from_template_button.text = tr_text("home.start_from_template")
	settings_button.text = tr_text("home.settings")

	form_title_label.text = tr_text("home.create_custom_story")
	story_title_input.placeholder_text = tr_text("story.title_placeholder")
	story_description_input.placeholder_text = tr_text("story.description_placeholder")
	create_story_button.text = tr_text("story.create")
	cancel_custom_story_button.text = tr_text("common.cancel")

	template_title_label.text = tr_text("template.choose")
	cancel_template_button.text = tr_text("common.cancel")

	current_paths_title_label.text = tr_text("dashboard.current_paths")
	no_paths_label.text = tr_text("dashboard.no_paths")
	suggested_paths_title_label.text = tr_text("dashboard.suggested_paths")
	sprints_title_label.text = tr_text("dashboard.sprints")
	add_sprint_hint_label.text = tr_text("dashboard.add_path_before_sprint")
	add_path_button.text = tr_text("dashboard.add_path")
	add_sprint_button.text = tr_text("dashboard.add_sprint")
	back_to_home_button.text = tr_text("common.back_to_home")

	add_path_title_label.text = tr_text("dashboard.add_path")
	path_name_input.placeholder_text = tr_text("path.name_placeholder")
	path_icon_input.placeholder_text = tr_text("path.icon_placeholder")
	create_path_button.text = tr_text("path.create")
	suggested_path_form_title_label.text = tr_text("path.add_from_suggestions")
	cancel_path_button.text = tr_text("common.cancel")

	add_sprint_title_label.text = tr_text("dashboard.add_sprint")
	create_custom_sprint_label.text = tr_text("sprint.create_custom")
	sprint_title_input.placeholder_text = tr_text("sprint.title_placeholder")
	sprint_start_date_input.placeholder_text = tr_text("sprint.start_date_placeholder")
	sprint_end_date_input.placeholder_text = tr_text("sprint.end_date_placeholder")
	create_sprint_button.text = tr_text("sprint.create")
	start_from_sprint_template_label.text = tr_text("sprint.start_from_template")
	sprint_templates_title_label.text = tr_text("sprint.templates")
	cancel_sprint_button.text = tr_text("common.cancel")

	settings_title_label.text = tr_text("settings.title")
	language_label.text = tr_text("settings.language")
	back_from_settings_button.text = tr_text("common.back_to_home")
	update_language_selector()


func update_language_selector() -> void:
	language_selector.clear()
	language_selector.add_item(tr_text("settings.english"))
	language_selector.add_item(tr_text("settings.persian"))
	language_selector.selected = 1 if localization.get_language() == Localization.PERSIAN else 0


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


func show_home() -> void:
	update_language_text()
	show_screen(home_screen)


func show_custom_story_form() -> void:
	story_title_input.text = ""
	story_description_input.text = ""
	form_message_label.text = ""
	show_screen(custom_story_screen)


func create_custom_story() -> void:
	var title := story_title_input.text.strip_edges()
	if title.is_empty():
		form_message_label.text = tr_text("error.empty_story_title")
		return

	active_story = {
		"title": title,
		"description": story_description_input.text.strip_edges(),
		"suggested_path_keys": [],
		"paths": [],
		"sprints": []
	}
	show_story_dashboard()


func show_template_selection() -> void:
	clear_dynamic_children(template_buttons_container)
	for story_template in story_templates:
		var button_text := "%s\n%s" % [
			tr_text(story_template["title_key"]),
			tr_text(story_template["description_key"])
		]
		template_buttons_container.add_child(
			make_list_button(button_text, create_story_from_template.bind(story_template))
		)
	show_screen(template_screen)


func create_story_from_template(template_data: Dictionary) -> void:
	active_story = {
		"template_id": template_data["id"],
		"title_key": template_data["title_key"],
		"description_key": template_data["description_key"],
		"suggested_path_keys": template_data["suggested_path_keys"].duplicate(),
		"paths": [],
		"sprints": []
	}
	show_story_dashboard()


func show_story_dashboard() -> void:
	if active_story.is_empty():
		show_home()
		return

	update_dashboard()
	show_screen(dashboard_screen)


func update_dashboard() -> void:
	story_title_label.text = localized_story_title()
	story_description_label.text = localized_story_description()
	update_paths_list()
	update_suggested_paths_list()
	update_sprints_list()


func update_paths_list() -> void:
	clear_dynamic_children(current_paths_list)
	no_paths_label.visible = active_story["paths"].is_empty()

	for path_data in active_story["paths"]:
		var icon_text := str(path_data.get("icon", ""))
		var path_text := localized_path_name(path_data)
		if not icon_text.is_empty():
			path_text = "%s %s" % [icon_text, path_text]
		current_paths_list.add_child(make_list_label("- %s" % path_text))

	add_sprint_button.visible = not active_story["paths"].is_empty()
	add_sprint_hint_label.visible = active_story["paths"].is_empty()


func update_suggested_paths_list() -> void:
	clear_dynamic_children(suggested_paths_list)
	var has_available_suggestions := false

	for path_key in active_story.get("suggested_path_keys", []):
		if not has_path_key(path_key):
			has_available_suggestions = true
			suggested_paths_list.add_child(
				make_list_button(tr_text(path_key), add_suggested_path_and_show_dashboard.bind(path_key))
			)

	suggested_paths_title_label.visible = has_available_suggestions
	suggested_paths_scroll_container.visible = has_available_suggestions


func update_sprints_list() -> void:
	clear_dynamic_children(sprints_list)
	var sprints: Array = active_story.get("sprints", [])
	sprints_title_label.visible = not sprints.is_empty()
	sprints_list.visible = not sprints.is_empty()

	for sprint_data in sprints:
		sprints_list.add_child(make_list_label("- %s" % sprint_data.get("title", "")))


func show_add_path_form() -> void:
	path_name_input.text = ""
	path_icon_input.text = ""
	path_form_message_label.text = ""
	update_path_form_suggestions()
	show_screen(add_path_screen)


func update_path_form_suggestions() -> void:
	clear_dynamic_children(path_form_suggested_list)
	var has_available_suggestions := false

	for path_key in active_story.get("suggested_path_keys", []):
		if not has_path_key(path_key):
			has_available_suggestions = true
			path_form_suggested_list.add_child(
				make_list_button(tr_text(path_key), add_suggested_path_from_form.bind(path_key))
			)

	suggested_path_form_title_label.visible = has_available_suggestions
	path_form_suggested_scroll_container.visible = has_available_suggestions


func create_custom_path() -> void:
	var path_name := path_name_input.text.strip_edges()
	if path_name.is_empty():
		path_form_message_label.text = tr_text("error.empty_path_name")
		return

	if not add_custom_path(path_name, path_icon_input.text):
		path_form_message_label.text = tr_text("error.duplicate_path")
		return

	show_story_dashboard()


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


func add_suggested_path_from_form(path_key: String) -> void:
	if not add_suggested_path(path_key):
		path_form_message_label.text = tr_text("error.duplicate_path")
		return
	show_story_dashboard()


func show_add_sprint_form() -> void:
	if active_story.get("paths", []).is_empty():
		add_sprint_hint_label.text = tr_text("dashboard.add_path_before_sprint")
		return

	sprint_title_input.text = ""
	sprint_start_date_input.text = get_date_text(0)
	sprint_end_date_input.text = get_date_text(1)
	sprint_form_message_label.text = ""
	update_sprint_template_buttons()
	show_screen(add_sprint_screen)


func create_sprint() -> void:
	var sprint_title := sprint_title_input.text.strip_edges()
	if sprint_title.is_empty():
		sprint_form_message_label.text = tr_text("error.empty_sprint_title")
		return

	active_story["sprints"].append({
		"title": sprint_title,
		"start_date": sprint_start_date_input.text.strip_edges(),
		"end_date": sprint_end_date_input.text.strip_edges()
	})
	show_story_dashboard()


func update_sprint_template_buttons() -> void:
	clear_dynamic_children(sprint_template_buttons_container)

	for sprint_template in sprint_templates:
		var duration_text := tr_text("sprint.duration_format") % [
			localized_number(sprint_template["duration_days"]),
			tr_text("sprint.days")
		]
		var button_text := "%s\n%s\n%s: %s\n%s: %s" % [
			tr_text(sprint_template["title_key"]),
			tr_text(sprint_template["subtitle_key"]),
			tr_text("sprint.duration"),
			duration_text,
			tr_text("sprint.suggested_name"),
			tr_text(sprint_template["suggested_name_key"])
		]
		sprint_template_buttons_container.add_child(
			make_list_button(button_text, create_sprint_from_template.bind(sprint_template))
		)


func create_sprint_from_template(sprint_template: Dictionary) -> void:
	active_story["sprints"].append({
		"title": tr_text(sprint_template["suggested_name_key"]),
		"start_date": get_date_text(0),
		"end_date": get_date_text(int(sprint_template["duration_days"]) - 1),
		"template_id": sprint_template["id"]
	})
	show_story_dashboard()


func get_date_text(days_from_today: int) -> String:
	var seconds_per_day := 86400
	var unix_time := Time.get_unix_time_from_system() + (days_from_today * seconds_per_day)
	var date := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%04d-%02d-%02d" % [date["year"], date["month"], date["day"]]


func localized_number(value: int) -> String:
	var number_text := str(value)
	if localization.get_language() != Localization.PERSIAN:
		return number_text

	var persian_digits := ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]
	var result := ""
	for digit in number_text:
		result += persian_digits[int(digit)]
	return result


func show_settings() -> void:
	show_screen(settings_screen)


func change_language(index: int) -> void:
	var next_language := Localization.PERSIAN if index == 1 else Localization.ENGLISH
	localization.set_language(next_language)
	update_language_text()

	if dashboard_screen.visible:
		update_dashboard()
	elif template_screen.visible:
		show_template_selection()
	elif add_path_screen.visible:
		update_path_form_suggestions()
	elif add_sprint_screen.visible:
		update_sprint_template_buttons()

	apply_language_direction()


func show_empty_home_without_story() -> void:
	active_story = {}
	show_home()
