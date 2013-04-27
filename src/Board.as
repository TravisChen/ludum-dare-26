package    {
	
	import flash.geom.Rectangle;
	
	import org.flixel.FlxG;
	import org.flixel.FlxTilemap;
	import org.flixel.system.FlxTile;
	
	public class Board {
		
		// Tiles
		public var tileMatrix:Array; 
		public const BOARD_TILE_WIDTH:uint = 24;
		public const BOARD_TILE_HEIGHT:uint = 24;
		public const MAX_COLLECTS:uint = 4;
		
		public var heightInTiles:int;
		public var widthInTiles:int;
		
		public var time:Number = 0.0;
		
		[Embed(source='../data/Tilemaps/MapCSV_Moonshine_Ground.txt',mimeType="application/octet-stream")] private var TxtMap:Class;
		
		public function Board()
		{
			loadMap( new TxtMap );
		}
		
		public function update():void
		{
			// Reset all tiles
			resetTiles();
			
			time += FlxG.elapsed;
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
						PlayState.groupBoard.add(tile);
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
			for( var x:int = 0; x < this.tileMatrix.length; x++ )
			{
				for( var y:int = 0; y < this.tileMatrix[x].length; y++ )
				{
					var tile:TileBackground = this.tileMatrix[x][y];
					tile.alpha = 0.0;
					tile.visible = false;
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
			var checkDistance:int = 10;
			var maxDistance:int = lightAmount;
			if( kicking )
			{
				maxDistance = maxDistance*2;
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
