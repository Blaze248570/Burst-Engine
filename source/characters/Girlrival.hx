package characters;

class Girlrival extends Character 
{
    public var rival:Rival = null;

    public function new(x:Float, y:Float, char:String = 'mom') {
        super(x, y, char, false);
    }
}