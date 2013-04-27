package
{
	import org.flixel.FlxSprite;
	
	public class TileBackground extends FlxSprite
	{
		[Embed(source='../data/tile-empty.png')] private var ImgTileEmpty:Class;
		[Embed(source='../data/tile-ground.png')] private var ImgTileGround:Class;
		[Embed(source='../data/tile-crate.png')] private var ImgTileCrate:Class;
		
		public var type:int  = 0;
		public var baseType:int = -1;
		public var maxAlpha:Number = 0.0;
		private var _board:Board;
		private var _xIndex:int;
		private var _yIndex:int;
		
		public function TileBackground( tileType:Number, X:Number, Y:Number, xIndex:int, yIndex:int, board:Board ):void
		{			
			super(X,Y);
			
			_board = board;
			_xIndex = xIndex;
			_yIndex = yIndex;
			
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
				case 2:
					width = 32;
					height = 48;
					offset.y = 16;
					loadGraphic(ImgTileCrate, true, true, width, height);
					break;
				default:
					break;
			}
			
			type = tileType;
		}
		
		public function moveableTile():Boolean
		{
			if( type != 1 )
				return false;
			
			return true;
		}
		
		override public function update():void
		{
			if( type == 2 )
			{
				if( _board )
				{
					_board.lightTile( _xIndex, _yIndex, 3, false );
				}
			}
			super.update();
		}
	}
}