package;

import characters.Character;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

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
            var babyArrow:StrumNote = new StrumNote(0, level.strumLine.y, i, (isPlayer ? 1 : 0));

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
        }
    }

    public function update(elapsed:Float):Void 
    {
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

                if (daNote.wasGoodHit)
                    goodNoteHit(daNote);

                if (daNote.y < -daNote.height) // That's actually pretty clever
                {
                    if (daNote.tooLate || !daNote.wasGoodHit)
                    {
                        level.health -= 0.0475;
                        level.vocals.volume = 0;
                    }

                    daNote.active = false;
                    daNote.visible = false;

                    daNote.kill();
                    notes.remove(daNote, true);
                    daNote.destroy();
                }
            });
        }

        // LAAAAAAAAME!!! Oh, well
        if (!level.inCutscene) 
        {
            if(cpucontrolled)
            {
                if(character.holdTimer > Conductor.stepCrochet * 4 * 0.001)
                {
                    if(character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
                    {
                        character.playAnim('idle');
                    }
                }
            }
            else
            {
                parent.updateKeys();
            }
        }
    }

    /*
        private function updateKeys():Void
        {
            // HOLDING

            var upP = controls.NOTE_UP_P;
            var rightP = controls.NOTE_RIGHT_P;
            var downP = controls.NOTE_DOWN_P;
            var leftP = controls.NOTE_LEFT_P;

            var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

            // FlxG.watch.addQuick('asdfa', upP);
            if (level.generatedMusic && !character.stunned && (upP || rightP || downP || leftP))
            {
                character.holdTimer = 0;

                var possibleNotes:Array<Note> = [];

                var ignoreList:Array<Int> = [];

                notes.forEachAlive(function(daNote:Note)
                {
                    if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
                    {
                        // the sorting probably doesn't need to be in here? who cares lol
                        possibleNotes.push(daNote);
                        // possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

                        ignoreList.push(daNote.noteData);
                    }
                });

                if (possibleNotes.length > 0)
                {
                    var daNote = possibleNotes[0];

                    if (level.perfectMode)
                        goodNoteHit(daNote);

                    // Jump notes
                    if (false && possibleNotes.length >= 2)
                    {
                        // What does this even do...?
                        if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
                        {
                            for (coolNote in possibleNotes)
                            {
                                if (controlArray[coolNote.noteData])
                                    goodNoteHit(coolNote);
                                else
                                {
                                    var inIgnoreList:Bool = false;
                                    for (shit in 0...ignoreList.length)
                                    {
                                        if (controlArray[ignoreList[shit]])
                                            inIgnoreList = true;
                                    }
                                    if (!inIgnoreList)
                                        badNoteCheck();
                                }
                            }
                        }
                        else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
                        {
                            goodNoteHit(daNote);
                        }
                        else
                        {
                            for (coolNote in possibleNotes)
                            {
                                goodNoteHit(coolNote);
                            }
                        }
                    }
                    else // regular notes?
                    {
                        goodNoteHit(daNote);
                    }
                }
                else
                    badNoteCheck(); // You did a ghost tap
            }

            var left = controls.NOTE_LEFT;
            var down = controls.NOTE_DOWN;
            var up = controls.NOTE_UP;
            var right = controls.NOTE_RIGHT;

            if (level.generatedMusic && !level.boyfriend.stunned && (up || right || down || left) )
            {
                notes.forEachAlive(function(daNote:Note)
                {
                    if (daNote.canBeHit && daNote.isSustainNote)
                    {
                        switch (daNote.noteData)
                        {
                            // NOTES YOU ARE HOLDING
                            case 0:
                                if (left)
                                    goodNoteHit(daNote);
                            case 1:
                                if (down)
                                    goodNoteHit(daNote);
                            case 2:
                                if (up)
                                    goodNoteHit(daNote);
                            case 3:
                                if (right)
                                    goodNoteHit(daNote);
                        }
                    }
                });
            }

            if (character.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
            {
                if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
                {
                    character.playAnim('idle');
                }
            }

            strumLineNotes.forEach(function(spr:FlxSprite)
            {
                switch (spr.ID)
                {
                    case 0:
                        if (leftP && spr.animation.curAnim.name != 'confirm')
                            spr.animation.play('pressed');
                        if (controls.NOTE_LEFT_R)
                            spr.animation.play('static');
                    case 1:
                        if (downP && spr.animation.curAnim.name != 'confirm')
                            spr.animation.play('pressed');
                        if (controls.NOTE_DOWN_R)
                            spr.animation.play('static');
                    case 2:
                        if (upP && spr.animation.curAnim.name != 'confirm')
                            spr.animation.play('pressed');
                        if (controls.NOTE_UP_R)
                            spr.animation.play('static');
                    case 3:
                        if (rightP && spr.animation.curAnim.name != 'confirm')
                            spr.animation.play('pressed');
                        if (controls.NOTE_RIGHT_R)
                            spr.animation.play('static');
                }

                if (spr.animation.curAnim.name == 'confirm' && !PlayState.curStage.startsWith('school'))
                {
                    spr.centerOffsets();
                    spr.offset.x -= 13;
                    spr.offset.y -= 13;
                }
                else
                    spr.centerOffsets();
            });
        }
    */

    function noteMiss(direction:Int = 1):Void
    {
        if (!level.boyfriend.stunned)
        {
            level.health -= 0.04;
            if (level.combo > 5 && level.gf.animOffsets.exists('sad'))
                level.gf.playAnim('sad');
            
            level.combo = 0;

            level.songScore -= 10;

            FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

            /*
                level.boyfriend.stunned = true;
                // get stunned for 5 seconds
                new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
                {
                    level.boyfriend.stunned = false;
                });
            */

            if(character.missAnimations[direction])
                character.playAnim(singAnimations[direction] + 'miss', true);
        }
    }

    function badNoteCheck()
    {
        // just double pasting this shit cuz fuk u
        // REDO THIS SYSTEM!
        var upP = controls.NOTE_UP_P;
        var rightP = controls.NOTE_RIGHT_P;
        var downP = controls.NOTE_DOWN_P;
        var leftP = controls.NOTE_LEFT_P;

        if (leftP)
            noteMiss(0);
        if (downP)
            noteMiss(1);
        if (upP)
            noteMiss(2);
        if (rightP)
            noteMiss(3);
    }

    /*
        function noteCheck(keyP:Bool, note:Note):Void
        {
            if (keyP)
                goodNoteHit(note);
            else
                badNoteCheck();
        }

        function rivalNoteHit(daNote:Note):Void 
        {
            if (PlayState.SONG.song != 'Tutorial')
                level.camZooming = true;

            var altAnim:String = "";

            if (PlayState.SONG.notes[Math.floor(level.curStep / 16)] != null)
            {
                if (PlayState.SONG.notes[Math.floor(level.curStep / 16)].altAnim)
                    altAnim = '-alt';
            }

            level.rival.playAnim(singAnimations[daNote.noteData] + altAnim, true);

            level.rival.holdTimer = 0;

            // strumPlayAnim(daNote.noteData);

            if (PlayState.SONG.needsVoices)
                level.vocals.volume = 1;

            daNote.kill();
            notes.remove(daNote, true);
            daNote.destroy();
        }
    */

    public function goodNoteHit(note:Note):Void 
    {
        // if (note.wasGoodHit)
            // return;

        character.playAnim(singAnimations[note.noteData], true);
        strumLineNotes.members[note.noteData].animation.play('confirm', true);

        level.vocals.volume = 1;

        // if (!note.isSustainNote)
        // {
            note.kill();
            notes.remove(note, true);
            note.destroy();
        // }

        if(cpucontrolled)
            return;

        if (!note.isSustainNote)
        {
            level.popUpScore(note.strumTime);
            level.combo += 1;
        }

        if (note.noteData >= 0)
            level.health += 0.023;
        else
            level.health += 0.004;

        // note.wasGoodHit = true;
    }
}

class StrumNote extends FlxSprite
{
    public var noteData:Int;
    private var player:Int;

    public function new(x:Float, y:Float, data:Int, player:Int) {
        super(x, y);

        noteData = data;
        this.player = player;

        loadNote();
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

    public function playAnim(anim:String, force:Bool = false)
    {
        animation.play(anim, force);
		centerOffsets();
		centerOrigin();
    }
}