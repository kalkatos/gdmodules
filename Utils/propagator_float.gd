class_name PropagatorFloat
## Utility component that categorizes a float value into discrete "ranks" based on defined thresholds.
extends Node

signal on_rank_1
signal on_rank_2
signal on_rank_3
signal on_rank_4
signal on_rank_5
signal on_rank_6
signal on_rank_7
signal on_rank_8
signal on_rank_9

@export_range(0.0, 1.0) var rank_1: float = 1.0
@export_range(0.0, 1.0) var rank_2: float = 1.0
@export_range(0.0, 1.0) var rank_3: float = 1.0
@export_range(0.0, 1.0) var rank_4: float = 1.0
@export_range(0.0, 1.0) var rank_5: float = 1.0
@export_range(0.0, 1.0) var rank_6: float = 1.0
@export_range(0.0, 1.0) var rank_7: float = 1.0
@export_range(0.0, 1.0) var rank_8: float = 1.0
@export_range(0.0, 1.0) var rank_9: float = 1.0


## Categorizes the input value into one of nine ranks and emits the corresponding signal.
func propagate (value: float) -> void:
	if value <= rank_1:
		on_rank_1.emit()
	elif value <= rank_2:
		on_rank_2.emit()
	elif value <= rank_3:
		on_rank_3.emit()
	elif value <= rank_4:
		on_rank_4.emit()
	elif value <= rank_5:
		on_rank_5.emit()
	elif value <= rank_6:
		on_rank_6.emit()
	elif value <= rank_7:
		on_rank_7.emit()
	elif value <= rank_8:
		on_rank_8.emit()
	else:
		on_rank_9.emit()
