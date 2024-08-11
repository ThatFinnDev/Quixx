extends Node
signal changed
var reverseLayout : bool
var makeLock : bool
var creatorDatas : Array
var creatorDataPrefab: PackedScene = preload("res://Prefabs/CreatorData.tscn")
var railCreatorSpacerPrefab : PackedScene = preload("res://Prefabs/SpacerForRail.tscn")

export(Array, Resource) var creatorDataResources = []
func _ready():
	change()

func setReverseLayout(value:bool):
	$ReverseLayout/HBoxContainer/CheckBoxContainer/CheckBox.pressed=value
	change()
func setMakeLock(value:bool):
	$MakeLock/HBoxContainer/CheckBoxContainer/CheckBox.pressed=value
	change()
func change():
	reverseLayout=$ReverseLayout/HBoxContainer/CheckBoxContainer/CheckBox.pressed
	makeLock=$MakeLock/HBoxContainer/CheckBoxContainer/CheckBox.pressed
	emit_signal("changed")

func redoCreatorDatas():
	creatorDataResources=[]
	for creatorData in creatorDatas:
		var creatorDataIn : RailEntryCreatorData = RailEntryCreatorData.new()
		creatorDataIn.color = creatorData.color
		creatorDataIn.count = creatorData.count
		creatorDataIn.customNumbers = creatorData.customNumbers
		creatorDataResources.append(creatorDataIn)
	change()

func _on_AddCreatorData_pressed():
	if($CreatorData/Contents.get_child_count()!=0):
		$CreatorData/Contents.add_child(railCreatorSpacerPrefab.instance())
	var newCreatorData = creatorDataPrefab.instance()
	$CreatorData/Contents.add_child(newCreatorData)
	creatorDatas.append(newCreatorData)
	newCreatorData.connect("changed",self,"redoCreatorDatas")
	redoCreatorDatas()
