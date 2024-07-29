class_name ValueButton extends Button

var otherButton
export var checkForOtherButton : bool = false
var isPressed : bool = false
var sheet : Control
var inRailNumber : int = 0

func _onPress():
	isPressed = !isPressed
	$Cross.visible=isPressed
	if(isPressed):
		if(checkForOtherButton):
			if(otherButton==null):
				var background = get_parent().get_parent().get_parent()
				var nextBackground
				if("Left" in background.name):	nextBackground = background.get_parent().get_child(background.get_index()+1)
				else:nextBackground = background.get_parent().get_child(background.get_index()-1)
				otherButton=nextBackground.get_child(0).get_child(0).get_child(0)
			if(otherButton.isPressed): otherButton._onPress()
		sheet.pressedCounts[inRailNumber]+=1
	else:
		sheet.pressedCounts[inRailNumber]-=1
	sheet.refreshValues()
func _ready():
	connect("pressed",self,"_onPress")
