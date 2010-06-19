package com.milkisevil.ui.facebook 
{
	import com.milkisevil.events.StatusEventEnhanced;
	import com.milkisevil.ui.BaseUI;

	import flash.events.MouseEvent;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class SwitchButtonGroup extends BaseUI 
	{
		public static const NAME:String 			= 'SwitchButtonGroup';
		public static const STATUS_EVENT:String 	= NAME + '.STATUS_EVENT';
		public static const BUTTON_SELECT:String 	= NAME + '.BUTTON_SELECT';		public static const ALIGN_LEFT:String 		= 'ALIGN_LEFT';		public static const ALIGN_RIGHT:String 		= 'ALIGN_RIGHT';
		
		private var buttons:Array = [];
		private var padding:Number;
		private var _align:String;

		public function SwitchButtonGroup( padding:Number = 10, align:String = ALIGN_LEFT )
		{
			super( );
			this.padding = padding;
			
			_align = align;
		}
		
		public function addButton( button:SwitchButton ):void
		{
			button.addEventListener( SwitchButton.STATUS_EVENT, buttonStatus );
			buttons.push( button );
		}
		
		public function render():void
		{
			for(var i:int = 0; i<buttons.length; i++)
			{
				addChild( buttons[i] );
			}
			
			align = align;		// reset the positioning
		}
		
		
		private function buttonStatus(event:StatusEventEnhanced):void
		{
			trace(' - SwitchButtonGroup.buttonStatus: ' + event.type );
			
			var button:SwitchButton = event.target as SwitchButton;
			
			switch(event.code)
			{
				case SwitchButton.SELECT:					
			
					for(var i:int = 0; i<buttons.length; i++)
					{
						var b:SwitchButton = buttons[i] as SwitchButton;
						if(button != b) b.selected = false;
					}
					
					dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, BUTTON_SELECT, button ) );
				break;
			}
		}
		
		public function get align():String
		{
			return _align;
		}
		
		public function set align(align:String):void
		{
			_align = align;
			
			var i:int;
			
			switch( align )
			{
				case ALIGN_LEFT:
					for(i = 0; i<buttons.length; i++)
					{
						if(i > 0) buttons[i].x = buttons[ i - 1 ].x + buttons[ i - 1 ].width + padding;
					}
				break;
				
				case ALIGN_RIGHT:
					for(i = 0; i<buttons.length; i++)
					{
						if(i == 0) buttons[i].x = -(buttons[i].x);
						else buttons[i].x = buttons[ i - 1 ].x - (buttons[ i - 1 ].width + padding);
					}
				break;
			}
		}
	}
}
