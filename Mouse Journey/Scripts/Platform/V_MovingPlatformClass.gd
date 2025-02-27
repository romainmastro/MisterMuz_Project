class_name VMovingPlatformClass
extends CharacterBody2D

@export_group("Settings")
@export var vitesse_sec : float = 1
@export var distance_pixel : float = 32
enum Moveset {bas, haut} 
@export var direction := Moveset.bas
