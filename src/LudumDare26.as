package
{
	import org.flixel.*; 
	[SWF(width="1280", height="800", backgroundColor="#000000")] 
	
	public class LudumDare26 extends FlxGame
	{
		public static var currLevelIndex:uint = 0;
		
		public function LudumDare26()
		{
			super(640,400,PlayState,2);
		}
	}
}