package;

#if desktop
import DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public var freeplayData:StoryMenuState.WeekJSON;

	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		freeplayData = Json.parse(Assets.getText(Paths.json("weekList")));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		for (i in 0...freeplayData.weeks.length)
		{
			if (freeplayData.weeks[i].hideInFreePlay == false)
				addWeek(freeplayData.weeks[i].weekSongs, freeplayData.weeks[i].songColor, i, freeplayData.weeks[i].songIcons);
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, songColor:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, songColor, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, color:String, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var icon:Int = 0;
		for (song in songs)
		{
			addSong(song, color, weekNum, songCharacters[icon]);

			if (songCharacters.length != 1)
				icon++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-1);
		}
		if (downP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(1);
		}

		if (controls.LEFT_P)
		{
			changeDiff(-1);
		}
		if (controls.RIGHT_P)
		{
			changeDiff(1);
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			#if PRELOAD_ALL
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			#end
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, CoolUtil.difficultyArray.length - 1);

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = '< ' + CoolUtil.difficultyArray[curDifficulty] + ' >';
	}

	var colorTween:ColorTween;

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

		if (colorTween == null)
		{
			colorTween = FlxTween.color(bg, 0.4, bg.color, FlxColor.fromString("#" + songs[curSelected].songColor), {startDelay: 0.05});
		}
		else if (FlxColor.fromString("#" + songs[curSelected].songColor) != colorTween.color)
		{
			colorTween.cancel();
			colorTween = FlxTween.color(bg, 0.4, bg.color, FlxColor.fromString("#" + songs[curSelected].songColor), {startDelay: 0.05});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:String = "";

	public function new(song:String, color:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.songColor = color;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
