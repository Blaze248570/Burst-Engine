package characters;

using StringTools;

class Boyfriend extends Character
{
	public function new(x:Float, y:Float, char:String = 'bf', isPlayer:Bool = true)
	{
		super(x, y, char, isPlayer);
	}

	override function update(elapsed:Float):Void
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
