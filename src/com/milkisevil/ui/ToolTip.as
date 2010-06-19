package com.milkisevil.ui 
{
	import com.milkisevil.ui.BaseUI;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Philip Bulley <philip@milkisevil.com>
	 * @version	3.1
	 * 
	 * 
	 * HISTORY ****************
	 * 
	 * 
	 * v3.1
	 * Added ToolTip.addTextField and ToolTip.setTextFormat
	 * 
	 * v3.0
	 * Converted from AS2 to AS3
	 * 
	 * 
	 * 
	 */
	public class ToolTip extends BaseUI
	{
		
		public static const VERTICAL_POSITION_ABOVE:String = 'ToolTip.VERTICAL_POSITION_ABOVE';
		public static const VERTICAL_POSITION_BELOW:String = 'ToolTip.VERTICAL_POSITION_BELOW';
		public static const HORIZONTAL_POSITION_LEFT:String = 'ToolTip.HORIZONTAL_POSITION_LEFT';
		public static const HORIZONTAL_POSITION_RIGHT:String = 'ToolTip.HORIZONTAL_POSITION_RIGHT';
		
		public static var instance:ToolTip;
		
		public var defaultDelay:Number = 1;
		public var defaultWidth:Number = 200;
		public var snapToPixels:Boolean = true;
		
		public var forceVerticalPosition:String;
		public var forceHorizontalPosition:String;
		
		private var container:Sprite;
		private var fillColor:Number;
		private var borderColor:Number = Number.NaN; //= 0x4F0000;
		public var tf:TextField;
		private var background:Shape;
		private var isShowing:Boolean;
		private var textFormat:TextFormat;
		public var easeFactor:Number = 8;

		public function ToolTip( blocker:SingletonBlocker ) 
		{
			this.hide( { delay:0 } );
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public static function getInstance():ToolTip
		{
			if(!instance) instance = new ToolTip( new SingletonBlocker() );
			return instance;
		}
		
		
		/**
		 * Call when first calling the ToolTip singleton and specify the MovieClip container to hold the ToolTip
		 * 
		 * @param	container		A MovieClip container to hold the ToolTip. Ideally at a depth above all other graphics in the application
		 * @return
		 */
		public function init( container:Sprite, font:Font = null, fontSize:Number = NaN, textColor:Number = 0xffffff, fillColor:Number = 0x6b0000, borderColor:Number = NaN ):ToolTip
		{
			this.container = container;
			
			this.fillColor = fillColor;
			this.borderColor = borderColor;
			
			this.background = this.createRectangle( 0, 0, 20, 20, this.fillColor, this.borderColor, .1 );
			this.addChild( this.background );
			
			this.tf = this.createText(
				font,
				fontSize,
				textColor,
				this.defaultWidth,
				50,
				{ wordWrap:true, multiline:true/*, background:true, backgroundColor:this.fillColor*/ },
				{ leftMargin: 3, rightMargin: 3, kerning: true }
			);
			this.addChild( this.tf );

			return this;
		}
		
		
		/**
		 * Use a custom TextField. 
		 * The TextField will be added as a child to the ToolTip, removing it
		 * from any other DisplayList.
		 * 
		 * @param textField		A TextField of your choice
		 * @see	setTextFormat
		 */
		public function addTextField( textField:TextField ):void
		{
			if( tf && contains(tf) )
			{
				removeChild( tf );
			}
			
			tf = textField;
			setTextFormat( tf.getTextFormat() );
			addChild( tf );
		}
		
		
		/**
		 * Apply a custom TextFormat to the TextField.
		 * Use instead of ToolTip.tf.setTextFormat()
		 */
		public function setTextFormat( textFormat:TextFormat ):void
		{
			this.textFormat = textFormat;
			
			tf.defaultTextFormat = textFormat;
			tf.setTextFormat(textFormat);
		}

		/**
		 * Shows the ToolTip
		 * 
		 * Note: Ensure ToolTip.init has been called first, specifying a container MovieClip
		 * 
		 * @param	htmlText			Text to display - supports HTML
		 * @param	tweenParams			An object containing parameters to pass to the tweening engine
		 * @param	width				Force the width of the ToolTip
		 */
		public function showTip( htmlText:String, tweenParams:Object = null, width:Number = NaN, forceHorizontalPosition:String = null, forceVerticalPosition:String = null ):void
		{
			//trace('exec ToolTip.showTip: text: ' + htmlText );
			
			if (tweenParams == null) tweenParams = { };
			if (tweenParams.duration == undefined) tweenParams.duration = 0;
			if (tweenParams.delay == undefined) tweenParams.delay = this.defaultDelay;
			
			this.forceHorizontalPosition = forceHorizontalPosition;
			this.forceVerticalPosition = forceVerticalPosition;
			
			//trace(' - ToolTip.showTip: width: ' + width + ', tf: ' + tf );
			
			this.tf.htmlText = htmlText;
			
			if(textFormat) tf.setTextFormat( textFormat );
			
			if ( !isNaN( width ) )
			{
				this.tf.width = width;
			}
			else
			{
				this.tf.wordWrap = false;
				var noWrapWidth:Number = this.tf.width;
				//trace(' - ToolTip.showTip: noWrapWidth: '+ noWrapWidth);
				this.tf.wordWrap = true;
				
				if (noWrapWidth < this.defaultWidth)
				{
					this.tf.width = noWrapWidth + 1;
				}
				else
				{
					this.tf.width = this.defaultWidth;
				}
				
				//trace(' - ToolTip.showTip: final width: '+ this.tf.width);
			}
			this.background.width = this.tf.width;
			this.background.height = this.tf.height + 2;
			
			
			
			if( !this.container.contains( this ) ) this.container.addChild( this );
			
			// Set initial position
			var targetPoint:Point = this.getTargetPoint();
			this.x = targetPoint.x;
			this.y = targetPoint.y;
			
			this.removeEventListener( Event.ENTER_FRAME, this.loop );		// Make sure any previous event has been removed
			this.addEventListener( Event.ENTER_FRAME, this.loop );
			
			this.show( tweenParams );
			
			this.isShowing = true;
		}
		
		/**
		 * Hides an already showing ToolTip
		 * 
		 * @param	tweenParams
		 */
		public function hideTip( tweenParams:Object = null ):void 
		{
			if( !this.isShowing ) return;
			
			if (tweenParams == null) tweenParams = { };
			tweenParams.onComplete = this.hideTipComplete;
			if (tweenParams.duration == undefined) tweenParams.duration = 0;
			
			this.forceHorizontalPosition = null;
			this.forceVerticalPosition = null;
			
			this.hide( tweenParams );
			
			this.isShowing = false;
		}
		
		private function hideTipComplete():void
		{
			//trace('exec ToolTip.hideTipComplete');
			
			this.container.removeChild( this );
			this.removeEventListener( Event.ENTER_FRAME, this.loop );
		}
		
		
		private function loop( event:Event ):void
		{
			var targetPoint:Point = this.getTargetPoint();
			
			var targetX:Number = targetPoint.x;
			var targetY:Number = targetPoint.y;
			this.x += (targetX - this.x) / easeFactor;
			this.y += (targetY - this.y) / easeFactor;
		}
		
		
		/**
		 * Gets the target Point position of the tooltip.
		 * Also checks to see if the tooltip is off the edge of the stage
		 * and will adjust the returned Point accordingly
		 * 
		 * @return
		 */
		private function getTargetPoint():Point
		{
			var tx:Number;
			var ty:Number;
			
			var globalTargetPoint:Point = this.parent.localToGlobal( new Point( (this.parent.mouseX + 11) + this.width, (this.parent.mouseY + 21) + this.height ) );
			
			//tx = (globalTargetPoint.x > stage.stageWidth) ? (this.parent.mouseX - 5) - this.width : this.parent.mouseX + 11;
			//ty = (globalTargetPoint.y > stage.stageHeight) ? (this.parent.mouseY - 3) - this.height : this.parent.mouseY + 21;
			
			if ( (!this.forceHorizontalPosition && globalTargetPoint.x > stage.stageWidth) || this.forceHorizontalPosition == ToolTip.HORIZONTAL_POSITION_LEFT)
			{
				tx = (this.parent.mouseX - 5) - this.width;
			}
			else
			{
				tx = this.parent.mouseX + 11;
			}
			
			if ( (!this.forceVerticalPosition && globalTargetPoint.y > stage.stageHeight) || this.forceVerticalPosition == ToolTip.VERTICAL_POSITION_ABOVE)
			{
				ty = (this.parent.mouseY - 3) - this.height;
			}
			else
			{
				ty = this.parent.mouseY + 21;
			}
			
			
			if (snapToPixels)
			{
				tx = Math.round( tx );
				ty = Math.round( ty );
			}
			
			return new Point( tx, ty );
		}
		
	}
	
}


internal class SingletonBlocker
{
	
}
