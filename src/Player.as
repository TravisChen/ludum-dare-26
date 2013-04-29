package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Player extends FlxSprite
	{
		[Embed(source='../data/player.png')] private var ImgPlayer:Class;
		[Embed(source='../data/wasd.png')] private var ImgWasd:Class;
		[Embed(source='../data/space.png')] private var ImgSpace:Class;
		
		[Embed(source = '../data/Audio/VO/haiku-01.mp3')] private var SndVO1:Class;
		[Embed(source = '../data/Audio/VO/haiku-02.mp3')] private var SndVO2:Class;
		[Embed(source = '../data/Audio/VO/haiku-03.mp3')] private var SndVO3:Class;
		[Embed(source = '../data/Audio/VO/haiku-04.mp3')] private var SndVO4:Class;
		[Embed(source = '../data/Audio/VO/haiku-05.mp3')] private var SndVO5:Class;
		[Embed(source = '../data/Audio/VO/haiku-06.mp3')] private var SndVO6:Class;
		[Embed(source = '../data/Audio/VO/haiku-09.mp3')] private var SndVO9:Class;
		[Embed(source = '../data/Audio/VO/haiku-10.mp3')] private var SndV10:Class;
		[Embed(source = '../data/Audio/VO/haiku-11.mp3')] private var SndV11:Class;
		[Embed(source = '../data/Audio/VO/haiku-12.mp3')] private var SndV12:Class;
		[Embed(source = '../data/Audio/VO/haiku-13.mp3')] private var SndV13:Class;
		[Embed(source = '../data/Audio/VO/haiku-14.mp3')] private var SndV14:Class;
		[Embed(source = '../data/Audio/VO/haiku-15.mp3')] private var SndV15:Class;
		[Embed(source = '../data/Audio/VO/haiku-16.mp3')] private var SndV16:Class;
		[Embed(source = '../data/Audio/VO/haiku-17.mp3')] private var SndV17:Class;
		
		[Embed(source = '../data/Audio/thunder.mp3')] private var SndThunder:Class;
		[Embed(source = '../data/Audio/explode.mp3')] private var SndExplode:Class;
		[Embed(source = '../data/Audio/drink.mp3')] private var SndDrink:Class;
		
		public var roundOver:Boolean = false;
		public var background:Boolean = false;
		public var foreground:Boolean = true;
		
		public var time:Number = 0.0;
		
		private var _board:Board;
		public var tileX:Number;
		public var tileY:Number;
		private var moveTo:TileBackground;
		private var moving:Boolean = false;
		public var startedMoving:Boolean = false;
		private var startedKick:Boolean = false;
		private var speed:Number = 1.1;
		
		public var kicking:Boolean = false;
		public var kickingLight:Number = 10;
		public var kickingDecrement:Boolean = false;
		
		private var forward:Boolean = true;
	
		// Light
		public var lightCharged:Number = 10.0;
		public var lightKickCharged:Number = 12.0;
		public var lightMin:Number = 2.0;
		public var lightDecrement:Number = 0.05;
		public var lightIncrement:Number = 0.25;
		public var light:Number = lightMin;
		
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
		
		public var collected:Boolean = false;
		public var lastLightPostX:int = 0;
		public var lastLightPostY:int = 0;
		public var farthestLightPosX:int = 0;
		
		public var VOArray:Array;
		public var VOIndex:int = 0;
		
		public var fin:Boolean = false;

		public function Player( X:int, Y:int, board:Board )
		{
			_board = board;
			
			super(X,Y);
			loadGraphic(ImgPlayer,true,true,67,53);
			
			VOArray = new Array(SndVO1, SndVO2, SndVO3, SndVO4, SndVO5,
								SndVO6, SndVO9, SndV10,
								SndV11, SndV12, SndV13, SndV14, SndV15,
								SndV16, SndV17);

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
		
			addAnimation("idle_forward", [21,22,23,24,25,26,27], 10);
			addAnimation("walk_forward", [6,5,4,3,2,1], 10);
			addAnimation("idle_backward", [7]);
			addAnimation("walk_backward", [8,9,10,11,12,13], 10);
			addAnimation("kick", [16,17,18,19,20,19,16,15,14], 20, false );
			addAnimation("fin",[28,28,28,28,28,29,28,28,29], 3);
		}
		
		public function playNextVO( farthestX:int ):void
		{
			farthestLightPosX = farthestX;
			if( VOIndex < VOArray.length )
			{
				FlxG.play(VOArray[VOIndex], 1.0);
				VOIndex++;
			}
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
					
					if( tile.type == 13 )
					{
						kick();
						fin = true;	
					}
					
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
			if( !wasd )
			{
				return;
			}
			
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
					wasd.kill();
				}
				
				if( !startedMoving )
				{
					startedMoving = true;
					
					// Test VO play
					playNextVO( tileX );
				}
			}
			else
			{
				if( wasdBounceTime <= 0 )
				{
					wasdBounceTime = 0.1;
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
			if( !space )
			{
				return;
			}
			
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
				if( space.alpha <= 0.0 )
				{
					space.kill();
				}
			}
			else
			{
				if( spaceBounceTime <= 0 )
				{
					spaceBounceTime = 0.1;
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
			

			
			if( !fin )
			{
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
			else
			{
				light -= 0.1;
			}
		}
		
		override public function update():void
		{	
			time += FlxG.elapsed;
			
			if( updateRespawn() )
			{
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
			
			if( fin )
			{
				play( "fin" );
				offset.x = 12;
				y -= 0.4;
				alpha -= 0.001;
				return;
			}
			
			if( kicking )
			{
				if( !kickingDecrement )
				{
					kickingLight += 1.0;
					if( kickingLight >= lightKickCharged )
					{
						kickingDecrement = true;
						kickingLight = lightKickCharged;
					}
				}
				else
				{
					kickingLight -= 1.0;
					if( kickingLight <= light )
					{
						kickingLight = light;
					}
				}
				
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
				kickingDecrement = false;
				kickingLight = light;
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