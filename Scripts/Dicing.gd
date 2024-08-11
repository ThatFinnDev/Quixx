extends Control

export var useNumbers:bool=true
var maxDiceNumber : int = 0;
var dicePrefab : PackedScene = preload("res://Prefabs/Dice.tscn")
export(Resource) var railTemplate
export(StyleBoxFlat) var diceStyleBoxTemplate
	
func getMaxNumbers():
	for railDataTemplate in railTemplate.railTemplateDatas:
		var totalRows : int = 0
		for creatorData in railDataTemplate.creatorData: totalRows+=creatorData.count
		if(railDataTemplate.makeLock): totalRows+=1
		if(maxDiceNumber<totalRows):
			maxDiceNumber=totalRows
	maxDiceNumber=int(maxDiceNumber/2+0.1)
	if(maxDiceNumber>9):
		useNumbers=true
	
var colors :PoolColorArray = []
func generateDices():
	colors = []
	
	for railDataTemplate in railTemplate.railTemplateDatas:
		for data in railDataTemplate.creatorData:
			if(!colors.has(data.color)):
				colors.append(data.color)
	for color in colors:
		var entry :Label = dicePrefab.instance()
		$Grid.add_child(entry)
		var styleBoxInstance : StyleBoxFlat= diceStyleBoxTemplate.duplicate()
		styleBoxInstance.bg_color=color
		entry.remove_stylebox_override("normal")
		entry.add_stylebox_override("normal",styleBoxInstance)
	
func _ready():
	if(OS.get_name()=="HTML5"):
		$Fullscreen.show()
	getMaxNumbers()
	generateDices()
	if !useNumbers:
		for child in $Grid.get_children():
			child.text=""
			setNumber(1,child.get_children())
func dice():
	randomize()
	if useNumbers:
		for child in $Grid.get_children():
			child.text = str(randi() % maxDiceNumber+1)
	else:
		for child in $Grid.get_children():
			setNumber(randi() % maxDiceNumber+1,child.get_children())
	
func setNumber(value:int, dots:Array):
	for node in dots:
		node.hide()
	match value:
		0:
			pass
		1:
			dots[4].show()
		2:
			dots[2].show()
			dots[6].show()
		3:
			dots[2].show()
			dots[4].show()
			dots[6].show()
		4:
			dots[0].show()
			dots[2].show()
			dots[6].show()
			dots[8].show()
		5:
			dots[0].show()
			dots[2].show()
			dots[4].show()
			dots[6].show()
			dots[8].show()
		6:
			dots[0].show()
			dots[2].show()
			dots[3].show()
			dots[5].show()
			dots[6].show()
			dots[8].show()
		7:
			dots[0].show()
			dots[2].show()
			dots[3].show()
			dots[4].show()
			dots[5].show()
			dots[6].show()
			dots[8].show()
		8:
			dots[0].show()
			dots[1].show()
			dots[2].show()
			dots[3].show()
			dots[5].show()
			dots[6].show()
			dots[7].show()
			dots[8].show()
		9:
			dots[0].show()
			dots[1].show()
			dots[2].show()
			dots[3].show()
			dots[4].show()
			dots[5].show()
			dots[6].show()
			dots[7].show()
			dots[8].show()
		
	pass



func _on_Back_pressed():
	get_tree().root.get_child(0).show()
	queue_free()


func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
