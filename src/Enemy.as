package
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
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
		private var speed:Number = 0.5;
		private var direction:Number = 0.0;
		private var stuck:int = 0;
		
		private var stuckThreshold:int = 1;
		private var strayThreshold:int = 5;
		private var startX:int = 0;
		private var startY:int = 0;
		
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
			startX = X;
			startY = Y;
			setTilePosition( x, y );
			
			// Bounding box tweaks
			width = 27;
			height = 27;
			offset.x = -2;
			offset.y = 15;
			alpha = 1.0;
			
			addAnimation("walk_forward", [0], 5);
			addAnimation("walk_backward", [1], 5);
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
					stuck = 0;
				}
				
				lastLastTile = lastTile;
				lastTile = tile;
			}
		}
			
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
					if( Math.abs( x - startX ) < strayThreshold &&  Math.abs( y - startY ) < strayThreshold )
					{
						if( tile.alpha < 0.1 )
						{
							if( stuck < stuckThreshold )
							{
								if( lastLastTile == null )
								{
									moveSafe = true;
								}
								else if ( lastLastTile != tile )
								{
									moveSafe = true;
								}
							}
							else
							{ 
								moveSafe = true;
							}
						}
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
		
		public function findSafeMove():Boolean
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
						
						if( !nextMoveSafe() )
						{
							stuck++;
							return false;
						}
					}
				}
			}	
			
			return true;
		}
		
		private function moveTowardsPlayer():Boolean
		{
			if( stuck < stuckThreshold )
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
			}
			else
			{
				direction = Math.floor(FlxG.random()*3);
			}
			
			if( findSafeMove() )
			{
				return true;
			}
			return false;
		}
		
		override public function update():void
		{	
			if( tileX == _player.tileX && tileY == _player.tileY && _player.playerInactiveTimer <= 0 )
			{
				_player.respawn();
			}
			
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
		
			if( moving )
			{
				updateMovement();
				return;
			}

			if( moveTowardsPlayer() )
			{
				if( direction == 0 )
				{
					play( "walk_backward" );
					facing = RIGHT;
					moveToTile( tileX - 1, tileY );
				}
				else if( direction == 1 )
				{
					play( "walk_forward" );
					facing = RIGHT;
					moveToTile( tileX + 1, tileY );
				}
				else if( direction == 2 )
				{
					play( "walk_backward" );
					facing = LEFT;
					moveToTile( tileX, tileY - 1);
				}
				else if( direction == 3 )
				{
					play( "walk_forward" );
					facing = LEFT;
					moveToTile( tileX, tileY + 1);
				}
			}
			
			super.update();
		}
	}
}