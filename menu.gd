extends Control




func _on_normal_tic_tac_toe_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_super_tic_tac_toe_pressed():
	get_tree().change_scene_to_file("res://supertictactoe.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
