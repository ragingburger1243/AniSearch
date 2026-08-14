extends Button

class_name AnimatedButton

const rest_scale := Vector2.ONE
const hover_scale := Vector2(1.2, 1.2)
const squash_scale := Vector2(0.9, 0.9)

var _tween: Tween = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	pivot_offset = size / 2
	

func _on_mouse_entered() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"scale", hover_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)


func _on_mouse_exited() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"scale", rest_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)


func _on_button_down() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, ^"scale", squash_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	_tween.tween_property(self, ^"scale", hover_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
