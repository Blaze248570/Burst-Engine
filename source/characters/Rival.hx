package characters;

class Rival extends Character 
{
    public var girlrival:Girlrival = null;

    public function new(x:Float, y:Float, char:String = 'dad', ?girlrival:Girlrival) {
        super(x, y, char, false);

        this.girlrival = girlrival;
    }
}