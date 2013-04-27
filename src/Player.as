package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Player extends FlxSprite
	{
		[Embed(source='../data/player.png')] private var ImgPlayer:Class;
		[Embed(source='../data/wasd.png')] private var ImgWasd:Class;
		[Embed(source='../data/space.png')] private var ImgSpace:Class;
		[Embed(source = '../data/Audio/slash-alt.mp3')] private var SndSlash:Class;
		[Embed(source = '../data/Audio/slash.mp3')] private var SndSlashBacking:Class;
		[Embed(source = '../data/Audio/pie-unveal.mp3')] private var SndPie:Class;
		
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
		private var speed:Number = 2.0;
		private var kicking:Boolean = false;
		
		public var wasd:FlxSprite;
		public var wasdFadeOutTime:Number = 0;
		public var wasdBounceTime:Number = 0;
		public var wasdBounceToggle:Boolean = true;
		
		public var space:FlxSprite;
		public var spaceFadeOutTime:Number = 0;
		public var spaceBounceTime:Number = 0;
		public var spaceBounceToggle:Boolean = true;
		public var collectedFirstPie:Boolean = false;
		public var alphaArray:Array;
		
		public function Player( X:int, Y:int, board:Board )
		{
			_board = board;
			
			super(X,Y);
			loadGraphic(ImgPlayer,true,true,45,39);
			
			alphaArray = new Array(1.0, 0.75, 0.25, 0.1);
			
			// Move player to Tile
			setTilePosition( x, y );
			
			// Bounding box tweaks
			width = 45;
			height = 39;
			offset.x = 12;
			offset.y = 30;
			
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
			
			addAnimation("idle", [0]);
			addAnimation("walk", [0], 20);
			addAnimation("kick", [0], 20, false );
			
			// Start time
			startTime = 0.0;
		}
		
		public function moveToTile( x:int, y:int ):void
		{
			if( validTile( x, y ) )
			{
				var tile:TileBackground = _board.tileMatrix[x][y];
				
				if( tile.type != 0 )
				{
					tileX = x;
					tileY = y;
					moveTo = tile;
					moving = true;
				}
			}
		}
		
		public function resetTiles():void
		{
			for( var x:int = 0; x < _board.tileMatrix.length; x++ )
			{
				for( var y:int = 0; y < _board.tileMatrix[x].length; y++ )
				{
					var tile:TileBackground = _board.tileMatrix[x][y];
					tile.alpha = 0.0;
					tile.alphaSet = false;
					tile.visible = false;
				}	
			}
		}
		
		public function validTile( x:int, y:int ):Boolean
		{
			if( x >= 0 && x < _board.tileMatrix.length )
			{
				if( y >= 0 && y < _board.tileMatrix[x].length )
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function distanceTwoPoints(x1:Number, x2:Number,  y1:Number, y2:Number):Number 
		{
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public function lightTile( origX:int, origY:int ): void 
		{
			var checkDistance:int = 10;
			var maxDistance:int = 4;
			if( kicking )
			{
				maxDistance = 10;
			}
			var oscAmount:Number = 3.0;
			var origTile:TileBackground = _board.tileMatrix[origX][origY];
			
			for( var x:int = origX - checkDistance; x < origX + checkDistance; x++ )
			{
				for( var y:int = origY - checkDistance; y < origY + checkDistance; y++ )
				{
					if( validTile( x, y ) )
					{
						
						var distance:Number = distanceTwoPoints( origX, x, origY, y );
						if( distance < maxDistance )
						{
							var tile:TileBackground = _board.tileMatrix[x][y];
							var osc:Number = (1 + Math.sin( time * oscAmount ) );										
							var alpha:Number = ( 1 - Math.abs( distance / ( maxDistance + osc ) ) );
							tile.visible = true;
							tile.alpha = Math.pow(alpha, 3);
							
							tile.alphaSet = false;
						}
					}
				}	
			}
		}
		
		public function kick():void
		{
			var startX:int = tileX - 1;
			var startY:int = tileY - 1;
			var incrementX:int = startX;
			var incrementY:int = startY;
			
			var ex:Number = 0.03;
			var explodeDelayArray:Array = new Array(ex*2,ex,0,ex*3,ex*8,ex*7,ex*4,ex*5,ex*6);
			
			FlxG.play(SndSlash,0.35);
			FlxG.play(SndSlashBacking,0.25);
			
			for( var i:int = 0; i < 3; i++ )
			{
				for( var j:int = 0; j < 3; j++ )
				{
					if( incrementX >= 0 && incrementX < _board.tileMatrix.length )
					{
						if( incrementY >= 0 && incrementY < _board.tileMatrix[incrementX].length )
						{
							var tile:TileBackground = _board.tileMatrix[incrementX][incrementY];
							
							if( tile.type != 0 )
							{
								// Create explosion
								var explosion:Explosion = new Explosion(tile.x,tile.y,explodeDelayArray[(i*3) + j]);
								PlayState.groupPlayerBehind.add(explosion);
							}
						}
					}
					incrementY += 1;
				}
				incrementX += 1;
				incrementY = startY;
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
//			}
//			
//			if( downY < _board.tileMatrix.length )
//			{
//				var downTile:TileBackground = _board.tileMatrix[tileX][downY];	
//			}
//			
//			if( rightX < _board.tileMatrix.length && downY < _board.tileMatrix.length )
//			{
//				var cornerTile:TileBackground = _board.tileMatrix[rightX][downY];	
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
			
			if( x == moveToX && y == moveToY )
				moving = false;
		}
		
		public function setTilePosition( x:int, y:int ):void
		{
			tileX = x;
			tileY = y;
			
			var tile:TileBackground = _board.tileMatrix[tileX][tileY];	
			this.x = tile.x;
			this.y = tile.y;
			
			resetTiles();
			lightTile( x, y );
			
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
				startedMoving = true;
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
		
		override public function update():void
		{	
			time += FlxG.elapsed;
			
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

			// Lighting
			resetTiles();
			lightTile( tileX, tileY );
			
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
			
			if( FlxG.keys.SPACE )
			{
				kick();
				kicking = true;
				play( "kick" );
			}
			else if(FlxG.keys.UP )
			{
				play( "walk" );
				moveToTile( tileX - 1, tileY );
			}
			else if(FlxG.keys.DOWN )
			{
				play( "walk" );
				moveToTile( tileX + 1, tileY );
			}
			else if(FlxG.keys.LEFT )
			{
				play( "walk" );
				moveToTile( tileX, tileY - 1);
			}
			else if(FlxG.keys.RIGHT )
			{
				play( "walk" );
				moveToTile( tileX, tileY + 1);
			}
			else
			{
				play( "idle" );
			}
		}
	}
}