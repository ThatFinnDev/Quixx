class_name ValueMinus extends Button

var isPressed : bool = false
var sheet : Control
func _onPress():
	isPressed = !isPressed
	$Cross.visible=isPressed
	if(isPressed):	sheet.minus+=1
	else:sheet.minus-=1
	sheet.refreshValues()
func _ready():
	connect("pressed",self,"_onPress")
