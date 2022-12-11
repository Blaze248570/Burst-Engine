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

import levels.MasterLevel;

using StringTools;

class StrumLine
{
    public static var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

    private var parent:MasterLevel;
    private var controls:Controls;
    private var character:Character;

    public var strumLineNotes:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;
    public var unspawnNotes:Array<Dynamic> = [];

    private var isPlayer:Bool;

    public function new(parent:MasterLevel, controls:Controls, character:Character) 
    {
        this.parent = parent;
        if(controls != null)
            this.controls = controls;
        // else
            // this.controls = new ComputerPlayer();

        this.character = character;
        isPlayer = character.isPlayer;

        strumLineNotes = new FlxTypedGroup<StrumNote>();
        strumLineNotes.cameras = [parent.camHUD];
        parent.add(strumLineNotes);
        
        notes = new FlxTypedGroup<Note>();
        notes.cameras = [parent.camHUD];
        parent.add(notes);
    }

    public function generateStaticArrows():Void 
    {
        for (i in 0...4)
        {
            // FlxG.log.add(i);
            var babyArrow:StrumNote = new StrumNote(0, parent.strumLine.y, i, (isPlayer ? 1 : 0));

            if (!MasterLevel.isStoryMode)
            {
                babyArrow.y -= 10;
                babyArrow.alpha = 0;
                FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            }

            babyArrow.ID = i;

            strumLineNotes.add(babyArrow);

            babyArrow.animation.play('static');
            babyArrow.x += (Note.swagWidth * i);
            babyArrow.x += 50;
            babyArrow.x += (FlxG.width / 2 * (isPlayer ? 1 : 0));
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

        if (parent.generatedMusic)
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

                daNote.y = (parent.strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(MasterLevel.SONG.speed, 2)));

                if  
                (
                    daNote.isSustainNote
                && 
                    daNote.y + daNote.offset.y <= parent.strumLine.y + Note.swagWidth / 2
                && 
                    (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
                )
                {
                    var swagRect = new FlxRect(0, parent.strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
                    swagRect.y /= daNote.scale.y;
                    swagRect.height -= swagRect.y;

                    daNote.clipRect = swagRect;
                }

                if (!daNote.mustPress && daNote.wasGoodHit)
                    rivalNoteHit(daNote);
                    

                // WIP interpolation shit? Need to fix the pause issue
                // daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * MasterLevel.SONG.speed));

                if (daNote.y < -daNote.height)
                {
                    if (daNote.tooLate || !daNote.wasGoodHit)
                    {
                        parent.health -= 0.0475;
                        parent.vocals.volume = 0;
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
        if (!parent.inCutscene && isPlayer)
            updateKeys();
    }

    private function updateKeys():Void
    {
        // HOLDING
        var up = controls.UP;
        var right = controls.RIGHT;
        var down = controls.DOWN;
        var left = controls.LEFT;

        var upP = controls.UP_P;
        var rightP = controls.RIGHT_P;
        var downP = controls.DOWN_P;
        var leftP = controls.LEFT_P;

        var upR = controls.UP_R;
        var rightR = controls.RIGHT_R;
        var downR = controls.DOWN_R;
        var leftR = controls.LEFT_R;

        var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

        // FlxG.watch.addQuick('asdfa', upP);
        if ((upP || rightP || downP || leftP) && !parent.boyfriend.stunned && parent.generatedMusic)
        {
            parent.boyfriend.holdTimer = 0;

            var possibleNotes:Array<Note> = [];

            var ignoreList:Array<Int> = [];

            notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
                {
                    // the sorting probably doesn't need to be in here? who cares lol
                    possibleNotes.push(daNote);
                    possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

                    ignoreList.push(daNote.noteData);
                }
            });

            if (possibleNotes.length > 0)
            {
                var daNote = possibleNotes[0];

                if (parent.perfectMode)
                    noteCheck(true, daNote);

                // Jump notes
                if (possibleNotes.length >= 2)
                {
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
                        noteCheck(controlArray[daNote.noteData], daNote);
                    }
                    else
                    {
                        for (coolNote in possibleNotes)
                        {
                            noteCheck(controlArray[coolNote.noteData], coolNote);
                        }
                    }
                }
                else // regular notes?
                    noteCheck(controlArray[daNote.noteData], daNote);
                /* 
                    if (controlArray[daNote.noteData])
                        goodNoteHit(daNote);
                    */
                // trace(daNote.noteData);
                /* 
                        switch (daNote.noteData)
                        {
                            case 2: // NOTES YOU JUST PRESSED
                                if (upP || rightP || downP || leftP)
                                    noteCheck(upP, daNote);
                            case 3:
                                if (upP || rightP || downP || leftP)
                                    noteCheck(rightP, daNote);
                            case 1:
                                if (upP || rightP || downP || leftP)
                                    noteCheck(downP, daNote);
                            case 0:
                                if (upP || rightP || downP || leftP)
                                    noteCheck(leftP, daNote);
                        }

                    //this is already done in noteCheck / goodNoteHit
                    if (daNote.wasGoodHit)
                    {
                        daNote.kill();
                        notes.remove(daNote, true);
                        daNote.destroy();
                    }
                    */
            }
            else
                badNoteCheck();
        }

        if ((up || right || down || left) && !parent.boyfriend.stunned && parent.generatedMusic)
        {
            notes.forEachAlive(function(daNote:Note)
            {
                if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
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

        if (parent.boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
        {
            if (parent.boyfriend.animation.curAnim.name.startsWith('sing') && !parent.boyfriend.animation.curAnim.name.endsWith('miss'))
                parent.boyfriend.playAnim('idle');
        }

        strumLineNotes.forEach(function(spr:FlxSprite)
        {
            switch (spr.ID)
            {
                case 0:
                    if (leftP && spr.animation.curAnim.name != 'confirm')
                        spr.animation.play('pressed');
                    if (leftR)
                        spr.animation.play('static');
                case 1:
                    if (downP && spr.animation.curAnim.name != 'confirm')
                        spr.animation.play('pressed');
                    if (downR)
                        spr.animation.play('static');
                case 2:
                    if (upP && spr.animation.curAnim.name != 'confirm')
                        spr.animation.play('pressed');
                    if (upR)
                        spr.animation.play('static');
                case 3:
                    if (rightP && spr.animation.curAnim.name != 'confirm')
                        spr.animation.play('pressed');
                    if (rightR)
                        spr.animation.play('static');
            }

            if (spr.animation.curAnim.name == 'confirm' && !MasterLevel.curStage.startsWith('school'))
            {
                spr.centerOffsets();
                spr.offset.x -= 13;
                spr.offset.y -= 13;
            }
            else
                spr.centerOffsets();
        });
    }

    function noteMiss(direction:Int = 1):Void
    {
        if (!parent.boyfriend.stunned)
        {
            parent.health -= 0.04;
            if (parent.combo > 5 && parent.gf.animOffsets.exists('sad'))
            {
                parent.gf.playAnim('sad');
            }
            parent.combo = 0;

            parent.songScore -= 10;

            FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
            // FlxG.sound.play(Paths.sound('missnote1'), 1, false);
            // FlxG.log.add('played imss note');

            parent.boyfriend.stunned = true;

            // get stunned for 5 seconds
            new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
            {
                parent.boyfriend.stunned = false;
            });

            parent.boyfriend.playAnim(singAnimations[direction] + 'miss', true);
        }
    }

    function badNoteCheck()
    {
        // just double pasting this shit cuz fuk u
        // REDO THIS SYSTEM!
        var upP = controls.UP_P;
        var rightP = controls.RIGHT_P;
        var downP = controls.DOWN_P;
        var leftP = controls.LEFT_P;

        if (leftP)
            noteMiss(0);
        if (downP)
            noteMiss(1);
        if (upP)
            noteMiss(2);
        if (rightP)
            noteMiss(3);
    }

    function noteCheck(keyP:Bool, note:Note):Void
    {
        if (keyP)
            goodNoteHit(note);
        else
            badNoteCheck();
    }

    function rivalNoteHit(daNote:Note):Void 
    {
        if (MasterLevel.SONG.song != 'Tutorial')
            parent.camZooming = true;

        var altAnim:String = "";

        if (MasterLevel.SONG.notes[Math.floor(parent.curStep / 16)] != null)
        {
            if (MasterLevel.SONG.notes[Math.floor(parent.curStep / 16)].altAnim)
                altAnim = '-alt';
        }

        parent.rival.playAnim(singAnimations[daNote.noteData] + altAnim, true);

        parent.rival.holdTimer = 0;

        // strumPlayAnim(daNote.noteData);

        if (MasterLevel.SONG.needsVoices)
            parent.vocals.volume = 1;

        daNote.kill();
        notes.remove(daNote, true);
        daNote.destroy();
    }

    function goodNoteHit(note:Note):Void 
    {
        if (!note.wasGoodHit)
        {
            if (!note.isSustainNote)
            {
                parent.popUpScore(note.strumTime);
                parent.combo += 1;
            }

            if (note.noteData >= 0)
                parent.health += 0.023;
            else
                parent.health += 0.004;

            parent.boyfriend.playAnim(singAnimations[note.noteData], true);
            
            strumLineNotes.forEach(function(spr:FlxSprite)
            {
                if (Math.abs(note.noteData) == spr.ID)
                {
                    spr.animation.play('confirm', true);
                }
            });

            note.wasGoodHit = true;
            parent.vocals.volume = 1;

            if (!note.isSustainNote)
            {
                note.kill();
                notes.remove(note, true);
                note.destroy();
            }
        }
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
        if(MasterLevel.isPixelLevel)
        {
            loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
            animation.add('green', [6]);
            animation.add('red', [7]);
            animation.add('blue', [5]);
            animation.add('purplel', [4]);

            setGraphicSize(Std.int(width * MasterLevel.daPixelZoom));
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