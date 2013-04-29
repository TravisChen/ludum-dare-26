package
{
	import org.flixel.*; 
	[SWF(width="1024", height="640", backgroundColor="#3a2431")] 
//	[Frame(factoryClass="Preloader")]
	
	public class Moonshine extends FlxGame
	{
		public static var currLevelIndex:uint = 0;
		
		public function Moonshine()
		{
			super(512,320,PlayState,2);
			forceDebugger = true;
		}
	}
}