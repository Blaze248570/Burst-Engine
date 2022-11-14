package levels;

import flixel.FlxG;
import flixel.system.FlxSound;

class Philly extends PlayState {
    var phillyLightsColors:Array<flixel.util.FlxColor>;
    var phillyCityLights:BGSprite;
	var phillyTrain:BGSprite;
	var trainSound:FlxSound;

    override public function createStage() {
        PlayState.curStage = 'philly';

        var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
        add(bg);

        var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
        city.setGraphicSize(Std.int(city.width * 0.85));
        city.updateHitbox();
        add(city);

        phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
        phillyCityLights = new BGSprite('philly/window', city.x, 0, 0.3, 0.3);
        phillyCityLights.setGraphicSize(Std.int(phillyCityLights.width * 0.85));
        phillyCityLights.updateHitbox();
        phillyCityLights.alpha = 0;
        add(phillyCityLights);

        var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
        add(streetBehind);

        phillyTrain = new BGSprite('philly/train', 2000, 360);
        add(phillyTrain);

        trainSound = new flixel.system.FlxSound().loadEmbedded(Paths.sound('train_passes'));
        FlxG.sound.list.add(trainSound);

        var street:BGSprite = new BGSprite('philly/street', -40, streetBehind.y);
        add(street);

        createCharacters();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (trainMoving)
        {
            trainFrameTiming += elapsed;

            if (trainFrameTiming >= 1 / 24)
            {
                updateTrainPos();
                trainFrameTiming = 0;
            }
        }

        phillyCityLights.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
    }

    var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
        gf.danced = false;
        gf.playAnim('hairFall');
        // gf.specialAnim = true;
		phillyTrain.x = flixel.FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}
    
	var curLight:Int = 0;

    override public function beatHit() {
        super.beatHit();

        if (!trainMoving)
            trainCooldown += 1;

        if (curBeat % 4 == 0)
        {
            curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
            phillyCityLights.color = phillyLightsColors[curLight];
            phillyCityLights.alpha = 1;
        }

        if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
        {
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
        }
    }
}