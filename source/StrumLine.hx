package;

import characters.Character;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class StrumLine
{
    public static var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

    private var parent:Player;
    private var level:PlayState;
    private var controls:Controls;
    private var character:Character;

    public var strumLineNotes:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;
    public var unspawnNotes:Array<Dynamic> = [];

    private var isPlayer:Bool;
    public var cpucontrolled:Bool;

    public function new(parent:Player) 
    {
        this.parent = parent;
        this.controls = parent.settings.controls;
        this.character = parent.sprite;

        this.isPlayer = character.isPlayer;
        this.cpucontrolled = parent.cpucontrolled;

        this.level = parent.curLevel;

        trace("Strum " + parent.playerNum + " : " + cpucontrolled);

        strumLineNotes = new FlxTypedGroup<StrumNote>();
        strumLineNotes.cameras = [level.camHUD];
        level.add(strumLineNotes);

        for(i in 0...4) {
            var babyArrow:StrumNote = new StrumNote(0, level.strumLine.y, i);

            babyArrow.ID = i;

            strumLineNotes.add(babyArrow);

            babyArrow.animation.play('static');
            babyArrow.x += (Note.swagWidth * i);
            babyArrow.x += 50;
            babyArrow.x += (FlxG.width / 2 * (isPlayer ? 1 : 0));
            babyArrow.alpha = 0;
        }
        
        notes = new FlxTypedGroup<Note>();
        notes.cameras = [level.camHUD];
        level.add(notes);
    }

    public function generateStaticArrows():Void 
    {
        for (i in 0...4)
        {
            if (!PlayState.isStoryMode)
            {
                var daNote:StrumNote = strumLineNotes.members[i];
                daNote.y -= 10;
                FlxTween.tween(daNote, {y: daNote.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            } 
            else 
            {
                strumLineNotes.members[i].alpha = 1; 
            }
        }
    }

    public function update(elapsed:Float):Void 
    {
        if (!level.inCutscene) 
        {
            if(!cpucontrolled)
            {
                parent.updateKeys();
            }
            else if(character.holdTimer > Conductor.stepCrochet * 4 * 0.001 && character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
            {
                character.dance();
            }
        }

        if (unspawnNotes[0] != null)
        {
            if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
            {
                var dunceNote:Note = unspawnNotes[0];
                notes.add(dunceNote);

                var index:Int = unspawnNotes.indexOf(dunceNote);
                unspawnNotes.splice(index, 1);
            }
        }

        if (level.generatedMusic)
        {
            notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.y > FlxG.height)
                {
                    daNote.active = false;
                    daNote.visible = false;
                }
                else
                {
                    daNote.visible = true;
                    daNote.active = true;
                }

                daNote.y = (level.strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));

                if  
                (
                    daNote.isSustainNote
                && 
                    daNote.y + daNote.offset.y <= level.strumLine.y + Note.swagWidth / 2
                && 
                    (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
                )
                {
                    var swagRect:FlxRect = new FlxRect(0, level.strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
                    swagRect.y /= daNote.scale.y;
                    swagRect.height -= swagRect.y;

                    daNote.clipRect = swagRect;
                }

                if (cpucontrolled && daNote.wasGoodHit)
                    computerNoteHit(daNote);

                if (daNote.y < -daNote.height)
                {
                    if (daNote.tooLate || !daNote.wasGoodHit)
                        noteMiss(daNote.noteData);

                    daNote.active = false;
                    daNote.visible = false;

                    daNote.kill();
                    notes.remove(daNote, true);
                    daNote.destroy();
                }
            });
        }
    }

    function noteMiss(direction:Int = 1):Void
    {
        if (!character.stunned)
        {
            level.health -= 0.0475;
            level.vocals.volume = 0;
            if (level.combo > 5 && level.gf.animOffsets.exists('sad'))
                level.gf.playAnim('sad');
            
            level.combo = 0;

            level.songScore -= 10;

            FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

            if(character.missAnimations[direction])
                character.playAnim(singAnimations[direction] + 'miss', true);
        }
    }

    public function noteMissPress(direction:Int):Void
    {
        if(!character.stunned)
        {
            level.health -= 0.05;
            level.vocals.volume = 0;

			if (level.combo > 5 && parent.partner != null && parent.partner.animOffsets.exists('sad'))
				parent.partner.playAnim('sad');
			
			level.combo = 0;

			level.songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(character.missAnimations[direction])
                character.playAnim(singAnimations[direction] + 'miss', true);
        }
    }

    public function computerNoteHit(note:Note):Void
    {
        character.playAnim(singAnimations[note.noteData], true);
        character.holdTimer = 0;

        level.vocals.volume = 1;

        var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}

        var daStrum:StrumNote = strumLineNotes.members[note.noteData % 4];
        daStrum.resetAnim = time;
		daStrum.playAnim('confirm', true);

        if (!note.isSustainNote)
        {
            note.kill();
            notes.remove(note, true);
            note.destroy();
        }
    }

    public function goodNoteHit(note:Note):Void 
    {
        if(note.wasGoodHit || cpucontrolled)
            return;

        character.playAnim(singAnimations[note.noteData], true);
        character.holdTimer = 0;

        strumLineNotes.members[note.noteData].playAnim('confirm', true);

        level.vocals.volume = 1;
        note.wasGoodHit = true;

        if (!note.isSustainNote)
        {
            level.popUpScore(note.strumTime);
            level.combo++;
        }

        if (note.noteData >= 0)
            level.health += 0.023;
        else
            level.health += 0.004;

        if (!note.isSustainNote)
        {
            note.kill();
            notes.remove(note, true);
            note.destroy();
        }
    }
}

class StrumNote extends FlxSprite
{
    public var noteData:Int;
    public var resetAnim:Float = 0;

    public function new(x:Float, y:Float, data:Int) {
        super(x, y);

        noteData = data;

        loadNote();
    }

    override public function update(elapsed:Float):Void
    {
        if(resetAnim > 0)
        {
            resetAnim -= elapsed;
            if(resetAnim <= 0)
            {
                playAnim('static');
                resetAnim = 0;
            }
        }

        super.update(elapsed);
    }

    public function playAnim(anim:String, force:Bool = false)
    {
        animation.play(anim, force);
        centerOffsets();
        centerOrigin();
    }

    private function loadNote() {
        if(PlayState.isPixelLevel)
        {
            loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
            animation.add('green', [6]);
            animation.add('red', [7]);
            animation.add('blue', [5]);
            animation.add('purplel', [4]);

            setGraphicSize(Std.int(width * PlayState.daPixelZoom));
            updateHitbox();
            antialiasing = false;

            switch (Math.abs(noteData))
            {
                case 0:
                    animation.add('static', [0]);
                    animation.add('pressed', [4, 8], 12, false);
                    animation.add('confirm', [12, 16], 24, false);
                case 1:
                    animation.add('static', [1]);
                    animation.add('pressed', [5, 9], 12, false);
                    animation.add('confirm', [13, 17], 24, false);
                case 2:
                    animation.add('static', [2]);
                    animation.add('pressed', [6, 10], 12, false);
                    animation.add('confirm', [14, 18], 12, false);
                case 3:
                    animation.add('static', [3]);
                    animation.add('pressed', [7, 11], 12, false);
                    animation.add('confirm', [15, 19], 24, false);
            }

        } else {
            frames = Paths.getSparrowAtlas('NOTE_assets');
            animation.addByPrefix('green', 'arrowUP');
            animation.addByPrefix('blue', 'arrowDOWN');
            animation.addByPrefix('purple', 'arrowLEFT');
            animation.addByPrefix('red', 'arrowRIGHT');

            antialiasing = true;
            setGraphicSize(Std.int(width * 0.7));

            switch (Math.abs(noteData))
            {
                case 0:
                    animation.addByPrefix('static', 'arrowLEFT');
                    animation.addByPrefix('pressed', 'left press', 24, false);
                    animation.addByPrefix('confirm', 'left confirm', 24, false);
                case 1:
                    animation.addByPrefix('static', 'arrowDOWN');
                    animation.addByPrefix('pressed', 'down press', 24, false);
                    animation.addByPrefix('confirm', 'down confirm', 24, false);
                case 2:
                    animation.addByPrefix('static', 'arrowUP');
                    animation.addByPrefix('pressed', 'up press', 24, false);
                    animation.addByPrefix('confirm', 'up confirm', 24, false);
                case 3:
                    animation.addByPrefix('static', 'arrowRIGHT');
                    animation.addByPrefix('pressed', 'right press', 24, false);
                    animation.addByPrefix('confirm', 'right confirm', 24, false);
            }
        }

        updateHitbox();
		scrollFactor.set();
    }
}