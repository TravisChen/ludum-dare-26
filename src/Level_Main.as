package    {
		
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	public class Level_Main extends Level{
	
		[Embed(source='../data/roundover.png')] private var ImgRoundEnd:Class;
		[Embed(source = '../data/Audio/song.mp3')] private var SndSong:Class;
		[Embed(source = '../data/game-bg.png')] private var ImgBackground:Class;
		
		// Points
		private var pointsText:FlxText;
		private var lengthText:FlxText;
		
		// Timer
		public var startTime:Number;
		public var endTime:Number;
		private var timerText:FlxText;

		// Round End
		private var roundEnd:Boolean;
		private var roundEndContinueText:FlxText;
		private var roundEndPointsText:FlxText;
		private var roundEndTitleText:FlxText;
		private var roundEndForeground:FlxSprite;
		
		// Consts
		public const MAX_TIME:uint = 120;
		public const TEXT_COLOR:uint = 0xFFFFFFFF;
		public const CONTINUE_COLOR:uint = 0x00C0F8;
		
		public var board:Board;
		
		public var enemy:Enemy;
		
		public function Level_Main( group:FlxGroup ) {
			
			levelSizeX = 1280;
			levelSizeY = 800;

			// Create board
			board = new Board();
			
			// Create player
			player = new Player(0,0,board);
			PlayState.groupBoardSort.add(player);
			board.createEnemies(player);

			// Timer
			startTime = 1.0;
			endTime = 3.0;
			timer = MAX_TIME;
			
			points = 0;
			
			timerText = new FlxText(0, 0, FlxG.width, "0:00");
			timerText.setFormat(null,32,TEXT_COLOR,"left");
			timerText.scrollFactor.x = timerText.scrollFactor.y = 0;
//			PlayState.groupBackground.add(timerText);
			
			// Points
			pointsText = new FlxText(0, 0, FlxG.width, "0");
			pointsText.setFormat(null,32,TEXT_COLOR,"right");
			pointsText.scrollFactor.x = pointsText.scrollFactor.y = 0;
//			PlayState.groupBackground.add(pointsText);
			
//			var backgroundSprite:FlxSprite;
//			backgroundSprite = new FlxSprite(0,0);
//			backgroundSprite.loadGraphic(ImgBackground, true, true, levelSizeX, levelSizeY);	
//			PlayState.groupLowest.add(backgroundSprite);

//			FlxG.playMusic(SndSong,1.0);
			
			// Round end
			roundEnd = false;
			buildRoundEnd();
			
			super();
		}
		
		public function buildRoundEnd():void {
			roundEndForeground = new FlxSprite(0,0);
			roundEndForeground.loadGraphic(ImgRoundEnd, true, true, levelSizeX, levelSizeY);
			roundEndForeground.scrollFactor.x = roundEndForeground.scrollFactor.y = 0;
			roundEndForeground.visible = false;
			PlayState.groupForeground.add(roundEndForeground);
			
			roundEndContinueText = new FlxText(0, FlxG.height - 154, FlxG.width, "PRESS ANY KEY TO CONTINUE");
			roundEndContinueText.setFormat(null,16,CONTINUE_COLOR,"center");
			roundEndContinueText.scrollFactor.x = roundEndContinueText.scrollFactor.y = 0;	
			roundEndContinueText.visible = false;
			PlayState.groupForeground.add(roundEndContinueText);
			
			roundEndPointsText = new FlxText(0, FlxG.height/2 - 30, FlxG.width, "");
			roundEndPointsText.setFormat(null,64,TEXT_COLOR,"center");
			roundEndPointsText.scrollFactor.x = roundEndPointsText.scrollFactor.y = 0;	
			roundEndPointsText.visible = false;
			PlayState.groupForeground.add(roundEndPointsText);
			
			roundEndTitleText = new FlxText(0, FlxG.height/2 - 70, FlxG.width, "ROUND OVER");
			roundEndTitleText.setFormat(null,32,CONTINUE_COLOR,"center");
			roundEndTitleText.scrollFactor.x = roundEndTitleText.scrollFactor.y = 0;	
			roundEndTitleText.visible = false;
			PlayState.groupForeground.add(roundEndTitleText);
		}
		
		private function updateTimer():void
		{
			return; 
			
			// Timer
			var minutes:uint = timer/60;
			var seconds:uint = timer - minutes*60;
			if( startTime <= 0 )
			{
				timer -= FlxG.elapsed;
			}
			else
			{
				startTime -= FlxG.elapsed;
			}
			
			// Check round end
			if( timer <= 0 )
			{
				showEndPrompt();
				if( endTime <= 0 )
				{
					checkAnyKey();					
				}
				else
				{
					endTime -= FlxG.elapsed;
				}
				return;
			}
			
			// Update timer text
			if( seconds < 10 )
				timerText.text = "" + minutes + ":0" + seconds;
			else
				timerText.text = "" + minutes + ":" + seconds;
		}
		
		override public function update():void
		{
			// BG color
			FlxG.bgColor = 0xFF3a2431;
			
			// Update board
			board.update();
		
			// Timer
			updateTimer();

			// Update points text
			pointsText.text = "0";
			roundEndPointsText.text = "" + points;
			
			super.update();
		}
		
		private function showEndPrompt():void 
		{
			FlxG.music.stop();

			PlayState._currLevel.player.roundOver = true;
			
			roundEndPointsText.visible = true;
			roundEndForeground.visible = true;
			roundEndTitleText.visible = true;
		}
		
		private function checkAnyKey():void 
		{
			roundEndContinueText.visible = true;
			if (FlxG.keys.any())
			{
				roundEnd = true;
			}		
		}
		
		override public function nextLevel():Boolean
		{
			if( roundEnd )
			{
				return true;
			}
			return false;
		}
	}
}
