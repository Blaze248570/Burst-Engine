package levels;

import flixel.FlxState;

class LevelData 
{
    public static var curLevel:FlxState;

    public static function setLevel(level:String) {
        switch(level.toLowerCase()) {
            case 'week2':
                // curLevel = new Spooky();

            case 'week3':
                // curLevel = new Philly();

            case 'week4':
                // curLevel = new Limo();

            case 'week5':
                // curLevel = new Mall();

            case 'week6':
                // curLevel = new School();

            // case 'week7':
                // curLevel = new BattleGround();

            default:
                // curLevel = new Theatre();
        }
    }
}