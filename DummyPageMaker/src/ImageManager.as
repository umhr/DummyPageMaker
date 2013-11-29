package  
{
	import by.blooddy.crypto.image.PNGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author umhr
	 */
	public class ImageManager extends Sprite
	{
		private static var _instance:ImageManager;
		public function ImageManager(block:Block){init();};
		public static function getInstance():ImageManager{
			if ( _instance == null ) {_instance = new ImageManager(new Block());};
			return _instance;
		}
		
		public var byteArrayList:Array/*ByteArray*/ = [];// new ByteArray();
		public var bitmapDataList:Array/*BitmapData*/ = [];
		private var _count:int;
		private var _width:int;
		private var _height:int;
		private var _rgb:int;
		private var _format:String;
		static public const FORMAT_JPG:String = "jpg";
		static public const FORMAT_PNG:String = "png";
		
		
		private function init():void
		{
		}
		
		public function getBitmap(count:int, format:String, width:int, height:int, rgb:int = -1):Bitmap {
			var text:String = width + " x " + height;
			var bitmapData:BitmapData = ImageGenerator.getInstance().getImage(count, width, height, text, rgb);
			return new Bitmap(bitmapData, "auto", true);
		}
		
		
		
		public function start(count:int, format:String, width:int, height:int, rgb:int = -1):void {
			byteArrayList = [];
			_count = count;
			_format = format;
			_width = width;
			_height = height;
			_rgb = rgb;
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			trace("ImageManager.enterFrame", _count);
			if (_count > 0) {
				gene();
				dispatchEvent(new Event("progress"));
			}else {
				comp();
			}
		}
		public function gene():void {
			var a:int = 1 + (50000000 / (_width * _height));
			var n:int = Math.min(20, _count, a);
			for (var i:int = 0; i < n; i++) 
			{
				var index:int = byteArrayList.length;
				var text:String = _width + " x " + _height;
				var bitmapData:BitmapData = ImageGenerator.getInstance().getImage(index, _width, _height, text, _rgb);
				var byteArray:ByteArray = new ByteArray();
				if (_format == FORMAT_JPG) {
					byteArray = bitmapData.encode(bitmapData.rect, new flash.display.JPEGEncoderOptions(90));
				}else {
					byteArray = by.blooddy.crypto.image.PNGEncoder.encode(bitmapData);
				}
				byteArrayList.push(byteArray);
				bitmapData = null;
			}
			
			_count -= n;
		}
		
		private function comp():void 
		{
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get format():String 
		{
			return _format;
		}
		
		public function get count():int 
		{
			return _count;
		}
		
	}
	
}
class Block { };