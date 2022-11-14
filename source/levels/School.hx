package levels;

import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;

//import WiggleEffect.WiggleEffectType;

class School extends PlayState 
{
    var bgGirls:BackgroundGirls = null;
	var wiggleShit:WiggleEffect = null;

    override public function createStage() {
        var curSong:String = Paths.formatToSongPath(PlayState.SONG.song);

        if(curSong == "thorns") {
            PlayState.curStage = 'schoolEvil';

            var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
            var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

            var posX = 400;
            var posY = 200;

            var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
            bg.animation.play('background 2');
            bg.scale.set(6, 6);
            bg.antialiasing = false;
            add(bg);

            /* 
                var bg:BGSprite = new BGSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
                bg.scale.set(6, 6);
                // bg.setGraphicSize(Std.int(bg.width * 6));
                // bg.updateHitbox();
                add(bg);

                var fg:BGSprite = new BGSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
                fg.scale.set(6, 6);
                // fg.setGraphicSize(Std.int(fg.width * 6));
                // fg.updateHitbox();
                add(fg);

                wiggleShit = new WiggleEffect();
                wiggleShit.effectType = WiggleEffectType.DREAMY;
                wiggleShit.waveAmplitude = 0.01;
                wiggleShit.waveFrequency = 60;
                wiggleShit.waveSpeed = 0.8;
            */

            // bg.shader = wiggleShit.shader;
            // fg.shader = wiggleShit.shader;

            /* 
                var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
                var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

                // Using scale since setGraphicSize() doesnt work???
                waveSprite.scale.set(6, 6);
                waveSpriteFG.scale.set(6, 6);
                waveSprite.setPosition(posX, posY);
                waveSpriteFG.setPosition(posX, posY);

                waveSprite.scrollFactor.set(0.7, 0.8);
                waveSpriteFG.scrollFactor.set(0.9, 0.8);

                // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
                // waveSprite.updateHitbox();
                // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
                // waveSpriteFG.updateHitbox();

                add(waveSprite);
                add(waveSpriteFG);
            */
        } else {
            PlayState.curStage = 'school';

            // defaultCamZoom = 0.9;
            var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
            bgSky.antialiasing = false;
            add(bgSky);

            var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', -200, 0, 0.6, 0.9);
            bgSchool.antialiasing = false;
            add(bgSchool);

            var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', -200, 0, 0.95, 0.95);
            bgStreet.antialiasing = false;
            add(bgStreet);

            var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', -30, 130, 0.9, 0.9);
            fgTrees.antialiasing = false;
            add(fgTrees);

            var bgTrees:FlxSprite = new FlxSprite(-580, -800);
            bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
            bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
            bgTrees.animation.play('treeLoop');
            bgTrees.scrollFactor.set(0.85, 0.85);
            bgTrees.antialiasing = false;
            add(bgTrees);

            var treeLeaves:BGSprite = new BGSprite('weeb/petals', -200, -40, 0.85, 0.85, ['PETALS ALL'], true);
            treeLeaves.animation.play('PETALS ALL');
            add(treeLeaves);

            var widShit = Std.int(bgSky.width * 6);

            bgSky.setGraphicSize(widShit);
            bgSchool.setGraphicSize(widShit);
            bgStreet.setGraphicSize(widShit);
            bgTrees.setGraphicSize(Std.int(widShit * 1.4));
            fgTrees.setGraphicSize(Std.int(widShit * 0.8));
            treeLeaves.setGraphicSize(widShit);

            fgTrees.updateHitbox();
            bgSky.updateHitbox();
            bgSchool.updateHitbox();
            bgStreet.updateHitbox();
            bgTrees.updateHitbox();
            treeLeaves.updateHitbox();

            bgGirls = new BackgroundGirls(-100, 190);
            bgGirls.scrollFactor.set(0.9, 0.9);

            if (curSong == 'roses')
                bgGirls.getScared();

            bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
            bgGirls.updateHitbox();
            bgGirls.antialiasing = false;
            add(bgGirls);
        }

        createCharacters();
    }

    override public function beatHit() {
        super.beatHit();

        if(wiggleShit != null)
            wiggleShit.update(Conductor.crochet);

        if(bgGirls != null)
            bgGirls.dance();
    }
}

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/bgFreaks');

		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function getScared():Void
	{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}