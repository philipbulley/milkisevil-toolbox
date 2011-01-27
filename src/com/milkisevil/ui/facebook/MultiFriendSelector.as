package com.milkisevil.ui.facebook 
{
	import fl.containers.ScrollPane;
    //import org.as3commons.collections.*;
	import com.facebook.graph.*;
	//import com.facebook.commands.friends.GetFriends;
	//import com.facebook.commands.users.GetInfo;
	//import com.facebook.data.friends.GetFriendsData;
	//import com.facebook.data.users.FacebookUser;
	//import com.facebook.data.users.FacebookUserCollection;
	//import com.facebook.data.users.GetInfoData;
	//import com.facebook.data.users.GetInfoFieldValues;
	//import com.facebook.events.FacebookEvent;
	import com.greensock.TweenMax;
	import com.milkisevil.events.StatusEventEnhanced;
	import com.milkisevil.ui.BaseUI;
	import org.as3commons.reflect.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class MultiFriendSelector extends BaseUI 
	{
		public static const NAME:String 			= 'MultiFriendSelector';
		public static const STATUS_EVENT:String 	= NAME + '.STATUS_EVENT';
		public static const CLOSE:String 			= NAME + '.CLOSE';
		public static const SUBMIT:String 			= NAME + '.SUBMIT';
		
		private static const FRIEND_BUTTON_SPACING_X:Number = 6;
		private static const FRIEND_BUTTON_SPACING_Y:Number = 6;
		private static const SCROLL_BAR_WIDTH:Number = 15;
		
		private var child:MultiFriendSelectorAsset;
		private var friendButtonList:Array = [];
		private var scrollPane:ScrollPane;
		private var users:Sprite;
		private var columns:int;
		private var searchField:FormInputTextField;
		private var bottomSpacer:Sprite;
		private var simultaneousImageDownloads:int;
		private var maxFriendsSelect:int;
		private var selectedButton:SwitchButton;
		private var allButton:SwitchButton;
		private var alertText:AlertText;
		public var allowDrag:Boolean = true;
		private var fb:Type;
		private var facebook:Class;
		private var api:Method;
		private var getImageUrl:Method;
		private var fbType:String;

		public function MultiFriendSelector( maxFriendsSelect:int = 16, simultaneousImageDownloads:int = 5, isAir:Boolean = true )
		{
			super( );
			this.maxFriendsSelect = (maxFriendsSelect == 0) ? 1 : maxFriendsSelect;		// Don't allow maxFriendsSelect to be 0
			this.simultaneousImageDownloads = simultaneousImageDownloads;
			//choose the appropriate clas depending on whether we are in an Air app or a Flash app
			fbType = ((isAir) ? "com.facebook.graph.FacebookDesktop" : "com.facebook.graph.Facebook");
			//get a reference to the appropriate class since the Actionscript Facebook API uses static methods and singletons 
			
			child = new MultiFriendSelectorAsset();
			scrollPane = child.content.scrollPane;
			
			var tempFriendButton:FriendButton = new FriendButton( {name:"",id:""} );
			columns = Math.floor( (scrollPane.width - FRIEND_BUTTON_SPACING_X - SCROLL_BAR_WIDTH) / (tempFriendButton.width + FRIEND_BUTTON_SPACING_X) );
			users = new Sprite();
			scrollPane.source = users;
			scrollPane.verticalLineScrollSize = tempFriendButton.height * .75;
			
			// Set the max friends
			child.content.heading2.autoSize = TextFieldAutoSize.LEFT;
			child.content.heading2.text = 'Add ' + ((maxFriendsSelect == 1) ? '' : 'up to ') + maxFriendsSelect + ' of your friends by clicking on ' + ((maxFriendsSelect == 1) ? 'a picture ' : 'their pictures ') + 'below';
			
			initSearchField();
			initButtons();
			initOptionBar();
			showLoading();
			
			addChild( child );
		}

		override protected function addedToStage(event:Event):void
		{
			super.addedToStage( event );
			
			initTitleBar();
			this.removeEventListener( Event.ADDED_TO_STAGE, this.addedToStage);
			//use the as3comons-reflection-api to find out if we are used by a web or desktop application
			fb = Type.forName(fbType);
			api = fb.getMethod('api');
			getImageUrl = fb.getMethod('getImageUrl');
			facebook = fb.clazz; //assign the Class to our local facebook variable so we can use it later
					
		}

		private function initOptionBar():void
		{
			allButton = new SwitchButton( 'All' );
			selectedButton = new SwitchButton( 'Selected (0)' );
			
			var switchButtonGroup:SwitchButtonGroup = new SwitchButtonGroup( );
			switchButtonGroup.addButton( allButton );
			switchButtonGroup.addButton( selectedButton );
			allButton.selected = true;
			switchButtonGroup.render();
			switchButtonGroup.x = child.content.optionBar.background.width - (switchButtonGroup.width + 10);
			switchButtonGroup.y = (child.content.optionBar.background.height * .5) - (switchButtonGroup.height * .5);
			child.content.optionBar.addChild( switchButtonGroup );
			
			// Add last, so we don't get any initial events (ie. by setting the initial selected)
			switchButtonGroup.addEventListener( SwitchButtonGroup.STATUS_EVENT, switchButtonGroupStatus );
			
			alertText = new AlertText();
			alertText.hide( {duration:0} );
			alertText.x = 10;
			alertText.y = 5;
			child.content.optionBar.addChild( alertText );
		}

		private function switchButtonGroupStatus(event:StatusEventEnhanced):void
		{
			trace('exec MultiFriendSelector.switchButtonGroupStatus: ' + event.code);
		
			switch(event.code)
			{
				case SwitchButtonGroup.BUTTON_SELECT:
					switch(event.data)
					{
						case allButton:
							removeAllFilters();
						break;
						
						case selectedButton:
							applySelectedFilter();
						break;
					}
				break;
			}
		}
		
		

		private function initSearchField():void
		{
			searchField = new FormInputTextField( );
			searchField.lableText = 'Find friends';
			searchField.defaultValue = 'Start typing a name';
			searchField.addEventListener( FormInputTextField.STATUS_EVENT, searchFieldListener );
			searchField.x = child.content.divider.x;
			searchField.y = child.content.divider.y + 15;
			child.content.addChild( searchField );
		}
		
		private function searchFieldListener(event:StatusEvent):void
		{
			trace('exec MultiFriendSelector.searchFieldListener: ' + event.code);
		
			switch(event.code)
			{
				case FormInputTextField.CHANGE:
					applyTextFilter( searchField.value );
				break;
			}
		}
		
		private function applyTextFilter(value:String):void
		{
			value = value.toLowerCase()
			
			for( var i:int = 0; i < friendButtonList.length ; i++ )
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				var facebookUser:Object = friendButton.facebookUser;
				if(facebookUser.name.toLowerCase().indexOf( value ) > -1)
				{
					friendButton.visible = true;
				}
				else
				{
					friendButton.visible = false;
				}
			}
			
			positionFriendButtons();
		}
		
		private function applySelectedFilter():void
		{
			for( var i:int = 0; i < friendButtonList.length ; i++ )
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				friendButton.visible = friendButton.selected;
			}
			
			positionFriendButtons();
		}
		
		/**
		 * Removes any filter applied to the display of FriendButtons
		 */
		private function removeAllFilters():void
		{
			searchField.value = '';
			applyTextFilter( '' );
		}

		private function initButtons():void
		{
			child.content.submitButton.mouseChildren = false;
			child.content.submitButton.buttonMode = true;
			child.content.submitButton.addEventListener( MouseEvent.CLICK, submitButtonListener );
			
			child.content.skipButton1.mouseChildren = false;
			child.content.skipButton1.buttonMode = true;
			child.content.skipButton1.addEventListener( MouseEvent.CLICK, skipButtonListener );
			
			child.content.skipButton2.mouseChildren = false;
			child.content.skipButton2.buttonMode = true;
			child.content.skipButton2.addEventListener( MouseEvent.CLICK, skipButtonListener );
		}
		
		private function submitButtonListener(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.CLICK:
					if( getSelected().length > 0 )
					{
						dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, SUBMIT ) );
					}
					else
					{
						showAlert( 'Please select at least 1 friend to continue' );
					}
				break;
			}
		}
		
		private function skipButtonListener(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.CLICK:
					dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, CLOSE ) );
				break;
			}
		}

		private function initTitleBar():void
		{       TweenMax.killTweensOf(this);
			child.titleBar.closeButton.mouseChildren = false;
			child.titleBar.closeButton.buttonMode = true;
			child.titleBar.closeButton.addEventListener( MouseEvent.CLICK, closeButtonListener );
			child.titleBar.closeButton.addEventListener( MouseEvent.ROLL_OVER, closeButtonListener );
			child.titleBar.closeButton.addEventListener( MouseEvent.ROLL_OUT, closeButtonListener );
			
			child.titleBar.favicon.mouseEnabled = false;
			child.titleBar.title.mouseEnabled = false;
			child.titleBar.background.addEventListener( MouseEvent.MOUSE_DOWN, dragListener );
			child.titleBar.background.addEventListener( MouseEvent.MOUSE_UP, dragListener );
			stage.addEventListener( Event.MOUSE_LEAVE, dragListener );
		}
		
		private function dragListener(event:Event):void
		{
			switch( event.type )
			{
				case MouseEvent.MOUSE_DOWN:
					if(allowDrag) startDrag();
				break;
				
				case MouseEvent.MOUSE_UP:
					stopDrag();
				break;
				
				case Event.MOUSE_LEAVE:
					stopDrag();
				break;
			}
		}

		private function closeButtonListener(event:MouseEvent = null):void
		{
			switch(event.type)
			{
				case MouseEvent.ROLL_OVER:
					TweenMax.to( child.titleBar.closeButton.cross, 0, { colorTransform:{tint:0xffffff, tintAmount:1} });
				break;
				
				case MouseEvent.ROLL_OUT:
					TweenMax.to( child.titleBar.closeButton.cross, .5, {colorTransform:{tint:0xffffff, tintAmount:0} });
				break;
				
				case MouseEvent.CLICK:
					dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, CLOSE ) );
				break;
			}
		}

		private function showLoading():void
		{
			child.miniSpinner.visible = true;
			child.content.visible = false;
		}
		
		private function hideLoading():void
		{
			child.miniSpinner.visible = false;
			child.content.visible = true;
		}

		public function getFriends():void
		{
		   var callBack:Function = this.getFriendsCallComplete
		   api.invoke(facebook,new Array("/me/friends",callBack));
		}
		
		private function getFriendsCallComplete(response:Object, fail:Object):void
		{

		    if (response){    
			var friends:Array  = response as Array;
			var friendCollection:Array = new Array();
			for(var i:int = 0; i<friends.length; i++)
			{
			   
				var friend:Object = {uid:friends[i].id, name:friends[i].name, pic_square:getImageUrl.invoke(facebook,new Array(friends[i].id,"square"))};
				friendCollection.push(friend);
			}
		
			addUsers(friendCollection);
            }
            else{
                    trace("could not getFriends "+fail.toString());
                }
		 	
		}

		
		private function addUsers(userCollection:Array):void
		{
			var friendsList:Array = [];
			var facebookUser:Object;
			
			for( var i:int = 0; i < userCollection.length ; i++ )
			{
				friendsList.push( userCollection[i] );
			}
			
			friendsList.sortOn( 'name' );
			
			//
			
			for( var j:int = 0; j < friendsList.length ; j++ )
			{
				facebookUser = friendsList[ j ] as Object;
				var friendButton:FriendButton = new FriendButton( facebookUser );
				friendButton.addEventListener( FriendButton.STATUS_EVENT, friendButtonStatus );
				friendButtonList.push( friendButton );
				users.addChild( friendButton );
			}
			
			positionFriendButtons();		
			
			hideLoading( );
			
			loadFriendButtonImages();
		}
		
		/**
		 * Starts the process of loading
		 */
		private function loadFriendButtonImages():void
		{
			var numToLoad:int = Math.min( simultaneousImageDownloads, friendButtonList.length );
			
			for(var i:int = 0; i<numToLoad; i++)
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				friendButton.loadImage();
			}
		}
		
		private function loadNextFriendButtonImage():void
		{
			for(var i:int = 0; i<friendButtonList.length; i++)
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				if(!friendButton.isLoadImageCalled)
				{
					friendButton.loadImage();
					break;
				}
			}
		}

		private function friendButtonStatus(event:StatusEventEnhanced):void
		{
			var friendButton:FriendButton = event.target as FriendButton;
			
			switch(event.code)
			{
				case FriendButton.LOAD_IMAGE_COMPLETE:
					loadNextFriendButtonImage();
				break;
				
				case FriendButton.LOAD_IMAGE_ERROR:
					trace('exec MultiFriendSelector.friendButtonStatus: LOAD_IMAGE_ERROR: ' + event.data );
					
					loadNextFriendButtonImage();
				break;
				
				case FriendButton.SELECT:
					if(updateSelected( ) > maxFriendsSelect)
					{
						friendButton.selected = false;
						showAlert('You may only select ' + maxFriendsSelect + ' friend' + ((maxFriendsSelect == 1) ? '' : 's') );
					}
				break;
				
				case FriendButton.DESELECT:
					updateSelected( );
					if(selectedButton.selected) friendButtonFadeOut( friendButton );					
				break;
			}
		}
		
		/**
		 * Fades a FriendButton out, and then re-positions all items
		 */
		private function friendButtonFadeOut( friendButton:FriendButton ):void
		{
			friendButton.enabled = false;		// Prevent re-selecting as it's fading away
			TweenMax.to( friendButton, .5, {autoAlpha:0, onComplete:friendButtonFadeOutComplete, onCompleteParams:[friendButton]} );
		}
		
		/**
		 * Part two of friendButtonFadeOut()
		 */
		private function friendButtonFadeOutComplete( friendButton:FriendButton ):void
		{
			friendButton.enabled = true;
			friendButton.alpha = 1;		// reset alpha, but not visible
			if(getSelected().length > 0)
			{
				positionFriendButtons();
			}
			else
			{
				allButton.selected = true;
			}
		}
		
		/**
		 * Shows the AlertText with a message
		 */
		private function showAlert(string:String):void
		{
			alertText.hide( {duration:0} );
			alertText.text = string;
			alertText.show( {duration:.5, onComplete:showAlertComplete} );
		}
		
		/**
		 * Prepares to hide the AlertText
		 */
		private function showAlertComplete():void
		{
			alertText.hide( {duration:3, delay:4} );
		}
		
		/**
		 * Checks which friendButtons are visible, and positions them accordingly.
		 * To create filters, change visible properties of all friendButtons first, then run this method
		 */
		private function positionFriendButtons():void
		{
			var position:int = 0;
			var lastVisibleFriendButton:FriendButton;
			for( var i:int = 0; i < friendButtonList.length ; i++ )
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				
				//trace(' - MultiFriendSelector.addUsers: ' + facebookUser.name );
				if(friendButton.visible)
				{
					var row:int = Math.floor( position / columns );
					var column:int = position % columns;
					friendButton.x = FRIEND_BUTTON_SPACING_X + ( friendButton.width * column ) + (FRIEND_BUTTON_SPACING_X * column);
					friendButton.y = FRIEND_BUTTON_SPACING_Y + ( friendButton.height * row ) + (FRIEND_BUTTON_SPACING_Y * row);
					if(!users.contains( friendButton )) users.addChild( friendButton );
					lastVisibleFriendButton = friendButton;
					position++;
				}
				else
				{
					if(users.contains( friendButton )) users.removeChild( friendButton );
				}
			}
			
			// Ensure there is padding when scrolling to the bottom
			if(!bottomSpacer)
			{
				bottomSpacer = new Sprite();
				bottomSpacer.addChild( createRectangle(0, 0, 1, FRIEND_BUTTON_SPACING_Y) );
				users.addChild( bottomSpacer );
			}
			if(lastVisibleFriendButton) bottomSpacer.y = lastVisibleFriendButton.y + lastVisibleFriendButton.height + FRIEND_BUTTON_SPACING_Y;
			else bottomSpacer.y = 0;		// No friend buttons are showing
			
			
			/*
			// Large background spacer			
			var bottomSpacer:Sprite = new Sprite();

			bottomSpacer.addChild( createRectangle(0, 0, scrollPane.width - 15, friendButtonList[friendButtonList.length - 1].y + friendButtonList[friendButtonList.length - 1].height + FRIEND_BUTTON_SPACING_Y, 0xff0000) );
			users.addChild( bottomSpacer );
			users.setChildIndex( bottomSpacer, 0 );
			scrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;			
			*/
			
			scrollPane.update();
		}
		
		/**
		 * Updates the selected button
		 * 
		 * @return	Number of current selected friends
		 */
		private function updateSelected():int
		{
			var userCollection:Array = getSelected();
			
			selectedButton.label = 'Selected (' + userCollection.length + ')';
			
			return userCollection.length;
		}
		
		/**
		 * Gets all of the selected users as a FacebookUserCollection
		 * 
		 * @return		All currently selected users
		 */
		private function getSelected():Array
		{
			var userCollection:Array = new Array();
			
			for( var i:int = 0; i < friendButtonList.length ; i++ )
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				
				if(friendButton.selected) userCollection.push( friendButton.facebookUser );
			}
			
			return userCollection;	
		}
		
		public function getSelectedFriends():Array
		{
			var returnable:Array = new Array();
			
			for( var i:int = 0; i < friendButtonList.length ; i++ )
			{
				var friendButton:FriendButton = friendButtonList[i] as FriendButton;
				var user:Object = (friendButton.facebookUser as Object);
				if(friendButton.selected) returnable.push( user );
			}
			
			return returnable;	
		}
		
		public function get title():String
		{
			return child.titleBar.title.text;
		}
		
		public function set title(title:String):void
		{
			child.titleBar.title.autoSize = TextFieldAutoSize.LEFT;
			child.titleBar.title.text = title;
		}
		
		public function get subtitle():String
		{
			return child.content.heading1.text;
		}
		
		public function set subtitle(subtitle:String):void
		{
			child.content.heading1.autoSize = TextFieldAutoSize.LEFT;
			child.content.heading1.text = subtitle;
		}
	
	}
}


