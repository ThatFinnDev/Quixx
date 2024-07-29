extends VBoxContainer
signal changed

export var color : Color
export var count : int = 11
export var customNumbers : PoolIntArray = []
func _ready():
	change()
func change():
	emit_signal("changed")

func setColor(value:Color):
	color=value
	$Color/HBoxContainer/Button.self_modulate=value

func setCount(value:int):
	count=value
	updateCount()

func setCustomNumbers(value:PoolIntArray):
	var finalText : String = ""
	customNumbers=value
	for i in value:
		finalText=str(i)+","
	$CustomNumbers/HBoxContainer/TextEdit.text=finalText

	
func _on_ColorPicker_pressed():
	$ColorPicker.visible=!$ColorPicker.visible


func _on_CountLess_pressed():
	count-=1
	updateCount()
func _on_CountMore_pressed():
	count+=1
	updateCount()
func updateCount():
	if(count<0): count=0
	$Count/HBoxContainer/Label2.text=str(count)
	change()



func _on_CustomNumberstext_changed():
	customNumbers=[]
	var text:String=$CustomNumbers/HBoxContainer/TextEdit.text
	var split = text.split(",")
	for entry in split:
		if(entry==""): continue
		if(entry==" "): continue
		if(entry==null): continue
		customNumbers.append(int(entry))
	change()


func _on_ColorPicker_color_changed(color):
	setColor(color)
	change()
