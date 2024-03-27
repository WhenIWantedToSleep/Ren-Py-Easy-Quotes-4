extends Control

var files : PackedStringArray
var folder : String

var output = []
var statements = ['label', '$', 'show', 'call', 'jump', 'scene', 'stop', 'play', 'python:', 'menu:',
				'init:', 'init', '"', "'", '#', '\\',
				'pause', 'zoom', 'align', 'xalign', 'yalign',
				'xpos', 'ypos', 'linear', 'transform', 'return', 
				'if', 'elif', 'else:', 'for', 'while', 'import', 'from', 'def', 'screen', 'pass']
var character_vars = []
var ends = ['::', ';:']
var special_ends = ['<>:']
var q = '"' # "'' | quotes type

@onready var quotes_type = $MC/Vbox/Hbox/quotes/quotes_type_option
@onready var language = $MC/Vbox/Hbox/language/language_option

@onready var files_path = $MC/Vbox/files/Hbox/files_path_line
@onready var pick_files = $MC/Vbox/files/Hbox/pick_files_button
@onready var output_folder = $MC/Vbox/output/Hbox/output_path_line
@onready var pick_folder = $MC/Vbox/output/Hbox/pick_folder_button
@onready var execute_button = $MC/Vbox/MC/execute_button

var notification = preload("res://notification.tscn")

## COLORS NOTIFICATION
const c_default = Color("#ffffff")
const c_success = Color("#22bb33")
const c_error = Color("#bb2124")

var file_title = "Выберите файлы"
var foldet_title = "Выберите папку"
var done = "Готово!"
var copied = "Скопировано!"
var file_was_not_found = "Файл не найден"
var folder_was_not_found = "Папка не найдена"
var this_file_exists = "Файл с таким названием уже существует в папке "

var RUSSIAN_LANGUAGE = {
	"QuotesLabel": "Тип кавычек:",
	"LanguageLabel": "Язык программы:",
	"CharactersLabel": "Переменные персонажей (через запятую):",
	"FilePathsLabel": "Путь к файлу(-ам):",
	"OutputPathLabel": "Путь для вывода:",
	"VersionLabel": "Версия",
	"HelpLabel": "Программа предназначена для расставления кавычек в фразах внутри скриптов движка Ren'Py (*.rpy файлы).
	Необходимо выбрать файл (или файлы), в которых нужно расставить кавычки, и указать папку, куда сохранятся отредактированные файлы, указать переменные персонажей, которые не должны выделяться (e \"Привет, Мир!\": в данном случае переменной является \"e\").
	Не удаляйте старые файлы. Сначала убедитесь, что полученные из программы файлы запускаются в Ren'Py и не создают ошибок.

	Если программа выделяет непредусмотренные операторы, то создайте файл statements.txt в одной директории с программой и вставьте туда список ниже и добавьте в него необходимые операторы. Просьба написать мне (через обратную связь), если обнаружатся недостающие операторы, чтобы я мог их добавить по умолчанию в последующих дополнениях.",
	"CloseButton": "Закрыть",
	"CopyButton": "Скопировать",
	"FeedbackButton": "Обратная связь",
	"HelpButton": "Справка",
	"PickFileButton": "Выбрать",
	"PickFolderButton": "Выбрать",
	"ExecuteButton": "Выполнить",
	
	"FileTitle": "Выберите файлы",
	"FolderTitle": "Выберите папку",
	"NotificationDone": "Готово!",
	"NotificationCopied": "Скопировано",
	"FileWasNotFound": "Файл не найден",
	"FolderWasNotFound": "Папка не найдена",
	"ThisFileExists": "Файл с таким названием уже существует в папке "
}
var ENGLISH_LANGUAGE = {
	"QuotesLabel": "Type of quotation marks:",
	"LanguageLabel": "Program language:",
	"CharactersLabel": "Character variables (separated by commas):",
	"FilePathsLabel": "Path to the file(s):",
	"OutputPathLabel": "Output path:",
	"VersionLabel": "Version",
	"HelpLabel": "The program is designed to insert quotation marks in phrases inside Ren'Py scripts (*.rpy files).
	You need to select file (or files) in which you want to insert quotes, output folder and input character variables that shouldn't be highlighted (e \"Hello, World!\": in this case, the variable is \"e\").
	Don't delete input files. First, make sure that output files run in Ren'Py and don't call errors.

	If program highlights unintended statements, then create file statements.txt in the same directory with the program and paste the list below and add statements to it. If you find any missing operators, please let me know (via feedback) so that I can include them by default for future bug fixes.",
	"CloseButton": "Close",
	"CopyButton": "Copy",
	"FeedbackButton": "Feedback",
	"HelpButton": "Help",
	"PickFileButton": "Select",
	"PickFolderButton": "Select",
	"ExecuteButton": "Execute",
	
	"FileTitle": "Select files",
	"FolderTitle": "Select folder",
	"NotificationDone": "Done!",
	"NotificationCopied": "Copied",
	"FileWasNotFound": "File was not found",
	"FolderWasNotFound": "Folder was not found",
	"ThisFileExists": "File with this name already exists in the folder "
}

func notify(text : String, color : Color):
	if $".".get_child_count() > 5:
		$".".get_children()[-1].queue_free()
	var new_notification = notification.instantiate()
	new_notification.border_color = color
	new_notification.text = text
	add_child(new_notification)

func inputs_check():
	if $MC/Vbox/files/Hbox/files_path_line.text == "" or $MC/Vbox/output/Hbox/output_path_line.text == "":
		$MC/Vbox/MC/execute_button.disabled = true
	else:
		$MC/Vbox/MC/execute_button.disabled = false

func _input(event):
	if event.is_action_pressed("ENTER") and not $MC/Vbox/MC/execute_button.disabled:
		_on_execute_button_button_up()

func _ready():
	## SET 
	$help_window/MC/Vbox/ScrollContainer/PC/MC/Vbox/MC/Hbox/TextEdit.context_menu_enabled = false
	inputs_check()
	change_language(RUSSIAN_LANGUAGE)
	## QUOTES
	quotes_type.add_item('"text"')
	quotes_type.add_item("'text'")
	## LANGUAGE
	language.add_item("Русский")
	language.add_item("English")
	## PICK FILES FILTER
	$Files.set_filters(PackedStringArray(["*.rpy ; Ren'Py"]))
	## STATEMENTS
	if FileAccess.file_exists("res://statements.txt"):
		var statements_file = FileAccess.open("res://statements.txt", FileAccess.READ)
		statements = statements_file.get_as_text()

func _on_chars_line_text_changed(new_text):
	character_vars = new_text.replace(" ", "").split(",")

func _on_quotes_type_option_item_selected(index):
	if index == 0:
		q = '"'
	elif index == 1:
		q = "'"

func _on_language_option_item_selected(index):
	var language = $MC/Vbox/Hbox/language/language_option.get_item_text(index)
	if language == "Русский":
		change_language(RUSSIAN_LANGUAGE)
	elif language == "English":
		change_language(ENGLISH_LANGUAGE)
		

func change_language(lang):
	$MC/Vbox/Hbox/quotes/quotes_type_label.text = lang["QuotesLabel"]
	$MC/Vbox/Hbox/language/language_label.text = lang["LanguageLabel"]
	$MC/Vbox/characters/chars_label.text = lang["CharactersLabel"]
	$MC/Vbox/files/files_path_label.text = lang["FilePathsLabel"]
	$MC/Vbox/output/output_path_label.text = lang["OutputPathLabel"]
	$help_window/MC/Vbox/Version.text = lang["VersionLabel"] + " 4.0.0"
	$help_window/MC/Vbox/ScrollContainer/PC/MC/Vbox/text.text = lang["HelpLabel"]
	$help_window/MC/Vbox/ScrollContainer/PC/MC/Vbox/MC/Hbox/copy_button.text = lang["CopyButton"]
	$help_window/MC/Vbox/close_button.text = lang["CloseButton"]
	$MC/Vbox/additional/feedback_button.text = lang["FeedbackButton"]
	$MC/Vbox/additional/help_button.text = lang["HelpButton"]
	pick_files.text = lang["PickFileButton"]
	pick_folder.text = lang["PickFolderButton"]
	execute_button.text = lang["ExecuteButton"]
	file_title = lang["FileTitle"]
	foldet_title = lang["FolderTitle"]
	done = lang["NotificationDone"]
	copied = lang["NotificationCopied"]
	file_was_not_found = lang["FileWasNotFound"]
	folder_was_not_found = lang["FolderWasNotFound"]
	this_file_exists = lang["ThisFileExists"]

func _on_pick_files_button_button_up():
	$Files.title = file_title
	$Files.popup()


func _on_pick_folder_button_button_up():
	$Folder.title = foldet_title
	$Folder.popup()


func _on_folder_dir_selected(dir):
	folder = dir
	output_folder.text = dir
	inputs_check()


func _on_files_files_selected(paths):
	files_path.text = "".join(paths)
	files = paths
	inputs_check()


func _on_execute_button_button_up():
	if not DirAccess.dir_exists_absolute(folder):
		notify(folder_was_not_found, c_error)
	else:
		for file in files:
			if not FileAccess.file_exists(file):
				notify(file_was_not_found, c_error)
				break
			if FileAccess.file_exists(folder+"\\"+file.get_file()):
				notify(this_file_exists+folder+"\\"+file.get_file(), c_error)
				break
			execute_main(file)


func _on_output_path_line_text_changed(new_text):
	folder = new_text
	inputs_check()


func _on_files_path_line_text_changed(new_text):
	var text = new_text.replace(" ", "")
	text = text.split(",")
	files = text
	inputs_check()


func _on_close_button_button_up():
	$help_window.hide()


func _on_help_button_button_up():
	$help_window.show()


func _on_copy_button_button_up():
	notify(copied, c_success)
	$help_window/MC/Vbox/ScrollContainer/PC/MC/Vbox/MC/Hbox/TextEdit.copy()

##### MAIN #####
	
func _check(word : String, mode : int): 
	
	##|> Return:
	#|    True - highlight;
	#|    False - don't highlight
	##|> Mode: 
	#|    0 - line without character var; 
	#|    1 - line with character var
	
	if mode == 0:
		if word in statements or word[0] in statements:
			return false
	elif mode == 1:
		if word[0] in statements:
			return false
	return true

func execute_main(path : String):
	var input_file = FileAccess.open(path, FileAccess.READ)
	
	while not input_file.eof_reached():
		var input_line = input_file.get_line()
		var line = input_line.strip_edges()
		var indentation = len(input_line) - len(line)
		var words = line.split(" ")
		if line != "":
			if words[0] in character_vars and _check(words[0], 0):
				var char_var = words[0]+" "
				words.remove_at(0)
				line = " ".join(words)
				if _check(line, 1):
					output.append((" ".repeat(indentation))+char_var+q+line+q)
				else:
					output.append((" ".repeat(indentation))+char_var+line)
					
			elif _check(words[0], 0) and words[-1].right(2) != '()':
				if words[-1].right(2) in ends:
					output.append((' '.repeat(indentation))+q+line.left(-1)+q+':')
				elif words[-1].right(3) in special_ends:
					output.append((' '.repeat(indentation))+q+line.left(-3)+q+':')
				else:
					output.append((' '.repeat(indentation))+q+line+q)
			else:
				output.append((" ".repeat(indentation))+line)
		else:
			output.append(line)
	input_file.close()
	var file = folder+"\\"+path.get_file()
	if DirAccess.dir_exists_absolute(file):
		DirAccess.make_dir_absolute(file)
	var output_file = FileAccess.open(file, FileAccess.WRITE)
	for item in output:
		output_file.store_string(item+"\n")
	output_file.close()
	
	notify(done, c_success)







