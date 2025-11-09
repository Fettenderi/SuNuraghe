@tool
extends EditorScript

var dic1 := {
	"time" : 1,
	"palle" : true
}

var dic2 := {
	"time" : 0.5
}

func _run() -> void:
	dic2.merge(dic1)
	
	print(dic2)
