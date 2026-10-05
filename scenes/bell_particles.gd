@tool
extends Node2D

@export_tool_button("Play", "Play") var play_ptc = play

func play():
	$CPUParticles2D3.emitting = true
	$CPUParticles2D5.emitting = true
	$CPUParticles2D4.emitting = true
