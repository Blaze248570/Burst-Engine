package levels;

class Mall extends PlayState 
{
    var upperBoppers:BGSprite = null;
	var bottomBoppers:BGSprite = null;
	var santa:BGSprite = null;

    override public function createStage() {
        if(Paths.formatToSongPath(PlayState.SONG.song) == 'winter-horrorland') {
            PlayState.curStage = 'mallEvil';
            var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
            bg.antialiasing = true;
            bg.setGraphicSize(Std.int(bg.width * 0.8));
            bg.updateHitbox();
            add(bg);

            var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
            evilTree.antialiasing = true;
            add(evilTree);

            var evilSnow:BGSprite = new BGSprite("christmas/evilSnow", -200, 700);
            evilSnow.antialiasing = true;
            add(evilSnow);
        } else {
            PlayState.curStage = 'mall';

            defaultCamZoom = 0.80;

            var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
            bg.antialiasing = true;
            bg.setGraphicSize(Std.int(bg.width * 0.8));
            bg.updateHitbox();
            add(bg);

            upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ["Upper Crowd Bob"]);
            upperBoppers.antialiasing = true;
            upperBoppers.scrollFactor.set(0.33, 0.33);
            upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
            upperBoppers.updateHitbox();
            add(upperBoppers);

            var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
            bgEscalator.antialiasing = true;
            bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
            bgEscalator.updateHitbox();
            add(bgEscalator);

            var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.4, 0.4);
            tree.antialiasing = true;
            add(tree);

            bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers']);
            bottomBoppers.antialiasing = true;
            // bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
            // bottomBoppers.updateHitbox();
            add(bottomBoppers);

            var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
            fgSnow.antialiasing = true;
            add(fgSnow);

            santa = new BGSprite('christmas/santa', -840, 150, 1.0, 1.0, ['santa idle in fear']);
            santa.antialiasing = true;
            add(santa);
        }

        createCharacters();
    }

    override public function beatHit() {
        super.beatHit();

        if(upperBoppers != null)
            upperBoppers.animation.play('Upper Crowd Bob', true);
        if(bottomBoppers != null)
            bottomBoppers.animation.play('Bottom Level Boppers', true);
        if(santa != null)
            santa.animation.play('santa idle in fear', true);
    }
}