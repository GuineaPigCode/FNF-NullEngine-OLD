package states.editors;

import dependency.MusicBeatState;
import dependency.Paths;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import game.sprites.Character;

/**
	*DEBUG MODE OR SEXY MODE, HAGAGHAAAHAHAHA FUNY
 */
class CharacterEditor extends MusicBeatState
{
	var char:Character;
	var ghost:Character;

	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'dad';
	var camFollow:FlxObject;

	var uiBox:FlxUITabMenu;

	var curCharacter:String = "";

	public function new(daAnim:String = 'dad', isDad:Bool)
	{
		super();

		this.daAnim = daAnim;
		this.isDad = isDad;
	}

	override function create()
	{
		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		var menuBG:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/menuLineArt"));
		menuBG.color = 0x8a2f76;
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		add(menuBG);

		// ghost
		ghost = new Character(0, 0, daAnim);
		ghost.screenCenter();
		ghost.debugMode = true;
		ghost.playAnim('idle');
		ghost.alpha = 0.6;

		add(ghost);

		var dadType:Bool = false;
		if (isDad == true)
		{
			dadType = false;
		}
		else
		{
			dadType = true;
		}

		char = new Character(0, 0, daAnim, dadType);
		char.screenCenter();
		char.debugMode = true;
		char.flipX = false;
		add(char);

		ghost.flipX = char.flipX;

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 60);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		createUIBOX();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow);

		createConfigsChar();

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.WHITE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	var checkAnti:FlxUICheckBox;
	var checkIsPlayer:FlxUICheckBox;

	function createConfigsChar()
	{
		checkAnti = new FlxUICheckBox(0, 50, null, null, "Antialiasing", 100);
		checkAnti.x = FlxG.width - checkAnti.width - 25;
		checkAnti.name = 'checkAnti';
		checkAnti.checked = char.antialiasing;
		checkAnti.scrollFactor.set();

		checkAnti.callback = function()
		{
			char.antialiasing = checkAnti.checked;
			ghost.antialiasing = checkAnti.checked;
		};

		checkIsPlayer = new FlxUICheckBox(0, checkAnti.y + 25, null, null, "isPlayer", 100);
		checkIsPlayer.x = FlxG.width - checkIsPlayer.width - 25;
		checkIsPlayer.name = 'checkIsPlayer';
		checkIsPlayer.checked = isDad == false;
		checkIsPlayer.scrollFactor.set();

		checkIsPlayer.callback = function()
		{
			char.flipX = checkIsPlayer.checked;
			ghost.flipX = checkIsPlayer.checked;
		};

		add(checkIsPlayer);
		add(checkAnti);
	}

	function createUIBOX()
	{
		var tabs = [{name: "Character", label: 'Character'}];
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(400, 200);
		uiBox.x = FlxG.width - uiBox.width - 20;
		uiBox.y = 20;
		uiBox.scrollFactor.set();
		add(uiBox);
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
		{
			curAnim = animList.length - 1;
		}
		if (curAnim >= animList.length)
		{
			curAnim = 0;
		}

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim], true);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		if (controls.BACK)
			FlxG.switchState(new PlayState());

		super.update(elapsed);
	}
}
