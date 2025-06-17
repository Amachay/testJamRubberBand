extends Node2D

const ROPE_SEGMENT = preload("res://rope_segment.tscn")
var segment_scene: PackedScene = ROPE_SEGMENT
var segment_count := 14
var max_distance = 300

@onready var player_1: CharacterBody2D = $"Player 1"
@onready var player_2: CharacterBody2D = $"Player 2"

func _ready():
	var last = player_1
	var start_pos = player_1.global_position
	var end_pos = player_2.global_position
	var delta = (end_pos - start_pos) / segment_count
	
	for i in range(segment_count):
		var segment = segment_scene.instantiate() as RigidBody2D
		segment.global_position = start_pos + delta*i
		add_child(segment)
		
		var joint = PinJoint2D.new()
		joint.node_a = last.get_path()
		joint.node_b = segment.get_path()
		joint.global_position = segment.global_position
		add_child(joint)
		
		last = segment
		
	var joint_end = PinJoint2D.new()
	joint_end.node_a = last.get_path()
	joint_end.node_b = player_2.get_path()
	joint_end.global_position = player_2.global_position
	add_child(joint_end)

func _physics_process(delta):
	var offset = player_2.global_position - player_1.global_position
	var distance = offset.length()
	
	if distance > max_distance:
		var direction = offset.normalized()
		var stretch_ratio = max(0, (distance - max_distance) / max_distance)
		var pull_strength = stretch_ratio * 20000.0
		higher_player().global_position += direction * pull_strength * delta
		player_2.global_position -= direction * pull_strength * delta
		
func higher_player():
	if player_1.global_position.y < player_2.global_position.y:
		return player_1
	return player_2
		
func lower_player():
	if player_2.global_position.y < player_1.global_position.y:
		return player_2
	return player_1
