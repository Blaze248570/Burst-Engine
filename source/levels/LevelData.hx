package levels;

import flixel.FlxState;

class LevelData 
{
    public static function getLevel(level:String):FlxState {
        var curLevel:FlxState = null;
        switch(level.toLowerCase()) {
            case 'week2':
                curLevel = new Spooky();

            case 'week3':
                curLevel = new Philly();

            case 'week4':
                curLevel = new Limo();

            case 'week5':
                curLevel = new Mall();

            case 'week6':
                curLevel = new School();

            // case 'week7':
                // curLevel = new BattleGround();

            default:
                curLevel = new PlayState();
        }

        return curLevel;
    }
}