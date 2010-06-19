package com.milkisevil.utils 
{
	import flash.events.Event;
	import com.milkisevil.events.StatusEventEnhanced;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	/**
	 * Adapted from the AS2 effect at http://www.ultrashock.com/forums/actionscript/yugop-text-effect-anyone-got-it-working-59597.html
	 * 
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class TextEffectDecrypt extends EventDispatcher
	{
		public static const NAME:String				= 'TextEffectDecrypt';
		public static const STATUS_EVENT:String		= NAME + '.STATUS_EVENT';
		public static const START:String			= NAME + '.START';
		public static const COMPLETE:String			= NAME + '.COMPLETE';
		
		private var randomCharacters:String = "!@#$%^&*()x/\|";
		private var str:String;
		private var randomHolder:String;
		private var currentRandom:String;
		private var tf:TextField;
		private var duration:Number;
		private var wait:Number = 0;
		private var randomLetterCount:Number = 0;
		private var clearLetterCount:Number = 0;
		
		/**
		 * Create an instance of the effect, for a specific TextField
		 * 
		 * @param	tf			The TextField to display the text effect
		 */
		public function TextEffectDecrypt(tf:TextField) 
		{
			this.tf = tf;
		}
		
		
		/**
		 * Set the random characters that will display whilst the effect is in progress
		 * 
		 * @param	randomCharacters	A string containing a selection of characters to be displayed
		 */
		public function setRandomCharacters( randomCharacters:String ):void
		{
			this.randomCharacters = randomCharacters;
		}
		
		
		/**
		 * Start the effetc
		 * 
		 * @param	str			The string to eventually show
		 * @param	duration	The time it takes for the effect to complete (in frames)
		 */
		public function start(str:String, duration:Number):void
		{
			this.tf.text = "";
			this.str = str;
			this.wait = 0;
			this.randomLetterCount = 0;
			this.clearLetterCount = 0;
			this.duration = duration;
			
			this.tf.addEventListener( Event.ENTER_FRAME, this.enterFrame );
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, START ) );
		}
		
		/**
		 * Prematurely stop an already started effect
		 */
		public function stop():void
		{
			this.tf.removeEventListener( Event.ENTER_FRAME, this.enterFrame );
		}
		
		
		
		private function enterFrame( event:Event ):void
		{
			if(this.clearLetterCount <= this.str.length) 
			{
				//clear out what's in the box right now
				this.randomHolder = "";
				this.tf.text = "";
				
				//lets populate the random string
				for(var j:Number = 0;j < this.str.length;j++) 
				{
					this.currentRandom = randomCharacters.charAt( Math.floor((Math.random() * randomCharacters.length)) );
					this.randomHolder += this.currentRandom;
				}
				
				tf.text = this.randomHolder.substr(0, this.randomLetterCount);
				
				if(this.wait > this.duration)
				{
					tf.text = this.str.substr(0,this.clearLetterCount);
					tf.appendText( this.randomHolder.substr(this.clearLetterCount, this.randomLetterCount - this.clearLetterCount) );
					this.clearLetterCount++;
				}
				
				this.randomLetterCount++;
				this.wait++;
			} 
			else 
			{
				this.stop();
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, COMPLETE ) );
			}
		}
		
	}
	
}