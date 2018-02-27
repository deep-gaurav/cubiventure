extends KinematicBody

#G3 Fix
var lm=null
var kin_col=null

# Member variables
var g = -19.6;
var vel = Vector3();
var dir = Vector3();
var chunk = [0,0];

# Constants
const MAX_SLOPE_ANGLE = 30;
const ATTACK_DELAY = 1.0;

var on_floor = false;
var next_idle = 0.0;
var next_attack = 0.0;

var tomato = "res://scenes/tomato.tscn";

func _ready():
	tomato = load(tomato);
	
	set_physics_process(true);

func _physics_process(delta):
	vel.y += g*delta
	
	var motion = move(vel*delta)
	
	on_floor = false
	var original_vel = vel
	var floor_velocity = Vector3()
	var attempts = 4
	
	while(is_colliding() and attempts and false):
		var n = get_collision_normal();
		var p = get_collision_position();
		var collider = get_collider();
		
		if (rad2deg(acos(n.dot(Vector3(0, 1, 0)))) < MAX_SLOPE_ANGLE):
				# If angle to the "up" vectors is < angle tolerance,
				# char is on floor
				floor_velocity = get_collider_velocity()
				on_floor = true
		if motion.length()<0.001:
			break
		motion = n.slide(motion)
		vel = n.slide(vel)
		if (original_vel.dot(vel) > 0):
			# Do not allow to slide towads the opposite direction we were coming from
			motion=move(motion)
			if (motion.length() < 0.001):
				break
		attempts -= 1
	
	if (on_floor and floor_velocity != Vector3()):
		move(floor_velocity*delta)
	
	###NOT IN 3
	var trans = get_transform();
	trans.basis = Basis(Quat(trans.basis).slerp(Quat(Vector3(0,-1,0), -atan2(dir.x, dir.z)), 10*delta));
	set_transform(trans);
	###
	
	
	if globals.game.time > next_idle:
		next_idle = globals.game.time + 2.0;
		set_animation("idle");
		
		if globals.player != null && !globals.player_dying:
			var dist = globals.player.get_global_transform().origin-get_global_transform().origin;
			var eyesight = 15.0;
			if globals.world_time >= 18 || globals.world_time < 5.5:
				eyesight = 20.0;
			
			if dist.length() < eyesight:
				dir.x = dist.x;
				dir.z = dist.z;
				dir = dir.normalized();
				attack();

func set_animation(ani, force = false, speed = 1.0):
	var ap = get_node("models/animations");
	if ap.get_current_animation() != ani || force:
		ap.play(ani);
		ap.set_speed_scale(speed);

func attack():
	if globals.game.time < next_attack:
		return;
	
	next_idle = globals.game.time+ATTACK_DELAY;
	next_attack = next_idle;
	
	set_animation("shoot", true);
	
	var inst = tomato.instance();
	inst.owner_tom = self;
	inst.set_translation(get_translation()+dir+Vector3(0,1.5,0));
	inst.apply_impulse(Vector3(), dir*20);
	inst.set_angular_velocity(Vector3(1,1,1)*deg2rad(360));
	get_node("../").add_child(inst, true);

func kill():
	var arr = globals.zombies_killed;
	arr.push_back(chunk);
	globals.zombies_killed = arr;
	queue_free();

func move(mv):
	kin_col=move_and_collide(mv)
	if kin_col!=null:
		return kin_col.remainder
	else:
		return Vector3()

func is_colliding():
	if kin_col!=null:
		return true
	else:
		return false
func get_collision_normal():
	return kin_col.normal
	for x in range(get_slide_count()):
		if get_slide_collision(x):
			return get_slide_collision(x).normal

func get_collision_position():
	return kin_col.position
	for x in range(get_slide_count()):
		if get_slide_collision(x):
			return get_slide_collision(x).position

func get_collider():
	return kin_col.collider
	for x in range(get_slide_count()):
		if get_slide_collision(x):
			return get_slide_collision(x).collider
			
func get_collider_velocity():
	return kin_col.collider_velocity
	for x in range(get_slide_count()):
		if get_slide_collision(x):
			return get_slide_collision(x).collider_velocity