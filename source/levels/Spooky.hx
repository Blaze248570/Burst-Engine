package levels;

import flixel.FlxG;

class Spooky extends PlayState
{
    var halloweenBG:BGSprite;

    override public function createStage() {
        PlayState.curStage = 'spooky';

        halloweenBG = new BGSprite('halloween_bg', -200, -100, 1.0, 1.0, ['halloweem bg0', 'halloweem bg lightning strike']);
        halloweenBG.antialiasing = true;
        add(halloweenBG);

        createCharacters();
    }

    var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
    override public function beatHit() {
        super.beatHit();

        if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
            FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
            halloweenBG.animation.play('halloweem bg lightning strike');

            lightningStrikeBeat = curBeat;
            lightningOffset = FlxG.random.int(8, 24);

            boyfriend.playAnim('scared', true);
            gf.playAnim('scared', true);
        }
    }
}