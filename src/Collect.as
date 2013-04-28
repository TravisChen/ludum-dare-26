package
{
	import org.flixel.FlxSprite;
	
	public class Collect extends FlxSprite
	{
		[Embed(source="../data/collect.png")] private var ImgCollect:Class;
	
		private var _board:Board;
		private var _player:Player;
		private var _tileX:int;
		private var _tileY:int;
		public var collected:Boolean;
		
		public function Collect( X:int, Y:int, board:Board, player:Player )
		{
			_board = board;
			_player = player;
			_tileX = X;
			_tileY = Y;
			
			super(X,Y);
			setTilePosition(X,Y);
			loadGraphic(ImgCollect,true,true,21,24);
			
			// Bounding box tweaks
			width = 21;
			height = 24;
			offset.x = -7;
			offset.y = 13;
			alpha = 1.0;
			
			addAnimation("idle", [0]);
		}
		public function setTilePosition( x:int, y:int ):void
		{
			var tile:TileBackground = _board.tileMatrix[x][y];	
			this.x = tile.x;
			this.y = tile.y;
			super.update();
		}
		
		override public function update():void
		{	
			var tile:TileBackground = _board.tileMatrix[_tileX][_tileY];
			alpha = tile.alpha * 2;
			
			play( "idle" );
			
			if( _player.tileX == _tileX && _player.tileY == _tileY )
			{
				collected = true;
				_player.collect();
				kill();
			}
			super.update();
		}
	}
}