class_name CharacterData
extends Resource

@export var type : LogicalCharacter.TYPE
@export var side : LogicalCharacter.SIDE


@export var price: int:
	set(value):
		if side == LogicalCharacter.SIDE.Good:
			price = value
		else:
			push_warning("Only Allies should have a price")
		
@export_category("Combat")
@export var health : float
@export var damage : float
@export var speed : float
@export_range(0,1) var crit : float
@export var shooter : bool

@export_category("Animation")
@export var animations : SpriteFrames
@export var projectile : CompressedTexture2D:
	set(value):
		if shooter:
			projectile = value
		else:
			push_warning("Only Ranged enemies should have a projectile")
