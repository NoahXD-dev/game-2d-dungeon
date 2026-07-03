class_name StateBase extends Node

# Referencia al nodo que vamos a controlar
@onready var controlled_node: Node = self.owner

# Referencia a la maquina de estados
var state_machine: StateMachine

# Metodos en comun:
func start():
	pass

func end():
	pass
