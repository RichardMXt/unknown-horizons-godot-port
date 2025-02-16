extends Node2D

func on_mouse_entered():
  print("mouse_entered")
  $AnimatedSprite2D.material.set_shader_parameter("width", 3)

func on_mouse_exited():
  print("mouse_exited")
  $AnimatedSprite2D.material.set_shader_parameter("width", 0)
