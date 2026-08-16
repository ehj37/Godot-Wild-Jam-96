extends Node

var _candidate_dialog_areas: Array[DialogArea]
var _dialog_box_queue: Array[DialogBox]


func register(dialog_area: DialogArea) -> void:
	_hide_interact_labels(_candidate_dialog_areas)

	_candidate_dialog_areas.append(dialog_area)
	dialog_area.display_interact_label()


func unregister(dialog_area: DialogArea) -> void:
	dialog_area.hide_interact_label()
	_candidate_dialog_areas.erase(dialog_area)

	_update_focused_dialog_area()


func _process(_delta: float) -> void:
	var in_dialog: bool = _dialog_box_queue.size() > 0
	if in_dialog:
		var active_dialog_box: DialogBox = _dialog_box_queue.front()
		if Input.is_action_pressed("interact") || Input.is_action_pressed("dialog_speed_up"):
			active_dialog_box.speed_up()
		else:
			active_dialog_box.slow_down()

		if (
			Input.is_action_just_pressed("interact")
			|| Input.is_action_just_pressed("dialog_speed_up")
		):
			if active_dialog_box.is_finished():
				active_dialog_box.reset()
				active_dialog_box.visible = false
				_dialog_box_queue.pop_front()

				if _dialog_box_queue.size() > 0:
					var new_active_dialog_box: DialogBox = _dialog_box_queue.front()
					new_active_dialog_box.visible = true
					new_active_dialog_box.start()
				else:
					_end_dialog()
	else:
		if Input.is_action_just_pressed("interact"):
			if _candidate_dialog_areas.size() > 0:
				_start_dialog()


func _start_dialog() -> void:
	var focused_dialog_area: DialogArea = _candidate_dialog_areas.back()
	focused_dialog_area.hide_interact_label()
	_dialog_box_queue = focused_dialog_area.dialog_boxes.duplicate()
	assert(_dialog_box_queue.size() > 0, "Active dialog area has no dialog boxes.")

	var active_dialog_box: DialogBox = _dialog_box_queue.front()
	active_dialog_box.visible = true
	active_dialog_box.start()


func _end_dialog() -> void:
	_update_focused_dialog_area()


func _hide_interact_labels(dialog_areas: Array[DialogArea]) -> void:
	for dialog_area: DialogArea in dialog_areas:
		dialog_area.hide_interact_label()


func _update_focused_dialog_area() -> void:
	if _candidate_dialog_areas.size() > 0:
		var new_focused_dialog_area: DialogArea = _candidate_dialog_areas.back()
		new_focused_dialog_area.display_interact_label()
		var non_focused_dialog_areas: Array[DialogArea] = _candidate_dialog_areas.filter(
			func(da: DialogArea) -> bool: return da != new_focused_dialog_area
		)
		_hide_interact_labels(non_focused_dialog_areas)
