package;

import Sys;
import flixel.FlxG;
import sys.FileSystem;
import sys.io.File;

class CoolLogSystem
{
	// COLORS
	public static var BLACK:Int = 30;
	public static var RED:Int = 31;
	public static var GREEN:Int = 32;
	public static var YELLOW:Int = 33;
	public static var BLUE:Int = 34;
	public static var MAGENTA:Int = 35;
	public static var CYAN:Int = 36;
	public static var WHITE:Int = 37;

	public static function log(message:Dynamic, color:Int = 32)
	{
		createMessage(message, "trace", color);
	}

	public static function warning(message:Dynamic)
	{
		createMessage(message, "warning", YELLOW);
	}

	public static function error(message:Dynamic)
	{
		createMessage(message, "error", RED);
	}

	public static function clear()
	{
	}

	var isCMD:Bool;

	static function createMessage(message:Dynamic, type:String, color:Int = 32)
	{
		var formatType = '[' + '${type.toUpperCase()}' + ']';
		var simpleColor:String = Std.string(color) + "m";

		var addColor = 'dinero';

		#if IS_CMD
		isCMD = true;
		#else
		isCMD = false;
		#end

		if (isCMD)
		{
			addColor = formatType;
		}
		else
		{
			addColor = '\033[0;${simpleColor} $formatType\033[0m';
		}

		var text:String = addColor + ' ${Std.string(message)}';
		Sys.println(text);
	}
}
