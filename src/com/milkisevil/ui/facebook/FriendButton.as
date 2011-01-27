package com.milkisevil.ui.facebook 
{
	import flash.display.MovieClip;

	//import com.facebook.data.FacebookLocation;

	import flash.system.LoaderContext;
	//import com.facebook.data.users.FacebookUser;
	import com.milkisevil.events.StatusEventEnhanced;
	import com.milkisevil.ui.BaseUI;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FriendButton extends BaseUI 
	{
		public static const NAME:String						= 'FriendButton';
		public static const STATUS_EVENT:String				= NAME + '.STATUS_EVENT';
		public static const LOAD_IMAGE_COMPLETE:String		= NAME + '.LOAD_IMAGE_COMPLETE';
		public static const LOAD_IMAGE_ERROR:String			= NAME + '.LOAD_IMAGE_ERROR';
		public static const SELECT:String					= NAME + '.SELECT';
		public static const DESELECT:String					= NAME + '.DESELECT';
		
		private var child:FriendButtonAsset;
		private var _selected:Boolean;
		private var _highlighted:Boolean;
		
		private static const TITLE_COLOR_NORMAL:String 			= '#000000';
		private static const TITLE_COLOR_HIGHLIGHT:String 		= '#000000';
		private static const TITLE_COLOR_SELECTED:String 		= '#ffffff';
		private static const SUBTITLE_COLOR_NORMAL:String 		= '#666666';
		private static const SUBTITLE_COLOR_HIGHLIGHT:String 	= '#666666';
		private static const SUBTITLE_COLOR_SELECTED:String 	= '#c3cddf';
		
		private var labelText:String;
		private var parsedText:String;
		private var _facebookUser:Object;
		private var _isLoadImageCalled:Boolean;
		

		/**
		 * To use a FriendButton, ensure the facebookUser contains:
		 * 		GetInfoFieldValues.PIC_SQUARE
		 * 		GetInfoFieldValues.NAME
		 * 		
		 */
		public function FriendButton( facebookUser:Object )
		{
			super( );
			
			child = new FriendButtonAsset();
			
			child.hit.buttonMode = true;
			child.hit.addEventListener( MouseEvent.ROLL_OVER, rollOver );
			child.hit.addEventListener( MouseEvent.ROLL_OUT, rollOut );
			child.hit.addEventListener( MouseEvent.CLICK, click );
			
			addUser( facebookUser );
			
			selected = false;
			highlighted = false;
			
			addChild(child);
		}
		
		private function rollOver(event:MouseEvent):void
		{
			if(!selected) highlighted = true;
		}

		private function rollOut(event:MouseEvent):void
		{
			if(!selected) highlighted = false;
		}

		private function click(event:MouseEvent):void
		{
			selected = (selected) ? false : true;
		}
		
		private function addUser( facebookUser:Object ):void
		{
			_facebookUser = facebookUser;
			
			//child.label.text = (facebookUser.name) ? facebookUser.name : '';
			//child.label.appendText( xxx );		// TODO: Append network
			
			var subTitle:String = '';
			var currentLocation:Object = facebookUser.current_location;
			if(currentLocation)
			{
				if(currentLocation.city) subTitle = currentLocation.city;
				if(subTitle == '' && currentLocation.country) subTitle = currentLocation.country;
			}
			
			labelText = '<font color="TITLE_COLOR_TAG">' + ((facebookUser.name) ? facebookUser.name : '') + '</font>';
			labelText += '<br><font color="SUBTITLE_COLOR_TAG">' + subTitle + '</font>';
			
			updateLabel( TITLE_COLOR_NORMAL, SUBTITLE_COLOR_NORMAL );
		}
		
		/**
		 * Gives the label the correct colours
		 */
		private function updateLabel( titleColor:String, subtitleColor:String ):void
		{
			child.label.htmlText = labelText.split( 'SUBTITLE_COLOR_TAG' ).join( subtitleColor ).split( 'TITLE_COLOR_TAG' ).join( titleColor );;
		}
		
		public function loadImage( imageURL:String = null ):void
		{
			_isLoadImageCalled = true;
			
			if(!imageURL) imageURL = facebookUser.pic_square;
			if(!imageURL) imageURL = facebookUser.pic_square_with_logo;
			if(imageURL)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadImageComplete );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loadImageError );
				loader.load( new URLRequest( imageURL ), new LoaderContext( true ) );
			}
			else
			{
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOAD_IMAGE_ERROR, 'No image URL available for ' + facebookUser.name ) );
			}
		}
		
		private function loadImageError(event:IOErrorEvent):void
		{
			trace('exec FriendButton.loadImageError: '  + facebookUser.name );
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOAD_IMAGE_ERROR, event.text ) );
		}

		public function loadImageComplete( event:Event ):void
		{
			child.thumb.image.removeChild( child.thumb.image.getChildAt(0) );
			
			var bitmap:Bitmap = LoaderInfo( event.target ).content as Bitmap;
			child.thumb.image.addChild( bitmap );
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOAD_IMAGE_COMPLETE ) );
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
				child.backgroundSelected.visible = true;
				child.thumb.frameSelected.visible = true;
				child.thumb.frameNormal.visible = false;
				updateLabel( TITLE_COLOR_SELECTED, SUBTITLE_COLOR_SELECTED );
				
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, SELECT ) );
			}
			else
			{
				child.backgroundSelected.visible = false;				
				child.thumb.frameSelected.visible = false;
				child.thumb.frameNormal.visible = true;
				updateLabel( TITLE_COLOR_NORMAL, SUBTITLE_COLOR_NORMAL );
				
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, DESELECT ) );
			}
		}
		
		public function get highlighted():Boolean
		{
			return _highlighted;
		}
		
		public function set highlighted(highlighted:Boolean):void
		{
			_highlighted = highlighted;
			
			if(highlighted)
			{
				child.backgroundHighlight.visible = true;
				child.thumb.frameHighlight.visible = false;
				child.thumb.frameNormal.visible = false;
				updateLabel( TITLE_COLOR_HIGHLIGHT, SUBTITLE_COLOR_HIGHLIGHT );
			}
			else
			{
				child.backgroundHighlight.visible = false;
				child.thumb.frameHighlight.visible = false;
				child.thumb.frameNormal.visible = true;
				updateLabel( TITLE_COLOR_NORMAL, SUBTITLE_COLOR_NORMAL );
			}
		}
		
		public function get facebookUser():Object
		{
			return _facebookUser;
		}
		
		public function get isLoadImageCalled():Boolean
		{
			return _isLoadImageCalled;
		}

		override public function get enabled():Boolean
		{
			return super.enabled;
		}

		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			child.hit.mouseEnabled = value;
			child.hit.buttonMode = value;
		}
	}
}
