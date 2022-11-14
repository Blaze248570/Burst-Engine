package;

/**
 *  Currently very similar to Psych's `BGSprite` as it's pretty much for convienence

    TO-DO:
 *  Perhaps add more functionality and complexity
**/
class BGSprite extends flixel.FlxSprite
{
    private var defaultAnim:String = null;
    public function new(image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1, scrollY:Float = 1, animArray:Array<String> = null, loop:Bool = false) {
        super(x, y);

        if(animArray != null) {
            frames = Paths.getSparrowAtlas(image);
            for(anim in animArray) {
                animation.addByPrefix(anim, anim, 24, loop);
                if(defaultAnim == null) {
                    defaultAnim = anim;
                    animation.play(anim);
                }
            }
        } else {
            if(image != null)
                loadGraphic(Paths.image(image));
            active = false;
        }

        antialiasing = true;
        scrollFactor.set(scrollX, scrollY);
    }
}