package gear.states.menus;

class TitleState extends MainState
{
    public function new()
    {
        super();

        Assets.loadContext("title");

        // load music as test
        menuMusic = new Music("music/menu/main", "music/menu/main");
        menuMusic.play();
        add(menuMusic);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (menuMusic.soundObject.playing)
        {
            trace('Beat: ${menuMusic.beat}, Step: ${menuMusic.step}');
        }
        
    }
}