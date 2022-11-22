package;

import flash.media.Sound;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

/**
	The Paths class contains many helper functions used to load assets simply, and more efficiently
 */
class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline public static function formatToSongPath(song:String)
	{
		return song.toLowerCase().replace(" ", "-").trim();
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return returnSound('sounds/$key', library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return returnSound('music/$key', library);
	}

	inline static public function voices(song:String):Sound
	{
		return returnSound('${formatToSongPath(song)}/Voices', 'songs');
	}

	inline static public function inst(song:String):Sound
	{
		return returnSound('${formatToSongPath(song)}/Inst', 'songs');
	}

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		return returnGraphic(key, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	// Idea to make these more 
	//    ... original ...
	// Use the currently purposeless Cache class to create different cached objects for each level 
	// that can be kept for week purposes (The Stress cutscene always had to take a long, odd pause for me)
	// and altogether discarded when no longer of use

	// Credit of course goes to ShadowMario, who I presume came up with them
	// Although, I did simplify them cause I don't really care to implement Lua or nothin'

	public static var cachedGraphics:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String):FlxGraphic {
		var path:String = getPath('images/$key.png', IMAGE, library);

		if(cachedGraphics.exists(path))
			return cachedGraphics.get(path);

		if(OpenFlAssets.exists(path)) {
			var graphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
			graphic.persist = true;
			cachedGraphics.set(path, graphic);

			return graphic;
		}
		
		// trace('Graphic: $path not found');
		// Turns out this catches the eye better
		trace('WOAH NO! $path returned null!!!');
		return null;
	}

	public static var cachedSounds:Map<String, Sound> = [];
	public static function returnSound(key:String, ?library:String):Sound {
		var path:String = getPath('$key.$SOUND_EXT', SOUND, library);

		if(cachedSounds.exists(path))
			return cachedSounds.get(path);

		if(OpenFlAssets.exists(path)) {
			var daSound:Sound = OpenFlAssets.getSound(path);
			cachedSounds.set(path, daSound);

			return daSound;
		}

		// trace('Sound: $path not found');
		trace('Hol\' up... $path has returned null!?!');
		return null;
	}
}
