extends Area2D

var speed = 60
var car_turn_speed = 25 

var direction = -1
var carSide
var score = 0
var lost = false

var rotations = Vector3(-22.5, 0, 22.5) # X for left, Y for center, Z for right (in degrees)

func _ready():
	%CarArea.position = Vector2(0, 0)
	%CarArea.rotation = deg_to_rad(rotations.y)

func _physics_process(delta: float) -> void:
	%StraightRoadTileMap.position.y -= speed * direction
	if not lost:
		score += 1
		_update_score()

	if %StraightRoadTileMap.position.y > 650:
		%StraightRoadTileMap.position.y = 0
	else:
		%StraightRoadTileMap.position.y -= speed * direction

	var target_rotation_degrees : float

	if Input.is_action_pressed("left"):
		%CarArea.position.x -= speed/2
		target_rotation_degrees = rotations.x
		%CarArea.rotation = lerp(%CarArea.rotation, deg_to_rad(target_rotation_degrees), delta * car_turn_speed)
	elif Input.is_action_pressed("right"):
		%CarArea.position.x += speed/2
		target_rotation_degrees = rotations.z # 22.5 degrees
		%CarArea.rotation = lerp(%CarArea.rotation, deg_to_rad(target_rotation_degrees), delta * car_turn_speed)
	else:
		target_rotation_degrees = rotations.y # 0 degrees
		%CarArea.rotation = lerp(%CarArea.rotation, deg_to_rad(target_rotation_degrees), delta * car_turn_speed)

	%EnemyCarArea.position.y -= speed * direction

	if %EnemyCarArea.position.y > 2000:
		%EnemyCarArea.position.y = -2600
		carSide = randi_range(1, 2)
		match(carSide):
			1:
				%EnemyCarArea.position.x = -170
			2:
				%EnemyCarArea.position.x = 170
			_:
				%EnemyCarArea.position.x = 170
	
	if lost:
		target_rotation_degrees = rotations.z
		%CarArea.rotation = lerp(%CarArea.rotation, deg_to_rad(target_rotation_degrees), delta * car_turn_speed)
		%Car.position.x += 10
		%Car.position.y += 10

func _update_score():
	%ScoreLabel.text = "Score: " + str(score)

func _game_over():
	if not lost:
		%Explosion.emitting = true
		lost = true
		%GameOverTimer.start()
		_update_score()

func _on_enemy_car_area_area_entered(_area: Area2D) -> void:
	_game_over()

func _on_cop_area_right_area_entered(_area: Area2D) -> void:
	_game_over()

func _on_cop_area_left_area_entered(_area: Area2D) -> void:
	_game_over()

func _on_game_over_timer_timeout() -> void:
	%Lose.visible = true
