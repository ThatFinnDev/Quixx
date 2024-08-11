class_name Main extends Control

#TODO:
#Make Create menu (to create layouts)

var createdLevels : Array = []
var customLevelResources : Array = []
var savedGames : Array = []
var sheetPrefab : PackedScene = preload("res://Scenes/QuixxPaperScene.tscn")
var dicePrefab : PackedScene = preload("res://Scenes/Dices.tscn")
var virtualDicePrefab : PackedScene = preload("res://Scenes/VirtualDice.tscn")
var selectSheetPrefab : PackedScene = preload("res://Prefabs/SelectSheet.tscn")
var selectStatePrefab : PackedScene = preload("res://Prefabs/SelectState.tscn")
var managePrefab : PackedScene = preload("res://Prefabs/ManageEntry.tscn")
var creatorPrefab : PackedScene = preload("res://Prefabs/LayoutCreator.tscn")
var whereisMain:int=0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Array, Resource) var defaultTemplates
var selectedThing : int = -1

const currMapVer : String = "1.4.5"

func AddCustomLevel(_level:String):
	var saveStates : PoolStringArray = []
	var level : String = _level
	var wasConflicting : bool = false
	var tmp = loadJsonAsSheet(level)
	var conflictingName : bool = true
	while conflictingName:
		conflictingName=false
		for resource in customLevelResources:
			if(resource.name == tmp.name):
				conflictingName=true
				wasConflicting=true
		for resource in defaultTemplates:
			if(resource.name == tmp.name):
				conflictingName=true
				wasConflicting=true
		if(conflictingName):
			tmp.name+="copy"
	if(wasConflicting):
		level=saveResourceAsJson(tmp)
	createdLevels.append(level)
	_save()
	get_tree().root.add_child((load("res://Scenes/Main.tscn")).instance())
	queue_free()
func loadJsonAsSheet(json:String) -> Resource:
	var parseResult : JSONParseResult = JSON.parse(json)
	if(parseResult.error==0):
		if(true):
			var sheetDictionary :Dictionary = parseResult.result
			var railTemplate = RailTemplate.new()
			if(sheetDictionary.get("v","")==currMapVer):
				railTemplate.name = sheetDictionary.get("n","NoName")
				railTemplate.maxFailButtons = sheetDictionary.get("m",4)
				railTemplate.useLuckNumbers = sheetDictionary.get("u",false)
				railTemplate.combineLastTwo = sheetDictionary.get("c",false)
				var railsArray :Array = sheetDictionary.get("r",[])
				if(railsArray!=null):
					var rails : Array = []
					for entry in railsArray:
						var railTemplateData : RailTemplateData = RailTemplateData.new()
						railTemplateData.reverseLayout=entry.get("r",true)
						railTemplateData.makeLock=entry.get("m",true)
						var creatorDataArray : Array = entry.get("c",[])
						var creatorDatas : Array = []
						if(creatorDataArray!=null):
							for cEntry in creatorDataArray:
								var creatorData : RailEntryCreatorData = RailEntryCreatorData.new()
								creatorData.color=Color8(cEntry.get("r",0),cEntry.get("g",0),cEntry.get("b",0),255)
								creatorData.count=cEntry.get("c",0)
								if(cEntry.has("o")):
									creatorData.customNumbers = PoolIntArray(cEntry.get("o"))
								creatorDatas.append(creatorData)
						railTemplateData.creatorData=creatorDatas
						rails.append(railTemplateData)
					railTemplate.railTemplateDatas=rails
				return railTemplate
	return null

func saveResourceAsJson(resource:Resource) -> String:
	var rails : Array = []
	for railTemplateData in resource.railTemplateDatas:
		var creatorData : Array = []
		for creatorD in railTemplateData.creatorData:
			var data : Dictionary
			if(Array(creatorD.customNumbers)==[]):
				data = {
				"r":creatorD.color.r8,
				"g":creatorD.color.g8,
				"b":creatorD.color.b8,
				"c":creatorD.count,
				}
			else:
				data = {
				"r":creatorD.color.r8,
				"g":creatorD.color.g8,
				"b":creatorD.color.b8,
				"c":creatorD.count,
				"o":Array(creatorD.customNumbers)
			}
			creatorData.append(data)
		var rail : Dictionary = {
			"r":railTemplateData.reverseLayout,
			"m":railTemplateData.makeLock,
			"c":creatorData
		}
		rails.append(rail)
	
	var dictionary : Dictionary = {
	"n": resource.name,
	"m": resource.maxFailButtons,
	"u" : resource.useLuckNumbers,
	"c" : resource.combineLastTwo,
	"v" : currMapVer,
	"r" : rails
	}
	var output : String = JSON.print(dictionary)
	#print(output)
	return output

func getSelectedThing() -> int:
	var i : int = -1
	for button in $SelectThing/SelectThing/Container.get_children():
		i+=1
		if(button.pressed):
			return i
	return -1

func checkSelectedThing():
	selectedThing = getSelectedThing()
	if(selectedThing!=-1):
		_on_PlayChoices_pressed()
		
func _on_latestverrequest_complete(result, response_code, headers, body):
	if(result==HTTPRequest.RESULT_SUCCESS):
		var newVer :String = body.get_string_from_utf8()
		newVer = newVer.replace("\n","").replace(" ","")
		if(newVer!="404: Not Found"):
			if(newVer!=$Main/HBoxContainer/Label.text.split(" ")[1]):
				$Main/HBoxContainer/Latest.text="\nNewest: "+newVer

func removeUnusableSheets():
	var newSavedGames = []
	var currTimeStamp : float = Time.get_unix_time_from_system()
	for savedGame in savedGames:
		var saveState : SaveState = convertJSONToSaveState(savedGame)
		#check if level still exists
		var partOnePassed : bool = false
		for resource in defaultTemplates:
			if(resource.name==saveState.mapName):
				partOnePassed=true
		if(!partOnePassed):
			for resource in customLevelResources:
				if(resource.name==saveState.mapName):
					partOnePassed=true
		if(!partOnePassed):
			break
		#check if older than 7 days
		var oldTimeStamp : float = float(saveState.name)
		if(currTimeStamp-oldTimeStamp>604800):
			break		
		newSavedGames.append(savedGame)
		
	savedGames=newSavedGames
	_save()
	

func _ready():
	_load()
	if(OS.get_name()!="HTML5"):
		$HTTPRequest.connect("request_completed", self, "_on_latestverrequest_complete")
		$HTTPRequest.request("https://raw.githubusercontent.com/ThatFinnDev/fullcodes/master/latesquixxver")

	for child in get_children():
		if(child is Control):
			child.hide()
	$Main.show()
	for resource in defaultTemplates:
		var entry = selectSheetPrefab.instance()
		entry.text=resource.name
		entry.connect("pressed",self,"checkSelectedThing")
		$SelectThing/SelectThing/Container.add_child(entry)
	
	for level in createdLevels:
		var entry = selectSheetPrefab.instance()
		var resource = loadJsonAsSheet(level)
		customLevelResources.append(resource)
		entry.text=resource.name
		entry.connect("pressed",self,"checkSelectedThing")
		$SelectThing/SelectThing/Container.add_child(entry)
		
	removeUnusableSheets()
	$Main/Top/AnimationPlayer.play("Start")
	$Main/Middle/Play.grab_focus()
	pass # Replace with function body.

var back : bool = false
func _process(delta):
	if(OS.get_name()=="HTML5"):
		$Fullscreen.show()
	if(Input.is_action_just_pressed("ui_cancel")):
		if($VirtualDice.visible or $DiceOnly.visible or $Normal.visible):_on_BackToPlay_pressed()
		else: _on_Back_pressed()
	if(back):
		back=false
		if($Play.visible):
			$Play.hide()
			$Main.show()
		elif $Create.visible or $Settings.visible:
			$Main.show()
			$Settings.hide()
			$Create.hide()
			$Main/Middle/Play.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Create_pressed():
	$Create.show()
	$Main.hide()
	$Create/Back.grab_focus()
	whereisMain=1


func _on_Settings_pressed():
	$Settings.show()
	$Main.hide()
	$Settings/Back.grab_focus()
	whereisMain=-1


func _on_Play_pressed():
	$Play.show()
	$Main.hide()
	$Play/Back.grab_focus()


func _on_PlayChoices_pressed():
	var resource
	if(selectedThing>defaultTemplates.size()-1):
		resource = customLevelResources[selectedThing-defaultTemplates.size()]
	else:
		resource = defaultTemplates[selectedThing]
	if($Normal.visible):
		var entry = sheetPrefab.instance()
		entry.railTemplate=resource
		get_tree().root.add_child(entry)
	elif($DiceOnly.visible):
		var entry = dicePrefab.instance()
		entry.railTemplate=resource
		entry.useNumbers = useNumbers
		get_tree().root.add_child(entry)
	elif($VirtualDice.visible):
		var entry = virtualDicePrefab.instance()
		entry.railTemplate=resource
		entry.useNumbers = useNumbers
		entry.get_child(0).railTemplate=resource
		get_tree().root.add_child(entry)
		
		
	for child in get_children():
		if(child is Control):
			child.hide()
	$Main.show()
	hide()


var useNumbers:bool=true
	
func _save():
	var save_game = File.new()
	save_game.open("user://settings.prefs", File.WRITE)
	save_game.store_line(to_json(exportSaveDict()))
	save_game.close()
func _load():
	var save_game = File.new()
	if not save_game.file_exists("user://settings.prefs"):
		return # Error! We don't have a save to load.
	save_game.open("user://settings.prefs", File.READ)
	var data = parse_json(save_game.get_line())
	for i in data.keys():
		match i:
			"useNumbers":
				$Settings/ShowNumbersOnDice/CheckBox.pressed = data[i]
				useNumbers = data[i]
			"customLevels":
				if(data[i] is PoolStringArray):
					createdLevels=data[i]
				elif(data[i] is Array):
					createdLevels=PoolStringArray(data[i])
			"saveStates":
				if(data[i] is PoolStringArray):
					savedGames=data[i]
				elif(data[i] is Array):
					savedGames=PoolStringArray(data[i])
				
	save_game.close()
func exportSaveDict():
	var save_dict = {
		"useNumbers" : useNumbers,
		"customLevels" : createdLevels,
		"saveStates" : savedGames
	}
	return save_dict

var restartRequired : bool = false
func _on_Back_pressed():
	back = true
	if(restartRequired or selectedThingForModify!=-1):
		get_tree().root.add_child((load("res://Scenes/Main.tscn")).instance())
		queue_free()
		return
	
	if($ModifyExisting.visible or $CreateNew.visible or $Manage.visible or $Import.visible):
		back=false
		$ModifyExisting.hide()
		$Manage.hide()
		$Import.hide()
		$CreateNew.hide()
		$Create.show()
	elif($Saves.visible):
		back=false
		$Saves.hide()
		$Play.show()


func _on_BackToPlay_pressed():
	$Main.hide()
	$Play.show()
	$DiceOnly.hide()
	$Normal.hide()
	$VirtualDice.hide()
	$SelectThing.hide()
	checkSelectedThing()


func _on_DiceOnly_pressed():
	$Play.hide()
	$DiceOnly.show()
	$SelectThing.show()


func _on_Normal_pressed():
	$Play.hide()
	$Normal.show()
	$SelectThing.show()


func _on_VirtualDice_pressed():
	$Play.hide()
	$VirtualDice.show()
	$SelectThing.show()


func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_ShowNumbersOnDiceCheckBox_pressed():
	useNumbers = $Settings/ShowNumbersOnDice/CheckBox.pressed
	_save()


func _on_CreateNew_pressed():
	$Create.hide()
	$CreateNew.show()

func getSelectedThingForModify() -> int:
	var i : int = -1
	for button in $ModifyExisting/SelectThing/Container.get_children():
		i+=1
		if(button.pressed):return i
	return -1
var selectedThingForModify : int = -1
func checkSelectedThingForModify():
	selectedThingForModify = getSelectedThingForModify()
	if(selectedThingForModify!=-1):
		SelectEntryForModify()
		
func _on_ModifyExisting_pressed():
	$Create.hide()
	$ModifyExisting.show()
	for child in $ModifyExisting/SelectThing/Container.get_children():
		child.queue_free()
	for level in createdLevels:
		var entry = selectSheetPrefab.instance()
		var resource = loadJsonAsSheet(level)
		customLevelResources.append(resource)
		entry.text=resource.name
		entry.connect("pressed",self,"checkSelectedThingForModify")
		$ModifyExisting/SelectThing/Container.add_child(entry)

func SelectEntryForModify():
	$ModifyExisting/SelectThing.hide()
	var entry = creatorPrefab.instance()
	$ModifyExisting.add_child(entry)
	$ModifyExisting/Save.show()
	entry.LoadJsonToEdit(createdLevels[selectedThingForModify])

func _on_ImportLevel_pressed():
	$Import.show()
	$Create.hide()

func removeLevelAt(index:int):
	createdLevels.remove(index)
	customLevelResources.remove(index)
	_save()
	restartRequired = true
	_on_ManageLevels_pressed()


func exportLevelAt(index:int):
	OS.clipboard=createdLevels[index]

func _on_ManageLevels_pressed():
	$Manage.show()
	$Create.hide()
	for child in $Manage/SelectThing/Container.get_children():
		child.queue_free()
	var i : int = -1
	for level in createdLevels:
		i+=1
		var entry = managePrefab.instance()
		var resource = loadJsonAsSheet(level)
		customLevelResources.append(resource)
		entry.get_child(0).text=resource.name
		entry.get_child(1).connect("pressed",self,"removeLevelAt",[i])
		entry.get_child(2).connect("pressed",self,"exportLevelAt",[i])
		$Manage/SelectThing/Container.add_child(entry)


func _on_SaveModified_pressed():
	createdLevels.remove(selectedThingForModify)
	_save()
	$ModifyExisting/LayoutCreator.Add()


func _on_Import_pressed():
	var text = $Import/TextEdit.text
	if(loadJsonAsSheet(text)!=null):
		AddCustomLevel(text)




func convertJSONToSaveState(json:String) -> SaveState:
	var parseResult : JSONParseResult = JSON.parse(json)
	if(parseResult.error==0):
		var stuff :Dictionary = parseResult.result
		var state = SaveState.new()
		state.mapName=stuff.get("m","Normal")
		state.name=stuff.get("n","missingname")
		state.virtualDices=stuff.get("v",[])
		state.luckNumbers=stuff.get("l",[])
		state.fails=stuff.get("f",[])
		state.entries=stuff.get("e",[])
		return state
	return null

func selectSaveState(index:int):
	var levelResource : RailTemplate = null
	var saveState : SaveState = convertJSONToSaveState(savedGames[index])
	for resource in defaultTemplates:
		if(resource.name==saveState.mapName):
			levelResource=resource
			break
	if(levelResource==null):
		for resource in customLevelResources:
			if(resource.name==saveState.mapName):
				levelResource=resource
	if(levelResource==null):
		#print(saveState.mapName)
		deleteSaveState(index)
	if(saveState.virtualDices.size()>0):
		var entry = virtualDicePrefab.instance()
		entry.railTemplate=levelResource
		entry.useNumbers = useNumbers
		entry.get_child(0).railTemplate=levelResource
		get_tree().root.add_child(entry)
		entry.loadState(saveState)
	else:
		var entry = sheetPrefab.instance()
		entry.railTemplate=levelResource
		get_tree().root.add_child(entry)
		entry.loadState(saveState)
	$Saves.hide()
	$Main.show()
	hide()

func deleteSaveState(index:int):
	savedGames.remove(index)
	_save()
	_on_PlaySaved_pressed()
func _on_PlaySaved_pressed():
	$Saves.show()
	$Play.hide()
	for child in $Saves/SelectThing/Container.get_children():
		child.queue_free()
		
	var i : int = -1
	for savedGame in savedGames:
		i+=1
		var entry = selectStatePrefab.instance()
		var saveState : SaveState = convertJSONToSaveState(savedGame)
		entry.text="  "+saveState.mapName+": "+Time.get_datetime_string_from_unix_time(float(saveState.name),true)
		entry.connect("pressed",self,"selectSaveState",[i])
		entry.get_child(0).connect("pressed",self,"deleteSaveState",[i])
		$Saves/SelectThing/Container.add_child(entry)
