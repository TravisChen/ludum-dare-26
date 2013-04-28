package
{
	import org.flixel.*;
	
	public class Poof extends FlxSprite
	{
		[Embed(source='../data/Poof.png')] private var ImgPoof:Class;
		
		public var explode:Boolean = false;
		
		public function Poof (X:int,Y:int):void
		{
			super(X,Y);
			
			loadGraphic(ImgPoof, true, true, 30, 32);
			width = 30;
			height = 32;
			offset.x = 0;
			offset.y = 20;
			
			addAnimation("explode", [0,1,2,3], 14, false);
			alpha = 0;
		}
		
		override public function update():void
		{
			super.update();

			if( !explode )
			{
				alpha = 1;
				explode = true;
				play( "explode" );
			}
			
			if( finished )
			{
				kill();
			}
		}
	}
}
