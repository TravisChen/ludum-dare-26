package
{
	import org.flixel.*;
	
	public class Helpers
	{
		public function Helpers()
		{
		}
		
		static public function randomNumber(min:Number, max:Number, Absolute:Boolean=false):Number
		{
			if(!Absolute)
			{
				return Math.floor(Math.random() * (1 + max - min) + min);
			}
			else
			{
				return Math.abs(Math.floor(Math.random() * (1 + max - min) + min));
			}
		}
		
		static public function scale(sprite:FlxSprite, scale:Number):void	
		{	
			sprite.scale.x = sprite.scale.y = scale;
			sprite.offset.x += Math.floor(sprite.width  * -(sprite.scale.x - 1)/2);
			sprite.offset.y += Math.floor(sprite.height * -(sprite.scale.y - 1)/2);
			sprite.width *= (sprite.scale.x);
			sprite.height *= (sprite.scale.y);	
		}
	}
}