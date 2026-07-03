extends Control

const LANGUAGE_ENGLISH := "en"
const LANGUAGE_PERSIAN := "fa"

var current_language := LANGUAGE_ENGLISH
var active_story := {}

var story_templates := [
	{
		"id": "starting_over",
		"title": "Starting Over",
		"description": "Rebuild your life step by step after a difficult change.",
		"suggested_paths": ["Health & Fitness", "Learning", "Income", "Family", "Creation", "Rest"]
	},
	{
		"id": "first_product",
		"title": "Build My First Product",
		"description": "Turn an idea into a small usable product through focused sprints.",
		"suggested_paths": ["Product", "Learning", "Marketing", "Income", "Health & Fitness", "Rest"]
	},
	{
		"id": "health_reset",
		"title": "Health Reset",
		"description": "Improve energy, fitness, sleep, and daily discipline.",
		"suggested_paths": ["Health & Fitness", "Nutrition", "Sleep", "Mindset", "Rest"]
	},
	{
		"id": "learning_sprint",
		"title": "Learning Sprint",
		"description": "Learn a new skill through daily practice and measurable progress.",
		"suggested_paths": ["Study", "Practice", "Projects", "Review", "Rest"]
	},
	{
		"id": "career_comeback",
		"title": "Career Comeback",
		"description": "Improve your resume, apply for jobs, prepare for interviews, and rebuild professional momentum.",
		"suggested_paths": ["Resume", "Applications", "Interview Practice", "Learning", "Income", "Health & Fitness"]
	}
]

var text := {
	LANGUAGE_ENGLISH: {
		"app_title": "QuestBoard",
		"empty_message": "No story yet. Create your first story to begin your journey.",
		"create_custom_story": "Create Custom Story",
		"start_from_template": "Start From Template",
		"settings": "Settings",
		"story_title": "Story title",
		"story_description": "Story description",
		"create": "Create",
		"cancel": "Cancel",
		"choose_template": "Choose a Story Template",
		"suggested_paths": "Suggested paths",
		"add_path": "Add Path",
		"back_to_home": "Back to Home",
		"language": "App language",
		"english": "English",
		"persian": "Persian",
		"empty_title_error": "Please enter a story title.",
		"path_placeholder": "Path creation will come later."
	},
	LANGUAGE_PERSIAN: {
		"app_title": "کوئست‌بورد",
		"empty_message": "هنوز داستانی وجود ندارد. اولین داستان خود را بسازید و مسیرتان را آغاز کنید.",
		"create_custom_story": "ساخت داستان دلخواه",
		"start_from_template": "شروع با قالب آماده",
		"settings": "تنظیمات",
		"story_title": "عنوان داستان",
		"story_description": "توضیح داستان",
		"create": "ساخت",
		"cancel": "لغو",
		"choose_template": "یک قالب داستان انتخاب کنید",
		"suggested_paths": "مسیرهای پیشنهادی",
		"add_path": "افزودن مسیر",
		"back_to_home": "بازگشت به خانه",
		"language": "زبان برنامه",
		"english": "انگلیسی",
		"persian": "فارسی",
		"empty_title_error": "لطفا عنوان داستان را وارد کنید.",
		"path_placeholder": "ساخت مسیر در مرحله بعد اضافه می‌شود."
	}
}

@onready var screen_container: CenterContainer = $ScreenContainer
@onready var content_box: VBoxContainer = $ScreenContainer/ContentBox


func _ready() -> void:
	show_home()


func tr_text(key: String) -> String:
	return text[current_language][key]


func clear_screen() -> void:
	for child in content_box.get_children():
		child.queue_free()


func apply_language_direction() -> void:
	if current_language == LANGUAGE_PERSIAN:
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
	button.custom_minimum_size = Vector2(320, 44)
	button.pressed.connect(pressed_action)
	content_box.add_child(button)
	return button


func show_home() -> void:
	clear_screen()
	apply_language_direction()

	add_label("TitleLabel", tr_text("app_title"), 32)

	if active_story.is_empty():
		add_label("EmptyStateLabel", tr_text("empty_message"), 16)
		add_button("CreateCustomStoryButton", tr_text("create_custom_story"), show_custom_story_form)
		add_button("StartFromTemplateButton", tr_text("start_from_template"), show_template_selection)
		add_button("SettingsButton", tr_text("settings"), show_settings)
	else:
		show_story_dashboard()


func show_custom_story_form() -> void:
	clear_screen()
	apply_language_direction()

	add_label("FormTitleLabel", tr_text("create_custom_story"), 28)

	var title_input := LineEdit.new()
	title_input.name = "StoryTitleInput"
	title_input.placeholder_text = tr_text("story_title")
	title_input.custom_minimum_size = Vector2(360, 44)
	content_box.add_child(title_input)

	var description_input := TextEdit.new()
	description_input.name = "StoryDescriptionInput"
	description_input.placeholder_text = tr_text("story_description")
	description_input.custom_minimum_size = Vector2(360, 110)
	content_box.add_child(description_input)

	var message_label := add_label("FormMessageLabel", "", 14)

	add_button(
		"CreateStoryButton",
		tr_text("create"),
		func() -> void:
			var title := title_input.text.strip_edges()
			if title.is_empty():
				message_label.text = tr_text("empty_title_error")
				return

			active_story = {
				"title": title,
				"description": description_input.text.strip_edges(),
				"suggested_paths": []
			}
			show_story_dashboard()
	)

	add_button("CancelButton", tr_text("cancel"), show_home)


func show_template_selection() -> void:
	clear_screen()
	apply_language_direction()

	add_label("TemplateTitleLabel", tr_text("choose_template"), 28)

	for story_template in story_templates:
		var template_button_text := "%s\n%s" % [story_template["title"], story_template["description"]]
		add_button(
			"TemplateButton_%s" % story_template["id"],
			template_button_text,
			create_story_from_template.bind(story_template)
		)

	add_button("CancelButton", tr_text("cancel"), show_home)


func create_story_from_template(template_data: Dictionary) -> void:
	active_story = {
		"title": template_data["title"],
		"description": template_data["description"],
		"suggested_paths": template_data["suggested_paths"].duplicate()
	}
	show_story_dashboard()


func show_story_dashboard() -> void:
	clear_screen()
	apply_language_direction()

	add_label("StoryTitleLabel", active_story["title"], 30)
	add_label("StoryDescriptionLabel", active_story["description"], 16)
	add_label("SuggestedPathsTitleLabel", tr_text("suggested_paths"), 20)

	for path_name in active_story["suggested_paths"]:
		add_label("PathLabel_%s" % path_name.replace(" ", "_"), "- %s" % path_name, 16)

	var message_label := add_label("DashboardMessageLabel", "", 14)
	add_button(
		"AddPathButton",
		tr_text("add_path"),
		func() -> void:
			message_label.text = tr_text("path_placeholder")
	)
	add_button("BackToHomeButton", tr_text("back_to_home"), show_empty_home_without_story)


func show_empty_home_without_story() -> void:
	active_story = {}
	show_home()


func show_settings() -> void:
	clear_screen()
	apply_language_direction()

	add_label("SettingsTitleLabel", tr_text("settings"), 28)
	add_label("LanguageLabel", tr_text("language"), 18)

	var language_selector := OptionButton.new()
	language_selector.name = "LanguageSelector"
	language_selector.custom_minimum_size = Vector2(320, 44)
	language_selector.add_item(tr_text("english"))
	language_selector.add_item(tr_text("persian"))
	language_selector.selected = 1 if current_language == LANGUAGE_PERSIAN else 0
	language_selector.item_selected.connect(
		func(index: int) -> void:
			current_language = LANGUAGE_PERSIAN if index == 1 else LANGUAGE_ENGLISH
			show_settings()
	)
	content_box.add_child(language_selector)

	add_button("BackToHomeButton", tr_text("back_to_home"), show_home)
