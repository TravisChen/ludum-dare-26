package
{
	import org.flixel.*;
	
	public class Enemy extends FlxSprite
	{
		[Embed(source="../data/enemy.png")] private var ImgEnemy:Class;
		[Embed(source="../data/particle-blood.png")] private var ImgParticle:Class;
		[Embed(source = '../data/Audio/appear.mp3')] private var SndAppear:Class;
		[Embed(source = '../data/Audio/destroy.mp3')] private var SndDestroy:Class;
		[Embed(source = '../data/Audio/stab.mp3')] private var SndStab:Class;
		
		public var startTime:Number;

		public var roundOver:Boolean = false;
		public var background:Boolean = false;
		public var foreground:Boolean = true;
		
		private var _board:Board;
		public var tileX:Number;
		public var tileY:Number;
		private var moveTo:TileBackground;
		private var moving:Boolean = false;
		private var speed:Number = 0.2;
		private var direction:Number = 0.0;
		
		private var _player:Player;
		private var lastTile:TileBackground = null;
		private var lastLastTile:TileBackground = null;
		
		private var particle:FlxEmitter;
		
		public function Enemy( X:int, Y:int, board:Board, player:Player )
		{
			_board = board;
			_player = player;
			
			super(X,Y);
			loadGraphic(ImgEnemy,true,true,27,27);
			
			// Move player to Tile
			setTilePosition( x, y );
			
			// Bounding box tweaks
			width = 27;
			height = 27;
			offset.x = -2;
			offset.y = 15;
			alpha = 1.0;
			
			addAnimation("walk", [0,1], 5);
		}

		public function moveToTile( x:int, y:int ):void
		{
			if( _board.validTile( x, y ) )
			{
				var tile:TileBackground = _board.tileMatrix[x][y];
				
				if( tile.moveableTile() )
				{
					tileX = x;
					tileY = y;
					moveTo = tile;
					moving = true;
				}
				
				lastLastTile = lastTile;
				lastTile = tile;
			}
		}
		
//		public function updateZOrdering():void
//		{
//			var rightX:int = tileX + 1;
//			var downY:int = tileY + 1;
//			var behind:Boolean = false;
//			if( rightX < _board.tileMatrix.length )
//			{
//				var rightTile:TileBackground = _board.tileMatrix[rightX][tileY];	
//				if( rightTile.isChain() )
//				{
//					behind = true;
//				}
//			}
//			
//			if( downY < _board.tileMatrix.length )
//			{
//				var downTile:TileBackground = _board.tileMatrix[tileX][downY];	
//				if( downTile.isChain() )
//				{
//					behind = true;
//				}
//			}
//			
//			if( rightX < _board.tileMatrix.length && downY < _board.tileMatrix.length )
//			{
//				var cornerTile:TileBackground = _board.tileMatrix[rightX][downY];	
//				if( cornerTile.isChain() )
//				{
//					behind = true;
//				}
//			}
//			
//			if( behind )
//			{
//				PlayState.groupPlayer.remove( this );
//				PlayState.groupPlayerBehind.add( this );
//			}
//			else
//			{
//				PlayState.groupPlayerBehind.remove( this );
//				PlayState.groupPlayer.add( this );
//			}
//		}
//		
		public function updateMovement():void
		{		
			var moveToX:Number = moveTo.x;
			var moveToY:Number = moveTo.y;
			
			if( x > moveToX )
				x -= 2 * speed;
			else if ( x < moveToX )
				x += 2 * speed;
			
			if( y > moveToY )
				y -= 1 * speed;
			else if ( y < moveToY )
				y += 1 * speed;
			
			if( x > moveToX - 1.0 && x < moveToX + 1.0 )
			{
				if( y > moveToY - 1.0 && y < moveToY + 1.0 ) 
				{
					moving = false;
				}
			}
		}
		
		public function setTilePosition( x:int, y:int ):void
		{
			tileX = x;
			tileY = y;
			
			var tile:TileBackground = _board.tileMatrix[tileX][tileY];	
			this.x = tile.x;
			this.y = tile.y;
			super.update();
		}
	
		public function moveSafe( x:int, y:int ):Boolean
		{
			var moveSafe:Boolean = false;
			if( _board.validTile( x, y ) )
			{					
				var tile:TileBackground = _board.tileMatrix[x][y];	
				if( tile.moveableTile() )
				{
					if( lastLastTile && lastLastTile != tile )
					{
						moveSafe = true;
					}
				}
			}
			return moveSafe;
		}
		
		public function nextMoveSafe():Boolean
		{
			var nextMoveSafe:Boolean = false;
			if( direction == 0 )
				nextMoveSafe = moveSafe( tileX - 1, tileY);
			else if ( direction == 1 )
				nextMoveSafe = moveSafe( tileX + 1, tileY );
			else if ( direction == 2 )
				nextMoveSafe = moveSafe( tileX, tileY - 1 );
			else if (direction == 3 )
				nextMoveSafe = moveSafe( tileX, tileY + 1 );
			
			return nextMoveSafe;
		}
		
		public function findSafeMove():void
		{
			var originalDirection:int = direction;
			
			if( !nextMoveSafe() )
			{
				if( originalDirection == 0 )
				{
					direction = 1;
				} 
				else if ( originalDirection == 1 )
				{
					direction = 0;						
				}
				else if ( originalDirection == 2 )
				{
					direction = 3;
				}
				else if ( originalDirection == 3 )
				{
					direction = 2;
				}
				
				if( !nextMoveSafe() )
				{
					if( originalDirection == 0 )
					{
						direction = 2;
					} 
					else if ( originalDirection == 1 )
					{
						direction = 2;						
					}
					else if ( originalDirection == 2 )
					{
						direction = 0;
					}
					else if ( originalDirection == 3 )
					{
						direction = 0;
					}
					
					if( !nextMoveSafe() )
					{
						if( originalDirection == 0 )
						{
							direction = 3;
						} 
						else if ( originalDirection == 1 )
						{
							direction = 3;						
						}
						else if ( originalDirection == 2 )
						{
							direction = 1;
						}
						else if ( originalDirection == 3 )
						{
							direction = 1;
						}
					}
				}
			}		
		}
		
		private function moveTowardsPlayer():void
		{
			if( this.tileX > _player.tileX )
			{
				direction = 0;
			}
			else if( this.tileX < _player.tileX  )
			{
				direction = 1;
			}
			else if( this.tileY > _player.tileY )
			{
				direction = 2;		
			}
			else if ( this.tileY < _player.tileY )
			{
				direction = 3;
			}
			
			findSafeMove();
		}
		
		override public function update():void
		{	
			if( startTime > 0 )
			{
				startTime -= FlxG.elapsed;
				return;
			}
			
			if( roundOver )
			{
				play("idle");
				return;
			}
		
			super.update();
			
			// Lighting
//			_board.lightTile( tileX, tileY, 2, false );
			
			moveTowardsPlayer();

			if( moving )
			{
				updateMovement();
				return;
			}

			if( direction == 0 )
			{
				play( "walk" );
				moveToTile( tileX - 1, tileY );
			}
			else if( direction == 1 )
			{
				play( "walk" );
				moveToTile( tileX + 1, tileY );
			}
			else if( direction == 2 )
			{
				play( "walk" );
				moveToTile( tileX, tileY - 1);
			}
			else if( direction == 3 )
			{
				play( "walk" );
				moveToTile( tileX, tileY + 1);
			}
		}
	}
}