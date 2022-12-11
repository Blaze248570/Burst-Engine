package characters;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	// This doesn't currently serve any purpose, but I believe it will at some point. Probably when I get to improving the strums
	public function new(x:Float, y:Float, char:String = 'bf')
	{
		super(x, y, char, true);

		switch(curCharacter) {
			case 'pico':
				animationData = [
					{anim: 'idle', name: 'Pico Idle Dance', fps: 24, loop: false, indices: [], offsets: [3, 0]},
					{anim: 'singLEFT', name: 'Pico NOTE LEFT0', fps: 24, loop: false, indices: [], offsets: [85, -10]},
					{anim: 'singLEFTmiss', name: 'Pico NOTE LEFT miss', fps: 24, loop: false, indices: [], offsets: [83, 28]},
					{anim: 'singDOWN', name: 'Pico Down Note0', fps: 24, loop: false, indices: [], offsets: [84, -80]},
					{anim: 'singDOWNmiss', name: 'Pico Down Note MISS', fps: 24, loop: false, indices: [], offsets: [80, -38]},
					{anim: 'singUP', name: 'pico Up note0', fps: 24, loop: false, indices: [], offsets: [21, 27]},
					{anim: 'singUPmiss', name: 'pico Up note miss', fps: 24, loop: false, indices: [], offsets: [28, 67]},
					{anim: 'singRIGHT', name: 'Pico Note Right0', fps: 24, loop: false, indices: [], offsets: [-48, 2]},
					{anim: 'singRIGHTmiss', name: 'Pico Note Right Miss', fps: 24, loop: false, indices: [], offsets: [-45, 50]}
				];
				
				loadAnimations(true);
		}
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
