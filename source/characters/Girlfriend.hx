package characters;

class Girlfriend extends Character 
{
    public var boyfriend:Boyfriend = null;

    public function new(x:Float, y:Float, char:String = 'gf', boyfriend:Boyfriend) {
        super(x, y, char, false);

        this.boyfriend = boyfriend;

        switch(curCharacter) {

        }
    }
}