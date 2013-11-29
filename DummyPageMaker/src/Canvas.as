package  
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends Sprite 
	{
		private var _uiStage:Sprite = new Sprite();
		private var _previewStage:Sprite = new Sprite();
		private var _bitmapDataList:Array/*BitmapData*/ = [];
		private var _counter:NumericStepper;
		private var _sizeWidth:NumericStepper;
		private var _sizeHeight:NumericStepper;
		private var _comboBox:ComboBox;
		private var _formatJPG:RadioButton;
		private var _currenPreviewParam:String;
		private var _ichimatsu:Ichimatsu;
		private var _colorChooser:ColorChooser;
		private var _checkBox:CheckBox;
		private var _timeCount:int = -10;
		public function Canvas() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			_ichimatsu = new Ichimatsu(0, 0);
			addChild(_ichimatsu);
			addChild(_previewStage);
			setUI();
			
			stage.addEventListener(Event.RESIZE, stage_resize);
			
			setPreview();
			reSize();
		}
		
		private function stage_resize(e:Event):void 
		{
			onCounterReset(null);
		}
		
		private function reSize():void 
		{
			if (_ichimatsu.width == stage.stageWidth && _ichimatsu.height == stage.stageHeight) {
				return;
			}
			
			if (_previewStage.numChildren > 0) {
				_previewStage.x = int((stage.stageWidth - _previewStage.getChildAt(0).width) * 0.5);
				_previewStage.y = int((stage.stageHeight - 70 - _previewStage.getChildAt(0).height) * 0.5);
			}
			
			_uiStage.x = int((stage.stageWidth - _uiStage.width) * 0.5);
			_uiStage.y = stage.stageHeight - 64;
			_ichimatsu.drawIchimatsu(stage.stageWidth, stage.stageHeight);
		}
		
		private function setPreview():void 
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			_timeCount++;
			if (_timeCount == 0) {
				onPreview();
				//trace("cap!");
				reSize();
			}
			
		}
		
		private function onPreview():void 
		{
			var width:int = _sizeWidth.value;
			var height:int = _sizeHeight.value;
			var count:int = _counter.value;
			var format:String = _formatJPG.selected?"jpg":"png";
			var rgb:int = _colorChooser.enabled?_colorChooser.value: -1;
			
			var previewParam:String = "" + width + "," + height + "," + rgb;
			
			if (isNaN(width) || isNaN(height) || isNaN(count) || isNaN(rgb)) {
				return;
			}
			if (width == 0 || height == 0 || count == 0) {
				return;
			}
			
			if (_currenPreviewParam == previewParam) {
				return;
			}
			_currenPreviewParam = previewParam;
			
			while (_previewStage.numChildren > 0) {
				_previewStage.removeChildAt(0);
			}
			
			var bitmap:Bitmap = ImageManager.getInstance().getBitmap(count, format, width, height, rgb);
			_previewStage.x = int((stage.stageWidth - bitmap.width) * 0.5);
			_previewStage.y = int((stage.stageHeight - 70 - bitmap.height) * 0.5);
			_previewStage.addChild(bitmap);
		}
		
		private function setUI():void {
			
			_uiStage.graphics.beginFill(0x333333, 1);
			_uiStage.graphics.drawRoundRect(0, 0, 570, 60, 8, 8);
			_uiStage.graphics.endFill();
			addChild(_uiStage);
			
			_formatJPG = new RadioButton(_uiStage, 16, 22, "jpg", true);
			var formatPNG:RadioButton = new RadioButton(_uiStage, 16, 38, "png", false);
			_formatJPG.groupName = formatPNG.groupName = "format";
			
			_sizeWidth = new NumericStepper(_uiStage, 70, 32, onCounterReset);
			_sizeWidth.value = 480;
			_sizeWidth.width = 70;
			_sizeHeight = new NumericStepper(_uiStage, 160, 32, onCounterReset);
			_sizeHeight.value = 320;
			_sizeHeight.width = 70;
			_counter = new NumericStepper(_uiStage, 335, 32);
			_counter.value = 100;
			_counter.width = 70;
			new Label(_uiStage, _formatJPG.x, 2, "Format");
			new Label(_uiStage, _sizeWidth.x, 14, "width");
			new Label(_uiStage, _sizeHeight.x, 14, "height");
			new Label(_uiStage, _counter.x, 14, "number");
			
			_checkBox = new CheckBox(_uiStage, 250, 18, "RnadomColor", onCheckBox);
			_checkBox.selected = true;
			_colorChooser = new ColorChooser(_uiStage, 250, 32, 0xFF9900, onCounterReset);
			_colorChooser.value = 0x787878;
			_colorChooser.enabled = false;
			
			new PushButton(_uiStage, 440, 20, "Generate", onGenerat);
		}
		
		private function onCounterReset(e:Event):void 
		{
			_timeCount = -60;
			//trace("reest!");
		}
		
		private function onCheckBox(e:MouseEvent):void 
		{
			_colorChooser.enabled = !_checkBox.selected;
			onCounterReset(null);
		}
		
		private function onGenerat(e:MouseEvent):void {
			setSheeld();
			
			var rgb:int = _colorChooser.enabled?_colorChooser.value: -1;
			var format:String = _formatJPG.selected?"jpg":"png";
			
			ImageManager.getInstance().addEventListener(Event.COMPLETE, complete);
			ImageManager.getInstance().addEventListener("progress", onProgress);
			ImageManager.getInstance().start(_counter.value, format, _sizeWidth.value, _sizeHeight.value, rgb);
		}
		
		private var _sheeld:Sprite = new Sprite();
		private var _sheeldLabel:Label;
		private var _saveBtn:PushButton;
		private function setSheeld():void 
		{
			_sheeld.graphics.clear();
			_sheeld.graphics.beginFill(0xFFFFFF, 0.7);
			_sheeld.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_sheeld.graphics.endFill();
			addChild(_sheeld);
			if(!_sheeldLabel){
				_sheeldLabel = new Label(_sheeld, 0, 0, "Progress: 0 / " + _counter.value);
				_saveBtn = new PushButton(_sheeld, 0, 0, "Save", onSave);
			}
			_sheeldLabel.x = int((stage.stageWidth - _sheeldLabel.width) * 0.5);
			_sheeldLabel.y = int((stage.stageHeight - _sheeldLabel.height) * 0.5);
			_saveBtn.x = int((stage.stageWidth - _saveBtn.width) * 0.5);
			_saveBtn.y = _sheeldLabel.y + 25;
			_saveBtn.enabled = false;
		}
		
		private function onProgress(e:Event):void 
		{
			var text:String = "Progress: " + (_counter.value-ImageManager.getInstance().count) + " / " + _counter.value;
			_sheeldLabel.text = "";
			_sheeldLabel.text = text;
		}
		
		private function complete(e:Event):void 
		{
			ImageManager.getInstance().removeEventListener("progress", onProgress);
			ImageManager.getInstance().removeEventListener(Event.COMPLETE, complete);
			
			_saveBtn.enabled = true;
			//atClick();
			
			//removeChild(_sheeld);
		}
		
		private function onSave(e:Event):void 
		{
            //zip化
            var zipOut:ZipOutput = new ZipOutput();
            
			var byteArrayList:Array/*ByteArray*/ = ImageManager.getInstance().byteArrayList;
			
			var extention:String = ImageManager.getInstance().format;
			
			var n:int = byteArrayList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var fileData:ByteArray = byteArrayList[i];
				zipOut.putNextEntry(new ZipEntry("image" + i + "." + extention));
				zipOut.write(fileData);
				zipOut.closeEntry();
			}
			
            zipOut.finish();
            
            //ファイルリファレンスで保存
            var fr:FileReference = new FileReference();
            fr.save(zipOut.byteArray, extention + _sizeWidth.value + "x" + _sizeHeight.value + "x" + n + ".zip");
            //function onComplete(e:Event):void {
                //trace(fr.name);
            //}
			removeChild(_sheeld);
            
        }
	}
	
}