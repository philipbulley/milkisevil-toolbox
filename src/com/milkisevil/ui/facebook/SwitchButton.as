package com.milkisevil.ui.facebook 
{
	import com.greensock.TweenMax;
	import com.milkisevil.events.StatusEventEnhanced;
	import com.milkisevil.ui.BaseUI;

	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class SwitchButton extends BaseUI 
	{
		public static const NAME:String 			= 'SwitchButton';
		public static const STATUS_EVENT:String 	= NAME + '.STATUS_EVENT';
		public static const SELECT:String 			= NAME + '.SELECT';
		
		private var child:SwitchButtonAsset;		private var _selected:Boolean;
		
		public function SwitchButton( label:String = null )
		{
			super( );
			
			child = new SwitchButtonAsset( );
			child.label.autoSize = TextFieldAutoSize.LEFT;
			if(label) this.label = label;
			
			selected = false;
			buttonMode = true;
			mouseChildren = false;
			addEventListener( MouseEvent.CLICK, click );
			
			addChild( child );
		}
		
		private function click(event:MouseEvent):void
		{
			if(!selected) selected = true;
		}

		public function get label():String
		{
			return child.label.text;
		}
		
		public function set label(text:String):void
		{
			child.label.text = text;
			
			child.background.width = child.label.x + child.label.width + child.label.x;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(selected:Boolean):void
		{
			_selected = selected;
			
			if(selected)
			{
				child.background.alpha = 1;
				TweenMax.to( child.label, 0, {tint:0xffffff} );
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, SELECT ) );
			}
			else
			{
				child.background.alpha = 0;
				TweenMax.to( child.label, 0, {tint:0x3B5998} );
			}
		}
	}
}
