extends Node2D

# Reference to the player character
var player : CharacterBody2D
# Reference to the enemy node itself
@onready var enemy = get_parent()

# Function to set up the enemy's behavior
func setup(p, offset = 0):
	# Assign the player reference for later use
	player = p
	
	# Calculate the direction vector from the enemy to the player and normalize it
	var direction : Vector2 = (player.global_position - enemy.global_position).normalized()
	# Rotate the direction by 45 degrees to make the enemy approach at an angle
	direction = direction.rotated(deg_to_rad(5)).normalized()
	# Set the enemy's velocity to move in the given direction at a speed of 300
	enemy.velocity = direction * 300

	# If there is no offset, duplicate the enemy twice and set up the duplicates
	if offset == 0:
		# Duplicate the enemy and add it to the scene tree
		var newEnemy = enemy.duplicate()
		get_node("../../").add_child(newEnemy)
		# Set up the new enemy with an offset of 1
		newEnemy.get_node("AI").setup(p, 1)

		# Duplicate the enemy again and add it to the scene tree
		newEnemy = enemy.duplicate()
		get_node("../../").add_child(newEnemy)
		# Set up the new enemy with an offset of -1
		newEnemy.get_node("AI").setup(p, -1)
	else:
		# If there is an offset, reposition the enemy to the side
		var reposition = direction.rotated(deg_to_rad(90))
		# Move the enemy 100 units along the perpendicular direction, multiplied by the offset
		enemy.position += 100 * reposition * offset

# Function to handle when the enemy is damaged (currently not implemented)
func on_enemy_damaged():
	pass
