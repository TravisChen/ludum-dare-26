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
		private var strayThreshold:int = 10;
		private var startX:int = 0;
		private var startY:int = 0;
		
		private var _player:Player;
		private var lastTile:TileBackground = null;
		private var lastLastTile:TileBackground = null;
		private var forward:Boolean = true;
		private var attacking:Boolean = false;
		
		private var particle:FlxEmitter;

		public const LOOKUP_BORDER:uint = 20;
		
		public function Enemy( X:int, Y:int, board:Board, player:Player )
		{
			_board = board;
			_player = player;
			
			super(X,Y);
			loadGraphic(ImgEnemy,true,true,34,30);
			
			// Move player to Tile
			startX = X;
			startY = Y;
			setTilePosition( x, y );
			
			// Bounding box tweaks
			width = 34;
			height = 30;
			offset.x = 0;
			offset.y = 18;
			alpha = 1.0;
			
			addAnimation("idle_forward", [14,15],8);
			addAnimation("walk_forward", [6,5,4,3,2,1], 8);
			addAnimation("idle_backward", [21,22],8);
			addAnimation("walk_backward", [7,8,9,10,11,12], 8);
			addAnimation("attack_forward", [14,15,16,17,18,19,20,14,15,16,17,18,19,20],16, false);
			addAnimation("attack_backward", [21,22,23,24,25,26,27,21,22,23,24,25,26,27],16, false);
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
						if( tile.alpha < 0.1 || ( _player.light <= _player.lightMin && !_player.kicking) )
						{
							var occupied:Boolean = false;
							for( var i:int = 0; i < _board.enemyArray.length; i++)
							{
								var enemy:Enemy = _board.enemyArray[i];
								if( this != enemy )
								{
									if( enemy.tileX == x && enemy.tileY == y )
									{
										occupied = true;
									}
								}
							}
							
							for( var j:int = 0; j < _board.collectArray.length; j++)
							{
								var collect:Collect = _board.collectArray[j];
								if( collect.tileX == x && collect.tileY == y )
								{
									occupied = true;
								}
							}
							
							for( var k:int = 0; k < _board.fireArray.length; k++)
							{
								var fire:Fire = _board.fireArray[k];
								if( fire.tileX == x && fire.tileY == y )
								{
									occupied = true;
								}
							}

							if( !occupied )
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
		
		public function distanceTwoPoints(x1:Number, x2:Number,  y1:Number, y2:Number):Number 
		{
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		override public function update():void
		{	
			if( tileX >= _player.tileX + LOOKUP_BORDER || tileX <= _player.tileX - LOOKUP_BORDER )
			{
				if( tileY >= _player.tileY + LOOKUP_BORDER || tileY <= _player.tileY - LOOKUP_BORDER )
				{
					return;
				}
			}
			
			if( distanceTwoPoints( tileX, _player.tileX, tileY, _player.tileY ) < 1.0 && _player.playerInactiveTimer <= 0.0 )
			{
				attacking = true;
				
				if( forward )
				{
					play( "attack_forward" );
				}
				else
				{
					play( "attack_backward" );
				}
				
				_player.respawn();
			}
			
			if( attacking )
			{
				if( finished )
				{
					attacking = false;	
				}
				return;
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
					forward = false;
					facing = RIGHT;
					moveToTile( tileX - 1, tileY );
				}
				else if( direction == 1 )
				{
					play( "walk_forward" );
					forward = true;
					facing = RIGHT;
					moveToTile( tileX + 1, tileY );
				}
				else if( direction == 2 )
				{
					play( "walk_backward" );
					forward = false;
					facing = LEFT;
					moveToTile( tileX, tileY - 1);
				}
				else if( direction == 3 )
				{
					play( "walk_forward" );
					forward = true;
					facing = LEFT;
					moveToTile( tileX, tileY + 1);
				}
			}
			else
			{
				if( forward )
				{
					play( "idle_forward" );
				}
				else
				{
					play( "idle_backward" );
				}
			}
			
			super.update();
		}
	}
}