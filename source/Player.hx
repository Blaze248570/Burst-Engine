package;

import characters.Boyfriend;
import characters.Girlfriend;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;

import openfl.events.KeyboardEvent;

using StringTools;

class Player
{
    static var enumerator:Int = 0;

    #if (haxe > "4.0.0")
    public final playerNum:Int = enumerator++;
    #else
    public var playerNum:Int = enumerator++;
    #end

    public var settings:PlayerSettings;

    public var noteKeyBinds:Map<String, Array<FlxKey>> = [
        'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
    ];

    private var keysArray:Array<Array<FlxKey>> = [];

    public var cpucontrolled:Bool = true;

    public var curState:FlxState = null;
    public var curLevel:PlayState = null;

    public var sprite:Boyfriend = null;
    public var partner:Girlfriend = null;
    public var strumLine:StrumLine = null;

    public function new() {}

    public function enter_level()
    {
        if(!cpucontrolled && playerNum == 0) {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		    FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
            
            keysArray = [
                noteKeyBinds.get('note_left'),
                noteKeyBinds.get('note_down'),
                noteKeyBinds.get('note_up'),
                noteKeyBinds.get('note_right')
            ];
        }
    }

    public function exit_level()
    {
        if(!cpucontrolled && playerNum == 0) {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		    FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
    }
    
    public function loadSprite(sprite:String):Void 
    {
        this.sprite = new Boyfriend(0, 0, sprite, playerNum == 0);
    }

    public function addPartner(sprite:String):Void
    {
        this.partner = new Girlfriend(0, 0, sprite, playerNum == 0);
    }

    public function updateKeys():Void
    {
        var up = settings.controls.NOTE_UP;
		var right = settings.controls.NOTE_RIGHT;
		var down = settings.controls.NOTE_DOWN;
		var left = settings.controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

        if (curLevel.startedCountdown && !sprite.stunned && curLevel.generatedMusic)
        {
            strumLine.notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) 
                {
                    strumLine.goodNoteHit(daNote);
                }
            });

            if(!controlHoldArray.contains(true) && sprite.holdTimer > Conductor.stepCrochet * 4 * 0.001)
            {
                if(sprite.animation.curAnim.name.startsWith('sing') && !sprite.animation.curAnim.name.endsWith('miss'))
                {
                    sprite.playAnim('idle');
                }
            }
        }
    }

    private function onKeyPress(event:KeyboardEvent):Void 
    {
        var pressedKey:FlxKey = event.keyCode;
        var key:Int = -1;

        for(i in 0...keysArray.length) 
        {
            for(j in 0...keysArray[i].length) 
            {
                if(pressedKey == keysArray[i][j]) 
                {
                    key = i;
                } 
            }
        }

        var pressNotes:Array<Note> = [];
        var notesStopped:Bool = false;
        var sortedNotesList:Array<Note> = [];

        strumLine.notes.forEachAlive(function(daNote:Note)
        {
            if(daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
            {
                if(daNote.noteData == key)
                {
                    sortedNotesList.push(daNote);
                }
            }
        });

        if(sortedNotesList.length > 0)
        {
            for (epicNote in sortedNotesList)
            {
                for (doubleNote in pressNotes) 
                {
                    if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) 
                    {
                        doubleNote.kill();
                        strumLine.notes.remove(doubleNote, true);
                        doubleNote.destroy();
                    } else
                        notesStopped = true;
                }

                if (!notesStopped) 
                {
                    strumLine.goodNoteHit(epicNote);
                    pressNotes.push(epicNote);
                }

            }
        }
        
        // if(key > -1)
            // trace("Pressed key " + keysArray[key][0].toString());
    }

	private function onKeyRelease(event:KeyboardEvent):Void 
    {
        var pressedKey:FlxKey = event.keyCode;
        var key:Int = -1;

        for(i in 0...keysArray.length) 
        {
            for(j in 0...keysArray[i].length) 
            {
                if(pressedKey == keysArray[i][j]) 
                {
                    key = i;
                } 
            }
        }

        if(curLevel.startedCountdown && !curLevel.paused && key > -1)
        {
            // My, my...
            strumLine.strumLineNotes.members[key].animation.play('static');
        }
    }
}