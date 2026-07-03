extends RefCounted

const ENGLISH := "en"
const PERSIAN := "fa"

var current_language := ENGLISH

var translations := {
	ENGLISH: {
		"app.title": "QuestBoard",
		"home.empty_message": "No story yet. Create your first story to begin your journey.",
		"home.create_custom_story": "Create Custom Story",
		"home.start_from_template": "Start From Template",
		"home.settings": "Settings",
		"story.title_placeholder": "Story title",
		"story.description_placeholder": "Story description",
		"story.create": "Create",
		"common.cancel": "Cancel",
		"common.back_to_home": "Back to Home",
		"template.choose": "Choose a Story Template",
		"dashboard.current_paths": "Current paths",
		"dashboard.suggested_paths": "Suggested paths",
		"dashboard.no_paths": "No paths yet. Add your first path to shape this story.",
		"dashboard.add_path": "Add Path",
		"dashboard.add_sprint": "Add Sprint",
		"dashboard.add_path_before_sprint": "Add at least one path before creating a sprint.",
		"dashboard.sprints": "Sprints",
		"settings.title": "Settings",
		"settings.language": "App language",
		"settings.english": "English",
		"settings.persian": "Persian",
		"error.empty_story_title": "Please enter a story title.",
		"error.empty_path_name": "Please enter a path name.",
		"error.empty_sprint_title": "Please enter a sprint title.",
		"error.duplicate_path": "This path already exists.",
		"path.name_placeholder": "Path name",
		"path.icon_placeholder": "Icon text, optional",
		"path.create": "Create Path",
		"path.add_from_suggestions": "Add from suggested paths",
		"sprint.title_placeholder": "Sprint title",
		"sprint.start_date_placeholder": "Start date",
		"sprint.end_date_placeholder": "End date",
		"sprint.create": "Create Sprint",
		"template.starting_over.title": "Starting Over",
		"template.starting_over.description": "Rebuild your life step by step after a difficult change.",
		"template.build_my_first_product.title": "Build My First Product",
		"template.build_my_first_product.description": "Turn an idea into a small usable product through focused sprints.",
		"template.health_reset.title": "Health Reset",
		"template.health_reset.description": "Improve energy, fitness, sleep, and daily discipline.",
		"template.learning_sprint.title": "Learning Sprint",
		"template.learning_sprint.description": "Learn a new skill through daily practice and measurable progress.",
		"template.career_comeback.title": "Career Comeback",
		"template.career_comeback.description": "Improve your resume, apply for jobs, prepare for interviews, and rebuild professional momentum.",
		"path.health_fitness": "Health & Fitness",
		"path.learning": "Learning",
		"path.income": "Income",
		"path.family": "Family",
		"path.creation": "Creation",
		"path.rest": "Rest",
		"path.product": "Product",
		"path.marketing": "Marketing",
		"path.nutrition": "Nutrition",
		"path.sleep": "Sleep",
		"path.mindset": "Mindset",
		"path.study": "Study",
		"path.practice": "Practice",
		"path.projects": "Projects",
		"path.review": "Review",
		"path.resume": "Resume",
		"path.applications": "Applications",
		"path.interview_practice": "Interview Practice"
	},
	PERSIAN: {
		"app.title": "کوئست‌بورد",
		"home.empty_message": "هنوز داستانی وجود ندارد. اولین داستان خود را بسازید و مسیرتان را آغاز کنید.",
		"home.create_custom_story": "ساخت داستان دلخواه",
		"home.start_from_template": "شروع با قالب آماده",
		"home.settings": "تنظیمات",
		"story.title_placeholder": "عنوان داستان",
		"story.description_placeholder": "توضیح داستان",
		"story.create": "ساخت",
		"common.cancel": "لغو",
		"common.back_to_home": "بازگشت به خانه",
		"template.choose": "یک قالب داستان انتخاب کنید",
		"dashboard.current_paths": "مسیرهای فعلی",
		"dashboard.suggested_paths": "مسیرهای پیشنهادی",
		"dashboard.no_paths": "هنوز مسیری ساخته نشده است. اولین مسیر را برای شکل دادن به این داستان اضافه کنید.",
		"dashboard.add_path": "افزودن مسیر",
		"dashboard.add_sprint": "افزودن اسپرینت",
		"dashboard.add_path_before_sprint": "قبل از ساخت اسپرینت، حداقل یک مسیر اضافه کنید.",
		"dashboard.sprints": "اسپرینت‌ها",
		"settings.title": "تنظیمات",
		"settings.language": "زبان برنامه",
		"settings.english": "انگلیسی",
		"settings.persian": "فارسی",
		"error.empty_story_title": "لطفا عنوان داستان را وارد کنید.",
		"error.empty_path_name": "لطفا نام مسیر را وارد کنید.",
		"error.empty_sprint_title": "لطفا عنوان اسپرینت را وارد کنید.",
		"error.duplicate_path": "این مسیر از قبل وجود دارد.",
		"path.name_placeholder": "نام مسیر",
		"path.icon_placeholder": "متن آیکون، اختیاری",
		"path.create": "ساخت مسیر",
		"path.add_from_suggestions": "افزودن از مسیرهای پیشنهادی",
		"sprint.title_placeholder": "عنوان اسپرینت",
		"sprint.start_date_placeholder": "تاریخ شروع",
		"sprint.end_date_placeholder": "تاریخ پایان",
		"sprint.create": "ساخت اسپرینت",
		"template.starting_over.title": "شروع دوباره",
		"template.starting_over.description": "اگه بعد از یک تغییر سخت می‌خوای دوباره خودت رو جمع‌وجور کنی و قدم‌به‌قدم برگردی به مسیر، این قالب برای توئه. از عادت‌های ساده شروع کن، مسیرهای مهم زندگیت رو مشخص کن و کم‌کم دوباره ریتمت رو بساز.",
		"template.build_my_first_product.title": "ساخت اولین محصول",
		"template.build_my_first_product.description": "اگه یه ایده توی ذهنت داری و می‌خوای تبدیلش کنی به یک محصول کوچک و قابل استفاده، این قالب کمکت می‌کنه مرحله‌به‌مرحله جلو بری؛ از یادگیری و ساخت گرفته تا تست، بازخورد و بهتر کردن محصول.",
		"template.health_reset.title": "بازسازی سلامت",
		"template.health_reset.description": "اگه حس می‌کنی انرژی، خواب، ورزش یا نظم روزانه‌ات از مسیر خارج شده، این قالب کمک می‌کنه دوباره بدنت و ذهنت رو تنظیم کنی و با قدم‌های کوچک ولی واقعی به وضعیت بهتر برسی.",
		"template.learning_sprint.title": "اسپرینت یادگیری",
		"template.learning_sprint.description": "اگه می‌خوای یک مهارت جدید رو جدی یاد بگیری، این قالب برای اینه که فقط دوره نبینی و رهاش نکنی. یاد می‌گیری، تمرین می‌کنی، پروژه می‌سازی و پیشرفتت رو قابل اندازه‌گیری می‌کنی.",
		"template.career_comeback.title": "بازگشت شغلی",
		"template.career_comeback.description": "اگه می‌خوای دوباره با قدرت وارد مسیر کاری بشی، این قالب کمکت می‌کنه رزومه‌ات رو بهتر کنی، برای فرصت‌های مناسب اقدام کنی، برای مصاحبه آماده بشی و قدم‌به‌قدم momentum حرفه‌ای بسازی.",
		"path.health_fitness": "ورزش و سلامتی",
		"path.learning": "یادگیری",
		"path.income": "درآمد",
		"path.family": "خانواده",
		"path.creation": "ساختن و خلق کردن",
		"path.rest": "استراحت",
		"path.product": "محصول",
		"path.marketing": "بازاریابی",
		"path.nutrition": "تغذیه",
		"path.sleep": "خواب",
		"path.mindset": "ذهنیت",
		"path.study": "مطالعه",
		"path.practice": "تمرین",
		"path.projects": "پروژه‌ها",
		"path.review": "مرور",
		"path.resume": "رزومه",
		"path.applications": "ارسال درخواست",
		"path.interview_practice": "تمرین مصاحبه"
	}
}


func set_language(language: String) -> void:
	if translations.has(language):
		current_language = language


func get_language() -> String:
	return current_language


func is_rtl() -> bool:
	return current_language == PERSIAN


func text(key: String) -> String:
	if translations[current_language].has(key):
		return translations[current_language][key]

	return key
