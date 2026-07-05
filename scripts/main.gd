extends Control

const Localization = preload("res://scripts/localization/localization.gd")
const SAVE_PATH := "user://questboard_data.json"
const SAVE_VERSION := 1

var localization := Localization.new()
var active_story := {}

var next_story_id := 1
var next_path_id := 1
var next_sprint_id := 1
var next_quest_id := 1
var next_objective_id := 1
var current_sprint_index := -1
var pending_sprint_index := -1
var current_quest_index := -1
var editing_objective_index := -1
var active_story_id := -1
var saved_screen_name := "home"
var is_loading_state := false

var story_templates := [
	{
		"id": "starting_over",
		"title_key": "template.starting_over.title",
		"description_key": "template.starting_over.description",
		"goal_key": "template.starting_over.goal",
		"suggested_path_keys": ["path.health_fitness", "path.learning", "path.income", "path.family", "path.creation", "path.rest"]
	},
	{
		"id": "build_my_first_product",
		"title_key": "template.build_my_first_product.title",
		"description_key": "template.build_my_first_product.description",
		"goal_key": "template.build_my_first_product.goal",
		"suggested_path_keys": ["path.product", "path.learning", "path.marketing", "path.income", "path.health_fitness", "path.rest"]
	},
	{
		"id": "health_reset",
		"title_key": "template.health_reset.title",
		"description_key": "template.health_reset.description",
		"goal_key": "template.health_reset.goal",
		"suggested_path_keys": ["path.health_fitness", "path.nutrition", "path.sleep", "path.mindset", "path.rest"]
	},
	{
		"id": "learning_sprint",
		"title_key": "template.learning_sprint.title",
		"description_key": "template.learning_sprint.description",
		"goal_key": "template.learning_sprint.goal",
		"suggested_path_keys": ["path.study", "path.practice", "path.projects", "path.review", "path.rest"]
	},
	{
		"id": "career_comeback",
		"title_key": "template.career_comeback.title",
		"description_key": "template.career_comeback.description",
		"goal_key": "template.career_comeback.goal",
		"suggested_path_keys": ["path.resume", "path.applications", "path.interview_practice", "path.learning", "path.income", "path.health_fitness"]
	}
]

var sprint_templates := [
	{"id": "start", "title_key": "sprint_template.start.title", "subtitle_key": "sprint_template.start.subtitle", "suggested_name_key": "sprint_template.start.suggested_name", "duration_days": 2},
	{"id": "rising", "title_key": "sprint_template.rising.title", "subtitle_key": "sprint_template.rising.subtitle", "suggested_name_key": "sprint_template.rising.suggested_name", "duration_days": 2},
	{"id": "day_zero", "title_key": "sprint_template.day_zero.title", "subtitle_key": "sprint_template.day_zero.subtitle", "suggested_name_key": "sprint_template.day_zero.suggested_name", "duration_days": 2},
	{"id": "rhythm", "title_key": "sprint_template.rhythm.title", "subtitle_key": "sprint_template.rhythm.subtitle", "suggested_name_key": "sprint_template.rhythm.suggested_name", "duration_days": 3},
	{"id": "focus", "title_key": "sprint_template.focus.title", "subtitle_key": "sprint_template.focus.subtitle", "suggested_name_key": "sprint_template.focus.suggested_name", "duration_days": 3}
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
@onready var story_title_input: LineEdit = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryFieldsColumn/StoryTitleInput
@onready var story_description_input: TextEdit = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryFieldsColumn/StoryDescriptionInput
@onready var story_goal_input: TextEdit = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryFieldsColumn/StoryGoalInput
@onready var form_message_label: Label = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryActionsColumn/FormMessageLabel
@onready var create_story_button: Button = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryActionsColumn/CreateStoryButton
@onready var cancel_custom_story_button: Button = $ScreenContainer/ContentBox/CustomStoryScreen/CustomStoryColumns/StoryActionsColumn/CancelCustomStoryButton

@onready var template_screen: VBoxContainer = $ScreenContainer/ContentBox/TemplateScreen
@onready var template_title_label: Label = $ScreenContainer/ContentBox/TemplateScreen/TemplateTitleLabel
@onready var template_buttons_container: VBoxContainer = $ScreenContainer/ContentBox/TemplateScreen/TemplateColumns/TemplateScrollContainer/TemplateButtonsContainer
@onready var cancel_template_button: Button = $ScreenContainer/ContentBox/TemplateScreen/TemplateColumns/TemplateActionsColumn/CancelTemplateButton

@onready var dashboard_screen: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen
@onready var story_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryTitleLabel
@onready var story_description_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryDescriptionLabel
@onready var story_goal_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryGoalLabel
@onready var story_progress_label: Label = $ScreenContainer/ContentBox/DashboardScreen/StoryProgressLabel
@onready var story_progress_bar: ProgressBar = $ScreenContainer/ContentBox/DashboardScreen/StoryProgressBar
@onready var current_paths_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/CurrentPathsTitleLabel
@onready var current_paths_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/CurrentPathsScrollContainer/CurrentPathsList
@onready var no_paths_label: Label = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/CurrentPathsScrollContainer/CurrentPathsList/NoPathsLabel
@onready var suggested_paths_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/SuggestedPathsTitleLabel
@onready var suggested_paths_scroll_container: ScrollContainer = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/SuggestedPathsScrollContainer
@onready var suggested_paths_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardPathsColumn/SuggestedPathsScrollContainer/SuggestedPathsList
@onready var sprints_title_label: Label = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/SprintsTitleLabel
@onready var sprints_list: VBoxContainer = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/SprintsScrollContainer/SprintsList
@onready var add_sprint_hint_label: Label = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/AddSprintHintLabel
@onready var add_path_button: Button = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/AddPathButton
@onready var add_sprint_button: Button = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/AddSprintButton
@onready var add_quest_button: Button = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/AddQuestButton
@onready var back_to_home_button: Button = $ScreenContainer/ContentBox/DashboardScreen/DashboardColumns/DashboardSprintsColumn/BackToHomeButton

@onready var add_path_screen: VBoxContainer = $ScreenContainer/ContentBox/AddPathScreen
@onready var add_path_title_label: Label = $ScreenContainer/ContentBox/AddPathScreen/AddPathTitleLabel
@onready var path_name_input: LineEdit = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/CustomPathFormColumn/PathNameInput
@onready var path_icon_input: LineEdit = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/CustomPathFormColumn/PathIconInput
@onready var path_form_message_label: Label = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/CustomPathFormColumn/PathFormMessageLabel
@onready var create_path_button: Button = $ScreenContainer/ContentBox/AddPathScreen/CreatePathButton
@onready var suggested_path_form_title_label: Label = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/CustomPathFormColumn/SuggestedPathFormTitleLabel
@onready var path_form_suggested_scroll_container: ScrollContainer = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/PathFormSuggestedScrollContainer
@onready var path_form_suggested_list: VBoxContainer = $ScreenContainer/ContentBox/AddPathScreen/PathContentColumns/PathFormSuggestedScrollContainer/PathFormSuggestedList
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

@onready var select_active_paths_screen: VBoxContainer = $ScreenContainer/ContentBox/SelectActivePathsScreen
@onready var select_active_paths_title_label: Label = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsTitleLabel
@onready var select_active_paths_hint_label: Label = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsHintLabel
@onready var active_path_options_list: VBoxContainer = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsColumns/ActivePathScrollContainer/ActivePathOptionsList
@onready var select_active_paths_message_label: Label = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsColumns/SelectActivePathsActionsColumn/SelectActivePathsMessageLabel
@onready var save_active_paths_button: Button = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsColumns/SelectActivePathsActionsColumn/SaveActivePathsButton
@onready var cancel_active_paths_button: Button = $ScreenContainer/ContentBox/SelectActivePathsScreen/SelectActivePathsColumns/SelectActivePathsActionsColumn/CancelActivePathsButton

@onready var add_quest_screen: VBoxContainer = $ScreenContainer/ContentBox/AddQuestScreen
@onready var add_quest_title_label: Label = $ScreenContainer/ContentBox/AddQuestScreen/AddQuestTitleLabel
@onready var quest_title_input: LineEdit = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestFieldsColumn/QuestTitleInput
@onready var quest_description_input: TextEdit = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestFieldsColumn/QuestDescriptionInput
@onready var quest_path_selector: OptionButton = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestFieldsColumn/QuestPathSelector
@onready var quest_due_date_input: LineEdit = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestFieldsColumn/QuestDueDateInput
@onready var quest_status_selector: OptionButton = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestFieldsColumn/QuestStatusSelector
@onready var quest_form_message_label: Label = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestActionsColumn/QuestFormMessageLabel
@onready var create_quest_button: Button = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestActionsColumn/CreateQuestButton
@onready var cancel_quest_button: Button = $ScreenContainer/ContentBox/AddQuestScreen/QuestColumns/QuestActionsColumn/CancelQuestButton

@onready var quest_detail_screen: VBoxContainer = $ScreenContainer/ContentBox/QuestDetailScreen
@onready var quest_detail_title_label: Label = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailTitleLabel
@onready var quest_detail_progress_label: Label = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailProgressLabel
@onready var quest_detail_progress_bar: ProgressBar = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailProgressBar
@onready var objectives_list: VBoxContainer = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailColumns/ObjectivesScrollContainer/ObjectivesList
@onready var objective_title_input: LineEdit = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailColumns/ObjectiveActionsColumn/ObjectiveTitleInput
@onready var objective_message_label: Label = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailColumns/ObjectiveActionsColumn/ObjectiveMessageLabel
@onready var add_objective_button: Button = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailColumns/ObjectiveActionsColumn/AddObjectiveButton
@onready var back_from_quest_detail_button: Button = $ScreenContainer/ContentBox/QuestDetailScreen/QuestDetailColumns/ObjectiveActionsColumn/BackFromQuestDetailButton

@onready var settings_screen: VBoxContainer = $ScreenContainer/ContentBox/SettingsScreen
@onready var settings_title_label: Label = $ScreenContainer/ContentBox/SettingsScreen/SettingsTitleLabel
@onready var language_label: Label = $ScreenContainer/ContentBox/SettingsScreen/SettingsColumns/SettingsLanguageColumn/LanguageLabel
@onready var language_selector: OptionButton = $ScreenContainer/ContentBox/SettingsScreen/SettingsColumns/SettingsLanguageColumn/LanguageSelector
@onready var back_from_settings_button: Button = $ScreenContainer/ContentBox/SettingsScreen/SettingsColumns/SettingsActionsColumn/BackFromSettingsButton


func _ready() -> void:
	connect_buttons()
	load_state()
	update_language_text()
	restore_saved_screen()


func connect_buttons() -> void:
	create_custom_story_button.pressed.connect(show_custom_story_form)
	start_from_template_button.pressed.connect(show_template_selection)
	settings_button.pressed.connect(show_settings)
	create_story_button.pressed.connect(create_custom_story)
	cancel_custom_story_button.pressed.connect(show_home)
	cancel_template_button.pressed.connect(show_home)
	add_path_button.pressed.connect(show_add_path_form)
	add_sprint_button.pressed.connect(show_add_sprint_form)
	add_quest_button.pressed.connect(show_add_quest_form)
	back_to_home_button.pressed.connect(show_empty_home_without_story)
	create_path_button.pressed.connect(create_custom_path)
	cancel_path_button.pressed.connect(show_story_dashboard)
	create_sprint_button.pressed.connect(create_sprint)
	cancel_sprint_button.pressed.connect(show_story_dashboard)
	save_active_paths_button.pressed.connect(save_active_paths_for_sprint)
	cancel_active_paths_button.pressed.connect(show_story_dashboard)
	create_quest_button.pressed.connect(create_quest)
	cancel_quest_button.pressed.connect(show_story_dashboard)
	add_objective_button.pressed.connect(save_objective)
	back_from_quest_detail_button.pressed.connect(show_story_dashboard)
	back_from_settings_button.pressed.connect(show_home)
	language_selector.item_selected.connect(change_language)


# Saves one readable JSON file in Godot's per-user app data folder.
func save_state() -> void:
	var save_data := {
		"save_version": SAVE_VERSION,
		"settings": {
			"language": localization.get_language()
		},
		"ui_state": {
			"last_screen": saved_screen_name,
			"active_story_id": active_story_id,
			"active_sprint_index": current_sprint_index,
			"active_quest_index": current_quest_index,
			"pending_sprint_index": pending_sprint_index
		},
		"ids": {
			"next_story_id": next_story_id,
			"next_path_id": next_path_id,
			"next_sprint_id": next_sprint_id,
			"next_quest_id": next_quest_id,
			"next_objective_id": next_objective_id
		},
		"stories": get_saved_stories(),
		"future": {
			"calendar": {},
			"ai": {},
			"achievements": {},
			"cloud_sync": {},
			"themes": {}
		}
	}

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		return

	save_file.store_string(JSON.stringify(save_data, "\t"))


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	is_loading_state = true
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		is_loading_state = false
		return

	var parsed = JSON.parse_string(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		is_loading_state = false
		return

	if parsed.has("save_version"):
		load_versioned_state(parsed)
	else:
		load_legacy_state(parsed)
	refresh_next_ids_from_loaded_story()
	is_loading_state = false


func load_versioned_state(save_data: Dictionary) -> void:
	var settings: Dictionary = save_data.get("settings", {})
	var ui_state: Dictionary = save_data.get("ui_state", {})
	var ids: Dictionary = save_data.get("ids", {})
	var stories: Array = save_data.get("stories", [])

	localization.set_language(settings.get("language", Localization.ENGLISH))
	next_story_id = int(ids.get("next_story_id", 1))
	next_path_id = int(ids.get("next_path_id", 1))
	next_sprint_id = int(ids.get("next_sprint_id", 1))
	next_quest_id = int(ids.get("next_quest_id", 1))
	next_objective_id = int(ids.get("next_objective_id", 1))
	active_story_id = int(ui_state.get("active_story_id", -1))
	current_sprint_index = int(ui_state.get("active_sprint_index", -1))
	current_quest_index = int(ui_state.get("active_quest_index", -1))
	pending_sprint_index = int(ui_state.get("pending_sprint_index", -1))
	saved_screen_name = ui_state.get("last_screen", "home")

	active_story = {}
	for story in stories:
		if int(story.get("id", -1)) == active_story_id:
			active_story = story
			break

	if active_story.is_empty() and not stories.is_empty():
		active_story = stories[0]
		active_story_id = int(active_story.get("id", -1))


func load_legacy_state(save_data: Dictionary) -> void:
	localization.set_language(save_data.get("language", Localization.ENGLISH))
	active_story = save_data.get("active_story", {})
	next_path_id = int(save_data.get("next_path_id", 1))
	next_sprint_id = int(save_data.get("next_sprint_id", 1))
	next_quest_id = int(save_data.get("next_quest_id", 1))
	next_objective_id = int(save_data.get("next_objective_id", 1))
	current_sprint_index = int(save_data.get("current_sprint_index", -1))
	current_quest_index = -1
	pending_sprint_index = -1
	saved_screen_name = "dashboard" if not active_story.is_empty() else "home"
	ensure_active_story_has_id()


func get_saved_stories() -> Array:
	if active_story.is_empty():
		return []
	return [active_story]


func ensure_active_story_has_id() -> void:
	if active_story.is_empty():
		active_story_id = -1
		return
	if not active_story.has("id"):
		active_story["id"] = next_story_id
		next_story_id += 1
	if not active_story.has("title") and active_story.has("title_key"):
		active_story["title"] = tr_text(active_story["title_key"])
	if not active_story.has("description") and active_story.has("description_key"):
		active_story["description"] = tr_text(active_story["description_key"])
	if not active_story.has("goal") and active_story.has("goal_key"):
		active_story["goal"] = tr_text(active_story["goal_key"])
	if not active_story.has("template_id"):
		active_story["template_id"] = ""
	if not active_story.has("paths"):
		active_story["paths"] = []
	if not active_story.has("sprints"):
		active_story["sprints"] = []
	active_story_id = int(active_story["id"])


func refresh_next_ids_from_loaded_story() -> void:
	ensure_active_story_has_id()
	if not active_story.is_empty():
		next_story_id = max(next_story_id, int(active_story.get("id", 0)) + 1)

	for path_data in active_story.get("paths", []):
		next_path_id = max(next_path_id, int(path_data.get("id", 0)) + 1)

	for sprint in active_story.get("sprints", []):
		next_sprint_id = max(next_sprint_id, int(sprint.get("id", 0)) + 1)
		for quest in sprint.get("quests", []):
			next_quest_id = max(next_quest_id, int(quest.get("id", 0)) + 1)
			for objective in quest.get("objectives", []):
				next_objective_id = max(next_objective_id, int(objective.get("id", 0)) + 1)

	var sprints: Array = active_story.get("sprints", [])
	if current_sprint_index >= sprints.size():
		current_sprint_index = sprints.size() - 1
	if pending_sprint_index >= sprints.size():
		pending_sprint_index = -1
	var current_sprint := get_current_sprint()
	var quests: Array = current_sprint.get("quests", [])
	if current_quest_index >= quests.size():
		current_quest_index = quests.size() - 1


func tr_text(key: String) -> String:
	return localization.text(key)


func show_screen(screen_to_show: Control) -> void:
	for screen in content_box.get_children():
		screen.visible = screen == screen_to_show
	saved_screen_name = get_screen_save_name(screen_to_show)
	apply_language_direction()
	if not is_loading_state:
		save_state()


func get_screen_save_name(screen: Control) -> String:
	if screen == home_screen:
		return "home"
	if screen == custom_story_screen:
		return "custom_story"
	if screen == template_screen:
		return "template"
	if screen == dashboard_screen:
		return "dashboard"
	if screen == add_path_screen:
		return "add_path"
	if screen == add_sprint_screen:
		return "add_sprint"
	if screen == select_active_paths_screen:
		return "select_active_paths"
	if screen == add_quest_screen:
		return "add_quest"
	if screen == quest_detail_screen:
		return "quest_detail"
	if screen == settings_screen:
		return "settings"
	return "home"


func restore_saved_screen() -> void:
	if active_story.is_empty():
		show_screen(home_screen)
		return

	match saved_screen_name:
		"custom_story":
			show_custom_story_form()
		"template":
			show_template_selection()
		"add_path":
			show_add_path_form()
		"add_sprint":
			if active_story.get("paths", []).is_empty():
				show_story_dashboard()
			else:
				show_add_sprint_form()
		"select_active_paths":
			if pending_sprint_index >= 0:
				show_select_active_paths(pending_sprint_index)
			else:
				show_story_dashboard()
		"add_quest":
			var sprint := get_current_sprint()
			if sprint.is_empty() or sprint.get("active_path_ids", []).is_empty():
				show_story_dashboard()
			else:
				show_add_quest_form()
		"quest_detail":
			if current_quest_index >= 0:
				show_quest_detail(current_quest_index)
			else:
				show_story_dashboard()
		"settings":
			show_settings()
		_:
			show_story_dashboard()


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


func make_progress_label(label_text: String, progress: float) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.set_meta("dynamic_item", true)
	var label := make_list_label("%s - %d%%" % [label_text, int(progress)])
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 16)
	bar.max_value = 100
	bar.value = progress
	box.add_child(label)
	box.add_child(bar)
	return box


func update_language_text() -> void:
	title_label.text = tr_text("app.title")
	empty_state_label.text = tr_text("home.empty_message")
	create_custom_story_button.text = tr_text("home.create_custom_story")
	start_from_template_button.text = tr_text("home.start_from_template")
	settings_button.text = tr_text("home.settings")

	form_title_label.text = tr_text("home.create_custom_story")
	story_title_input.placeholder_text = tr_text("story.title_placeholder")
	story_description_input.placeholder_text = tr_text("story.description_placeholder")
	story_goal_input.placeholder_text = tr_text("story.goal_placeholder")
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
	add_quest_button.text = tr_text("dashboard.add_quest")
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

	select_active_paths_title_label.text = tr_text("sprint.select_active_paths")
	select_active_paths_hint_label.text = tr_text("sprint.select_active_paths_hint")
	save_active_paths_button.text = tr_text("sprint.save_active_paths")
	cancel_active_paths_button.text = tr_text("common.cancel")

	add_quest_title_label.text = tr_text("quest.add")
	quest_title_input.placeholder_text = tr_text("quest.title_placeholder")
	quest_description_input.placeholder_text = tr_text("quest.description_placeholder")
	quest_due_date_input.placeholder_text = tr_text("quest.due_date_placeholder")
	create_quest_button.text = tr_text("quest.create")
	cancel_quest_button.text = tr_text("common.cancel")

	objective_title_input.placeholder_text = tr_text("objective.title_placeholder")
	add_objective_button.text = tr_text("objective.add")
	back_from_quest_detail_button.text = tr_text("common.back")

	settings_title_label.text = tr_text("settings.title")
	language_label.text = tr_text("settings.language")
	back_from_settings_button.text = tr_text("common.back_to_home")
	update_language_selector()
	update_quest_status_selector()


func update_language_selector() -> void:
	language_selector.clear()
	language_selector.add_item(tr_text("settings.english"))
	language_selector.add_item(tr_text("settings.persian"))
	language_selector.selected = 1 if localization.get_language() == Localization.PERSIAN else 0


func update_quest_status_selector() -> void:
	if quest_status_selector == null:
		return
	quest_status_selector.clear()
	quest_status_selector.add_item(tr_text("quest.status_planned"))
	quest_status_selector.add_item(tr_text("quest.status_active"))
	quest_status_selector.add_item(tr_text("quest.status_done"))


func localized_story_title() -> String:
	if active_story.has("title_key"):
		return tr_text(active_story["title_key"])
	return active_story.get("title", "")


func localized_story_description() -> String:
	if active_story.has("description_key"):
		return tr_text(active_story["description_key"])
	return active_story.get("description", "")


func localized_story_goal() -> String:
	if active_story.has("goal_key"):
		return tr_text(active_story["goal_key"])
	return active_story.get("goal", "")


func localized_path_name(path_data: Dictionary) -> String:
	if path_data.has("name_key"):
		return tr_text(path_data["name_key"])
	return path_data.get("name", "")


func get_path_by_id(path_id: int) -> Dictionary:
	for path_data in active_story.get("paths", []):
		if int(path_data.get("id", 0)) == path_id:
			return path_data
	return {}


func get_current_sprint() -> Dictionary:
	var sprints: Array = active_story.get("sprints", [])
	if current_sprint_index < 0 or current_sprint_index >= sprints.size():
		return {}
	return sprints[current_sprint_index]


func get_current_quest() -> Dictionary:
	var sprint := get_current_sprint()
	var quests: Array = sprint.get("quests", [])
	if current_quest_index < 0 or current_quest_index >= quests.size():
		return {}
	return quests[current_quest_index]


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
	if active_story.is_empty():
		show_screen(home_screen)
	else:
		show_story_dashboard()


func show_custom_story_form() -> void:
	story_title_input.text = ""
	story_description_input.text = ""
	story_goal_input.text = ""
	form_message_label.text = ""
	show_screen(custom_story_screen)


func create_custom_story() -> void:
	var title := story_title_input.text.strip_edges()
	if title.is_empty():
		form_message_label.text = tr_text("error.empty_story_title")
		return

	active_story = {
		"id": next_story_id,
		"title": title,
		"description": story_description_input.text.strip_edges(),
		"goal": story_goal_input.text.strip_edges(),
		"template_id": "",
		"suggested_path_keys": [],
		"paths": [],
		"sprints": []
	}
	next_story_id += 1
	active_story_id = int(active_story["id"])
	current_sprint_index = -1
	current_quest_index = -1
	save_state()
	show_story_dashboard()


func show_template_selection() -> void:
	clear_dynamic_children(template_buttons_container)
	for story_template in story_templates:
		var button_text := "%s\n%s\n%s: %s" % [
			tr_text(story_template["title_key"]),
			tr_text(story_template["description_key"]),
			tr_text("story.goal"),
			tr_text(story_template["goal_key"])
		]
		template_buttons_container.add_child(
			make_list_button(button_text, create_story_from_template.bind(story_template))
		)
	show_screen(template_screen)


func create_story_from_template(template_data: Dictionary) -> void:
	active_story = {
		"id": next_story_id,
		"template_id": template_data["id"],
		"title": tr_text(template_data["title_key"]),
		"description": tr_text(template_data["description_key"]),
		"goal": tr_text(template_data["goal_key"]),
		"title_key": template_data["title_key"],
		"description_key": template_data["description_key"],
		"goal_key": template_data["goal_key"],
		"suggested_path_keys": template_data["suggested_path_keys"].duplicate(),
		"paths": [],
		"sprints": []
	}
	next_story_id += 1
	active_story_id = int(active_story["id"])
	current_sprint_index = -1
	current_quest_index = -1
	save_state()
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
	story_goal_label.text = "%s: %s" % [tr_text("story.goal"), localized_story_goal()]
	var story_progress := calculate_story_progress()
	story_progress_label.text = "%s: %d%%" % [tr_text("progress.story"), int(story_progress)]
	story_progress_bar.value = story_progress
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
		current_paths_list.add_child(make_progress_label(path_text, calculate_path_progress(int(path_data["id"]))))

	add_sprint_button.visible = not active_story["paths"].is_empty()
	add_sprint_hint_label.visible = active_story["paths"].is_empty()


func update_suggested_paths_list() -> void:
	clear_dynamic_children(suggested_paths_list)
	var has_available_suggestions := false
	for path_key in active_story.get("suggested_path_keys", []):
		if not has_path_key(path_key):
			has_available_suggestions = true
			suggested_paths_list.add_child(make_list_button(tr_text(path_key), add_suggested_path_and_show_dashboard.bind(path_key)))
	suggested_paths_title_label.visible = has_available_suggestions
	suggested_paths_scroll_container.visible = has_available_suggestions


func update_sprints_list() -> void:
	clear_dynamic_children(sprints_list)
	var sprints: Array = active_story.get("sprints", [])
	sprints_title_label.visible = not sprints.is_empty()
	sprints_list.visible = not sprints.is_empty()
	add_quest_button.visible = false

	if active_story.get("paths", []).is_empty():
		add_sprint_hint_label.text = tr_text("dashboard.add_path_before_sprint")
		add_sprint_hint_label.visible = true
		return

	if sprints.is_empty():
		add_sprint_hint_label.text = tr_text("dashboard.create_first_sprint")
		add_sprint_hint_label.visible = true
		return

	add_sprint_hint_label.visible = false
	if current_sprint_index == -1 and not sprints.is_empty():
		current_sprint_index = sprints.size() - 1

	for index in range(sprints.size()):
		var sprint: Dictionary = sprints[index]
		var sprint_label := "%s: %s" % [tr_text("sprint.label"), sprint.get("title", "")]
		sprints_list.add_child(make_progress_label(sprint_label, calculate_sprint_progress(sprint)))
		sprints_list.add_child(make_list_button(tr_text("sprint.select_active_paths"), show_select_active_paths.bind(index)))
		if index == current_sprint_index:
			add_current_sprint_quests(sprint)

	var current_sprint := get_current_sprint()
	add_quest_button.visible = not current_sprint.is_empty() and not current_sprint.get("active_path_ids", []).is_empty()


func add_current_sprint_quests(sprint: Dictionary) -> void:
	sprints_list.add_child(make_list_label("%s: %s" % [tr_text("dashboard.active_sprint"), sprint.get("title", "")]))
	sprints_list.add_child(make_list_label("%s: %s" % [tr_text("dashboard.active_paths"), get_active_path_names(sprint)]))
	sprints_list.add_child(make_list_label(tr_text("quest.quests")))
	var quests: Array = sprint.get("quests", [])
	if quests.is_empty():
		sprints_list.add_child(make_list_label(tr_text("dashboard.add_first_quest")))
	for quest_index in range(quests.size()):
		var quest: Dictionary = quests[quest_index]
		var button_text := "%s - %d%%" % [quest.get("title", ""), int(calculate_quest_progress(quest))]
		sprints_list.add_child(make_list_button(button_text, show_quest_detail.bind(quest_index)))
		add_quest_objective_summary(quest)

	var counts := count_objectives_for_sprint(sprint)
	sprints_list.add_child(make_list_label("%s: %d/%d" % [tr_text("dashboard.completed_objectives"), counts["completed"], counts["total"]]))
	if counts["total"] == 0 and not quests.is_empty():
		sprints_list.add_child(make_list_label(tr_text("dashboard.add_objectives")))


func add_quest_objective_summary(quest: Dictionary) -> void:
	var objectives: Array = quest.get("objectives", [])
	for objective in objectives:
		var objective_title := str(objective.get("title", ""))
		if objective.get("completed", false):
			sprints_list.add_child(make_list_label("  %s: %s" % [tr_text("objective.completed_marker"), objective_title]))
		else:
			sprints_list.add_child(make_list_label("  %s: %s" % [tr_text("dashboard.active_objectives"), objective_title]))


func get_active_path_names(sprint: Dictionary) -> String:
	var path_names := []
	for path_id in sprint.get("active_path_ids", []):
		var path_data := get_path_by_id(int(path_id))
		if not path_data.is_empty():
			path_names.append(localized_path_name(path_data))
	if path_names.is_empty():
		return tr_text("error.select_active_path")
	return ", ".join(path_names)


func count_objectives_for_sprint(sprint: Dictionary) -> Dictionary:
	var total := 0
	var completed := 0
	for quest in sprint.get("quests", []):
		for objective in quest.get("objectives", []):
			total += 1
			if objective.get("completed", false):
				completed += 1
	return {"completed": completed, "total": total}


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
			path_form_suggested_list.add_child(make_list_button(tr_text(path_key), add_suggested_path_from_form.bind(path_key)))
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
	active_story["paths"].append({"id": next_path_id, "name": clean_name, "icon": icon_text.strip_edges()})
	next_path_id += 1
	save_state()
	return true


func add_suggested_path(path_key: String) -> bool:
	if has_path_key(path_key) or has_path_name(tr_text(path_key)):
		return false
	active_story["paths"].append({"id": next_path_id, "name_key": path_key, "icon": ""})
	next_path_id += 1
	save_state()
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
	add_sprint({
		"title": sprint_title,
		"start_date": sprint_start_date_input.text.strip_edges(),
		"end_date": sprint_end_date_input.text.strip_edges()
	})


func update_sprint_template_buttons() -> void:
	clear_dynamic_children(sprint_template_buttons_container)
	for sprint_template in sprint_templates:
		var duration_text := tr_text("sprint.duration_format") % [localized_number(sprint_template["duration_days"]), tr_text("sprint.days")]
		var button_text := "%s\n%s\n%s: %s\n%s: %s" % [
			tr_text(sprint_template["title_key"]),
			tr_text(sprint_template["subtitle_key"]),
			tr_text("sprint.duration"),
			duration_text,
			tr_text("sprint.suggested_name"),
			tr_text(sprint_template["suggested_name_key"])
		]
		sprint_template_buttons_container.add_child(make_list_button(button_text, create_sprint_from_template.bind(sprint_template)))


func create_sprint_from_template(sprint_template: Dictionary) -> void:
	add_sprint({
		"title": tr_text(sprint_template["suggested_name_key"]),
		"start_date": get_date_text(0),
		"end_date": get_date_text(int(sprint_template["duration_days"]) - 1),
		"template_id": sprint_template["id"]
	})


func add_sprint(sprint_data: Dictionary) -> void:
	sprint_data["id"] = next_sprint_id
	next_sprint_id += 1
	sprint_data["active_path_ids"] = []
	sprint_data["quests"] = []
	active_story["sprints"].append(sprint_data)
	current_sprint_index = active_story["sprints"].size() - 1
	save_state()
	show_select_active_paths(current_sprint_index)


func show_select_active_paths(sprint_index: int) -> void:
	pending_sprint_index = sprint_index
	clear_dynamic_children(active_path_options_list)
	select_active_paths_message_label.text = ""
	var sprint: Dictionary = active_story["sprints"][pending_sprint_index]
	for path_data in active_story.get("paths", []):
		var check_box := CheckBox.new()
		check_box.text = localized_path_name(path_data)
		check_box.button_pressed = sprint.get("active_path_ids", []).has(path_data["id"])
		check_box.set_meta("dynamic_item", true)
		check_box.set_meta("path_id", path_data["id"])
		active_path_options_list.add_child(check_box)
	show_screen(select_active_paths_screen)


func save_active_paths_for_sprint() -> void:
	if pending_sprint_index < 0:
		show_story_dashboard()
		return
	var selected_path_ids := []
	for child in active_path_options_list.get_children():
		if child.get_meta("dynamic_item", false) and child is CheckBox and child.button_pressed:
			selected_path_ids.append(child.get_meta("path_id"))
	if selected_path_ids.is_empty():
		select_active_paths_message_label.text = tr_text("error.select_active_path")
		return
	active_story["sprints"][pending_sprint_index]["active_path_ids"] = selected_path_ids
	current_sprint_index = pending_sprint_index
	pending_sprint_index = -1
	save_state()
	show_story_dashboard()


func show_add_quest_form() -> void:
	var sprint := get_current_sprint()
	if sprint.is_empty() or sprint.get("active_path_ids", []).is_empty():
		add_sprint_hint_label.text = tr_text("error.select_active_path")
		return
	quest_title_input.text = ""
	quest_description_input.text = ""
	quest_due_date_input.text = ""
	quest_form_message_label.text = ""
	update_quest_path_selector()
	update_quest_status_selector()
	show_screen(add_quest_screen)


func update_quest_path_selector() -> void:
	quest_path_selector.clear()
	var sprint := get_current_sprint()
	for path_id in sprint.get("active_path_ids", []):
		var path_data := get_path_by_id(int(path_id))
		if not path_data.is_empty():
			quest_path_selector.add_item(localized_path_name(path_data), int(path_id))


func create_quest() -> void:
	var quest_title := quest_title_input.text.strip_edges()
	if quest_title.is_empty():
		quest_form_message_label.text = tr_text("error.empty_quest_title")
		return
	if quest_path_selector.item_count == 0:
		quest_form_message_label.text = tr_text("error.select_active_path")
		return
	var sprint: Dictionary = active_story["sprints"][current_sprint_index]
	sprint["quests"].append({
		"id": next_quest_id,
		"title": quest_title,
		"description": quest_description_input.text.strip_edges(),
		"path_id": quest_path_selector.get_selected_id(),
		"due_date": quest_due_date_input.text.strip_edges(),
		"status": quest_status_selector.selected,
		"objectives": []
	})
	next_quest_id += 1
	save_state()
	show_story_dashboard()


func show_quest_detail(quest_index: int) -> void:
	current_quest_index = quest_index
	editing_objective_index = -1
	objective_title_input.text = ""
	objective_message_label.text = ""
	update_quest_detail()
	show_screen(quest_detail_screen)


func update_quest_detail() -> void:
	var quest := get_current_quest()
	if quest.is_empty():
		show_story_dashboard()
		return
	quest_detail_title_label.text = quest.get("title", "")
	var progress := calculate_quest_progress(quest)
	quest_detail_progress_label.text = "%s: %d%%" % [tr_text("progress.quest"), int(progress)]
	quest_detail_progress_bar.value = progress
	clear_dynamic_children(objectives_list)
	var objectives: Array = quest.get("objectives", [])
	if objectives.is_empty():
		objectives_list.add_child(make_list_label(tr_text("objective.no_objectives")))
	for objective_index in range(objectives.size()):
		add_objective_row(objective_index, objectives[objective_index])


func add_objective_row(objective_index: int, objective: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.set_meta("dynamic_item", true)
	var check_box := CheckBox.new()
	check_box.text = objective.get("title", "")
	check_box.button_pressed = objective.get("completed", false)
	check_box.toggled.connect(toggle_objective.bind(objective_index))
	row.add_child(check_box)
	row.add_child(make_list_button(tr_text("objective.edit"), edit_objective.bind(objective_index)))
	row.add_child(make_list_button(tr_text("objective.delete"), delete_objective.bind(objective_index)))
	objectives_list.add_child(row)


func save_objective() -> void:
	var title := objective_title_input.text.strip_edges()
	if title.is_empty():
		objective_message_label.text = tr_text("error.empty_objective_title")
		return
	var quest: Dictionary = active_story["sprints"][current_sprint_index]["quests"][current_quest_index]
	if editing_objective_index >= 0:
		quest["objectives"][editing_objective_index]["title"] = title
		editing_objective_index = -1
	else:
		quest["objectives"].append({"id": next_objective_id, "title": title, "completed": false})
		next_objective_id += 1
	objective_title_input.text = ""
	objective_message_label.text = ""
	add_objective_button.text = tr_text("objective.add")
	save_state()
	update_quest_detail()


func edit_objective(objective_index: int) -> void:
	var quest := get_current_quest()
	editing_objective_index = objective_index
	objective_title_input.text = quest["objectives"][objective_index].get("title", "")
	add_objective_button.text = tr_text("objective.save")


func delete_objective(objective_index: int) -> void:
	var quest: Dictionary = active_story["sprints"][current_sprint_index]["quests"][current_quest_index]
	quest["objectives"].remove_at(objective_index)
	editing_objective_index = -1
	objective_title_input.text = ""
	add_objective_button.text = tr_text("objective.add")
	save_state()
	update_quest_detail()


func toggle_objective(pressed: bool, objective_index: int) -> void:
	var quest: Dictionary = active_story["sprints"][current_sprint_index]["quests"][current_quest_index]
	quest["objectives"][objective_index]["completed"] = pressed
	save_state()
	update_quest_detail()


func calculate_objective_progress(objective: Dictionary) -> float:
	return 100.0 if objective.get("completed", false) else 0.0


func calculate_quest_progress(quest: Dictionary) -> float:
	var objectives: Array = quest.get("objectives", [])
	if objectives.is_empty():
		return 0.0
	var total := 0.0
	for objective in objectives:
		total += calculate_objective_progress(objective)
	return total / objectives.size()


func calculate_sprint_progress(sprint: Dictionary) -> float:
	var quests: Array = sprint.get("quests", [])
	if quests.is_empty():
		return 0.0
	var total := 0.0
	for quest in quests:
		total += calculate_quest_progress(quest)
	return total / quests.size()


func calculate_path_progress(path_id: int) -> float:
	var path_quests := []
	for sprint in active_story.get("sprints", []):
		if sprint.get("active_path_ids", []).has(path_id):
			for quest in sprint.get("quests", []):
				if int(quest.get("path_id", 0)) == path_id:
					path_quests.append(quest)
	if path_quests.is_empty():
		return 0.0
	var total := 0.0
	for quest in path_quests:
		total += calculate_quest_progress(quest)
	return total / path_quests.size()


func calculate_story_progress() -> float:
	var paths: Array = active_story.get("paths", [])
	if paths.is_empty():
		return 0.0
	var total := 0.0
	for path_data in paths:
		total += calculate_path_progress(int(path_data["id"]))
	return total / paths.size()


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
	save_state()
	update_language_text()
	if dashboard_screen.visible:
		update_dashboard()
	elif template_screen.visible:
		show_template_selection()
	elif add_path_screen.visible:
		update_path_form_suggestions()
	elif add_sprint_screen.visible:
		update_sprint_template_buttons()
	elif add_quest_screen.visible:
		update_quest_path_selector()
	elif quest_detail_screen.visible:
		update_quest_detail()
	apply_language_direction()


func show_empty_home_without_story() -> void:
	show_home()
