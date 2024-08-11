extends Control

export var useNumbers:bool=true
var maxDiceNumber : int = 0;
var dicePrefab : PackedScene = preload("res://Prefabs/Dice.tscn")
export(Resource) var railTemplate
export(StyleBoxFlat) var diceStyleBoxTemplate
	
var stateToLoad :SaveState = null


func loadState(state:SaveState):
	if(ready):
		stateToLoad=null
		$Sheet.loadState(state)
		var i : int = -1
		for child in $Dices.get_children():
			if(child.name=="Back"): continue
			i+=1
			child.text=""
			if(useNumbers):child.text=str(state.virtualDices[i])
			else: setNumber(state.virtualDices[i],child.get_children())
		virtualDices = state.virtualDices
	else:
		_ready()
		stateToLoad=state
	

func _process(delta):
	if(stateToLoad!=null):
		loadState(stateToLoad)

var virtualDices : Array = []
func saveState() -> SaveState:
	return $Sheet.saveState(virtualDices)

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
	
func generateDices():
	for railDataTemplate in railTemplate.railTemplateDatas:
		var entry :Label = dicePrefab.instance()
		$Dices.add_child(entry)
		var styleBoxInstance : StyleBoxFlat= diceStyleBoxTemplate.duplicate()
		styleBoxInstance.bg_color=railDataTemplate.creatorData[railDataTemplate.creatorData.size()-1].color
		entry.remove_stylebox_override("normal")
		entry.add_stylebox_override("normal",styleBoxInstance)
	
var ready : bool = false
func _ready():
	if(ready):return
	if(OS.get_name()=="HTML5"):
		$HBoxContainer/Fullscreen.show()
	getMaxNumbers()
	generateDices()
	if !useNumbers:
		for child in $Dices.get_children():
			if(child.name=="Back"): continue
			child.text=""
			setNumber(1,child.get_children())
	ready=true
func dice():
	virtualDices=[]
	randomize()
	if useNumbers:
		for child in $Dices.get_children():
			if(child.name=="Back"): continue
			var number : int = randi() % maxDiceNumber+1
			virtualDices.append(number)
			child.text = str(number)
	else:
		for child in $Dices.get_children():
			if(child.name=="Back"): continue
			child.text=""
			var number : int = randi() % maxDiceNumber+1
			virtualDices.append(number)
			setNumber(number,child.get_children())
	
func setNumber(value:int, dots:Array):
	
	print(value)
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


func convertSaveStateToJSON(state:SaveState) -> String:
	var dictionary : Dictionary = {
	"m": state.mapName,
	"n": state.name,
	"v": state.virtualDices,
	"f" : state.fails,
	"l" : state.luckNumbers,
	"e" : state.entries
	}
	var output : String = JSON.print(dictionary)
	#print(output)
	return output
func _on_Back_pressed():
	get_tree().root.get_child(0).savedGames.append(convertSaveStateToJSON(saveState()))
	get_tree().root.get_child(0)._save()
	get_tree().root.get_child(0).show()
	queue_free()

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
