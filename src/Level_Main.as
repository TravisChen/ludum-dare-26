package    {
		
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxParticle;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	public class Level_Main extends Level{
	
		[Embed(source='../data/roundover.png')] private var ImgRoundEnd:Class;
		[Embed(source = '../data/Audio/rain-loop.mp3')] private var SndSong:Class;
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
		
		public var rainEmitter:FlxEmitter;
		
		public var playMusic:Boolean = false;
		
		public function Level_Main( group:FlxGroup ) {
			
			levelSizeX = 1024;
			levelSizeY = 640;

			// Create board
			board = new Board();
			
			// Create player
			player = board.createPlayer();
			PlayState.groupBoardSort.add(player);
			board.createSpawns(player);
			board.setPlayer(player);

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
			
			// Round end
			roundEnd = false;
			buildRoundEnd();
			
			super();
			
			createRain();
		}
		
		public function createRain():void {
			
			rainEmitter = new FlxEmitter(0, 100, 200);
			rainEmitter.setSize(FlxG.width/3, 0);
			rainEmitter.setXSpeed(5, 5);
			rainEmitter.setYSpeed(75, 75);
			rainEmitter.setRotation(0, 0);
			PlayState.groupForeground.add(rainEmitter);
			
			var rainDrop:FlxParticle;
			for (var i:int = 0; i < rainEmitter.maxSize; i++) 
			{
				rainDrop = new FlxParticle();
				rainDrop.makeGraphic(1, 3, 0xFFeed294);
				rainDrop.alpha = 0.25 - FlxG.random() * 0.1;
				rainDrop.visible = false;
				rainEmitter.add(rainDrop);
			}
			
			rainEmitter.start(false, 3, 0.25);
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
			if( !playMusic )
			{
				FlxG.playMusic(SndSong,0.4);
				playMusic = true;
			}
			
			rainEmitter.x = player.x - FlxG.width/6;
			rainEmitter.y = player.y - FlxG.height/2;
			
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
