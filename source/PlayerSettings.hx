package;

import Controls;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;

class PlayerSettings
{
	static public var numPlayers(default, null):Int = 0;
	static public var numAvatars(default, null):Int = 0;
	static public var player1(default, null):Player;
	static public var player2(default, null):Player;

	#if (haxe >= "4.0.0")
	static public final onAvatarAdd:FlxTypedSignal<PlayerSettings->Void> = new FlxTypedSignal();
	static public final onAvatarRemove:FlxTypedSignal<PlayerSettings->Void> = new FlxTypedSignal();
	#else
	static public var onAvatarAdd:FlxTypedSignal<PlayerSettings->Void> = new FlxTypedSignal();
	static public var onAvatarRemove:FlxTypedSignal<PlayerSettings->Void> = new FlxTypedSignal();
	#end

	public static var uiKeyBinds:Map<String, Array<FlxKey>> = [
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R],
		
		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN],
		'debug_2'		=> [EIGHT]
	];

	/* 
		static public function addAvatar(avatar:Player):PlayerSettings
		{
			var settings:PlayerSettings;

			if (player1 == null)
			{
				player1 = new PlayerSettings(0, Solo);
				++numPlayers;
			}

			if (player1.avatar == null)
				settings = player1;
			else
			{
				if (player2 == null)
				{
					if (player1.controls.keyboardScheme.match(Duo(true)))
						player2 = new PlayerSettings(1, Duo(false));
					else
						player2 = new PlayerSettings(1, None);
					++numPlayers;
				}

				if (player2.avatar == null)
					settings = player2;
				else
					throw throw 'Invalid number of players: ${numPlayers + 1}';
			}
			++numAvatars;
			settings.avatar = avatar;
			avatar.settings = settings;

			splitCameras();

			onAvatarAdd.dispatch(settings);

			return settings;
		}

		static public function removeAvatar(avatar:Player):Void
		{
			var settings:PlayerSettings;

			if (player1 != null && player1.avatar == avatar)
				settings = player1;
			else if (player2 != null && player2.avatar == avatar)
			{
				settings = player2;
				if (player1.controls.keyboardScheme.match(Duo(_)))
					player1.controls.setKeyboardScheme(scheme);
			}
			else
				throw "Cannot remove avatar that is not for a player";

			settings.avatar = null;
			while (settings.controls.gamepadsAdded.length > 0)
			{
				final id = settings.controls.gamepadsAdded.shift();
				settings.controls.removeGamepad(id);
				DeviceManager.releaseGamepad(FlxG.gamepads.getByID(id));
			}

			--numAvatars;

			splitCameras();

			onAvatarRemove.dispatch(avatar.settings);
		}
	*/

	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new Player();
			player1.cpucontrolled = false;
			player1.settings = new PlayerSettings(0, Solo);
			++numPlayers;
		}

		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.settings.controls.addDefaultGamepad(0);
		}

		if (numGamepads > 1)
		{
			if (player2 == null)
			{
				player2 = new Player();
				player2.cpucontrolled = false;
				player2.settings = new PlayerSettings(1, None);
				++numPlayers;
			}

			var gamepad = FlxG.gamepads.getByID(1);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player2.settings.controls.addDefaultGamepad(1);
		} 
		else
		{
			if(player2 == null)
			{
				player2 = new Player();
				player2.settings = new PlayerSettings(1, None);
			}
		}

		// DeviceManager.init();
	}

	static public function reset()
	{
		player1 = null;
		player2 = null;
		numPlayers = 0;
	}

	public var id(default, null):Int;

	#if (haxe >= "4.0.0")
	public final controls:Controls;
	#else
	public var controls:Controls;
	#end

	// public var avatar:Player;
	// public var camera(get, never):PlayCamera;

	function new(id, scheme)
	{
		this.id = id;
		this.controls = new Controls('player$id', scheme);
	}
}
