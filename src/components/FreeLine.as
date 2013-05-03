package components
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	public class FreeLine
	{
		private var _pts:Array=new Array();
		private var _onComplete:Function;
		public var color:uint=0x0000ff;
		public var size:int=2;
		public var alpha:Number=1.0;
		
		private var graphics:Graphics;
		public function FreeLine(gra:Graphics)
		{
			graphics=gra;
		}
		
		public  function get onComplete():Function{
			return _onComplete;
		}
		
		public  function set onComplete(va:Function):void{
			_onComplete=va;
		}
		
	
		public function get points():Array{
			return _pts;
		}
		public function set points(pts:Array):void{
			_pts=pts;
		}
		public  function push(pt:Point):void{
			var pf:Point;
			if(points.length>0){
				pf=points[points.length-1];
				graphics.moveTo(pf.x,pf.y);
				graphics.lineTo(pt.x,pt.y);
			}
			points.push(pt);
		}
		public   function pop():Point{
			var re:Point=points.pop();
			this.reDraw();
			return re;
		}
		public  function reDraw():void{
			setLineStyle();
			if(points==null||points.length<2)return;
			var len:int=points.length;
			var ptf:Point;
			var ptt:Point;
			while (len>1){
				ptf=points[len-1];
				ptt=points[len-2];
				graphics.moveTo(ptf.x,ptf.y);
				graphics.lineTo(ptt.x,ptt.y);
				len--;
			} 
			graphics.endFill();
		}
		
		/**
		 * 设置线属性 
		 */		 
		private function setLineStyle():void{
			graphics.endFill();
			graphics.lineStyle(size,color,alpha,true,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND,3);
			graphics.beginFill(color);
		}
		/*
		 * 目前只输出点串，需要时再具体修改 
		 * @return 
		 */		
		public function toString():String{
			var re:String="[";
			var i:int=0;
			var pt:Point;
			while (i<points.length){
				pt=points[i++] as Point;
				re+="x:"+pt.x+",";
				re+="y:"+pt.y;
				if(i<points.length){
					re+=";";
				}
			}
			re=re+"]";
			return re;
		}
	}
}