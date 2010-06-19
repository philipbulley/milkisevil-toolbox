package com.milkisevil.ui.facebook 
{
	import com.milkisevil.ui.BaseUI;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.StatusEvent;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FormInputTextField extends BaseUI 
	{
		public static var NAME:String 				= 'FormInputTextField';		public static var STATUS_EVENT:String 		= NAME + '.STATUS_EVENT';		public static var FOCUS:String 				= NAME + '.FOCUS';		public static var BLUR:String 				= NAME + '.BLUR';		public static var ENTER:String 				= NAME + '.ENTER';		public static var CHANGE:String 			= NAME + '.CHANGE';
				public static var LABEL_PADDING:Number 		= 10;
		
		private var child:FormInputTextFieldAsset;		private var _defaultValue:String;		private var _focus:Boolean;		private var _lableText:String;

		public function FormInputTextField()
		{
			super( );
			
			child = new FormInputTextFieldAsset();
			addChild( child );
			
			init( );
		}
		
		private function init():void
		{
			child.textField.addEventListener( Event.CHANGE, textFieldListener );			child.textField.addEventListener( KeyboardEvent.KEY_DOWN, textFieldKeyListener );			child.textField.addEventListener( FocusEvent.FOCUS_IN, textFieldFocusListener );			child.textField.addEventListener( FocusEvent.FOCUS_OUT, textFieldFocusListener );
			
			child.textField.borderColor = 0xbdc7d8;
		}

		private function textFieldListener(event:Event):void
		{
			switch( event.type )
			{
				case Event.CHANGE:
					dispatchEvent( new StatusEvent( STATUS_EVENT, false, false, CHANGE ) );
				break;
			}
		}
		
		private function textFieldKeyListener(event:KeyboardEvent):void
		{
			switch( event.type )
			{
				case KeyboardEvent.KEY_DOWN:
					if(focus && event.keyCode == Keyboard.ENTER)
					{
						dispatchEvent( new StatusEvent( STATUS_EVENT, false, false, ENTER ) );
					}
				break;
			}
		}
		
		private function textFieldFocusListener(event:FocusEvent):void
		{
			switch( event.type )
			{
				case FocusEvent.FOCUS_IN:
					_focus = true;
					if (child.textField.text == defaultValue) child.textField.text = '';
					dispatchEvent( new StatusEvent( STATUS_EVENT, false, false, FOCUS ) );
				break;
				
				case FocusEvent.FOCUS_OUT:
					_focus = false;
					if (defaultValue && child.textField.text == '') value = defaultValue;
					dispatchEvent( new StatusEvent( STATUS_EVENT, false, false, BLUR ) );
				break;
			}
		}

//		override public function set enabled(bool:Boolean):void
//		{
//			if (bool && !_enabled) 
//			{				
//				_enabled = true;
//				child.textField.type = TextFieldType.INPUT;
//			} 
//			else if (!bool && _enabled)
//			{				
//				_enabled = true;
//				child.textField.type = TextFieldType.DYNAMIC;
//			}
//		}
//	
//		override public function get enabled():Boolean
//		{
//			return _enabled;			
//		}
		
		public function get value():String
		{
			var _value:String = child.textField.text;
			if(_value == _defaultValue) _value = ''; 
			return _value;
		}
		
		public function set value(str:String):void
		{
			if(defaultValue && (str == '' || str == null)) str = defaultValue;
			if (enabled) child.textField.text = str;
		}
		
		public function get defaultValue():String
		{
			return _defaultValue;
		}
		
		public function set defaultValue(str:String):void
		{
			if (value == defaultValue || value == '' || !value) value = str;
			_defaultValue = str;
		}
		
		public function get focus():Boolean
		{
			return _focus;
		}
		
		public function set focus(bool:Boolean):void
		{
			_focus = bool;
			if( bool ) stage.focus = child.textField;
			else stage.focus = stage;
		}
		
		public function get lableText():String
		{
			return child.label.text;
		}
		
		public function set lableText(lableText:String):void
		{
			child.label.autoSize = TextFieldAutoSize.LEFT;
			child.label.text = lableText;
			child.textField.x = child.label.x + child.label.width + LABEL_PADDING;
		}
	}
}
