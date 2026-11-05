extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# إعدادات حساسية الماوس والكاميرا
@export var mouse_sensitivity: float = 0.003
@onready var camera = $Camera3D

func _ready():
	# تثبيت مؤشر الماوس جوه اللعبة للتحكم بالرؤية
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# تحريك الكاميرا بالماوس
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# نظام تكسير البلوكات بالكليك
	if event is InputEventMouseButton and event.pressed:
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 10.0
		
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			if event.button_index == MOUSE_BUTTON_LEFT:
				# كليك شمال لتكسير البلوكة أو الجسم اللي اللاعب باصص عليه
				print("تم الضغط لتكسير: ", result.collider.name)
				# لو عايز البلوكة تختفي تماماً أول ما تدوس عليها، شيل علامة الـ # من السطر الجاي:
				# result.collider.queue_free()

func _physics_process(delta: float):
	# إضافة الجاذبية
	if not is_on_floor():
		velocity += get_gravity() * delta

	# التعامل مع النط (Jump)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# أخذ اتجاه الحركة (W, A, S, D)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
