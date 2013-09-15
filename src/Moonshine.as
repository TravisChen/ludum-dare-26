package
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxGame;

	[SWF(width="1024", height="640", backgroundColor="#3a2431")] 
//	[Frame(factoryClass="Preloader")]

	public class Moonshine extends FlxGame
	{
		public static var currLevelIndex:uint = 0;
		
		public function Moonshine()
		{
			super(512,320,PlayState,4,60,60);
			
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
			FlxG.stage.addEventListener(Event.RESIZE, window_resized);
			window_resized();
//			forceDebugger = true;
		}
		
		private function window_resized(e:Event = null):void {
			
			// 2. Change the size of the Flixel game window
			//    We already changed the size of the Flash window, so now we need to update Flixel.
			//    Just update the FlxG dimensions to match the new stage dimensions from step 1
			FlxG.width = FlxG.stage.stageWidth / FlxCamera.defaultZoom;
			FlxG.height = FlxG.stage.stageHeight / FlxCamera.defaultZoom;
			
			// 3. Change the size of the Flixel camera
			//    Lastly, update the Flixel camera to match the new dimensions from the previous step
			//    This is so that the camera can see all of the freshly resized dimensions
			//			FlxG.resetCameras(new FlxCamera(0, 0, FlxG.width, FlxG.height));
		}
	}
}