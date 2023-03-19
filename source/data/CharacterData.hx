package data;

import dependency.Paths;
import haxe.Json;
import haxe.format.JsonParser;
import jsonHelper.JsonExtra.Point;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef CharacterINFO =
{
	var anims:Array<Anims>;
	// FUNKIN ANIMS SEPARATOR
	var prefs:Prefs;
}

typedef Prefs =
{
	var isGF:Bool;
	var antialiasing:Bool;
	var flipX:Bool;
	var healthBarColor:String;
	var singDuration:Float;
	var setScale:Float;
	// cam char wtf separator
	var cameraOffset:Array<Float>;
	var charOffset:Array<Float>;
}

typedef Anims =
{
	var animName:String;
	var animPrefix:String;
	var loop:Bool;
	var fps:Int;
	var indices:Array<Int>;
	var offsets:Point;
}

class CharacterData
{
	public static var anims:Array<Anims>;
	public static var prefs:Prefs;

	public static function getJSON(char:String)
	{
		var path:String = Paths.getPreloadPath('characters/${char}/data.json');

		var charJSON:CharacterINFO = Json.parse(File.getContent(path));

		anims = charJSON.anims;
		prefs = charJSON.prefs;
	}

	public static function jsonPath(char:String)
	{
		var path:String = Paths.getPreloadPath('characters/${char}/data.json');

		return path;
	}
}
