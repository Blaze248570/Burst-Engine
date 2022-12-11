package characters;

import levels.MasterLevel;

using StringTools;

typedef AnimationData = {
	var anim:String;
	var name:String;
	var indices:Array<Int>;
	var fps:Int;
	var loop:Bool;
	var offsets:Array<Int>;
}

class Character extends flixel.FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animationData:Array<AnimationData> = null;
	public var debugMode:Bool = false;

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var missAnimations:Array<Bool> = [false, false, false, false];

	public var partner:Character = null;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;

		switch (curCharacter)
		{
			default:
				positionArray = [0, 350];

				frames = Paths.getSparrowAtlas('BOYFRIEND');
				flipX = !isPlayer;

				animationData = [
					{offsets: [0, -5], name: "BF idle dance", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [5, -6], name: "BF NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [7, 19], name: "BF NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
					{offsets: [-20, -51], name: "BF NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [-15, -19], name: "BF NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
					{offsets: [-46, 27], name: "BF NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [-46, 27], name: "BF NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
					{offsets: [-48, -7], name: "BF NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
					{offsets: [-44, 22], name: "BF NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'},
					{offsets: [-3, 5], name: "BF HEY", loop: false, indices: [], fps: 24, anim: 'hey'},
					{offsets: [14, 18], name: "BF hit", loop: false, indices: [], fps: 24, anim: 'hurt'},
					{offsets: [-4, 0], name: "BF idle shaking", loop: false, indices: [], fps: 24, anim: 'scared'},
					{offsets: [-10, -16], name: "boyfriend dodge", loop: false, indices: [], fps: 24, anim: 'dodge'},
					{offsets: [294, 267], name: "boyfriend attack", loop: false, indices: [], fps: 24, anim: 'attack'},
					{offsets: [-40, -40], name: "bf pre attack", loop: false, indices: [], fps: 24, anim: 'pre-attack'}
				];
			case 'bf-dead':
				positionArray = [0, 350];

				frames = Paths.getSparrowAtlas('BOYFRIEND_DEAD');
				flipX = !isPlayer;

				animationData = [
					{offsets: [37, 11], name: "BF dies", loop: false, indices: [], fps: 24, anim: 'firstDeath'},
					{offsets: [37, 5], name: "BF Dead Loop", loop: true, indices: [], fps: 24, anim: 'deathLoop'},
					{offsets: [37, 69], name: "BF Dead confirm", loop: false, indices: [], fps: 24, anim: 'deathConfirm'},
				];

			case 'bf-christmas':
				positionArray = [0, 350];
				cameraPosition = [0, -100];

				frames = Paths.getSparrowAtlas('christmas/bfChristmas');
				flipX = !isPlayer;

				animationData = [
					{anim: 'idle', name: 'BF idle dance', fps: 24, loop: false, indices: [], offsets: [-3, 1]},
					{anim: 'singLEFT', name: 'BF NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [12, -6]},
					{anim: 'singDOWN', name: 'BF NOTE DOWN0', fps: 24, loop: false, indices: [], offsets: [-10, -50]},
					{anim: 'singUP', name: 'BF NOTE UP0', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHT', name: 'BF NOTE RIGHT0', fps: 24, loop: false, indices: [], offsets: [-38, -7]},
					{anim: 'singLEFTmiss', name: 'BF NOTE LEFT MISS', fps: 24, loop: false, indices: [], offsets: [12, 24]},
					{anim: 'singDOWNmiss', name: 'BF NOTE DOWN MISS', fps: 24, loop: false, indices: [], offsets: [-11, -19]},
					{anim: 'singUPmiss', name: 'BF NOTE UP MISS', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHTmiss', name: 'BF NOTE RIGHT MISS', fps: 24, loop: false, indices: [], offsets: [-30, 21]},
					{anim: 'hey', name: 'BF HEY', fps: 24, loop: false, indices: [], offsets: [-3, 5]}
				];
				
			case 'bf-car':
				positionArray = [0, 350];
				cameraPosition = [200, 0];

				frames = Paths.getSparrowAtlas('bfCar');
				flipX = !isPlayer;

				animationData = [
					{anim: 'idle', name: 'BF idle dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'BF NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [12, -6]},
					{anim: 'singLEFTmiss', name: 'BF NOTE LEFT MISS', fps: 24, loop: false, indices: [], offsets: [12, 24]},
					{anim: 'singDOWN', name: 'BF NOTE DOWN0', fps: 24, loop: false, indices: [], offsets: [-10, -50]},
					{anim: 'singDOWNmiss', name: 'BF NOTE DOWN MISS', fps: 24, loop: false, indices: [], offsets: [-11, -19]},
					{anim: 'singUP', name: 'BF NOTE UP0', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singUPmiss', name: 'BF NOTE UP MISS', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHT', name: 'BF NOTE RIGHT0', fps: 24, loop: false, indices: [], offsets: [-38, -7]},
					{anim: 'singRIGHTmiss', name: 'BF NOTE RIGHT MISS', fps: 24, loop: false, indices: [], offsets: [-30, 21]}
				];

			case 'bf-pixel':
				positionArray = [0, 350];
				cameraPosition = [50, -60];

				frames = Paths.getSparrowAtlas('weeb/bfPixel');
				flipX = !isPlayer;
				antialiasing = false;

				setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
				updateHitbox();

				animationData = [
					{anim: 'idle', name: 'BF IDLE instance 1', fps: 24, loop: false, indices: [], offsets: [2, 0]},
					{anim: 'singLEFT', name: 'BF RIGHT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFTmiss', name: 'BF LEFT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singDOWNmiss', name: 'BF DOWN MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singDOWN', name: 'BF DOWN NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singUP', name: 'BF UP NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singUPmiss', name: 'BF UP MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singRIGHT', name: 'BF LEFT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singRIGHTmiss', name: 'BF RIGHT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]}
				];

				if (isPlayer) {
					animationData = [
						{anim: 'idle', name: 'BF IDLE instance 1', fps: 24, loop: false, indices: [], offsets: [7, 0]},
						{anim: 'singLEFT', name: 'BF LEFT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singLEFTmiss', name: 'BF LEFT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singDOWN', name: 'BF DOWN NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singDOWNmiss', name: 'BF DOWN MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singUP', name: 'BF UP NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singUPmiss', name: 'BF UP MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singRIGHT', name: 'BF RIGHT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singRIGHTmiss', name: 'BF RIGHT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]}
					];
				}

			case 'bf-pixel-dead':
				positionArray = [0, 350];
				cameraPosition = [50, -60];

				frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD');
				flipX = !isPlayer;
				antialiasing = false;

				setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
				updateHitbox();
				
				animationData = [
					{anim: 'firstDeath', name: 'BF Dies pixel', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'deathLoop', name: 'Retry Loop', fps: 24, loop: true, indices: [], offsets: [-30, -12]},
					{anim: 'deathConfirm', name: 'RETRY CONFIRM', fps: 24, loop: false, indices: [], offsets: [-26, -12]}
				];

			case 'gf' | 'gf-christmas':
				frames = Paths.getSparrowAtlas(curCharacter == 'gf-christmas' ? 'christmas/gfChristmas' : 'GF_assets');

				animationData = [
					{anim: 'cheer', name: 'GF Cheer', indices: [], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'singLEFT', name: 'GF left note', indices: [], fps: 24, loop: false, offsets: [0, -19]},
					{anim: 'singDOWN', name: 'GF Down Note', indices: [], fps: 24, loop: false, offsets: [0, -20]},
					{anim: 'singUP', name: 'GF Up Note', indices: [], fps: 24, loop: false, offsets: [0, 4]},
					{anim: 'singRIGHT', name: 'GF Right Note', indices: [], fps: 24, loop: false, offsets: [0, -20]},
					{anim: 'sad', name: 'gf sad', indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], fps: 24, loop: false, offsets: [-2, -2]},
					{anim: 'danceLeft', name: 'GF Dancing Beat', indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], fps: 24, loop: false, offsets: [0, -9]},
					{anim: 'danceRight', name: 'GF Dancing Beat', indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], fps: 24, loop: false, offsets: [0, -9]},
					{anim: 'hairBlow', name: 'GF Dancing Beat Hair blowing', indices: [0, 1, 2, 3], fps: 24, loop: true, offsets: [45, -8]},
					{anim: 'hairFall', name: 'GF Dancing Beat Hair Landing', indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], fps: 24, loop: true, offsets: [0, -9]},
					{anim: 'scared', name: 'GF FEAR', indices: [], fps: 24, loop: true, offsets: [-2, -17]},
				];

			case 'gf-car':
				frames = Paths.getSparrowAtlas('gfCar');

				animationData = [
					{anim: 'danceLeft', name: 'GF Dancing Beat Hair blowing CAR', indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'danceRight', name: 'GF Dancing Beat Hair blowing CAR', indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], fps: 24, loop: false, offsets: [0, 0]}
				];

			case 'gf-pixel':
				cameraPosition = [-20, 80];

				frames = Paths.getSparrowAtlas('weeb/gfPixel');
				antialiasing = false;

				setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
				updateHitbox();

				animationData = [
					{anim: 'danceLeft', name: 'GF IDLE', indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'danceRight', name: 'GF IDLE', indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], fps: 24, loop: false, offsets: [0, 0]}
				];

			case 'dad':
				frames = Paths.getSparrowAtlas('DADDY_DEAREST');

				animationData = [
					{anim: 'idle', name: 'Dad idle dance', indices: [], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Dad Sing Note LEFT', indices: [], fps: 24, loop: false, offsets: [-10, -10]},
					{anim: 'singDOWN', name: 'Dad Sing Note DOWN', indices: [], fps: 24, loop: false, offsets: [0, -30]},
					{anim: 'singUP', name: 'Dad Sing Note UP', indices: [], fps: 24, loop: false, offsets: [-6, 50]},
					{anim: 'singRIGHT', name: 'Dad Sing Note RIGHT', indices: [], fps: 24, loop: false, offsets: [0, 27]},
				];

			case 'spooky':
				positionArray = [0, 200];
				frames = Paths.getSparrowAtlas('spooky_kids_assets');

				animationData = [
					{anim: 'danceLeft', name: 'spooky dance idle', indices: [0, 2, 6], fps: 12, loop: false, offsets: [0, 0]},
					{anim: 'danceRight', name: 'spooky dance idle', indices: [8, 10, 12, 14], fps: 12, loop: false, offsets: [0, 0]},
					{anim: 'singLEFT', name: 'note sing left', indices: [], fps: 24, loop: false, offsets: [130, -10]},
					{anim: 'singDOWN', name: 'spooky DOWN note', indices: [], fps: 24, loop: false, offsets: [-50, -130]},
					{anim: 'singUP', name: 'spooky UP NOTE', indices: [], fps: 24, loop: false, offsets: [-20, 26]},
					{anim: 'singRIGHT', name: 'spooky sing right', indices: [], fps: 24, loop: false, offsets: [-130, -14]},
				];
			
			case 'monster' | 'monster-christmas':
				positionArray = [0, 100];

				frames = Paths.getSparrowAtlas(curCharacter == 'monster-christmas' ? 'christmas/monsterChristmas' : 'Monster_Assets');

				animationData = [
					{anim: 'idle', name: 'monster idle', indices: [], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Monster left note', indices: [], fps: 24, loop: false, offsets: [-30, 0]},
					{anim: 'singDOWN', name: 'monster down', indices: [], fps: 24, loop: false, offsets: [-30, -40]},
					{anim: 'singUP', name: 'monster up note', indices: [], fps: 24, loop: false, offsets: [-20, 50]},
					{anim: 'singRIGHT', name: 'Monster Right note', indices: [], fps: 24, loop: false, offsets: [-51, 0]},
				];

			case 'pico':
				positionArray = [0, 300];
				frames = Paths.getSparrowAtlas('Pico_FNF_assetss');
				flipX = !isPlayer;

				animationData = [
					{anim: 'idle', name: 'Pico Idle Dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Pico Note Right0', fps: 24, loop: false, indices: [], offsets: [65, 9]},
					{anim: 'singLEFTmiss', name: 'Pico Note Right Miss', fps: 24, loop: false, indices: [], offsets: [62, 64]},
					{anim: 'singDOWN', name: 'Pico Down Note0', fps: 24, loop: false, indices: [], offsets: [200, -70]},
					{anim: 'singDOWNmiss', name: 'Pico Down Note MISS', fps: 24, loop: false, indices: [], offsets: [210, -28]},
					{anim: 'singUP', name: 'pico Up note0', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singUPmiss', name: 'pico Up note miss', fps: 24, loop: false, indices: [], offsets: [-19, 67]},
					{anim: 'singRIGHT', name: 'Pico NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [-68, -7]},
					{anim: 'singRIGHTmiss', name: 'Pico NOTE LEFT miss', fps: 24, loop: false, indices: [], offsets: [-60, 41]}
				];

			case 'mom' | 'mom-car':
				frames = Paths.getSparrowAtlas(curCharacter == 'mom-car' ? 'momCar' : 'Mom_Assets');

				animationData = [
					{anim: 'idle', name: 'Mom Idle', indices: [], fps: 24, loop: false, offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Mom Left Pose', indices: [], fps: 24, loop: false, offsets: [250, -23]},
					{anim: 'singDOWN', name: 'MOM DOWN POSE', indices: [], fps: 24, loop: false, offsets: [20, -160]},
					{anim: 'singUP', name: 'Mom Up Pose', indices: [], fps: 24, loop: false, offsets: [14, 71]},
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					{anim: 'singRIGHT', name: 'Mom Pose Left', indices: [], fps: 24, loop: false, offsets: [10, -60]},
				];

			case 'parents-christmas':
				positionArray = [-500, 0];
				frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets');

				animationData = [
					{anim: 'idle', name: 'Parent Christmas Idle', fps: 24, loop: false, indices: [], offsets: [2, 0]},
					{anim: 'singLEFT', name: 'Parent Left Note Dad', fps: 24, loop: false, indices: [], offsets: [-30, 16]},
					{anim: 'singDOWN', name: 'Parent Down Note Dad', fps: 24, loop: false, indices: [], offsets: [-31, -29]},
					{anim: 'singUP', name: 'Parent Up Note Dad', fps: 24, loop: false, indices: [], offsets: [-47, 24]},
					{anim: 'singRIGHT', name: 'Parent Right Note Dad', fps: 24, loop: false, indices: [], offsets: [-1, -23]},
					{anim: 'singLEFT-alt', name: 'Parent Left Note Mom', fps: 24, loop: false, indices: [], offsets: [-30, 15]},
					{anim: 'singDOWN-alt', name: 'Parent Down Note Mom', fps: 24, loop: false, indices: [], offsets: [-30, -27]},
					{anim: 'singUP-alt', name: 'Parent Up Note Mom', fps: 24, loop: false, indices: [], offsets: [-47, 24]},
					{anim: 'singRIGHT-alt', name: 'Parent Right Note Mom', fps: 24, loop: false, indices: [], offsets: [-1, -24]},
				];
			
			case 'senpai' | 'senpai-angry':
				positionArray = [150, 360];
				cameraPosition = [-240, -330];
				frames = Paths.getSparrowAtlas('weeb/senpai');
				antialiasing = false;
	
				setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
				updateHitbox();

				animationData = (curCharacter == 'senpai-angry') 
				  ? (
					[
						{offsets: [2, 0], name: "Angry Senpai Idle instance 1", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [40, 0], name: "Angry Senpai LEFT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [14, 0], name: "Angry Senpai DOWN NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [5, 37], name: "Angry Senpai UP NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [0, 0], name: "Angry Senpai RIGHT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
					]
				) : (
					[
						{offsets: [1, 0], name: "Senpai Idle instance 1", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [40, 0], name: "SENPAI LEFT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [14, 0], name: "SENPAI DOWN NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [5, 37], name: "SENPAI UP NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [0, 0], name: "SENPAI RIGHT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
					]
				) ;

			case 'spirit':
				positionArray = [-150, 100];

				frames = Paths.getPackerAtlas('weeb/spirit');
				antialiasing = false;

				setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
				updateHitbox();

				animationData = [
					{offsets: [-218, -280], name: "idle spirit_", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [-200, -280], name: "left_", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [170, 110], name: "spirit down_", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [-220, -240], name: "up_", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [-220, -280], name: "right_", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
				];

		}

		loadAnimations();

		/* 
			// Don't believe this is of use anymore
			if (isPlayer)
			{
				flipX = !flipX;

				// Doesn't flip for BF, since his are already in the right place???
				if (!curCharacter.startsWith('bf'))
				{
					// var animArray
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;

					// IF THEY HAVE MISS ANIMATIONS??
					if (animation.getByName('singRIGHTmiss') != null)
					{
						var oldMiss = animation.getByName('singRIGHTmiss').frames;
						animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
						animation.getByName('singLEFTmiss').frames = oldMiss;
					}
				}
			}
		*/
	}

	private function loadAnimations(reset:Bool = false) {
		if(reset) animation.destroyAnimations();

		if(animationData != null && animationData.length > 0) {
			for(anim in animationData) {
				if(anim.indices.length > 0) {
					animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
				} else {
					animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
				}

				animOffsets[anim.anim] = anim.offsets;
			}
		}

		missAnimations = [ 
			animOffsets.exists('singLEFTmiss'),
			animOffsets.exists('singDOWNmiss'),
			animOffsets.exists('singUPmiss'),
			animOffsets.exists('singRIGHTmiss')
		];

		danceIdle = (animation.exists("danceLeft") && animation.exists("danceRight"));
		dance();
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	/**
	 * FOR GF DANCING SHIT
	 */
	public var danced:Bool = false;
	private var danceIdle:Bool = false;
	public function dance()
	{
		if (!debugMode)
		{
			if(danceIdle) {
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			} else {
				playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
