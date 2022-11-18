package characters;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	// This doesn't currently serve any purpose, but I believe it will at some point. Probably when I get to improving the strums
	public var girlfriend:Girlfriend = null;

	public function new(x:Float, y:Float, char:String = 'bf', ?girlfriend:Girlfriend)
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
