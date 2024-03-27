extends PanelContainer

var bg_color = Color("#2e2a32")
var border_color = Color("#ffffff")
var text = "text"

func _ready():
	$MC/text.text = text
	var panel = StyleBoxFlat.new()
	panel.bg_color = bg_color
	panel.border_width_left = 2
	panel.border_width_top = 2
	panel.border_width_right = 2
	panel.border_width_bottom = 2
	panel.border_color = border_color
	panel.corner_radius_top_right = 10
	panel.corner_radius_bottom_right = 10
	$"."["theme_override_styles/panel"] = panel
	$AnimationPlayer.play("notification")
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "notification":
		$Timer.start()
	else:
		queue_free()

func _on_timer_timeout():
	$AnimationPlayer.play("notification_backwards")
