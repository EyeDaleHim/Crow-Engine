package states.options;

class OptionsState extends MainState
{
    // theoretical list
    final categoryList:Array<String> = [
        "Gameplay",
        "Input",
        "Graphics",
        "Audio",
        "Accessibility"
    ];

    public static var curSelected:Int = 0;

    public var background:FlxSprite;

    public var leftBar:FlxSprite;
    public var topBar:FlxSprite;
    public var mainBar:FlxSprite;

    public var categories:FlxTypedContainer<Button>;

    public var applyButton:Button;
    public var cancelButton:Button;
    public var backButton:Button;

    public function new()
    {
        super();

        Controls.registerFunction(Control.BACK, JUST_PRESSED, function()
        {
            FlxG.switchState(states.menus.MainMenuState.new);
        }, {once: false});
    }

    override function create()
    {
        background = new FlxSprite(Assets.image('menus/settingsBG'));
		background.active = false;
        background.color = 0xFF7D67C4;
		add(background);

        topBar = new FlxSprite().makeGraphic(FlxG.width, Math.floor(FlxG.height * 0.12), FlxColor.BLACK);
        topBar.alpha = 0.6;
        add(topBar);

        leftBar = new FlxSprite(0, FlxG.height * 0.12).makeGraphic(Math.floor(FlxG.width * 0.12), Math.floor(FlxG.height * 0.9), FlxColor.BLACK);
        leftBar.alpha = 0.6;
        add(leftBar);

        mainBar = new FlxSprite(leftBar.objRight(), topBar.objBottom()).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        mainBar.alpha = 0.3;
        add(mainBar);

        categories = new FlxTypedContainer<Button>();
        add(categories);

        var buttonStyle:ButtonStyle = {
            hoverColor: 0xFF7C7C7C,
            clickColor: 0xFF2E2E2E,
            font: "vcr",
            fontSize: 16
        };

        for (i in 0...categoryList.length)
        {
            var item:String = categoryList[i];

            var style:Style = {
                width: leftBar.frameWidth - 8,
                height: 36,
                bgColor: FlxColor.BLACK
            };

            if (i == 0)
            {
                style.topLeftSize = 8.0;
                style.topRightSize = 8.0;
            }
            else if (i == categoryList.length - 1)
            {
                style.botLeftSize = 8.0;
                style.botRightSize = 8.0;
            }

            var categoryButton:Button = new Button(4, leftBar.y + 4 + (37 * i), style, buttonStyle, item);
            categoryButton.ID = i;
            categoryButton.onClick = changeSelection.bind(categoryButton.ID - curSelected);
            categories.add(categoryButton);
        }

        var style:Style = {
            width: leftBar.frameWidth - 8,
            height: 36,
            bgColor: FlxColor.BLACK,
            cornerSize: 8.0
        };

        var midPoint:Float = leftBar.getMidpoint().y + 100;

        applyButton = new Button(4, midPoint, style, buttonStyle, "Accept");
        add(applyButton);
        midPoint += applyButton.height + 4;

        cancelButton = new Button(4, midPoint, style, buttonStyle, "Cancel");
        add(cancelButton);
        midPoint += cancelButton.height + 4;

        backButton = new Button(4, midPoint, style, buttonStyle, "Back");
        add(backButton);

        super.create();

        changeSelection(curSelected);
    }

    public function changeSelection(selected:Int = 0)
    {
        categories.members[curSelected].active = true;

        categories.members[selected].active = false;
        categories.members[selected].color = categories.members[selected].buttonStyle.clickColor;

        curSelected = selected;
    }
}