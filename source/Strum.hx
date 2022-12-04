package;

import characters.Boyfriend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

import levels.MasterLevel;

using StringTools;

class Strum
{
    public var parent:MasterLevel;

    public var strumLineNotes:FlxTypedGroup<StrumNote>;
    public var notes:FlxTypedGroup<Note>;
    public var unspawnNotes:Array<Dynamic> = [];

    public function new(parent:MasterLevel) {
        this.parent = parent;

        strumLineNotes = new FlxTypedGroup<StrumNote>();
        strumLineNotes.cameras = [parent.camHUD];
        parent.add(strumLineNotes);
        
        notes = new FlxTypedGroup<Note>();
        notes.cameras = [parent.camHUD];
        parent.add(notes);
    }

    public function generateStaticArrows(player:Int):Void {
        for (i in 0...4)
        {
            // FlxG.log.add(i);
            var babyArrow:StrumNote = new StrumNote(0, parent.strumLine.y, i, player);

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
            babyArrow.x += (FlxG.width / 2 * player);
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
}