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
		
		[Embed(source='../data/Tilemaps/MapCSV_Evolution_Ground.txt',mimeType="application/octet-stream")] private var TxtMap:Class;
		
		public function Board()
		{
//			createTiles();
			loadMap( new TxtMap );
		}
		
		public function update():void
		{
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

			for( var x:int = 0; x < heightInTiles - 1; x++)
			{
				columns = rows[x].split(",");
				widthInTiles = columns.length;

				var row:Array = new Array();
				for( var y:int = 0; y < widthInTiles; y++)
				{
					type = 0;				
					var tile:TileBackground = new TileBackground( columns[y], startX + x*offsetX + y*isometrixOffsetY,  startY + y*offsetY + x*isometrixOffsetX );					
					PlayState.groupBoard.add(tile);
					row.push(tile);
				}
				
				tileMatrix.push(row);
			}
		}
		
		private function createTiles():void {
			
			var offsetX:int = 16;
			var offsetY:int = 8;
			var isometrixOffsetY:int = -16;
			var isometrixOffsetX:int = 8;
			
			var startX:int = FlxG.width/2 - offsetX;
			var startY:int = FlxG.height/6;		
			var type:int = 0;
			tileMatrix = new Array();
			
			var alternate:Boolean = false;
			for( var x:int = 0; x < BOARD_TILE_WIDTH; x++)
			{
				var row:Array = new Array();
				for( var y:int = 0; y < BOARD_TILE_HEIGHT; y++ )
				{	
					type = 0;				
					var tile:TileBackground = new TileBackground( type, startX + x*offsetX + y*isometrixOffsetY,  startY + y*offsetY + x*isometrixOffsetX );					
					PlayState.groupBoard.add(tile);
					row.push(tile);
				}
				
				tileMatrix.push(row);
			}
		}
	}
	
}
