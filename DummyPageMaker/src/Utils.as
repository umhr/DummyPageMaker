﻿package {	import flash.display.DisplayObjectContainer;	import flash.geom.ColorTransform;	import flash.geom.Point;	import flash.geom.Vector3D;	import flash.utils.getQualifiedClassName;	//Dump		//zSort	public class Utils {		public function Utils():void { };		/**		 * フィールドカラーに変色します.		 * 6桁16進数から、2桁ぶんずつを取り出す。 		 * 色情報は24bit。r8bit+g8bit+b8bit。24桁の二進数 		 * @param	rgb		 * @param	ratio		 * @return		 */		static public function colorFromRGB(rgb:int, ratio:Number = 1):ColorTransform {				//ratioが1以外の場合、明度変更関数へ			if(ratio != 1){rgb = rgbBrightness(rgb,ratio)};			var color:ColorTransform = new ColorTransform();			color.redMultiplier = color.blueMultiplier = color.greenMultiplier = 0;			color.redOffset = rgb >> 16;//16bit右にずらす。			color.greenOffset = rgb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。			color.blueOffset = rgb & 0xff;//下位8bitのみを取り出す。			return color;		}		/*		色の明度を相対的に変える関数。		rgb値と割合を与えて、結果を返す。		rgbは、0xffffff段階の値。		ratioが0の時に0x000000に、1の時にそのまま、2の時には0xffffffになる。		相対的に、ちょっと暗くしたい時には、ratioを0.8に、		ちょっと明るくしたい時にはratioを1.2などに設定する。		*/		static public function rgbBrightness(rgb:int,ratio:Number):int{			if(ratio < 0 || 2 < ratio){ratio = 1;trace("function colorBrightness 範囲外")}			var _r:int = rgb >> 16;//16bit右にずらす。			var _g:int = rgb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。			var _b:int = rgb & 0xff;//下位8bitのみを取り出す。			if(ratio <= 1){				_r *= ratio;				_g *= ratio;				_b *= ratio;			}else{				_r = (255 - _r)*(ratio-1)+_r;				_g = (255 - _g)*(ratio-1)+_g;				_b = (255 - _b)*(ratio-1)+_b;			}			return _r<<16 | _g<<8 | _b;		}		//shuffle		static public function shuffle(num:int):Array {			var _array:Array = new Array();			for (var i:int = 0; i < num; i++) {					_array[i] = Math.random();			}			return _array.sort(Array.RETURNINDEXEDARRAY);		}		//Dump		static public function dump(obj:Object, isTrace:Boolean = true):String {			var str:String = returnDump(obj)			if (isTrace) {				trace(str);			}			return str;		}		static public function returnDump(obj:Object):String {			var str:String = _dump(obj);			if (str.length == 0) {				str = String(obj);			}else if (getQualifiedClassName(obj) == "Array") {				str = "[\n" + str.slice( 0, -2 ) + "\n]";			}else {				str = "{\n" + str.slice( 0, -2 ) + "\n}";			}			return str;		}				static public function traceDump(obj:Object):void {			trace(returnDump(obj));		}				//zSort		static private function _dump(obj:Object, indent:int = 0):String {			var result:String = "";						var da:String = (getQualifiedClassName(obj) == "Array")?'':'"';						var tab:String = "";			for ( var i:int = 0; i < indent; ++i ) {				tab += "    ";			}						for (var key:String in obj) {				if (typeof obj[key] == "object") {					var type:String = getQualifiedClassName(obj[key]);					if (type == "Object" || type == "Array") {						result += tab + da + key + da + ":"+((type == "Array")?"[":"{");						var dump_str:String = _dump(obj[key], indent + 1);						if (dump_str.length > 0) {							result += "\n" + dump_str.slice(0, -2) + "\n";							result += tab;						}						result += (type == "Array")?"],\n":"},\n";					}else {						result += tab + '"' + key + '":<' + type + ">,\n";					}				}else if (typeof obj[key] == "function") {					result += tab + '"' + key + '":<Function>,\n';				}else {					var dd:String = (typeof obj[key] == "string")?"'":"";					result += tab + da + key + da + ":" + dd + obj[key] +dd + ",\n";				}			}						return result;		}		static public function zSort(target:DisplayObjectContainer, generation:int = 2):void {			if(generation == 0 || !target.root){return};			var n:int = target.numChildren;			var array:Array = [];			var reference:Array = [];			for (var i:int = 0; i < n; i++) {				if (target.getChildAt(i).transform.matrix3D) {					var poz:Vector3D = target.getChildAt(i).transform.getRelativeMatrix3D(target.root.stage).position;					var point:Point = target.root.stage.transform.perspectiveProjection.projectionCenter;					array[i] = poz.subtract(new Vector3D(point.x, point.y, -target.root.stage.transform.perspectiveProjection.focalLength)).length;					reference[i] = target.getChildAt(i);				}			}			var temp:Array = array.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);			for (i = 0; i < n; i++) {				if (target.getChildAt(i).transform.matrix3D) {					target.setChildIndex(reference[temp[i]],0);					if(reference[temp[i]].numChildren > 1){						zSort(reference[temp[i]], generation - 1);					}				}			}			//return;			for (i = 0; i < n; i++) {				if (target.getChildAt(i).transform.matrix3D) {					target.getChildAt(i).visible = (target.getChildAt(i).transform.getRelativeMatrix3D(target.root.stage).position.z > -400);				}			}		}	}}