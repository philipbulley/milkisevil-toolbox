package com.milkisevil.ui.facebook 
{
	import flash.text.TextFieldAutoSize;
	import com.milkisevil.ui.BaseUI;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class AlertText extends BaseUI 
	{
		private var child:AlertTextAsset;
		
		public function AlertText()
		{
			super( );
			
			child = new AlertTextAsset();
			child.tf.autoSize = TextFieldAutoSize.LEFT;
			addChild( child );
		}
		
		public function get text():String
		{
			return child.tf.text;
		}
		
		public function set text(text:String):void
		{
			child.tf.text = text;
		}
	}
}
