package;

import characters.*;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import levels.MasterLevel;

import openfl.events.KeyboardEvent;

class Player
{
    static var idEnumerator = 1;
    #if (haxe > "4.0.0")
    public final playerNum:Int = idEnumerator++;
    #else
    public var playerNum:Int = idEnumerator++;
    #end

    public var settings:PlayerSettings;

    public var curState:MusicBeatState = null;
    public var curLevel:MasterLevel = null;

    public var sprite:Character = null;
    public var strumLine:StrumLine = null;

    public function new()
    {
        if(playerNum == 1) {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		    FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
    }

    private function loadSprite():Void
    {
        switch(playerNum) {
            case 1:
                this.sprite = new Rival(0, 0, MasterLevel.SONG.player2);

                if(MasterLevel.SONG.girlrival != null)
                    this.sprite.partner = new Girlrival(0, 0, MasterLevel.SONG.girlrival);

            case 2:
                this.sprite = new Boyfriend(0, 0, MasterLevel.SONG.player1);

                if(MasterLevel.SONG.girlfriend != null)
                    this.sprite.partner = new Girlfriend(0, 0, MasterLevel.SONG.girlfriend);
        }

        strumLine = new StrumLine(curLevel, curState.controls, sprite);
    }

    public function trackKeys():Void
    {

    }

    function onKeyPress(event:KeyboardEvent):Void 
    {
        
    }

	function onKeyRelease(event:KeyboardEvent):Void 
    {

    }
}