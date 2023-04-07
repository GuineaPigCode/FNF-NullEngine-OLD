package game.sprites;

import dependency.Paths;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef MenuCharacterInfo =
{
	var path:String;
	var idleAnim:String;
	var confirmAnim:String;
	var scale:Float;
	var flipX:Bool;
	var offsets:Array<Float>;
};

class MenuCharacter extends FlxSprite
{
	public var character:String;

	var default_character:String = 'bf';

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeMenuCharacter(character);
	}

	function restartOptions()
	{
		visible = true;

		setGraphicSize(Std.int(1));
		updateHitbox();

		offset.set(0, 0);
	}

	public function changeMenuCharacter(character:String)
	{
		if (character == this.character)
			return;

		this.character = character;

		switch (character)
		{
			case "":
				visible = false;

			default:
				var path = 'menu_characters/${character}.json';

				var checkJSON = Paths.getObjectsPath(path);

				var char:MenuCharacterInfo = Json.parse(File.getContent(checkJSON));

				restartOptions();

				frames = FlxAtlasFrames.fromSparrow(Paths.getObjectsPath("menu_characters/images/" + char.path + ".png"),
					Paths.getObjectsPath("menu_characters/images/" + char.path + ".xml"));

				animation.addByPrefix(character + "-idle", char.idleAnim, 24);

				if (char.confirmAnim != null || char.confirmAnim.length > 0)
					animation.addByPrefix(character + "-confirm", char.confirmAnim, 24, false);

				flipX = (char.flipX == true);

				setGraphicSize(Std.int(width * char.scale));
				updateHitbox();

				offset.set(char.offsets[0], char.offsets[1]);

				playAnim("idle");
		}
	}

	public function playAnim(name:String)
	{
		animation.play(character + "-" + name);
	}
}
