@tool
extends Node

const LINE_FOUND_MAX:= 5

signal progress_updated(index: int, total: int)
signal file_found(file: SearchEverywhere.File)

static var text_suffixes = [".txt", ".tscn", ".tres", ".json", ".csv", ".xml", ".properties", ".md"]

var thread:= Thread.new()
var options: SearchEverywhere.Options
var new_search: bool
var in_dirs: Array[String]
var in_dir_index: int
var in_files: Array[SearchEverywhere.File]
var in_file_index: int
var scanned_files: Dictionary[String, SearchEverywhere.File] # To merge files match both name and content.
var semaphore:= Semaphore.new()
var mutex:= Mutex.new()
var progress_index: int
var progress_total: int
var stopped: bool

func search(options: SearchEverywhere.Options) -> void:
	mutex.lock()
	self.options = options
	new_search = true
	in_dirs.clear()
	in_dir_index = 0
	in_files.clear()
	in_file_index = 0
	scanned_files.clear()
	progress_index = 0
	progress_total = 0
	mutex.unlock()
	semaphore.post()

func stop() -> void:
	stopped = true
	semaphore.post()
	thread.wait_to_finish()

func _ready() -> void:
	thread.start(_work, Thread.PRIORITY_LOW)

func _work() -> void:
	while not stopped:
		semaphore.wait()
		if new_search and options.keyword:
			new_search = false
			_scan_dirs("")
			progress_total = in_dirs.size() + in_files.size()
			_search_in_dirs()
			_search_in_files()

func _scan_dirs(dir_path: String) -> void:
	if stopped or new_search:
		return
	var dir:= DirAccess.open("res://%s" % dir_path)
	if dir:
		if dir_path.begins_with("/addons/") and not options.addons:
			return
		in_dirs.append(dir_path)
		for f in dir.get_files():
			if _is_ignored(f):
				continue
			if options.searchInFiles and _is_text(f):
				mutex.lock()
				var file:= SearchEverywhere.File.new(dir_path, f)
				in_files.append(file)
				scanned_files[file.full_path] = file
				mutex.unlock()
		for sub_path in dir.get_directories():
			if not sub_path.begins_with("."):
				_scan_dirs("%s/%s" % [dir_path, sub_path])

func _search_in_dirs() -> void:
	while not stopped and not new_search:
		await get_tree().process_frame
		var dir_path: String
		var dir_next:= true # Cannot use dir_path as "" means root directory.
		mutex.lock()
		if in_dir_index < in_dirs.size():
			dir_path = in_dirs[in_dir_index]
			in_dir_index += 1
		else:
			dir_next = false
		mutex.unlock()
		if dir_next:
			progress_index += 1
			call_deferred("_emit_progress_updated", progress_index, progress_total)
			var dir:= DirAccess.open("res://%s" % dir_path)
			if dir:
				for f in dir.get_files():
					if _is_ignored(f):
						continue
					if f.containsn(options.keyword):
						var file = SearchEverywhere.File.new(dir_path, f)
						if file.full_path in scanned_files:
							file = scanned_files[file.full_path]
						file.keyword = options.keyword
						call_deferred("_emit_file_found", file)
		else:
			break

func _search_in_files() -> void:
	while not stopped and not new_search:
		await get_tree().process_frame
		var file: SearchEverywhere.File
		mutex.lock()
		if in_file_index < in_files.size():
			file = in_files[in_file_index]
			in_file_index += 1
		mutex.unlock()
		if file:
			progress_index += 1
			call_deferred("_emit_progress_updated", progress_index, progress_total)
			var keyword:= options.keyword
			if keyword:
				var fa = FileAccess.open("res://%s" % file.full_path, FileAccess.READ)
				var ln = 0
				while not fa.eof_reached():
					var line:= fa.get_line()
					ln += 1
					if line.containsn(keyword):
						if file.lines.size() < LINE_FOUND_MAX:
							file.keyword = keyword
							file.lines[ln] = line
							call_deferred("_emit_file_found", file)
						else:
							file.lines_more = true
							call_deferred("_emit_file_found", file)
							break
				fa.close()
			else:
				break
		else:
			break

func _is_ignored(filename: String) -> bool:
	if filename.ends_with(".uid") and not options.uid:
		return true
	if filename.ends_with(".import") and not options.import:
		return true
	return false

func _is_text(filename: String) -> bool:
	var lower:= filename.to_lower()
	for s in text_suffixes:
		if lower.ends_with(s):
			return true
	return false

func _emit_progress_updated(index: int, total: int) -> void:
	progress_updated.emit(index, total)

func _emit_file_found(file: SearchEverywhere.File) -> void:
	file_found.emit(file)
