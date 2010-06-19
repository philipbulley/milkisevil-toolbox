/**
* ...
* @author Philip Bulley <philip@milkisevil.com>
* @version 3.1.1
* 
* 
* History ****************************
* 
* v3.1.1
* Added setGroupTabIndex
* 
* v3.1
* No longer defining child here as this should be typed in subclass
* createRectangle now has bgColor as optional
* 
* 
* v3.0
* Ported from AS2 version to AS3
* 
* 
*/

package com.milkisevil.ui
{
	import com.greensock.TweenMax;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class BaseUI extends MovieClip 
	{
		
		private var defaultX:Number;
		private var defaultY:Number;
		private var initPosition:Boolean;
		private var isListenForResizeActive:Boolean = false;
		
		
		public function BaseUI()
		{
			
			this.addEventListener( Event.ADDED_TO_STAGE, this.addedToStage );
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.removedFromStage );
			
		}
		
		
		protected function addedToStage( event:Event ):void
		{
			// to be overriden by extending class
			
			stage.focus = stage;					// This is mainly for keyboard events
		}
		
		protected function removedFromStage( event:Event ):void
		{
			// to be overriden by extending class
			if( this.isListenForResizeActive ) this.listenForResize( false );
			
			stage.focus = stage;					// This is mainly for keyboard events
		}
		
		
		public function listenForResize(listen:Boolean = true, stage:Stage = null):void
		{
			//trace('exec BaseUI.listenForResize: '+this+', listen: ' + listen);
			if(!stage) stage = this.stage;
			if (listen)
			{
				stage.addEventListener(Event.RESIZE, this.resize);
				this.isListenForResizeActive = true;
			}
			else
			{
				stage.removeEventListener(Event.RESIZE, this.resize);
				this.isListenForResizeActive = false;
			}
			
		}
		
		public function resize(event:Event = null):void
		{
			
			// To be overriden by classes which extend BaseUI
			
			/*
			// Shortucts
			var w:int = stage.stageWidth;		// Width
			var h:int = stage.stageHeight;		// Height
			var cx:int = w * .5;				// Center X position
			var cy:int = h * .5;				// Center Y position
			*/
		}
		
		
		/**
		* Create a formatted TextField
		* 
		* @param	font					The name of the font
		* @param	size					The font size
		* @param	colour					The hex colour value (ie. 0xff00ff)
		* @param	width					Width of the resulting TextField (use null for default)
		* @param	height					Height of the resulting TextField (use null for default)
		* @param	overrideTextFieldAttributes		Object containing TextField attributes. These attributes will override the default.
		* @param	overrideTextFormatAttributes	Object containing TextFormat attributes. These attributes will override the default.
		* @return	TextField				A reference to the TextField created
		*/
		public function createText(font:Font = null, size:Number = 11, color:Number = 0xff0000, width:Number = 50, height:Number = 50, overrideTextFieldAttributes:Object = null, overrideTextFormatAttributes:Object = null):TextField
		{
			
			var tf:TextField = new TextField();
			var	fmt:TextFormat = new TextFormat();
			
			if(font) fmt.font = font.fontName;
			fmt.align = TextFormatAlign.LEFT;
			fmt.color = color;
			fmt.size = size;
			
			tf.embedFonts = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			tf.border = false;
			
			if(overrideTextFieldAttributes){
				for(var tfAttribute:String in overrideTextFieldAttributes){
					tf[tfAttribute] = overrideTextFieldAttributes[tfAttribute];
				}
			}
			
			if(overrideTextFormatAttributes){
				for(var fmtAttribute:String in overrideTextFormatAttributes){
					fmt[fmtAttribute] = overrideTextFormatAttributes[fmtAttribute];
				}
			}
			
			tf.defaultTextFormat = fmt;
			
			
			return tf;
			
		}
		
		
		/**
		 * Set the tabIndex of a group of InteractiveObjects based on their 
		 * order in the supplied array
		 */
		protected function setGroupTabIndex(tabIndexOrder:Array):void
		{
			for(var i:int = 0; i<tabIndexOrder.length; i++)
			{
				tabIndexOrder[i].tabIndex = i;
			}
		}
		
		
		/**
		* Moves clip to a specific position
		* @param	x	x position of the footer
		* @param	y	y position of the footer
		*/
		public function setPosition( point:Point ):void
		{
			if (!isNaN(point.x)) this.x = point.x;
			if (!isNaN(point.y)) this.y = point.y;
			
			if ( !this.initPosition )
			{
				this.defaultX = this.x;
				this.defaultY = this.y;
				this.initPosition = true;
			}
		}
		
		/**
		 * Get's the x and y position currently at the
		 * centre of this DisplayObject
		 */
		public function getCenterPosition():Point
		{
			return new Point( x + (width*.5), y + (height*.5) );
		}
		
		
		public function createRectangle(x:Number, y:Number, w:Number, h:Number, bgColor:Number = NaN, borderColor:Number = NaN, borderSize:Number = 1):Shape
		{
			var bgColorAlpha:Number = 1;
			if( isNaN(bgColor) ) bgColorAlpha = 0;
			
			var shape:Shape = new Shape();
            shape.graphics.beginFill(bgColor, bgColorAlpha);
            if(!isNaN(borderColor)) shape.graphics.lineStyle(borderSize, borderColor);
            shape.graphics.drawRect(x, y, w, h);
            shape.graphics.endFill();
			
			return shape;
			
		}
		
		
		public function createHitArea(w:Number = 50, h:Number = 50, x:Number = 0, y:Number = 0):Sprite
		{
			var hitArea:Sprite = new Sprite();
			var shape:Shape = this.createRectangle(x, y, w, h, 0x3399ff);
			hitArea.addChild(shape);
			hitArea.alpha = 0;
			
			return hitArea;
			
		}
		
		
		
		public function createLine(sprite:Sprite, length:Number = 50, color:Number = 0xff0000, thickness:Number = 1):Sprite
		{
			
			sprite.graphics.lineStyle(thickness, color, 1);
			sprite.graphics.lineTo(length, 0);
			
			return sprite;
			
		}
		
		
		//duration:Number = 1, delay:Number = 0
		public function show(tweenParams:Object = null):void
		{
			if (tweenParams == null) tweenParams = { };
			if (tweenParams.alpha == undefined) tweenParams.alpha = 1;
			if (tweenParams.duration == undefined) tweenParams.duration = 1;
			
			this.goVisible();
			
			// Remove duration from tweenParams
			var duration:Number = tweenParams.duration;
			delete tweenParams.duration;
			
			// Do the tween
			TweenMax.killTweensOf( this );
			TweenMax.killDelayedCallsTo( this );
			TweenMax.to( this, duration, tweenParams );			
		}
		
		public function hide(tweenParams:Object = null):void
		{
			//trace('BaseUI.hide: this.child: ' + this.child);
			
			if (tweenParams == null) tweenParams = { };
			if (tweenParams.alpha == undefined) tweenParams.alpha = 0;
			if (tweenParams.duration == undefined) tweenParams.duration = 1;
			
			// Use a timer to call a method onComplete of this Tween, so as not to overwrite the tweenParams.onComplete
			//var timer:Timer = new Timer( tweenParams.duration * 1000, 1);
			//timer.add
			
			// Remove duration from tweenParams
			var duration:Number = tweenParams.duration;
			delete tweenParams.duration;
			
			if (tweenParams.alpha == 0)
			{
				tweenParams.autoAlpha = tweenParams.alpha;
				delete tweenParams.alpha;
			}
			
			// Do the tween
			TweenMax.killTweensOf( this );
			TweenMax.killDelayedCallsTo( this );
			TweenMax.to( this, duration, tweenParams );			
		}
		
		private function hideComplete(event:TimerEvent):void
		{
			this.goInvisible();
		}
		
		
		public function goVisible(displayObject:DisplayObject = null):void
		{
			if (!displayObject) displayObject = this;
			displayObject.visible = true;
			
			//trace('BaseUI.goVisible: ' + displayObject);
		}
		
		public function goInvisible(displayObject:DisplayObject = null):void
		{
			
			if (!displayObject) displayObject = this;
			displayObject.visible = false;
			
			//trace('BaseUI.goInvisible: ' + displayObject);
			
		}
		
		public function removeFromParent(displayObject:DisplayObject = null):void
		{
			if (!displayObject) displayObject = this;
			if (displayObject.parent && displayObject.parent.contains( displayObject )) displayObject.parent.removeChild( displayObject );
		}
		
		public function removeFilters(displayObject:DisplayObject = null):void
		{
			if (!displayObject) displayObject = this;
			displayObject.filters = null;
		}
		
		
		public function stripHTML(htmlText:String):String
		{
			
			var t:TextField = new TextField();
			t.htmlText = htmlText;
			
			return t.text;			
			
		}
		
		
		/**
		 * Short-cut method for stage width
		 * NOTE: Ensure DisplayObject has been added to the DisplayList before calling
		 */
		protected function get sw():Number
		{
			return (stage) ? stage.stageWidth : NaN;
		}
		
		/**
		 * Short-cut method for stage height
		 * NOTE: Ensure DisplayObject has been added to the DisplayList before calling
		 */
		protected function get sh():Number
		{
			return (stage) ? stage.stageHeight : NaN;
		}
		
		/**
		 * Short-cut method for x position at the center of the stage (stage center x)
		 * NOTE: Ensure DisplayObject has been added to the DisplayList before calling
		 */
		protected function get scx():Number
		{
			return (stage) ? stage.stageWidth * .5 : NaN;
		}
		
		/**
		 * Short-cut method for y position at the center of the stage (stage center y)
		 * NOTE: Ensure DisplayObject has been added to the DisplayList before calling
		 */
		protected function get scy():Number
		{
			return (stage) ? stage.stageHeight * .5 : NaN;
		}
		
		
		
		
		
		public function traceObject(theArray:Object, spacing:* = null):void
		{
			if (spacing == null || spacing.length == 0){
				trace("Object{");
				spacing = "";
			} 
			for (var oneChoice:* in theArray){
				var theType:* = typeof(theArray[oneChoice]);
				if (theType != "object"){
					trace(spacing+"     [\""+oneChoice+"\"]=>\""+theArray[oneChoice]+"\"");
				}else{
					trace(spacing+"     [\""+oneChoice+"\"]=>{Array");
					var andSpacing:String = "   ";
					traceObject(theArray[oneChoice],spacing+andSpacing);
				}
			}
			trace(spacing+"  }");
		}
		
		

		
		/**
		 * Recursively traces the children of the DisplayObjectContainer supplied
		 * 
		 * @param	container
		 * @param	indentString
		 */
		public function traceDisplayList(container:DisplayObjectContainer, indentString:String = ""):void
		{
			var child:DisplayObject;
			for (var i:uint=0; i < container.numChildren; i++)
			{
				child = container.getChildAt(i);
				trace(indentString, child, child.name);
				if (container.getChildAt(i) is DisplayObjectContainer)
				{
					traceDisplayList(DisplayObjectContainer(child), indentString + "    ")
				}
			}
		}

		
		
		public function tracePath(obj:DisplayObject, path:String = ''):void
		{
			var path:String = obj.name + '.' + path;
			if (!obj.parent) 
			{
				trace(path);
			} 
			else 
			{
				this.tracePath(obj.parent, path);
			}			
		}
		
		
		
		
		
		
	}
	
}
