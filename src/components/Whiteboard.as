package components
{
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class Whiteboard extends Canvas
	{
		
		private var _strokeSize:int=2;
		private var _strokeColor:uint=0x0000ff;
		private var _strokeAlpha:Number=1.0;
		
		private var cx:int;
		private var cy:int;
		public var layer:UIComponent=new UIComponent();
		/**
		 * 全部线对象 
		 */		
		private var lines:Array=new Array();
		/**
		 * 撤销的线对象 
		 */		
		private var undoLines:Array=new Array();
		 
		//当前对象
		private var cline:FreeLine;
		public function Whiteboard()
		{
			layer.width=this.width;
			layer.height=this.height;
			this.addChild(layer);
			setLineStyle();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,function():void{drawRefline()});
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown_handler);
			this.addEventListener(MouseEvent.MOUSE_UP,mouseUp_handler);
		}
		/**
		 * 笔画颜色 
		 * @return 
		 * 
		 */	
		[Bindable]	
		public function get strokeColor():uint{
			return _strokeColor;
		}
		public function set strokeColor(va:uint):void{
			 _strokeColor=va;
			 setLineStyle();
		}
		/**
		 * 笔画宽度 
		 * @return 
		 * 
		 */		
		[Bindable]	
		public function get strokeSize():int{
			return _strokeSize;
		}
		public function set strokeSize(va:int):void{
			 _strokeSize=va;
			 setLineStyle();
		}
		/**
		 * 笔画透明度 
		 * @return 
		 * 
		 */		
		[Bindable]	
		public function get strokeAlpha():Number{
			return _strokeAlpha;
		}
		public function set strokeAlpha(va:Number):void{
			 _strokeAlpha=va;
			 setLineStyle();
		}
		
		/**
		 * 设置线属性 
		 */		 
		private function setLineStyle():void{
			layer.graphics.endFill();
			layer.graphics.lineStyle(_strokeSize,_strokeColor,_strokeAlpha,true,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND,3);
			layer.graphics.beginFill(_strokeColor);
		}
		/*---------------------------------------
		 * 参考线 Start
		 *多种类型的参考背景，照顾有点密集恐惧症的朋友 >_<
		 * --------------------------------------
		 */		
		/**
		 * 绘制背景参考线 
		 * @param style
		 * <li> gird
		 * <li> line
		 * <li> point
		 */		
		public function drawRefline(style:String="point"):void{
			var mat:Matrix=new Matrix();
			var bgImage:BitmapData;
			switch(style){
				case "point":{
					bgImage=bgImagePoint;
				}break;
				case "line":{
					bgImage=bgImageLine;
				}break;
				case "grid":{
					bgImage=bgImageGrid;
				}break;
			}
			graphics.clear();
			//背景网格
			graphics.beginBitmapFill(bgImage,mat,true);
			graphics.drawRect(0,0,this.width,this.height);
			graphics.endFill();
			// 米字格
			graphics.lineStyle(1,0xbbbbbb,1,true,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND,3);
			graphics.beginFill(_strokeColor);
			
			graphics.moveTo(0,0);
			graphics.lineTo(this.width,this.height);
			
			graphics.moveTo(this.width,0);
			graphics.lineTo(0,this.height);
			
			graphics.moveTo(this.width/2,0);
			graphics.lineTo(this.width/2,this.height);
			
			graphics.moveTo(0,this.height/2);
			graphics.lineTo(this.width,this.height/2);
	
			graphics.endFill(); 
			trace("reflines");
		}
		/**
		 * 网格背景 
		 * @return 
		 * 
		 */		
		private function  get bgImageGrid():BitmapData{
			var bgimg:BitmapData=new BitmapData(20,20,false,0xffffff);
			var i:int=9;
			var j:int=9;
			while (i>-1){
				while (j>-1){
					bgimg.setPixel(i,j--,0xdddddd);
					trace(i+"-"+j);
				} 
				j=9;
				i--;
			}
			i=19;
			j=19;
			while (i>9){
				while (j>9){
					bgimg.setPixel(i,j--,0xdddddd);
					trace(i+"-"+j);
				} 
				j=19;
				i--;
			}
			return bgimg;
		}
		/**
		 * 线条背景 
		 * @return 
		 * 
		 */		
		private function  get bgImageLine():BitmapData{
			var bgimg:BitmapData=new BitmapData(10,10,false,0xffffff);
			var i:int=10;
			while (i>-1){
				bgimg.setPixel(i--,0,0xdddddd);
			} 
			i=10;
			while (i>-1){
				bgimg.setPixel(0,i--,0xdddddd);
			} 
			
			return bgimg;
		}
		/**
		 * 点阵背景 
		 * @return 
		 * 
		 */		
		private function  get bgImagePoint():BitmapData{
			var bgimg:BitmapData=new BitmapData(10,10,false,0xffffff);
			bgimg.setPixel(5,5,0x000000);
			return bgimg;
		}
		/*----------------------------------------
		 * 参考线 End
		 * 多种类型的参考背景，照顾有点密集恐惧症的朋友 >_<
		 * ---------------------------------------
		 */	
		
		/**
		 * 清除 
		 * 
		 */		
		public function clear(removeLines:Boolean=true):void{
			this.layer.graphics.clear();
			if(removeLines){
				lines=new Array();
				undoLines=new Array();
			}
			setLineStyle();
		}
		/**
		 * 撤销 
		 * 
		 */		
		public function unDo():void{
			if(lines.length<1)return;
			clear(false);
			var l:FreeLine= lines.pop() as FreeLine;
			undoLines.push(l);
			reDraw();
		}
		/**
		 * 重做 
		 * 
		 */		
		public function reDo():void{
			if(undoLines.length<1)return;
			clear(false);
			var l:FreeLine= undoLines.pop() as FreeLine;
			lines.push(l);
			reDraw();
		}
		/**
		 * 输出 
		 * 
		 */		
		public function output():void{
			Alert.show(lines.toString());
		}
		
		public function reDraw():void{
			var len:int=lines.length;
			while(len--){
				FreeLine(lines[len]).reDraw();
			}
		}
		
		private function mouseDown_handler(event:MouseEvent):void{
			
			cline=new FreeLine(layer.graphics);
			cline.color=strokeColor;
			cline.alpha=strokeAlpha;
			cline.size=strokeSize;
			//按shift 单击绘制直线
			if(event.shiftKey){
				if(cx*cy!=0){
					cline.push(new Point(cx,cy));
				}
				cx=event.localX;
				cy=event.localY;
				cline.push(new Point(cx,cy));
				this.addEventListener(MouseEvent.MOUSE_UP,mouseUp_handler);
				return;
			}
			cx=event.localX;
			cy=event.localY;
			undoLines=new Array();
			
			this.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove_handler);
			this.addEventListener(MouseEvent.ROLL_OUT,mouseOut_handler);
			trace("mouse down");
		}
		private function mouseMove_handler(event:MouseEvent):void{
			cx=event.localX;
			cy=event.localY;
			cline.push(new Point(cx,cy));
		}
		private function mouseUp_handler(event:MouseEvent):void{
			layer.graphics.endFill();
			if(cline&&cline.points.length>1){
				lines.push(cline);
			}
			this.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove_handler);
			this.removeEventListener(MouseEvent.ROLL_OUT,mouseOut_handler);
			trace("mouse up");
		}
		private function mouseOut_handler(event:MouseEvent):void{
			mouseUp_handler(event);
			trace("roll out");
		}
		
	}
}