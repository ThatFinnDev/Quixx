class_name Sheet extends Control

var valueEntry : PackedScene = preload("res://Prefabs/ValueEntry.tscn")
var valueEntryLeft : PackedScene = preload("res://Prefabs/ValueEntryLeft.tscn")
var valueEntryRight : PackedScene = preload("res://Prefabs/ValueEntryRight.tscn")
var valueNegative : PackedScene = preload("res://Prefabs/ValueNegative.tscn")
var valueLock : PackedScene = preload("res://Prefabs/ValueLock.tscn")
var valueRail : PackedScene = preload("res://Prefabs/ValueRail.tscn")
var valueShower : PackedScene = preload("res://Prefabs/ValueShower.tscn")
var showerInfoEntry : PackedScene = preload("res://Prefabs/ShowerInfoEntry.tscn")
var luckyNumber : PackedScene = preload("res://Prefabs/LuckNumber.tscn")
export var showBackButton : bool = true
export var startNumber : int = 2
export(Resource) var railTemplate
var pressedCounts : PoolIntArray
var valueShowers : Array
var rails : Array
var highestRowCount := 0
var minus:= 0

var stateToLoad :SaveState = null


func loadState(state:SaveState):
	if(!ready):
		_ready()
		stateToLoad=state
		return
	stateToLoad=null
	var n : int = -1
	var i : int = -1
	var l : int = -1
	for child in $InformationArea/ShowerInfo.get_children():
		if("ValueNegativePanel" in child.name):
			n+=1
			if(state.fails[n]==1):
				child.get_child(0).get_child(0).get_child(0)._onPress()
		if("LuckNumber" in child.name):
			l+=1
			if(state.luckNumbers.size()!=0):
				child.get_child(0).text=str(state.luckNumbers[l])
	for row in $Rails.get_children():
		for entry in row.get_children():
			var buttonMaybe = entry.get_child(0).get_child(0).get_child(0)
			if(buttonMaybe is Button):
				i+=1
				if(state.entries[i]==1):
					buttonMaybe.sheet=self
					buttonMaybe._onPress()
	

func saveState(virtualDice:Array) -> SaveState:
	var state = SaveState.new()
	state.virtualDices=virtualDice
	state.name=str(Time.get_unix_time_from_system())
	state.mapName=railTemplate.name
	
	for child in $InformationArea/ShowerInfo.get_children():
		if("ValueNegativePanel" in child.name):
			var pressed : int = 0
			if (child.get_child(0).get_child(0).get_child(0).isPressed): pressed=1
			state.fails.append(pressed)
		if("LuckNumber" in child.name):
			state.luckNumbers.append(int(child.get_child(0).text))
	for row in $Rails.get_children():
		for entry in row.get_children():
			var buttonMaybe = entry.get_child(0).get_child(0).get_child(0)
			if(buttonMaybe is Button):
				var pressed : int = 0
				if(buttonMaybe.isPressed): 
					pressed=1
				state.entries.append(pressed)
	#print(convertSaveStateToJSON(state))
	return state

const currMapVer : String = "1.4.5"

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

var ready : bool = false
func _ready():
	if(ready): return
	if(!showBackButton):
		$InformationArea/ShowerInfo/Back.hide()
		
	if(OS.get_name()=="HTML5"):
		$InformationArea/ShowerInfo/Fullscreen.show()
	get_tree().root.get_viewport().connect("size_changed",self,"onViewportChange")
	#var error = ResourceSaver.save(save_path,loadJsonAsSheet(saveResourceAsJson()),32)
	#var error = ResourceSaver.save(save_path,loadJsonAsSheet("{\"n\":\"Mixed 2\",\"m\":4,\"v\":\"1.4.5\",\"r\":[{\"r\":false,\"m\":true,\"c\":[{\"r\":255,\"g\":255,\"b\":0,\"c\":3},{\"r\":0,\"g\":125,\"b\":255,\"c\":3},{\"r\":38,\"g\":255,\"b\":0,\"c\":3},{\"r\":255,\"g\":16,\"b\":16,\"c\":2}]},{\"r\":false,\"m\":true,\"c\":[{\"r\":255,\"g\":16,\"b\":16,\"c\":2},{\"r\":38,\"g\":255,\"b\":0,\"c\":4},{\"r\":0,\"g\":125,\"b\":255,\"c\":2},{\"r\":255,\"g\":255,\"b\":0,\"c\":3}]},{\"r\":true,\"m\":true,\"c\":[{\"r\":0,\"g\":125,\"b\":255,\"c\":3},{\"r\":255,\"g\":255,\"b\":0,\"c\":3},{\"r\":255,\"g\":16,\"b\":16,\"c\":3},{\"r\":38,\"g\":255,\"b\":0,\"c\":2}]},{\"r\":true,\"m\":true,\"c\":[{\"r\":38,\"g\":255,\"b\":0,\"c\":2},{\"r\":255,\"g\":16,\"b\":16,\"c\":4},{\"r\":255,\"g\":255,\"b\":0,\"c\":2},{\"r\":0,\"g\":125,\"b\":255,\"c\":3}]}]}"),32)

	var railIndex : int = -1
	for railDataTemplate in railTemplate.railTemplateDatas:
		var reverseLayout : bool = railDataTemplate.reverseLayout
		var makeLock : bool = railDataTemplate.makeLock
		railIndex+=1
		var rail = valueRail.instance()
		$Rails.add_child(rail)
		pressedCounts.append(0)
		rails.append(rail)
		var color = Color.white
		var alreadyMadeRows :int= 0
		var totalRows : int = 0
		var totalCreatorData : int = 0
		var currentCreatorData : int = 0
		for creatorData in railDataTemplate.creatorData:
			totalRows+=creatorData.count
			totalCreatorData+=1
		
		for creatorData in railDataTemplate.creatorData:
			currentCreatorData+=1
			var lastCreatorData : bool = currentCreatorData == totalCreatorData
			if(!railTemplate.combineLastTwo):
				lastCreatorData=false
			color = creatorData.color
			var rows : int = creatorData.count
			var customNumbers : Array = Array(creatorData.customNumbers)
			var useCustomNumbers : bool = false
			if(customNumbers!=null):
				if(customNumbers!=[]):
					useCustomNumbers=true
			else: customNumbers=[]
			
			for iUnmodded in rows:
				if(rail.get_child_count()>=16): continue
				var i : int = iUnmodded+startNumber+alreadyMadeRows
				if reverseLayout:
					i=totalRows-(iUnmodded-startNumber+alreadyMadeRows+1)
				var entry
				if(lastCreatorData):
					if(iUnmodded==rows-1):
						entry = valueEntryRight.instance()
					elif(iUnmodded==rows-2):
						entry = valueEntryLeft.instance()
					else:
						entry = valueEntry.instance()
				else:
					entry = valueEntry.instance()
				rail.add_child(entry) 
				var newEntryBackground = entry.get_stylebox("panel").duplicate()
				newEntryBackground.bg_color = color
				entry.add_stylebox_override("panel",newEntryBackground)
				var button : Button = entry.get_child(0).get_child(0).get_child(0)
				button.sheet = self
				button.inRailNumber=railIndex
				button.add_color_override("font_color_disabled", color);
				button.add_color_override("font_color_focus", color);
				button.add_color_override("font_color", color);
				button.add_color_override("font_color_hover", color);
				button.add_color_override("font_color_pressed", color);
				
				if(useCustomNumbers):
					if(customNumbers.size()>iUnmodded): button.text=str(customNumbers[iUnmodded])
					else: button.text=str(i)
				else: button.text=str(i)
			alreadyMadeRows+=rows
		if(makeLock):
			var entry = valueLock.instance()
			rail.add_child(entry)
			var newEntryBackground = entry.get_stylebox("panel").duplicate()
			newEntryBackground.bg_color = color
			entry.add_stylebox_override("panel",newEntryBackground)
			var button : Button = entry.get_child(0).get_child(0).get_child(0)
			button.sheet = self
			button.inRailNumber=railIndex
		if true:
			var entry = valueShower.instance()
			rail.add_child(entry)
			#var newEntryBackground = entry.get_stylebox("panel").duplicate()
			#newEntryBackground.bg_color = color
			#entry.add_stylebox_override("panel",newEntryBackground)
			valueShowers.append(entry)
			var label : Label = entry.get_child(0).get_child(0).get_child(0)
			label.remove_color_override("font_color")
			label.add_color_override("font_color", color);
			var newInnerBackground = entry.get_child(0).get_stylebox("panel").duplicate()
			newInnerBackground.border_color = color
			entry.get_child(0).add_stylebox_override("panel",newInnerBackground)
		var currRowCountThing : int = rail.get_child_count()
		if(railTemplate.combineLastTwo):
			currRowCountThing-=1
		if(highestRowCount<currRowCountThing):
			highestRowCount=currRowCountThing
	refreshValues()
	var showEntry : Node
	for i in highestRowCount:
		if(i==0): continue
		showEntry = showerInfoEntry.instance()
		$InformationArea/ShowerInfo.add_child(showEntry)
		var label : Label = showEntry.get_child(0)
		label.text=" "+str(i)+" \n-\n "+str(_getCorrPointsForColor(i))+" "
		showEntry.rect_min_size.x=label.rect_size.x
	if(showEntry!=null):
		showEntry.size_flags_horizontal=2
	if(railTemplate.useLuckNumbers):
		var luckyNumber1 = luckyNumber.instance()
		$InformationArea/ShowerInfo.add_child(luckyNumber1)
		var label1 : Label = luckyNumber1.get_child(0)
		var luckyNumber2 = luckyNumber.instance()
		$InformationArea/ShowerInfo.add_child(luckyNumber2)
		var label2 : Label = luckyNumber2.get_child(0)
		
		randomize()
		match (randi() % 4):
			0:
				label1.text="7"
				label2.text="12"
			01:
				label1.text="6"
				label2.text="11"
			2:
				label1.text="8"
				label2.text="13"
			3:
				label1.text="5"
				label2.text="10"
	for i in railTemplate.maxFailButtons:
		var entry = valueNegative.instance()
		entry.get_child(0).get_child(0).get_child(0).sheet=self
		$InformationArea/ShowerInfo.add_child(entry)
		
	ready=true

func onViewportChange():
	var scaler : float = rect_size.x/$Rails.rect_size.x
	$Rails.rect_scale=Vector2(scaler,scaler)
	var scalerT : float = rect_size.x/$InformationArea/ShowerInfo.rect_size.x
	$InformationArea/ShowerInfo.rect_scale=Vector2(scalerT,-scalerT)

var firstTick : bool = true
var secondTick : bool = true
func _process(delta):
	#$InformationArea.rect_position.y=$Rails.rect_size.y+25*$Rails.rect_scale.x
	#$InformationArea.rect_size.y=rect_size.y-$InformationArea.rect_position.y
	
	
	if(firstTick):
		firstTick=false
		for child in $InformationArea/ShowerInfo.get_children():
			if(child.get_child_count()>0):
				if(child.get_child(0) is Label):
					var label : Label = child.get_child(0)
					child.rect_min_size.x=label.rect_size.x
		onViewportChange()
		$InformationArea/ShowerInfo.move_child($InformationArea/ShowerInfo/EndValue,$InformationArea/ShowerInfo.get_child_count()-1)
		$InformationArea/ShowerInfo.move_child($InformationArea/ShowerInfo/Fullscreen,$InformationArea/ShowerInfo.get_child_count()-1)
		$InformationArea/ShowerInfo.move_child($InformationArea/ShowerInfo/Back,0)
	elif(secondTick):
		secondTick=false
		onViewportChange()
	else:
		if(stateToLoad!=null):
			loadState(stateToLoad)
func getNegativePoints() -> int:
	return minus*5
func refreshValues():
	var i : int = -1
	var endValue : int = 0
	for valueShower in valueShowers:
		i+=1
		var label : Label = valueShower.get_child(0).get_child(0).get_child(0)
		var value : int = _getCorrPointsForColor(pressedCounts[i])
		endValue += value
		label.text = str(value)
	$InformationArea/ShowerInfo/EndValue/ValueShower/WorkArea/Label.text = str(endValue-getNegativePoints())
	pass

func _getCorrPointsForColor(value: int) -> int:
	var e:=0
	match(value):
		0:e=0
		1:e=1
		2:e=3
		3:e=6
		4:e=10
		5:e=15
		6:e=21
		7:e=28
		8:e=36
		9:e=45
		10:e=55
		11:e=66
		12:e=78
		13:e=91
		14:e=105
		15:e=120
	return e

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
	get_tree().root.get_child(0).savedGames.append(convertSaveStateToJSON(saveState([])))
	get_tree().root.get_child(0)._save()
	get_tree().root.get_child(0).show()
	queue_free()

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
