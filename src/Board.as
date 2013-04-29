package    
{
	
	import org.flixel.FlxG;
	
	public class Board {
		
		// Tiles
		public var tileMatrix:Array; 
		public var fireArray:Array;
		public var enemyArray:Array;
		public var collectArray:Array;
		
		public const BOARD_TILE_WIDTH:uint = 24;
		public const BOARD_TILE_HEIGHT:uint = 24;
		public const MAX_COLLECTS:uint = 4;
		public const LOOKUP_BORDER:uint = 20;
		
		public var heightInTiles:int;
		public var widthInTiles:int;
		
		public var time:Number = 0.0;
		private var _player:Player = null;

		[Embed(source='../data/Tilemaps/MapCSV_Moonshine_Ground.txt',mimeType="application/octet-stream")] private var TxtMap:Class;
		[Embed(source='../data/Tilemaps/MapCSV_Moonshine_Spawns.txt',mimeType="application/octet-stream")] private var TxtSpawns:Class;
		
		public function Board()
		{
			loadMap( new TxtMap );
		}
		
		public function update():void
		{
			// Reset all tiles
			resetTiles();
			
			time += FlxG.elapsed;
			
			for( var i:int = 0; i < fireArray.length; i++)
			{
				var fire:Fire = fireArray[i];
				if( fire.tileX < _player.tileX + LOOKUP_BORDER && fire.tileX > _player.tileX - LOOKUP_BORDER )
				{
					if( fire.tileY < _player.tileY + LOOKUP_BORDER && fire.tileY > _player.tileY - LOOKUP_BORDER )
					{
						if( fire.explode )
						{
							lightTile( fire.tileX, fire.tileY, 2, false );
						}
					}
				}
			}
			
			// Lamp lighting
			for( var x:int = _player.tileX - LOOKUP_BORDER; x < _player.tileX + LOOKUP_BORDER; x++ )
			{
				for( var y:int = _player.tileY - LOOKUP_BORDER; y < _player.tileY + LOOKUP_BORDER; y++ )
				{
					if( validTile (x,y) )
					{
						var tile:TileBackground = this.tileMatrix[x][y];
						if( tile.type == 4 )
						{
							lightTile( x, y, 4, false );
							
							if( Math.abs(_player.tileX - x) <= 3 )
							{
								if( Math.abs(_player.tileY - y) <= 3 )
								{
									if( x < _player.farthestLightPosX )
									{
										_player.playNextVO( x );
									}
									
									switch( Math.floor( FlxG.random() * 3 ) )
									{
										case 0:
										{
											_player.lastLightPostX = x - 1;
											_player.lastLightPostY = y + 1;
											break;
										}
											
										case 1:
										{
											_player.lastLightPostX = x + 1;
											_player.lastLightPostY = y - 1;
											break;
										}
										case 2:
										{
											_player.lastLightPostX = x + 1;
											_player.lastLightPostY = y + 1;
											break;
										}
									}
								}
							}
						}
					}
				}
			}
			
			// Lighting
			if( _player != null )
			{
				_player.updateLight();
				lightTile( _player.tileX, _player.tileY, _player.light, _player.kicking );
			}
			
		}
		
		public function setPlayer( player:Player ):void
		{
			_player = player;
		}
		
		public function createPlayer():Player
		{
			var mapData:String = new TxtSpawns;
			var player:Player;
			
			//Figure out the map dimensions based on the data string
			var columns:Array;
			var rows:Array = mapData.split("\n");
			var column:uint;
			
			var emptyTile:TileBackground = new TileBackground( 0, 0, 0, 0, 0, this);
			
			for( var x:int = 0; x < rows.length - 1; x++)
			{
				columns = rows[x].split(",");
				for( var y:int = 0; y < columns.length; y++)
				{
					if( columns[y] == 5)
					{
						player = new Player(x,y,this);
						PlayState.groupBoardSort.add(player);
					}
					
				}
			}
			
			return player;
		}
		
		public function createSpawns( player:Player ):void
		{
			var mapData:String = new TxtSpawns;
			enemyArray = new Array();
			fireArray = new Array();
			collectArray = new Array();
			
			//Figure out the map dimensions based on the data string
			var columns:Array;
			var rows:Array = mapData.split("\n");
			var column:uint;
			
			var emptyTile:TileBackground = new TileBackground( 0, 0, 0, 0, 0, this);
			
			for( var x:int = 0; x < rows.length - 1; x++)
			{
				columns = rows[x].split(",");
				for( var y:int = 0; y < columns.length; y++)
				{
					if( columns[y] == 3 )
					{
						var enemy:Enemy = new Enemy(x,y,this,player);
						PlayState.groupBoardSort.add(enemy);
						enemyArray.push( enemy );
					}
					else if( columns[y] == 6 )
					{
						var collect:Collect = new Collect(x,y,this,player);
						PlayState.groupBoardSort.add(collect);
						collectArray.push( collect );
					}
					else if( columns[y] == 7 || columns[y] == 8 || columns[y] == 9 || columns[y] == 10 || columns[y] == 11 )
					{
						var fire:Fire = new Fire(x,y, this, player, ( ( columns[y] - 6 ) / 5 ) * 0.75 );
						PlayState.groupBoardSort.add(fire);
						fireArray.push( fire );
					}

				}
			}
		}
		
		public function loadMap( MapData:String ):void
		{
			//Figure out the map dimensions based on the data string
			var columns:Array;
			var rows:Array = MapData.split("\n");
			heightInTiles = rows.length;
			var column:uint;

			var offsetX:int = -16;
			var offsetY:int = 8;
			var isometrixOffsetY:int = 16;
			var isometrixOffsetX:int = 8;
			
			var startX:int = FlxG.width/2 - offsetX;
			var startY:int = FlxG.height/6;		
			var type:int = 0;
			tileMatrix = new Array();

			var emptyTile:TileBackground = new TileBackground( 0, 0, 0, 0, 0, this);
			
			for( var x:int = 0; x < heightInTiles - 1; x++)
			{
				columns = rows[x].split(",");
				widthInTiles = columns.length;

				var row:Array = new Array();
				for( var y:int = 0; y < widthInTiles; y++)
				{
					type = columns[y];
					if( type > 0 )
					{
						var tile:TileBackground = new TileBackground( columns[y], startX + x*offsetX + y*isometrixOffsetY,  startY + y*offsetY + x*isometrixOffsetX, x, y, this);					
						
						if( columns[y] == 1 )
						{
							PlayState.groupBoard.add(tile);
						}
						else
						{
							PlayState.groupBoardSort.add(tile);
						}
						row.push(tile);
					}
					else
					{
						row.push(emptyTile);
					}
				}
				
				tileMatrix.push(row);
			}
		}
		
		public function resetTiles():void
		{
			for( var x:int = _player.tileX - LOOKUP_BORDER; x < _player.tileX + LOOKUP_BORDER; x++ )
			{
				for( var y:int = _player.tileY - LOOKUP_BORDER; y < _player.tileY + LOOKUP_BORDER; y++ )
				{
					if( validTile (x,y) )
					{
						var tile:TileBackground = this.tileMatrix[x][y];
						tile.alpha = 0.0;
						tile.visible = false;
					}
				}	
			}
		}
		
		
		public function validTile( x:int, y:int ):Boolean
		{
			if( x >= 0 && x < this.tileMatrix.length )
			{
				if( y >= 0 && y < this.tileMatrix[x].length )
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
		
		public function lightTile( origX:int, origY:int, lightAmount:int, kicking:Boolean ): void 
		{
			var maxDistance:int = lightAmount;
			var checkDistance:int = maxDistance;
			if( kicking )
			{
				maxDistance = 9;
				checkDistance = 9;
			}
			var oscAmount:Number = 3.0;
			var origTile:TileBackground = this.tileMatrix[origX][origY];
			
			for( var x:int = origX - checkDistance; x < origX + checkDistance; x++ )
			{
				for( var y:int = origY - checkDistance; y < origY + checkDistance; y++ )
				{
					if( validTile( x, y ) )
					{
						
						var distance:Number = distanceTwoPoints( origX, x, origY, y );
						if( distance < maxDistance )
						{
							var tile:TileBackground = this.tileMatrix[x][y];
							var osc:Number = (1 + Math.sin( time * oscAmount ) );										
							var alpha:Number = ( 1 - Math.abs( distance / ( maxDistance + osc ) ) );
							var newAlpha:Number = Math.pow(alpha, 3);
							tile.visible = true;
							
							if( newAlpha > tile.alpha )
							{
								tile.alpha = newAlpha;
							}
						}
					}
				}	
			}
		}
	}
	
}
