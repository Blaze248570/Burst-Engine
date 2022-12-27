package;

import characters.*;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import levels.MasterLevel;

import openfl.events.KeyboardEvent;

class Player
{
    static var idEnumerator:Int = 1;

    #if (haxe > "4.0.0")
    public final playerNum:Int = idEnumerator++;
    #else
    public var playerNum:Int = idEnumerator++;
    #end

    public var settings:PlayerSettings;

    public var curState:MusicBeatState = null;
    public var curLevel:MasterLevel = null;

    public var sprite:Boyfriend = null;
    public var partner:Girlfriend = null;
    public var strumLine:StrumLine = null;

    public function new()
    {
        if(playerNum == 1) {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		    FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
    }

    public function loadSprite(sprite:String):Void 
    {
        this.sprite = new Boyfriend(0, 0, sprite, playerNum == 1);
    }

    public function addPartner(sprite:String):Void
    {
        this.partner = new Girlfriend(0, 0, sprite, playerNum == 1);
    }

    public function trackKeys():Void
    {
        
    }

    private function onKeyPress(event:KeyboardEvent):Void 
    {
        
    }

	private function onKeyRelease(event:KeyboardEvent):Void 
    {

    }
}