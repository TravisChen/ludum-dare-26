package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Fire extends FlxSprite
	{
		[Embed(source='../data/Explosion.png')] private var ImgExplosion:Class;
		
		public var explode:Boolean = false;
		public var explodeDelay:Number;
		private var _delay:Number = 1.0;
		private var _board:Board;
		private var _player:Player;
		public var tileX:int;
		public var tileY:int;
		
		public function Fire(X:int,Y:int, board:Board, player:Player, startDelay:Number):void
		{
			_board = board;
			_player = player;
			tileX = X;
			tileY = Y;
			
			super(X,Y);
			
			loadGraphic(ImgExplosion, true, true, 32, 64);
			width = 32;
			height = 64;
			offset.x = -2;
			offset.y = 48;
			
			explodeDelay = startDelay;
			
			addAnimation("idle", [0] );
			addAnimation("explode", [0,1,2,3], 15, false);
			alpha = 0;
		
			setTilePosition( X, Y );
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
			super.update();
			
			if( explode )
			{
				if( _player.tileX == tileX && _player.tileY == tileY && _player.playerInactiveTimer <= 0.0 )
				{
					_player.respawn();
				}
			}

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
				if( explode )
				{
					explodeDelay = _delay;
					explode = false;
					alpha = 0;
				}
			}
		}
	}
}
