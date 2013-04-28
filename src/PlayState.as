package
{
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSortGroup;
	
	public class PlayState extends BasePlayState
	{
		public static var _currLevel:Level;
		
		public static var groupLowest:FlxGroup;
		public static var groupBackground:FlxGroup;
		public static var groupPlayerBehind:FlxGroup;
		public static var groupBoard:FlxGroup;
		public static var groupBoardSort:FlxGroup;
		public static var groupCollects:FlxGroup;
		public static var groupPlayer:FlxGroup;
		public static var groupForeground:FlxGroup;
		
		function PlayState():void
		{
			super();

			groupLowest = new FlxGroup;
			groupBackground = new FlxGroup;
			groupPlayerBehind = new FlxGroup;
			groupBoard = new FlxGroup;
			groupBoardSort = new FlxSortGroup;
			groupPlayer = new FlxGroup;
			groupCollects = new FlxGroup;
			groupForeground = new FlxGroup;
			
			// Create the level
			var currLevelClass:Class = levelArray[Moonshine.currLevelIndex];
			_currLevel = new currLevelClass( groupBackground );
			
			this.add(groupLowest);
			this.add(groupBackground);
			this.add(groupBoard);
			this.add(groupBoardSort);
			this.add(groupPlayerBehind);
			this.add(groupPlayer);
			this.add(groupCollects);
			this.add(groupForeground);
		}
		
		override public function update():void
		{					
			// Camera
			if( _currLevel.player != null )
			{
				FlxG.camera.follow(_currLevel.player, FlxCamera.STYLE_LOCKON);
				FlxG.camera.width = FlxG.width;
				FlxG.camera.height = FlxG.height;
			}
			
			// Update level
			_currLevel.update();
			
			// Next level
			if( _currLevel.nextLevel() )
			{
				nextLevel();				
			}
			
			super.update();
		}
		
		public function nextLevel():void
		{
			Moonshine.currLevelIndex++;
			if( Moonshine.currLevelIndex > levelArray.length - 1 )
			{
				Moonshine.currLevelIndex = 0;
			}
			FlxG.switchState(new PlayState());
		}
		
		override public function create():void
		{
		}

		override public function destroy():void
		{
			// Update level
			_currLevel.destroy();
			
			super.destroy();
		}
	}
}