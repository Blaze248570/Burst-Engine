package levels;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;

// import openfl.display.BlendMode;
// import openfl.filters.ShaderFilter;

class Limo extends PlayState {
    var limo:BGSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

    override public function createStage() {
        PlayState.curStage = 'limo';
        defaultCamZoom = 0.9;
        BF_POS.set(1030, -120);

        add(new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1));

        var bgLimo:BGSprite = new BGSprite('limo/bgLimo', -200, 480, 0.4, 0.4, ["background limo pink"], true);
        bgLimo.animation.play("background limo pink");
        add(bgLimo);

        grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
        add(grpLimoDancers);

        for (i in 0...5)
        {
            var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
            dancer.scrollFactor.set(0.4, 0.4);
            grpLimoDancers.add(dancer);
        }

        // Intriguing... I'll have to look into this
        /* 
            var overlayShit:BGSprite = new BGSprite('limo/limoOverlay', -500, -600);
            overlayShit.alpha = 0.5;
            add(overlayShit);
            var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
            FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
            overlayShit.shader = shaderBullshit;
        */ 

        createCharacters();

        limo = new BGSprite('limo/limoDrive', -120, 550, 1.0, 1.0, ["Limo stage"], true);
        limo.animation.play('Limo stage');
        limo.antialiasing = true;
        insert(members.indexOf(rival), limo);

        fastCar = new BGSprite('limo/fastCarLol', -300, 160);
        resetFastCar();
        add(fastCar);
    }

    var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

    override function beatHit() {
        super.beatHit();

        grpLimoDancers.forEach(function(dancer:BackgroundDancer)
        {
            dancer.dance();
        });

        if (FlxG.random.bool(10) && fastCarCanDrive)
            fastCarDrive();
    }
}

class BackgroundDancer extends flixel.FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("limo/limoDancer");
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = true;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}