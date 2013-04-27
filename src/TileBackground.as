package
{
	import org.flixel.FlxSprite;
	
	public class TileBackground extends FlxSprite
	{
		[Embed(source='../data/tile-empty.png')] private var ImgTileEmpty:Class;
		[Embed(source='../data/tile-ground.png')] private var ImgTileGround:Class;
		
		public var type:int;
		public var baseType:int = -1;
		public var alphaSet:Boolean = false;
		
		public function TileBackground( tileType:Number, X:Number, Y:Number ):void
		{			
			super(X,Y);
			
			updateGraphic(tileType);
		}
		
		private function updateGraphic( tileType:int ):void
		{
			if( baseType < 0 )
				baseType = tileType;
			
			width = 32;
			height = 32;
			offset.x = 0;
			offset.y = 0;
			alpha = 1.0;
			
			switch( tileType )
			{
				case 0:
					loadGraphic(ImgTileEmpty, true, true, width, height);
					break;
				case 1:
					loadGraphic(ImgTileGround, true, true, width, height);
					break;
				default:
					break;
			}
			
			type = tileType;
		}
		
		override public function update():void
		{			
			super.update();
		}
	}
}