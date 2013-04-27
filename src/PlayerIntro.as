package
{
	import org.flixel.*;
	
	public class PlayerIntro extends FlxSprite
	{
		[Embed(source="../data/finn.png")] private var ImgFinn:Class;
		
		public var startX:Number = 0;
		public var endX:Number = FlxG.width/2 + 170;
		public var speed:Number = 3;
		public var direction:Boolean = false;
		
		public function PlayerIntro(X:int,Y:int)
		{
			super(X,Y);
			loadGraphic(ImgFinn,true,true,74,64);
			
			startX = x;
			scale.x = 2;
			scale.y = 2;
			
			// Bounding box tweaks
			width = 74;
			height = 64;
			offset.x = 22;
			offset.y = 53;
		
			addAnimation("walk", [1,2,3,4,5,6], 20);
		}
		
		override public function update():void
		{
			if( x <= startX )
			{
				direction = true;
			}
			
			if( x >= endX )
			{
				direction = false;
			}
			
			if( direction )
			{
				facing = RIGHT;
				x += speed;
			}
			else
			{
				facing = LEFT;
				x -= speed;
			}
			
			//UPDATE POSITION AND ANIMATION
			super.update();
			
			play("walk");
		}
	}
}