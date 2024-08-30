package objects.stages.stage_data;

class DadStage extends Stage
{
    public var back:Prop;
    public var front:Prop;
    public var curtains:Prop;

    public function new()
    {
        super();

        back = new Prop(-600, -200);
        back.loadGraphic(Assets.image('stages/stage/stageback'));

        back.scrollFactor.set(0.9, 0.9);

        back.active = false;
        add(back);

        front = new Prop(-650, 600);
        front.loadGraphic(Assets.image('stages/stage/stagefront'));

        front.scrollFactor.set(0.9, 0.9);
        front.scale.set(1.1, 1.1);
        front.updateHitbox();

        front.active = false;
        add(front);

        curtains = new Prop(-500, -300);
        curtains.loadGraphic(Assets.image('stages/stage/stagecurtains'));

        curtains.scrollFactor.set(1.3, 1.3);
        curtains.scale.set(0.9, 0.9);
        curtains.updateHitbox();

        curtains.active = false;
        add(curtains);

        setPlayerPos(970, 375);
        setSpectatorPos(400, 130);
        setOpponentPos(100, 100);
    }
}