extends Control

var current_checks: int setget set_current_checks
export var total_checks: int setget set_total_checks
export var icon: Texture

var notes_tab: HSplitContainer

onready var notes_tab_scene: PackedScene = preload("res://src/GUI/NotesTab.tscn")
onready var item_note_scene: PackedScene = preload("res://src/GUI/ItemNote.tscn")
onready var label: Label = $Label

func _ready() -> void:
	update_label()
#	$Texture.texture_normal = icon
	$Texture.texture = icon
	notes_tab = notes_tab_scene.instance()
	notes_tab.attach_notes(self)
	Events.connect("marker_clicked", self, "_on_marker_clicked")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			Events.emit_signal("mode_changed", Util.MODE_DUNGEON)
			Events.emit_signal("notes_clicked", notes_tab)
		elif event.button_index == BUTTON_RIGHT:
			current_checks = current_checks + 1
			if current_checks > total_checks:
				current_checks = total_checks
			set_current_checks(current_checks)

func update_label() -> void:
	label.text = "%d/%d" % [current_checks, total_checks]

func set_current_checks(value: int) -> void:
	current_checks = value
	notes_tab.current_slider.value = current_checks
	if label:
		update_label()

func set_total_checks(value: int) -> void:
	total_checks = value
	if label:
		update_label()

func _current_checks_changed(value: int) -> void:
	current_checks = value
	if current_checks > total_checks:
		current_checks = total_checks
		notes_tab.current_slider.value = total_checks
	if label:
		update_label()

func _total_checks_changed(value: int) -> void:
	total_checks = value
	if label:
		update_label()

func _on_marker_clicked(texture: Texture, _color: Color, _connector: String) -> void:
	if Util.mode != Util.MODE_DUNGEON:
		return
	if !notes_tab.is_inside_tree():
		return

	var item_note = item_note_scene.instance()
	notes_tab.item_container.add_child(item_note)
	item_note.set_item(texture)
