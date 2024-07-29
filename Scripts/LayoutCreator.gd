class_name LayoutCreator extends ScrollContainer

var railTemplate : RailTemplate
var rails : Array
var railCreatorPrefab : PackedScene = preload("res://Prefabs/CreatorRail.tscn")
var railCreatorSpacerPrefab : PackedScene = preload("res://Prefabs/SpacerForRail.tscn")
func _ready():
	railTemplate = RailTemplate.new()
	
func Add():
	get_tree().root.get_child(0).AddCustomLevel(saveResourceAsJson())
func saveResourceAsJson() -> String:
	var resource = railTemplate
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

func LoadJsonToEdit(json:String):
	var template : RailTemplate = loadJsonAsSheet(json)
	for child in $Container/Rails/Contents.get_children():
		child.queue_free()
	rails=[]
	$Container/CombineLastTwo/HBoxContainer/CheckBoxContainer/CheckBox.pressed=template.combineLastTwo
	$Container/LuckNumbers/HBoxContainer/CheckBoxContainer/CheckBox.pressed=template.useLuckNumbers
	$Container/MaxFails/HBoxContainer/Label2.text=str(template.maxFailButtons)
	$Container/TextEdit.text=template.name
	var i : int = -1
	print(template.railTemplateDatas.size())
	print(template.railTemplateDatas.size())
	print(template.railTemplateDatas.size())
	print(template.railTemplateDatas.size())
	print(template.railTemplateDatas.size())

	for templateData in template.railTemplateDatas:
		i+=1
		_on_AddRail_pressed()
		rails[i].setReverseLayout(templateData.reverseLayout)
		rails[i].setMakeLock(templateData.makeLock)
		var j : int = -1
		for creatorData in templateData.creatorData:
			j+=1
			rails[i]._on_AddCreatorData_pressed()
			rails[i].creatorDatas[j].setColor(creatorData.color)
			rails[i].creatorDatas[j].setCount(creatorData.count)
			rails[i].creatorDatas[j].setCustomNumbers(creatorData.customNumbers)
			rails[i].creatorDatas[j].change()


func redoRails():
	railTemplate.railTemplateDatas=[]
	for rail in rails:
		var templateData : RailTemplateData = RailTemplateData.new()
		templateData.makeLock=rail.makeLock
		templateData.reverseLayout=rail.reverseLayout
		templateData.creatorData=rail.creatorDataResources
		print(rail.creatorDataResources.size())
		railTemplate.railTemplateDatas.append(templateData)

func _on_AddRail_pressed():
	if($Container/Rails/Contents.get_child_count()!=0):
		$Container/Rails/Contents.add_child(railCreatorSpacerPrefab.instance())
	var newRail = railCreatorPrefab.instance()
	$Container/Rails/Contents.add_child(newRail)
	rails.append(newRail)
	newRail.connect("changed",self,"redoRails")
	redoRails()
		



func _on_LuckyNumbers_pressed():railTemplate.useLuckNumbers=$Container/LuckNumbers/HBoxContainer/CheckBoxContainer/CheckBox.pressed
func _on_CombineLastTwo_pressed():railTemplate.combineLastTwo=$Container/CombineLastTwo/HBoxContainer/CheckBoxContainer/CheckBox.pressed
func _on_Title_changed():railTemplate.name=$Container/TextEdit.text


func _on_MaxFailsLess_pressed():
	railTemplate.maxFailButtons-=1
	updateMaxFails()
func _on_MaxFailsMore_pressed():
	railTemplate.maxFailButtons+=1
	updateMaxFails()
func updateMaxFails():
	if(railTemplate.maxFailButtons<0): railTemplate.maxFailButtons=0
	if(railTemplate.maxFailButtons>10): railTemplate.maxFailButtons=10
	$Container/MaxFails/HBoxContainer/Label2.text=str(railTemplate.maxFailButtons)


