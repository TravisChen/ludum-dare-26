package
{
	import org.flixel.*;
	
	public class Explosion extends FlxSprite
	{
		[Embed(source='../data/Explosion.png')] private var ImgExplosion:Class;
		
		public var explode:Boolean = false;
		public var explodeDelay:Number;
		
		public function Explosion(X:int,Y:int, delay:Number):void
		{
			super(X,Y);
			
			loadGraphic(ImgExplosion, true, true, 32, 64);
			width = 32;
			height = 64;
			offset.x = -2;
			offset.y = 48;
			
			explodeDelay = delay;
			
			addAnimation("explode", [0,1,2,3], 20, false);
			alpha = 0;
		}
		
		override public function update():void
		{
			super.update();

			if( explodeDelay <= 0 )
			{
				if( !explode )
				{
					alpha = 1;
					explode = true;
					play( "explode" );
				}
			}
			else
			{
				explodeDelay -= FlxG.elapsed;
			}
			
			if( finished )
			{
				kill();
			}
		}
	}
}
