package com.milkisevil.ui 
{
	import com.milkisevil.events.StatusEventEnhanced;
	import com.milkisevil.ui.BaseUI;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class Thumbnail extends BaseUI 
	{
		public static const NAME:String					= 'Thumbnail';
		public static const STATUS_EVENT:String			= NAME + '.STATUS_EVENT';
		public static const LOAD_COMPLETE:String		= NAME + '.LOAD_COMPLETE';
		public static const LOAD_ERROR:String			= NAME + '.LOAD_ERROR';
		
		private var forceHeight:Number;
		private var forceWidth:Number;
		private var loader:Loader;
		private var borderColor:int;
		private var border:Shape;
		private var imageSrc:String;
		private var preserveAspectRatio:Boolean;

		public function Thumbnail( forceWidth:Number = NaN, forceHeight:Number = NaN, borderColor:Number = NaN, preserveAspectRatio:Boolean = true )
		{
			super( );
			
			this.forceWidth = forceWidth;
			this.forceHeight = forceHeight;
			this.borderColor = borderColor;
			this.preserveAspectRatio = preserveAspectRatio;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loadError );
			addChild( loader );
			
			drawBorder( );
		}
		
		private function drawBorder():void
		{
			if(forceWidth && forceHeight)
			{
				if( borderColor && !isNaN(borderColor) )
				{
					border = createRectangle( 0, 0, forceWidth, forceHeight, NaN, borderColor );
					addChild( border );
				}
			}			
		}

		public function load( imageSrc:String ):void
		{
			trace('exec Thumbnail.load: ' + imageSrc );
			
			this.imageSrc = imageSrc;
			loader.load( new URLRequest( imageSrc ), new LoaderContext(true) );
		}
		
		private function loadError(event:IOErrorEvent):void
		{
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOAD_ERROR ) );
		}
		
		private function loadComplete(event:Event):void
		{
			var bitmap:Bitmap = LoaderInfo( event.target ).content as Bitmap;
			bitmap.smoothing = true;
			
			if(forceWidth)
			{
				loader.width = forceWidth;
				if(preserveAspectRatio) loader.scaleY = loader.scaleX;
			}
			else
			{
				forceWidth = loader.width;
			}
			
			if(forceHeight)
			{
				loader.height = forceHeight;
				if(preserveAspectRatio) loader.scaleX = loader.scaleY;
			}
			else
			{
				forceHeight = loader.height;
			}
			
			drawBorder( );
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOAD_COMPLETE ) );
		}
	}
}
