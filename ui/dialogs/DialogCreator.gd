extends Node

const DialogBoxScene = preload("res://dialogs/DialogBox.tscn")

# { obj_name => dialog_box }
var dialogs = {}

func new_dialog_for(chara: Node) -> DialogBox:
	var box: DialogBox
	if !dialogs.has(chara.name):
		box = DialogBoxScene.instance()
		box.dialog_owner = chara
		dialogs[chara.name] = box
		add_child(box)
	else:
		box = dialogs[chara.name]
	
	return box
	

func destroy_dialog(chara: Node):
	if dialogs.has(chara.name):
		var d = dialogs[chara.name]
		remove_child(d)
		d.kill()
		d.queue_free()
		dialogs.erase(chara.name)
