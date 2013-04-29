package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Collect extends FlxSprite
	{
		[Embed(source="../data/collect.png")] private var ImgCollect:Class;
	
		private var _board:Board;
		private var _player:Player;
		public var tileX:int;
		public var tileY:int;
		public var collected:Boolean;
		
		public const COLLECTED_HOLD_TIME:Number = 0.5;
		public var collectedHoldTime:Number = COLLECTED_HOLD_TIME;

		
		public function Collect( X:int, Y:int, board:Board, player:Player )
		{
			_board = board;
			_player = player;
			tileX = X;
			tileY = Y;
			
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
			var tile:TileBackground = _board.tileMatrix[tileX][tileY];
			
			if( ! collected )
			{
				alpha = tile.alpha * 2;
			}
			
			play( "idle" );
			
			if( !collected && _player.tileX == tileX && _player.tileY == tileY )
			{
				collected = true;
				_player.collect();
			}
			
			if( _player.playerInactiveTimer > 0.0 )
			{
				collected = false;
				visible = true;
				collectedHoldTime = COLLECTED_HOLD_TIME;
				setTilePosition( tileX, tileY );
			}
			
			if( collected )
			{
				x = _player.x;
				
				if( y > _player.y - 50 )
				{
					y -= 5.0;
				}
				else
				{
					collectedHoldTime -= FlxG.elapsed;
					if( collectedHoldTime <= 0 )
					{
						alpha -= 0.05;
					}
				}
				
				return;
			}
			
			super.update();
		}
	}
}