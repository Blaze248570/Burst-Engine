package;

#if lol_this_is_a_reference

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var shortName:String = 'bf';
	public var arrowSkin:String = 'NOTE_assets';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	public var hasMissAnimations:Bool = false;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		var library:String = null;
		switch (curCharacter) {
			case 'bf-dead':
				positionArray = [0, 350];
				cameraPosition = [0, 0];

				healthIcon = 'bf';
				singDuration = 4;
				flipX = true;
				healthColorArray = [49, 176, 209];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/BOYFRIEND_DEAD');

				animationsArray = [
					{offsets: [37, 11], name: "BF dies", loop: false, indices: [], fps: 24, anim: 'firstDeath'},
					{offsets: [37, 5], name: "BF Dead Loop", loop: true, indices: [], fps: 24, anim: 'deathLoop'},
					{offsets: [37, 69], name: "BF Dead confirm", loop: false, indices: [], fps: 24, anim: 'deathConfirm'},
				];
			case 'bf-car':
				positionArray = [0, 350];
				cameraPosition = [0, 0];
				healthIcon = 'bf';
				healthColorArray = [49, 176, 209];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/bfCar');

				animationsArray = [
					{anim: 'idle', name: 'BF idle dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'BF NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [12, -6]},
					{anim: 'singDOWN', name: 'BF NOTE DOWN0', fps: 24, loop: false, indices: [], offsets: [-10, -50]},
					{anim: 'singUP', name: 'BF NOTE UP0', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHT', name: 'BF NOTE RIGHT0', fps: 24, loop: false, indices: [], offsets: [-38, -7]},
					{anim: 'singLEFTmiss', name: 'BF NOTE LEFT MISS', fps: 24, loop: false, indices: [], offsets: [12, 24]},
					{anim: 'singDOWNmiss', name: 'BF NOTE DOWN MISS', fps: 24, loop: false, indices: [], offsets: [-11, -19]},
					{anim: 'singUPmiss', name: 'BF NOTE UP MISS', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHTmiss', name: 'BF NOTE RIGHT MISS', fps: 24, loop: false, indices: [], offsets: [-30, 21]},
					{anim: 'idle-loop', name: 'BF idle dance', fps: 24, loop: true, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT-loop', name: 'BF NOTE LEFT0', fps: 24, loop: true, indices: [], offsets: [12, -6]},
					{anim: 'singDOWN-loop', name: 'BF NOTE DOWN0', fps: 24, loop: true, indices: [], offsets: [-10, -50]},
					{anim: 'singUP-loop', name: 'BF NOTE UP0', fps: 24, loop: true, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHT-loop', name: 'BF NOTE RIGHT0', fps: 24, loop: true, indices: [], offsets: [-38, -7]}
				];
			case 'bf-christmas':
				positionArray = [0, 350];
				cameraPosition = [0, 0];
				healthIcon = 'bf';
				healthColorArray = [49, 176, 209];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/bfChristmas');

				animationsArray = [
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
			case 'bf-holding-gf':
				positionArray = [0, 350];
				cameraPosition = [0, 0];
				healthIcon = 'bf';
				healthColorArray = [49, 176, 209];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/bfAndGF');

				animationsArray = [
					{anim: 'idle', name: 'BF idle dance', fps: 24, loop: false, indices: [], offsets: [-5, 0]},
					{anim: 'singLEFT', name: 'BF NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [12, 7]},
					{anim: 'singDOWN', name: 'BF NOTE DOWN0', fps: 24, loop: false, indices: [], offsets: [-10, -10]},
					{anim: 'singUP', name: 'BF NOTE UP0', fps: 24, loop: false, indices: [], offsets: [-29, 10]},
					{anim: 'singRIGHT', name: 'BF NOTE RIGHT0', fps: 24, loop: false, indices: [], offsets: [-41, 23]},
					{anim: 'singLEFTmiss', name: 'BF NOTE LEFT MISS', fps: 24, loop: false, indices: [], offsets: [12, 7]},
					{anim: 'singDOWNmiss', name: 'BF NOTE DOWN MISS', fps: 24, loop: false, indices: [], offsets: [-10, -10]},
					{anim: 'singUPmiss', name: 'BF NOTE UP MISS', fps: 24, loop: false, indices: [], offsets: [-29, 10]},
					{anim: 'singRIGHTmiss', name: 'BF NOTE RIGHT MISS', fps: 24, loop: false, indices: [], offsets: [-42, 23]},
					{anim: 'bfCatch', name: 'BF catches GF', fps: 24, loop: false, indices: [], offsets: [0, 90]}
				];
			case 'bf-holding-gf-dead':
				positionArray = [0, 350];
				cameraPosition = [50, -60];
				healthIcon = 'bf';
				healthColorArray = [49, 176, 209];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/bfHoldingGF-DEAD');

				setGraphicSize(Std.int(width * 1.05));
				updateHitbox();

				animationsArray = [
					{anim: 'firstDeath', name: 'BF Dies with GF', fps: 24, loop: false, indices: [], offsets: [37, 14]},
					{anim: 'deathLoop', name: 'BF Dead with GF Loop', fps: 24, loop: true, indices: [], offsets: [37, -3]},
					{anim: 'deathConfirm', name: 'RETRY confirm holding gf', fps: 24, loop: false, indices: [], offsets: [37, 28]}
				];
			case 'bf-pixel':
				positionArray = [80, 480];
				cameraPosition = [50, -160];
				healthIcon = 'bf-pixel';
				healthColorArray = [123, 214, 246];
				flipX = true;

				noAntialiasing = true;
				antialiasing = false;

				frames = Paths.getSparrowAtlas('characters/bf/bfPixel');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				animationsArray = [
					{anim: 'idle', name: 'BF IDLE instance 1', fps: 24, loop: false, indices: [], offsets: [2, 0]},
					{anim: 'singRIGHT', name: 'BF LEFT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singDOWN', name: 'BF DOWN NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singUP', name: 'BF UP NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'BF RIGHT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFTmiss', name: 'BF LEFT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singDOWNmiss', name: 'BF DOWN MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singUPmiss', name: 'BF UP MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singRIGHTmiss', name: 'BF RIGHT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]}
				];

				if (isPlayer) {
					positionArray = [0, 350];
					cameraPosition = [50, -60];
					animationsArray = [
						{anim: 'idle', name: 'BF IDLE instance 1', fps: 24, loop: false, indices: [], offsets: [7, 0]},
						{anim: 'singLEFT', name: 'BF LEFT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singDOWN', name: 'BF DOWN NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singUP', name: 'BF UP NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singRIGHT', name: 'BF RIGHT NOTE instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singLEFTmiss', name: 'BF LEFT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singDOWNmiss', name: 'BF DOWN MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singUPmiss', name: 'BF UP MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singRIGHTmiss', name: 'BF RIGHT MISS instance 1', fps: 24, loop: false, indices: [], offsets: [0, 0]}
					];
				}
			case 'bf-pixel-dead':
				positionArray = [0, 350];
				cameraPosition = [50, -60];
				healthIcon = 'bf-pixel';
				healthColorArray = [49, 176, 209];
				flipX = true;

				antialiasing = false;
				noAntialiasing = true;

				frames = Paths.getSparrowAtlas('characters/bf/bfPixelsDEAD');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				animationsArray = [
					{anim: 'firstDeath', name: 'BF Dies pixel', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'deathLoop', name: 'Retry Loop', fps: 24, loop: true, indices: [], offsets: [-30, -12]},
					{anim: 'deathConfirm', name: 'RETRY CONFIRM', fps: 24, loop: false, indices: [], offsets: [-26, -12]}
				];
			case 'gf' | 'gf-christmas':
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'gf';
				healthColorArray = [165, 0, 77];
				flipX = false;

				antialiasing = ClientPrefs.globalAntialiasing;

				if (curCharacter == 'gf-christmas')
					frames = Paths.getSparrowAtlas('characters/gf/gfChristmas');
				else
					frames = Paths.getSparrowAtlas('characters/gf/GF_assets');

				animationsArray = [
					{anim: 'danceLeft', name: 'GF Dancing Beat', fps: 24, loop: false, indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], offsets: [0, -9]},
					{anim: 'danceRight', name: 'GF Dancing Beat', fps: 24, loop: false, indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], offsets: [0, -9]},
					{anim: 'cheer', name: 'GF Cheer', fps: 24, loop: false, indices: [], offsets: [3, 0]},
					{anim: 'singLEFT', name: 'GF left note', fps: 24, loop: false, indices: [], offsets: [0, -19]},
					{anim: 'singDOWN', name: 'GF Down Note', fps: 24, loop: false, indices: [], offsets: [0, -20]},
					{anim: 'singUP', name: 'GF Up Note', fps: 24, loop: false, indices: [], offsets: [0, 4]},
					{anim: 'singRIGHT', name: 'GF Right Note', fps: 24, loop: false, indices: [], offsets: [0, -20]},
					{anim: 'sad', name: 'gf sad', fps: 24, loop: false, indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], offsets: [-2, -21]},
					{anim: 'hairBlow', name: 'GF Dancing Beat Hair blowing', fps: 24, loop: true, indices: [0, 1, 2, 3], offsets: [45, -8]},
					{anim: 'hairFall', name: 'GF Dancing Beat Hair Landing', fps: 24, loop: false, indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], offsets: [0, -9]},
					{anim: 'scared', name: 'GF FEAR', fps: 24, loop: true, indices: [], offsets: [-2, -17]}
				];
			case 'gf-car':
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'gf';
				healthColorArray = [165, 0, 77];
				flipX = false;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/gf/gfCar');

				animationsArray = [
					{anim: 'danceLeft', name: 'GF Dancing Beat Hair blowing CAR', fps: 24, loop: false, indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], offsets: [0, 0]},
					{anim: 'danceRight', name: 'GF Dancing Beat Hair blowing CAR', fps: 24, loop: false, indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], offsets: [0, 0]}
				];
			case 'gf-tankmen':
				positionArray = [0, 0];
				cameraPosition = [0, 140];
				healthIcon = 'gf';
				healthColorArray = [165, 0, 77];
				flipX = false;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/gf/gfTankmen');

				animationsArray = [
					{anim: 'sad', name: 'GF Crying at Gunpoint ', fps: 24, loop: false, indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], offsets: [0, -27]},
					{anim: 'danceLeft', name: 'GF Dancing at Gunpoint', fps: 24, loop: false, indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], offsets: [0, -9]},
					{anim: 'danceRight', name: 'GF Dancing at Gunpoint', fps: 24, loop: false, indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], offsets: [0, -9]}
				];
			case 'gf-pixel':
				positionArray = [0, 0];
				cameraPosition = [-20, 80];
				healthIcon = 'gf';
				healthColorArray = [165, 0, 77];
				flipX = false;

				antialiasing = false;
				noAntialiasing = true;

				frames = Paths.getSparrowAtlas('characters/gf/gfPixel');

				setGraphicSize(Std.int(width * 5.99999999999999)); //Wtf?
				updateHitbox();

				animationsArray = [
					{anim: 'danceLeft', name: 'GF IDLE', fps: 24, loop: false, indices: [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], offsets: [0, 0]},
					{anim: 'danceRight', name: 'GF IDLE', fps: 24, loop: false, indices: [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], offsets: [0, 0]}
				];
			case 'dad':
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'dad';
				healthColorArray = [175, 102, 206];
				singDuration = 6.1;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/dad/DADDY_DEAREST');

				animationsArray = [
					{anim: 'idle', name: 'Dad idle dance', fps: 24, loop: false, indices: [], offsets: [-5, -20]},
					{anim: 'singLEFT', name: 'Dad Sing Note LEFT', fps: 24, loop: false, indices: [], offsets: [-9, 10]},
					{anim: 'singDOWN', name: 'Dad Sing Note DOWN', fps: 24, loop: false, indices: [], offsets: [0, -30]},
					{anim: 'singUP', name: 'Dad Sing Note UP', fps: 24, loop: false, indices: [], offsets: [-6, 50]},
					{anim: 'singRIGHT', name: 'Dad Sing Note RIGHT', fps: 24, loop: false, indices: [], offsets: [0, 27]},
					{anim: 'idle-loop', name: 'Dad idle dance', fps: 24, loop: true, indices: [10, 11, 12, 12], offsets: [-5, -20]},
					{anim: 'singLEFT-loop', name: 'Dad Sing Note LEFT', fps: 24, loop: true, indices: [12, 13, 14, 15], offsets: [-9, 10]},
					{anim: 'singUP-loop', name: 'Dad Sing Note UP', fps: 24, loop: true, indices: [56, 57, 58, 59], offsets: [-6, 50]},
					{anim: 'singRIGHT-loop', name: 'Dad Sing Note RIGHT', fps: 24, loop: true, indices: [15, 16, 17, 18], offsets: [0, 27]}
				];
			case 'spooky':
				positionArray = [0, 200];
				cameraPosition = [0, 0];
				healthIcon = 'spooky';
				healthColorArray = [213, 126, 0];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/spooky/spooky_kids_assets');

				animationsArray = [
					{anim: 'danceLeft', name: 'spooky dance idle', fps: 12, loop: false, indices: [0, 2, 6], offsets: [0, 0]},
					{anim: 'danceRight', name: 'spooky dance idle', fps: 12, loop: false, indices: [8, 10, 12, 14], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'note sing left', fps: 24, loop: false, indices: [], offsets: [130, -10]},
					{anim: 'singDOWN', name: 'spooky DOWN note', fps: 24, loop: false, indices: [], offsets: [-50, -130]},
					{anim: 'singUP', name: 'spooky UP NOTE', fps: 24, loop: false, indices: [], offsets: [-20, 26]},
					{anim: 'singRIGHT', name: 'spooky sing right', fps: 24, loop: false, indices: [], offsets: [-130, -14]},
					{anim: 'hey', name: 'spooky kids YEAH!!', fps: 24, loop: false, indices: [], offsets: [59, -20]}
				];
			case 'monster' | 'monster-christmas':
				positionArray = [0, 100];
				cameraPosition = [0, 0];
				healthIcon = 'monster';
				healthColorArray = [243, 255, 110];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/monster/Monster_Assets');

				animationsArray = [
					{anim: 'idle', name: 'monster idle', fps: 24, loop: false, indices: [], offsets: [3, 0]},
					{anim: 'singLEFT', name: 'Monster left note', fps: 24, loop: false, indices: [], offsets: [-30, 20]},
					{anim: 'singDOWN', name: 'monster down', fps: 24, loop: false, indices: [], offsets: [-50, -80]},
					{anim: 'singUP', name: 'monster up note', fps: 24, loop: false, indices: [], offsets: [-20, 94]},
					{anim: 'singRIGHT', name: 'Monster Right note', fps: 24, loop: false, indices: [], offsets: [-51, 30]},
					{anim: 'idle-loop', name: 'monster idle', fps: 24, loop: true, indices: [], offsets: [3, 0]},
					{anim: 'singLEFT-loop', name: 'Monster left note', fps: 24, loop: true, indices: [], offsets: [-30, 20]},
					{anim: 'singDOWN-loop', name: 'monster down', fps: 24, loop: true, indices: [], offsets: [-50, -80]},
					{anim: 'singUP-loop', name: 'monster up note', fps: 24, loop: true, indices: [], offsets: [-20, 94]},
					{anim: 'singRIGHT-loop', name: 'Monster Right note', fps: 24, loop: true, indices: [], offsets: [-51, 30]}
				];

				if (curCharacter == 'monster-christmas') {
					positionArray = [0, 130];
					frames = Paths.getSparrowAtlas('characters/monster/monsterChristmas');
					animationsArray = [
						{anim: 'idle', name: 'monster idle', fps: 24, loop: false, indices: [], offsets: [1, 0]},
						{anim: 'singLEFT', name: 'Monster left note', fps: 24, loop: false, indices: [], offsets: [-30, 0]},
						{anim: 'singDOWN', name: 'monster down', fps: 24, loop: false, indices: [], offsets: [-40, -94]},
						{anim: 'singUP', name: 'monster up note', fps: 24, loop: false, indices: [], offsets: [-20, 50]},
						{anim: 'singRIGHT', name: 'Monster Right note', fps: 24, loop: false, indices: [], offsets: [-51, 0]},
						{anim: 'idle-loop', name: 'monster idle', fps: 24, loop: true, indices: [], offsets: [1, 0]},
						{anim: 'singLEFT-loop', name: 'Monster left note', fps: 24, loop: true, indices: [], offsets: [-30, 0]},
						{anim: 'singDOWN-loop', name: 'monster down', fps: 24, loop: true, indices: [], offsets: [-40, -94]},
						{anim: 'singUP-loop', name: 'monster up note', fps: 24, loop: true, indices: [], offsets: [-20, 50]},
						{anim: 'singRIGHT-loop', name: 'Monster Right note', fps: 24, loop: true, indices: [], offsets: [-51, 0]}
					];
				} 
			case 'pico':
				positionArray = [0, 300];
				cameraPosition = [0, 0];
				healthIcon = 'pico';
				healthColorArray = [183, 216, 85];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/pico/Pico_FNF_assetss');

				animationsArray = [
					{anim: 'idle', name: 'Pico Idle Dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Pico Note Right0', fps: 24, loop: false, indices: [], offsets: [65, 9]},
					{anim: 'singDOWN', name: 'Pico Down Note0', fps: 24, loop: false, indices: [], offsets: [200, -70]},
					{anim: 'singUP', name: 'pico Up note0', fps: 24, loop: false, indices: [], offsets: [-29, 27]},
					{anim: 'singRIGHT', name: 'Pico NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [-68, -7]},
					{anim: 'singLEFTmiss', name: 'Pico Note Right Miss', fps: 24, loop: false, indices: [], offsets: [62, 64]},
					{anim: 'singDOWNmiss', name: 'Pico Down Note MISS', fps: 24, loop: false, indices: [], offsets: [210, -28]},
					{anim: 'singUPmiss', name: 'pico Up note miss', fps: 24, loop: false, indices: [], offsets: [-19, 67]},
					{anim: 'singRIGHTmiss', name: 'Pico NOTE LEFT miss', fps: 24, loop: false, indices: [], offsets: [-60, 41]}
				];

				if (isPlayer) {
					cameraPosition = [220, 0];
					animationsArray = [
						{anim: 'idle', name: 'Pico Idle Dance', fps: 24, loop: false, indices: [], offsets: [3, 0]},
						{anim: 'singRIGHT', name: 'Pico Note Right0', fps: 24, loop: false, indices: [], offsets: [-48, 2]},
						{anim: 'singDOWN', name: 'Pico Down Note0', fps: 24, loop: false, indices: [], offsets: [84, -80]},
						{anim: 'singUP', name: 'pico Up note0', fps: 24, loop: false, indices: [], offsets: [21, 27]},
						{anim: 'singLEFT', name: 'Pico NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [85, -10]},
						{anim: 'singRIGHTmiss', name: 'Pico Note Right Miss', fps: 24, loop: false, indices: [], offsets: [-45, 50]},
						{anim: 'singDOWNmiss', name: 'Pico Down Note MISS', fps: 24, loop: false, indices: [], offsets: [80, -38]},
						{anim: 'singUPmiss', name: 'pico Up note miss', fps: 24, loop: false, indices: [], offsets: [28, 67]},
						{anim: 'singLEFTmiss', name: 'Pico NOTE LEFT miss', fps: 24, loop: false, indices: [], offsets: [83, 28]}
					];
				}
			case 'pico-speaker':
				positionArray = [120, -125];
				cameraPosition = [-310, 100];
				healthIcon = 'pico';
				healthColorArray = [183, 216, 85];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/pico/picoSpeaker');

				animationsArray = [
					{anim: 'shoot1', name: 'Pico shoot 1', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'shoot2', name: 'Pico shoot 2', fps: 24, loop: false, indices: [], offsets: [-1, -128]},
					{anim: 'shoot3', name: 'Pico shoot 3', fps: 24, loop: false, indices: [], offsets: [412, -64]},
					{anim: 'shoot4', name: 'Pico shoot 4', fps: 24, loop: false, indices: [], offsets: [439, -19]},
					{anim: 'shoot1-loop', name: 'Pico shoot 1', fps: 24, loop: true, indices: [23, 24, 25], offsets: [0, 0]},
					{anim: 'shoot2-loop', name: 'Pico shoot 2', fps: 24, loop: true, indices: [57, 58, 59], offsets: [-1, -128]},
					{anim: 'shoot3-loop', name: 'Pico shoot 3', fps: 24, loop: true, indices: [50, 51, 52], offsets: [412, -64]},
					{anim: 'shoot4-loop', name: 'Pico shoot 4', fps: 24, loop: true, indices: [50, 51, 52], offsets: [439, -19]}
				];
			case 'mom' | 'mom-car':
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'mom';
				healthColorArray = [216, 85, 142];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/mom/Mom_Assets');

				animationsArray = [
					{anim: 'idle', name: 'Mom Idle', fps: 24, loop: false, indices: [], offsets: [0, 0]},
					{anim: 'singLEFT', name: 'Mom Left Pose', fps: 24, loop: false, indices: [], offsets: [250, -23]},
					{anim: 'singDOWN', name: 'MOM DOWN POSE', fps: 24, loop: false, indices: [], offsets: [20, -160]},
					{anim: 'singUP', name: 'Mom Up Pose', fps: 24, loop: false, indices: [], offsets: [14, 71]},
					{anim: 'singRIGHT', name: 'Mom Pose Left', fps: 24, loop: false, indices: [], offsets: [10, -60]}
				];

				if (curCharacter == 'mom-car') {
					frames = Paths.getSparrowAtlas('characters/mom/momCar');
					animationsArray = [
						{anim: 'idle', name: 'Mom Idle', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singLEFT', name: 'Mom Left Pose', fps: 24, loop: false, indices: [], offsets: [250, -23]},
						{anim: 'singDOWN', name: 'MOM DOWN POSE', fps: 24, loop: false, indices: [], offsets: [20, -160]},
						{anim: 'singUP', name: 'Mom Up Pose', fps: 24, loop: false, indices: [], offsets: [14, 71]},
						{anim: 'singRIGHT', name: 'Mom Pose Left', fps: 24, loop: false, indices: [], offsets: [10, -60]},
						{anim: 'idle-loop', name: 'Mom Idle', fps: 24, loop: true, indices: [10, 11, 12, 13], offsets: [0, 0]},
						{anim: 'singLEFT-loop', name: 'Mom Left Pose', fps: 24, loop: true, indices: [6, 7, 8, 9], offsets: [250, -23]},
						{anim: 'singDOWN-loop', name: 'MOM DOWN POSE', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [20, -160]},
						{anim: 'singUP-loop', name: 'Mom Up Pose', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [14, 71]},
						{anim: 'singRIGHT-loop', name: 'Mom Pose Left', fps: 24, loop: true, indices: [6, 7, 8, 9], offsets: [10, -60]}
					];
				}
			case 'parents-christmas':
				positionArray = [-500, 0];
				cameraPosition = [0, 0];
				healthIcon = 'parents';
				healthColorArray = [196, 94, 174];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/parents/mom_dad_christmas_assets');

				animationsArray = [
					{anim: 'idle', name: 'Parent Christmas Idle', fps: 24, loop: false, indices: [], offsets: [2, 0]},
					{anim: 'singLEFT', name: 'Parent Left Note Dad', fps: 24, loop: false, indices: [], offsets: [-30, 16]},
					{anim: 'singDOWN', name: 'Parent Down Note Dad', fps: 24, loop: false, indices: [], offsets: [-31, -29]},
					{anim: 'singUP', name: 'Parent Up Note Dad', fps: 24, loop: false, indices: [], offsets: [-47, 24]},
					{anim: 'singRIGHT', name: 'Parent Right Note Dad', fps: 24, loop: false, indices: [], offsets: [-1, -23]},
					{anim: 'singLEFT-alt', name: 'Parent Left Note Mom', fps: 24, loop: false, indices: [], offsets: [-30, 15]},
					{anim: 'singDOWN-alt', name: 'Parent Down Note Mom', fps: 24, loop: false, indices: [], offsets: [-30, -27]},
					{anim: 'singUP-alt', name: 'Parent Up Note Mom', fps: 24, loop: false, indices: [], offsets: [-47, 24]},
					{anim: 'singRIGHT-alt', name: 'Parent Right Note Mom', fps: 24, loop: false, indices: [], offsets: [-1, -24]},
					//For fuck's sake, why???
					{anim: 'idle-loop', name: 'Parent Christmas Idle', fps: 24, loop: true, indices: [10, 11, 12, 13], offsets: [2, 0]},
					{anim: 'singLEFT-loop', name: 'Parent Left Note Dad', fps: 24, loop: true, indices: [12, 13, 14, 15], offsets: [-30, 16]},
					{anim: 'singDOWN-loop', name: 'Parent Down Note Dad', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [-31, -29]},
					{anim: 'singUP-loop', name: 'Parent Up Note Dad', fps: 24, loop: true, indices: [10, 11, 12, 13], offsets: [-47, 24]},
					{anim: 'singRIGHT-loop', name: 'Parent Right Note Dad', fps: 24, loop: true, indices: [12, 13, 14, 15], offsets: [-1, -23]},
					{anim: 'singLEFT-alt-loop', name: 'Parent Left Note Mom', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [-30, 15]},
					{anim: 'singDOWN-alt-loop', name: 'Parent Down Note Mom', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [-30, -27]},
					{anim: 'singUP-alt-loop', name: 'Parent Up Note Mom', fps: 24, loop: true, indices: [10, 11, 12, 13], offsets: [-47, 24]},
					{anim: 'singRIGHT-alt-loop', name: 'Parent Right Note Mom', fps: 24, loop: true, indices: [11, 12, 13, 14], offsets: [-1, -24]}
				];
			case 'senpai':
				positionArray = [150, 360];
				cameraPosition = [-240, -330];

				healthIcon = 'senpai-pixel';
				healthColorArray = [255, 170, 111];
				shortName = 'senpai';

				antialiasing = false;
				noAntialiasing = true;

				frames = Paths.getSparrowAtlas('characters/senpai/senpai');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				animationsArray = [
					{offsets: [1, 0], name: "Senpai Idle instance 1", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [40, 0], name: "SENPAI LEFT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [14, 0], name: "SENPAI DOWN NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [5, 37], name: "SENPAI UP NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [0, 0], name: "SENPAI RIGHT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
				];
			case 'senpai-angry':
				positionArray = [150, 360];
				cameraPosition = [-240, -330];

				healthIcon = 'senpai-pixel';
				healthColorArray = [255, 170, 111];
				shortName = 'senpai';

				antialiasing = false;
				noAntialiasing = true;

				frames = Paths.getSparrowAtlas('characters/senpai/senpai');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				animationsArray = [
					{offsets: [2, 0], name: "Angry Senpai Idle instance 1", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [40, 0], name: "Angry Senpai LEFT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [14, 0], name: "Angry Senpai DOWN NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [5, 37], name: "Angry Senpai UP NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [0, 0], name: "Angry Senpai RIGHT NOTE instance 1", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
				];
			case 'spirit':
				positionArray = [-150, 100];
				cameraPosition = [0, 0];

				healthIcon = 'spirit-pixel';
				healthColorArray = [255, 60, 110];
				shortName = 'senpai';

				antialiasing = false;
				noAntialiasing = true;

				frames = Paths.getPackerAtlas('characters/senpai/spirit');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				animationsArray = [
					{offsets: [-218, -280], name: "idle spirit_", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [-200, -280], name: "left_", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [170, 110], name: "spirit down_", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [-220, -240], name: "up_", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [-220, -280], name: "right_", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
				];
			case 'tankman':
				positionArray = [0, 240];
				cameraPosition = [0, 0];
				healthIcon = 'tankman';
				healthColorArray = [225, 225, 225];
				flipX = true;

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/tankman/tankmanCaptain');

				if (isPlayer) {
					animationsArray = [
						{anim: 'idle', name: 'Tankman Idle Dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singRIGHT', name: 'Tankman Right Note 1', fps: 24, loop: false, indices: [], offsets: [-21, -11]},
						{anim: 'singDOWN', name: 'Tankman DOWN note 1', fps: 24, loop: false, indices: [], offsets: [66, -107]},
						{anim: 'singUP', name: 'Tankman UP note 1', fps: 24, loop: false, indices: [], offsets: [28, 54]},
						{anim: 'singLEFT', name: 'Tankman Note Left 1', fps: 24, loop: false, indices: [], offsets: [91, -23]},
						{anim: 'singLEFTmiss', name: 'Tankman Note Left MISS', fps: 24, loop: false, indices: [], offsets: [91, -23]},
						{anim: 'singDOWNmiss', name: 'Tankman DOWN note MISS', fps: 24, loop: false, indices: [], offsets: [66, -107]},
						{anim: 'singUPmiss', name: 'Tankman UP note MISS', fps: 24, loop: false, indices: [], offsets: [28, 54]},
						{anim: 'singRIGHTmiss', name: 'Tankman Right Note MISS', fps: 24, loop: false, indices: [], offsets: [-16, -11]},
						{anim: 'singUP-alt', name: 'TANKMAN UGH', fps: 24, loop: false, indices: [], offsets: [-12, -8]},
						{anim: 'singDOWN-alt', name: 'PRETTY GOOD tankman', fps: 24, loop: false, indices: [], offsets: [101, 16]},
					];
				} else {
					animationsArray = [
						{anim: 'idle', name: 'Tankman Idle Dance', fps: 24, loop: false, indices: [], offsets: [0, 0]},
						{anim: 'singLEFT', name: 'Tankman Right Note 1', fps: 24, loop: false, indices: [], offsets: [84, -14]},
						{anim: 'singDOWN', name: 'Tankman DOWN note 1', fps: 24, loop: false, indices: [], offsets: [76, -101]},
						{anim: 'singUP', name: 'Tankman UP note 1', fps: 24, loop: false, indices: [], offsets: [48, 54]},
						{anim: 'singRIGHT', name: 'Tankman Note Left 1', fps: 24, loop: false, indices: [], offsets: [-21, -31]},
						{anim: 'singRIGHTmiss', name: 'Tankman Note Left MISS', fps: 24, loop: false, indices: [], offsets: [91, -23]},
						{anim: 'singDOWNmiss', name: 'Tankman DOWN note MISS', fps: 24, loop: false, indices: [], offsets: [66, -107]},
						{anim: 'singUPmiss', name: 'Tankman UP note MISS', fps: 24, loop: false, indices: [], offsets: [28, 54]},
						{anim: 'singLEFTmiss', name: 'Tankman Right Note MISS', fps: 24, loop: false, indices: [], offsets: [-16, -11]},
						{anim: 'singUP-alt', name: 'TANKMAN UGH', fps: 24, loop: false, indices: [], offsets: [-15, -8]},
						{anim: 'singDOWN-alt', name: 'PRETTY GOOD tankman', fps: 24, loop: false, indices: [], offsets: [1, 16]},
					];
				}
			case 'buster':
				positionArray = [10, 70];
				cameraPosition = [150, 150];
				healthIcon = 'buster';
				healthColorArray = [43, 75, 155];
				shortName = 'busta';
				arrowSkin = 'busterNOTE_assets';

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/busty/THIGHS');

				if (isPlayer) {
					positionArray = [50, 70];
					animationsArray = [
						{offsets: [0, 0], name: "Buster Idle Dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [-30, -30], name: "Buster LEFT NOTE", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						{offsets: [-30, -30], name: "Buster LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'},
						{offsets: [-12, -44], name: "Buster DOWN NOTE", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [-12, -44], name: "Buster DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [-4, 30], name: "Buster UP NOTE", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [-4, 30], name: "Buster UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [15, -30], name: "Buster RIGHT NOTE", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [15, -30], name: "Buster RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'}
					];
				} else {
					animationsArray = [
						{offsets: [0, 0], name: "Buster Idle Dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [-30, 0], name: "Buster LEFT NOTE", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [-30, 0], name: "Buster LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
						{offsets: [8, -34], name: "Buster DOWN NOTE", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [8, -34], name: "Buster DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [19, 34], name: "Buster UP NOTE", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [19, 34], name: "Buster UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [-55, -30], name: "Buster RIGHT NOTE", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						{offsets: [-55, -30], name: "Buster RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'}
					];
				}
			case 'buster-holding-amethyst':
				positionArray = [80, 160];
				cameraPosition = [130, 50];
				healthIcon = 'buster';
				healthColorArray = [43, 75, 155];
				shortName = 'busta';

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/busta/Buster-Holding-Amethyst-cute');

				if (isPlayer) {
					animationsArray = [
						{offsets: [45, 10], name: "B-A idle dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [42, 10], name: "B-A NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [30, -40], name: "B-A NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [6, 57], name: "B-A NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [96, 7], name: "B-A NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						/*{offsets: [7, 19], name: "B-A NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
						{offsets: [-15, -19], name: "B-A NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [-46, 27], name: "B-A NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [-44, 22], name: "B-A NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'}, */
						{offsets: [-11, 46], name: "B-A HEY", loop: false, indices: [], fps: 24, anim: 'hey'}
					];
				} else {
					animationsArray = [
						{offsets: [45, 10], name: "B-A idle dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [96, 7], name: "B-A NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [30, -40], name: "B-A NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [6, 57], name: "B-A NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [42, 10], name: "B-A NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						/*{offsets: [7, 19], name: "B-A NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
						{offsets: [-15, -19], name: "B-A NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [-46, 27], name: "B-A NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [-44, 22], name: "B-A NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'}, */
						{offsets: [-11, 46], name: "B-A HEY", loop: false, indices: [], fps: 24, anim: 'hey'}
					];
				}
			case 'rusty-speaker':
				positionArray = [50, -130];
				cameraPosition = [50, 0];
				healthIcon = 'rusty';
				healthColorArray = [101, 6, 32];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/rusty/SpeakerBlaze');

				animationsArray = [
					{anim: 'shoot1', name: 'Blaze Shoot1', fps: 24, loop: false, indices: [], offsets: [-3, 0]},
					{anim: 'shoot2', name: 'Blaze Shoot2', fps: 24, loop: false, indices: [], offsets: [-4, -128]},
					{anim: 'shoot3', name: 'Blaze Shoot3', fps: 24, loop: false, indices: [], offsets: [418, -125]},
					{anim: 'shoot4', name: 'Blaze Shoot4', fps: 24, loop: false, indices: [], offsets: [458, 3]},
					{anim: 'shoot1-loop', name: 'Blaze Shoot1', fps: 24, loop: true, indices: [4, 5, 6], offsets: [-3, 0]},
					{anim: 'shoot2-loop', name: 'Blaze Shoot2', fps: 24, loop: true, indices: [4, 5, 6], offsets: [-4, -128]},
					{anim: 'shoot3-loop', name: 'Blaze Shoot3', fps: 24, loop: true, indices: [4, 5, 6], offsets: [418, -125]},
					{anim: 'shoot4-loop', name: 'Blaze Shoot4', fps: 24, loop: true, indices: [4, 5, 6], offsets: [458, 3]}
				];
			case 'EXBurst':
				positionArray = [80, 50];
				cameraPosition = [70, 240];
				healthIcon = 'EXBurst';
				healthColorArray = [255, 0, 0];
				shortName = 'burst';

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/burst/EXBurst');

				if (isPlayer) {
					animationsArray = [
						{offsets: [19, -33], name: "EXBurst idle dance", loop: true, indices: [], fps: 24, anim: 'idle'},
						{offsets: [280, -70], name: "EXBurst NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [10, -250], name: "EXBurst NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [0, -90], name: "EXBurst NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [40, -107], name: "EXBurst NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'}
						/*{offsets: [7, 19], name: "EXBurst NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
						{offsets: [-15, -19], name: "EXBurst NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [-46, 27], name: "EXBurst NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [-44, 22], name: "EXBurst NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'}*/
					];
				} else {
					animationsArray = [
						{offsets: [60, -30], name: "EXBurst idle dance", loop: true, indices: [], fps: 24, anim: 'idle'},
						{offsets: [210, -90], name: "EXBurst NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [-20, -320], name: "EXBurst NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [20, -70], name: "EXBurst NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [-110, -70], name: "EXBurst NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'}
					];
				}
			case 'ebwa':
				positionArray = [50, -130];
				cameraPosition = [50, 0];
				healthIcon = 'twilight';
				healthColorArray = [240, 125, 106];
				shortName = 'twoi';

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/twoi/eboiOnDaSpeaker');

				animationsArray = [
					{anim: 'danceLeft', name: 'eboiBop', fps: 24, loop: true, indices: [24, 25, 26, 27, 28, 29, 30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], offsets: [0, 0]},
					{anim: 'danceRight', name: 'eboiBop', fps: 24, loop: true, indices: [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], offsets: [0, 0]}
				];
			case 'sapphire':
				positionArray = [50, 200];
				cameraPosition = [50, 70];

				healthIcon = 'sapphire';
				singDuration = 4;
				flipX = true;
				healthColorArray = [49, 176, 209];

				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				frames = Paths.getSparrowAtlas('characters/sapph/Sapphire');

				animationsArray = [
					{offsets: [0, 0], name: "Sapphire NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [-18, 24], name: "Sapphire NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [50, -53], name: "Sapphire NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [-33, 94], name: "Sapphire NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [0, 0], name: "Sapphire NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
					//{offsets: [7, 19], name: "BF NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
					//{offsets: [-15, -19], name: "BF NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
					//{offsets: [-46, 27], name: "BF NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
					//{offsets: [-44, 22], name: "BF NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'},
				];
			case 'Mewtwo':
				positionArray = [70, 50];
				cameraPosition = [70, 80];
				healthIcon = 'mewtwo';
				healthColorArray = [141, 83, 138];
				shortName = 'legs';

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('null/SpaceKitty');

				if (isPlayer) {
					animationsArray = [
						{offsets: [0, 0], name: "MewTwo Idle Dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [-18, -40], name: "mew LEFT NOTE", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						{offsets: [-18, -40], name: "mew LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'},
						{offsets: [-10, -100], name: "Mewtwo DOWN NOTE", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [-10, -100], name: "Mewtwo DOWN miss", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [70, 15], name: "mewtwo UP NOTE", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [70, 15], name: "mewtwo up MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [98, -12], name: "TWO NOTE RIGHT", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [98, -12], name: "TWO RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'}
					];
				} else {
					animationsArray = [
						{offsets: [0, 0], name: "MewTwo Idle Dance", loop: false, indices: [], fps: 24, anim: 'idle'},
						{offsets: [100, -40], name: "mew LEFT NOTE", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
						{offsets: [100, -40], name: "mew LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
						{offsets: [-30, -90], name: "Mewtwo DOWN NOTE", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
						{offsets: [-30, -90], name: "Mewtwo DOWN miss", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
						{offsets: [-109, 15], name: "mewtwo UP NOTE", loop: false, indices: [], fps: 24, anim: 'singUP'},
						{offsets: [-109, 15], name: "mewtwo up MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
						{offsets: [-12, -12], name: "TWO NOTE RIGHT", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
						{offsets: [-12, -12], name: "TWO RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'}
					];
				}
			default:
				positionArray = [0, 350];
				cameraPosition = [0, 0];

				healthIcon = 'bf';
				singDuration = 4;
				flipX = true;
				healthColorArray = [49, 176, 209];

				antialiasing = ClientPrefs.globalAntialiasing;

				frames = Paths.getSparrowAtlas('characters/bf/BOYFRIEND');

				animationsArray = [
					{offsets: [0, -5], name: "BF idle dance", loop: false, indices: [], fps: 24, anim: 'idle'},
					{offsets: [5, -6], name: "BF NOTE LEFT0", loop: false, indices: [], fps: 24, anim: 'singLEFT'},
					{offsets: [-20, -51], name: "BF NOTE DOWN0", loop: false, indices: [], fps: 24, anim: 'singDOWN'},
					{offsets: [-46, 27], name: "BF NOTE UP0", loop: false, indices: [], fps: 24, anim: 'singUP'},
					{offsets: [-48, -7], name: "BF NOTE RIGHT0", loop: false, indices: [], fps: 24, anim: 'singRIGHT'},
					{offsets: [7, 19], name: "BF NOTE LEFT MISS", loop: false, indices: [], fps: 24, anim: 'singLEFTmiss'},
					{offsets: [-15, -19], name: "BF NOTE DOWN MISS", loop: false, indices: [], fps: 24, anim: 'singDOWNmiss'},
					{offsets: [-46, 27], name: "BF NOTE UP MISS", loop: false, indices: [], fps: 24, anim: 'singUPmiss'},
					{offsets: [-44, 22], name: "BF NOTE RIGHT MISS", loop: false, indices: [], fps: 24, anim: 'singRIGHTmiss'},
					{offsets: [-3, 5], name: "BF HEY", loop: false, indices: [], fps: 24, anim: 'hey'},
					{offsets: [14, 18], name: "BF hit", loop: false, indices: [], fps: 24, anim: 'hurt'},
					{offsets: [-4, 0], name: "BF idle shaking", loop: false, indices: [], fps: 24, anim: 'scared'},
					{offsets: [-10, -16], name: "boyfriend dodge", loop: false, indices: [], fps: 24, anim: 'dodge'},
					{offsets: [294, 267], name: "boyfriend attack", loop: false, indices: [], fps: 24, anim: 'attack'},
					{offsets: [-40, -40], name: "bf pre attack", loop: false, indices: [], fps: 24, anim: 'pre-attack'}
				];
		}
		

		if(animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;
				if(animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}

				if(anim.offsets != null && anim.offsets.length > 1) {
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}
			}
		} else {
			quickAnimAdd('idle', 'BF idle dance');
		}

		originalFlipX = flipX;

		if(animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();

		if (isPlayer) {
			flipX = !flipX;
		}

		switch(curCharacter)
		{
			case 'pico-speaker' | 'blaze-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
			
			switch(curCharacter)
			{
				case 'pico-speaker' | 'blaze-speaker':
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if(animationNotes[0][1] > 2) noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
				case 'buster':
					/*if (y < positionArray[1] - 100) {
						velocity.y = 30;
					} else if (y > positionArray[1] + 100) {
						velocity.y = -30;
					}
					velocity.y = -30;*/
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
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
	
	function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				animationNotes.push(songNotes);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
#end