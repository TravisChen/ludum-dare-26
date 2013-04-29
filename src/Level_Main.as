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
		[Embed(source = '../data/title.png')] private var ImgTitle:Class;

		// Round End
		private var roundEnd:Boolean;
		private var roundEndContinueText:FlxText;
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
		
		public var titleSprite:FlxSprite;
		
		public var startTimer:Number = 1.0;
		
		public function Level_Main( group:FlxGroup ) {
			
			levelSizeX = 512;
			levelSizeY = 320;

			// Create board
			board = new Board();
			
			// Create player
			player = board.createPlayer();
			PlayState.groupBoardSort.add(player);
			board.createSpawns(player);
			board.setPlayer(player);

			// Create title
			titleSprite = new FlxSprite(0,0);
			titleSprite.loadGraphic(ImgTitle, true, true, levelSizeX, levelSizeY);	
			titleSprite.scrollFactor.x = titleSprite.scrollFactor.y = 0;
			PlayState.groupForeground.add(titleSprite);
			
			// Round end
			roundEnd = false;
			buildRoundEnd();
			
			super();
			
			createRain();
		}
		
		public function createRain():void {
			
			rainEmitter = new FlxEmitter(0, 0, 150);
			rainEmitter.setSize(FlxG.width/4, 0);
			rainEmitter.setXSpeed(5, 5);
			rainEmitter.setYSpeed(75, 75);
			rainEmitter.setRotation(0, 0);
			PlayState.groupForeground.add(rainEmitter);
			
			var rainDrop:FlxParticle;
			for (var i:int = 0; i < rainEmitter.maxSize; i++) 
			{
				rainDrop = new FlxParticle();

				switch( Helpers.randomNumber( 0, 2 ) )
				{
					case 0:
					{
						rainDrop.makeGraphic(1, 3, 0xFF7f4468);
						break;
					}
					case 1:
					{
						rainDrop.makeGraphic(1, 3, 0xFFa45485);
						break;
					}
					case 2:
					{
						rainDrop.makeGraphic(1, 3, 0xFFeed294);
						break;
					}
				}
				
				rainDrop.alpha = 0.25 - FlxG.random() * 0.1;
				rainDrop.visible = false;
				rainEmitter.add(rainDrop);
			}
			
			rainEmitter.start(false, 3, 0.1);
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
			
			roundEndTitleText = new FlxText(0, FlxG.height/2 - 70, FlxG.width, "ROUND OVER");
			roundEndTitleText.setFormat(null,32,CONTINUE_COLOR,"center");
			roundEndTitleText.scrollFactor.x = roundEndTitleText.scrollFactor.y = 0;	
			roundEndTitleText.visible = false;
			PlayState.groupForeground.add(roundEndTitleText);
		}
		
		override public function update():void
		{
			if( !playMusic )
			{
				FlxG.playMusic(SndSong,0.4);
				playMusic = true;
			}
			
			rainEmitter.x = player.x - FlxG.width/8;
			rainEmitter.y = player.y - FlxG.height/2 - 20;
			
			// BG color
			FlxG.bgColor = 0xFF3a2431;
			
			// Update board
			board.update();
			
			// Start timer
			if( player.startedMoving && startTimer > 0.0 )
			{
				startTimer -= FlxG.elapsed;
				return;
			}
			else
			{
				if( startTimer <= 0.0 )
				{
					titleSprite.alpha -= 0.025;
					if( titleSprite.alpha <= 0.0 )
					{
						titleSprite.alpha = 0.0;
					}
				}
			}
		
			super.update();
		}
		
		private function showEndPrompt():void 
		{
			FlxG.music.stop();

			PlayState._currLevel.player.roundOver = true;

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
