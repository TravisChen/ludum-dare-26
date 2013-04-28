package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Player extends FlxSprite
	{
		[Embed(source='../data/player.png')] private var ImgPlayer:Class;
		[Embed(source='../data/wasd.png')] private var ImgWasd:Class;
		[Embed(source='../data/space.png')] private var ImgSpace:Class;
		
		[Embed(source = '../data/Audio/VO-01.mp3')] private var SndVO1:Class;
		
		[Embed(source = '../data/Audio/thunder.mp3')] private var SndThunder:Class;
		[Embed(source = '../data/Audio/explode.mp3')] private var SndExplode:Class;
		[Embed(source = '../data/Audio/drink.mp3')] private var SndDrink:Class;
		
		public var startTime:Number;

		public var roundOver:Boolean = false;
		public var background:Boolean = false;
		public var foreground:Boolean = true;
		
		public var time:Number = 0.0;
		
		private var _board:Board;
		public var tileX:Number;
		public var tileY:Number;
		private var moveTo:TileBackground;
		private var moving:Boolean = false;
		private var startedMoving:Boolean = false;
		private var startedKick:Boolean = false;
		private var speed:Number = 1.1;
		public var kicking:Boolean = false;
		private var forward:Boolean = true;
	
		// Light
		public var lightCharged:Number = 10.0;
		public var lightMin:Number = 2.0;
		public var lightDecrement:Number = 0.05;
		public var lightIncrement:Number = 0.25;
		public var light:Number = lightCharged;
		
		public var playerDeadTime:Number = 1.0;
		public var playerDeadTimer:Number = 0.0;
		public var playerInactiveTime:Number = 0.25;
		public var playerInactiveTimer:Number = 0.0;

		public var wasd:FlxSprite;
		public var wasdFadeOutTime:Number = 0;
		public var wasdBounceTime:Number = 0;
		public var wasdBounceToggle:Boolean = true;
		
		public var space:FlxSprite;
		public var spaceFadeOutTime:Number = 0;
		public var spaceBounceTime:Number = 0;
		public var spaceBounceToggle:Boolean = true;
		public var alphaArray:Array;
		
		public var collected:Boolean = false;
		public var lastLightPostX:int = 0;
		public var lastLightPostY:int = 0;

		public function Player( X:int, Y:int, board:Board )
		{
			_board = board;
			
			super(X,Y);
			loadGraphic(ImgPlayer,true,true,67,53);
			
			alphaArray = new Array(1.0, 0.75, 0.25, 0.1);
			
			// Move player to Tile
			setTilePosition( x, y );
			
			// Bounding box tweaks
			width = 67;
			height = 53;
			offset.x = 17;
			offset.y = 42;
			
			// WASD
			wasd = new FlxSprite(0,0);
			wasd.loadGraphic(ImgWasd, true, true, 32, 32);
			wasd.alpha = 1;
			PlayState.groupForeground.add(wasd);
			
			// SPACE
			space = new FlxSprite(0,0);
			space.loadGraphic(ImgSpace, true, true, 32, 32);
			space.alpha = 1;
			PlayState.groupForeground.add(space);
			
			addAnimation("idle_forward", [0]);
			addAnimation("walk_forward", [6,5,4,3,2,1], 10);
			addAnimation("idle_backward", [7]);
			addAnimation("walk_backward", [8,9,10,11,12,13], 10);
			addAnimation("kick", [0], 20, false );
			
			// Start time
			startTime = 0.0;
		}
		
		public function moveToTile( x:int, y:int ):Boolean
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
					
					return true;
				}
			}
			return false;
		}
		
		public function respawn():void 
		{
			
			// Create explosion
			var poofDie:Poof = new Poof(this.x,this.y+1);
			PlayState.groupBoardSort.add(poofDie);
			
			playerDeadTimer = playerDeadTime;
			playerInactiveTimer = playerInactiveTime;	
			
			visible = false;
			space.visible = false;
			wasd.visible = false;
			
			FlxG.play(SndExplode, 0.15);
		}
		
		public function updateRespawn():Boolean
		{
			if( playerDeadTimer > 0.0 )
			{
				playerDeadTimer -= FlxG.elapsed;
				if( playerDeadTimer <= 0.0 )
				{
					setTilePosition( lastLightPostX, lastLightPostY );
					
					visible = true;
					space.visible = true;
					wasd.visible = true;
					playerDeadTimer = 0;
					
					// Create explosion
					var poofRespwan:Poof = new Poof(this.x,this.y+1);
					PlayState.groupBoardSort.add(poofRespwan);
					
					play( "idle_forward" );
				}
				return true;
			}
			else if ( playerInactiveTimer > 0.0 )
			{
				playerInactiveTimer -= FlxG.elapsed;
				if( playerInactiveTimer <= 0.0 )
				{
					playerInactiveTimer = 0.0;
				}
				return true;
			}
			return false;
		}
		
		public function collect():void
		{
			collected = true;
			
			FlxG.play(SndDrink, 1.0);
		}
		
		public function kick():void
		{
			var startX:int = tileX - 1;
			var startY:int = tileY - 1;
			var incrementX:int = startX;
			var incrementY:int = startY;
			
			var ex:Number = 0.03;
			var explodeDelayArray:Array = new Array(ex*2,ex,0,ex*3,ex*8,ex*7,ex*4,ex*5,ex*6);
			
			for( var i:int = 0; i < 3; i++ )
			{
				for( var j:int = 0; j < 3; j++ )
				{
					if( incrementX >= 0 && incrementX < _board.tileMatrix.length )
					{
						if( incrementY >= 0 && incrementY < _board.tileMatrix[incrementX].length )
						{
							var tile:TileBackground = _board.tileMatrix[incrementX][incrementY];
							
							if( tile.moveableTile())
							{
								// Create explosion
								var explosion:Explosion = new Explosion(tile.x,tile.y,explodeDelayArray[(i*3) + j]);
								PlayState.groupBoardSort.add(explosion);
							}
						}
					}
					incrementY += 1;
				}
				incrementX += 1;
				incrementY = startY;
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
			
			if( x > moveToX - speed && x < moveToX + speed )
			{
				if( y > moveToY - speed && y < moveToY + speed ) 
				{
					moving = false;
					x = moveToX;
					y = moveToY;
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
			
			moveTo = tile;
			moving = false;
			
			super.update();
		}
	
		public function updateWasd():void 
		{
			wasd.y = y - 76;
			wasd.x = x;
			
			if( moving || startedMoving )
			{
				if( wasd.alpha > 0.0 )
				{
					wasd.alpha -= 0.05;		
				}
				else
				{
					wasd.alpha = 0;
				}
				
				if( !startedMoving )
				{
					startedMoving = true;
					
					// Test VO play
					FlxG.play(SndVO1, 1.0);
				}
			}
			else
			{
				if( wasdBounceTime <= 0 )
				{
					wasdBounceTime = 0.02;
					if( wasdBounceToggle )
					{
						wasd.y += 1;
						wasdBounceToggle = false;
					}
					else
					{
						wasd.y -= 1;
						wasdBounceToggle = true;
					}
				}
				else
				{
					wasdBounceTime -= FlxG.elapsed;
				}
			}
		}
		
		public function updateSpace():void 
		{
			space.y = y - 76;
			space.x = x;
			
			if( !startedMoving )
			{
				space.visible = false;
				return;
			}
			
			space.visible = true;
			
			if( startedKick )
			{
				space.alpha -= 0.05;		
			}
			else
			{
				if( spaceBounceTime <= 0 )
				{
					spaceBounceTime = 0.02;
					if( wasdBounceToggle )
					{
						space.y += 1;
						spaceBounceToggle = false;
					}
					else
					{
						space.y -= 1;
						spaceBounceToggle = true;
					}
				}
				else
				{
					spaceBounceTime -= FlxG.elapsed;
				}
			}
		}
		
		public function pulse():void
		{
			return;
			var osc:Number = 1.0 - (1 + Math.sin( time * 3.0 ) );										
			alpha = 1.0 - 0.25*osc;
			
			if( kicking )
			{
				alpha = 1.0;
			}
		}
		
		public function updateLight():void
		{
			var tile:TileBackground = _board.tileMatrix[tileX][tileY];
			
			if( tile.alpha == 0 && !collected )
			{
				if( light > lightMin )
				{
					light -= lightDecrement;
				}
				else
				{
					light = lightMin;
				}
			}
			else
			{
				if( light < lightCharged )
				{
					light += lightIncrement;
				}
				else
				{
					light = lightCharged;
					collected = false;
				}
			}
		}
		
		override public function update():void
		{	
			time += FlxG.elapsed;
			
			if( updateRespawn() )
			{
				return;
			}
			
			if( startTime > 0 )
			{
				startTime -= FlxG.elapsed;
				return;
			}
			
			if( roundOver )
			{
				play( "idle" );
				return;
			}

			updateWasd();
			updateSpace();
						
			super.update();			

			if( moving )
			{
				updateMovement();
				return;
			}
			
			if( kicking )
			{
				startedKick = true;
				if( finished )
				{
					kicking = false;
				}
				return;
			}
			
			var doMove:Boolean = false;

			if( FlxG.keys.SPACE )
			{
				kick();
				kicking = true;
				play( "kick" );
				FlxG.play( SndThunder, 0.15 );
			}
			else if(FlxG.keys.UP )
			{
				if( !moveToTile( tileX - 1, tileY ) )
				{
					if( moveToTile( tileX, tileY - 1) )
					{
						play( "walk_backward" );
						forward = false;
						facing = LEFT;
					}
				}
				else
				{
					play( "walk_backward" );
					forward = false;
					facing = RIGHT;
				}
			}
			else if(FlxG.keys.DOWN )
			{
				if( !moveToTile( tileX + 1, tileY ) )
				{
					if( moveToTile( tileX, tileY + 1) )
					{
						play( "walk_forward" );
						forward = true;
						facing = LEFT;
					}
				}
				else
				{
					play( "walk_forward" );
					forward = true;
					facing = RIGHT;
				}
			}
			else if(FlxG.keys.LEFT )
			{
				if( !moveToTile( tileX, tileY - 1) )
				{
					if( moveToTile( tileX + 1, tileY ) )
					{
						play( "walk_forward" );
						forward = true;
						facing = RIGHT;
					}
				}
				else
				{
					play( "walk_backward" );
					forward = false;
					facing = LEFT;
				}
			}
			else if(FlxG.keys.RIGHT )
			{
				if( !moveToTile( tileX, tileY + 1) )
				{
					if( moveToTile( tileX - 1, tileY ) )
					{
						play( "walk_backward" );
						forward = false;
						facing = RIGHT;
					}
				}
				else
				{
					play( "walk_forward" );
					forward = true;
					facing = LEFT;
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
		}
	}
}