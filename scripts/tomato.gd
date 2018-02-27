extends RigidBody

const ALIVE_TIMEOUT = 5.0;

var time = 0.0;
var owner_tom = null;

func _ready():
	connect("body_entered", self, "body_enter");
	set_process(true);

func _process(delta):
	time += delta;
	
	if time >= ALIVE_TIMEOUT:
		queue_free();

func body_enter(body):
	if owner_tom == null:
		return;
	
	if owner_tom is preload("res://scripts/zombie.gd") && body is preload("res://scripts/player.gd"):
		globals.game.player_apply_damage(rand_range(5.0,10.0));
		queue_free();
	
	if owner_tom is preload("res://scripts/player.gd") && body is preload("res://scripts/zombie.gd"):
		body.kill();
		globals.game.player_give_exp(40);
		globals.game.player_apply_damage(-20);
		queue_free();

