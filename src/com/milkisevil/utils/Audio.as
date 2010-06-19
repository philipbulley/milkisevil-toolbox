


/**
* 
* @author Philip Bulley <philip@milkisevil.com>
* @version 2.0
*/

package com.milkisevil.utils 
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VolumePlugin;
	import com.milkisevil.events.StatusEventEnhanced;

	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class Audio extends EventDispatcher 
	{
		
		public static const NAME:String 				= 'Audio';
		public static const STATUS_EVENT:String 		= NAME + '.STATUS_EVENT';
		public static const MUTED:String 				= NAME + '.MUTED';
		public static const UNMUTED:String 				= NAME + '.UNMUTED';
		
		private static var instance:Audio;
		private var _isMute:Boolean;
		private var cache:Cache;
		
		
		function Audio(blocker:SingletonBlocker)
		{
			//trace('exec Audio');
			
			TweenPlugin.activate([VolumePlugin]);
		
			this.mute(0);	// This should be set before the Cache is instantiated			
			
			this.cache = Cache.getInstance('Audio');		
			
			//trace('Audio.isMute cached: '+this.cache.get('Audio', 'isMute'));		
			if( !this.cache.get('Audio', 'isMute') )
			{
				this.unmute(0);
			}
			
			//this.unmute();			
		}
		
		public static function getInstance():Audio
		{
			if(!instance){
				instance = new Audio(new SingletonBlocker());
			}
			return instance;
		}
		
		/**
		 * Globally mutes all audio
		 * 
		 * @param	time			Seconds it takes for the volume to fade to mute
		 * @param	delay			Seconds until the the mute process begins
		 */
		public function mute(duration:Number = 1, delay:Number = 0):void
		{
			//trace('exec Audio.unmute: duration:'+duration+', delay:'+delay);
			
			this.fadeVolume(0, duration, delay);			
		}
		
		
		/**
		 * Globally unmutes all audio
		 * 
		 * @param	time			Seconds it takes for the volume to fade to mute
		 * @param	delay			Seconds until the the mute process begins
		 */
		public function unmute(duration:Number = 1, delay:Number = 0):void
		{
			//trace('exec Audio.unmute: duration:'+duration+', delay:'+delay);
			
			this.fadeVolume(1, duration, delay);
		}
		
		
		/**
		 * Globally fades all audio
		 * 
		 * @param	level			A numeric value between 1 and 0 where 0 is mute
		 * @param	time			Seconds it takes for the volume to fade to mute
		 * @param	delay			Seconds until the the mute process begins
		 */
		public function fadeVolume(level:Number, duration:Number = 1, delay:Number = 0):void
		{
			TweenLite.to( SoundMixer, duration, {volume:level, onComplete:checkMute, delay:delay} );
		}
		
		
		/**
		 * Allows you to set the volume of a specific sound channel
		 * Also used internally by other methods to set the volume
		 * 
		 * @param	vol				A numerical value between 0 and 1. Specify as null to set to Audio's global volume
		 * @param	soundChannel	The channel the sound is playing within
		 */
		public function setVolume(vol:Number = -1, soundChannel:SoundChannel = null):void
		{
			//trace('exec Audio.setVolume: '+vol);
			if(!soundChannel) if (vol == -1) vol = this.volume;
			var st:SoundTransform = new SoundTransform(vol);
			if (!soundChannel)
			{
				SoundMixer.soundTransform = st;
			}
			else
			{
				soundChannel.soundTransform = st;
			}
			
			checkMute();
		}
		
		private function checkMute():void
		{
			_isMute = (volume == 0) ? true : false;
			//trace(' - Audio.checkMute: ' + _isMute);
			
			// Save to cache so we can use same setting on user's next return
			
			if (this.cache) 
			{
				this.cache.set('Audio', 'isMute', _isMute, new DateEnhanced().addTime('wk', 1) );
			}
			
			if(_isMute)
			{
				this.dispatchEvent( new StatusEventEnhanced( Audio.STATUS_EVENT, false, false, Audio.MUTED ) );
			}
			else 
			{
				this.dispatchEvent( new StatusEventEnhanced( Audio.STATUS_EVENT, false, false, Audio.UNMUTED ) );
			}		
		}
		
		/**
		 * Is the volume currently muted?
		 * Read-only
		 */
		public function get isMute():Boolean
		{
			return _isMute;
		}
		
	
		/**
		 * Plays a sound from the library or from an external file
		 * 
		 * @param	source						Either an instance of Sound, a String URL, or a URLRequest
		 * @param	startTime					The initial position in milliseconds at which playback should start
		 * @param	loops						Defines the number of times a sound loops back to the startTime value before the sound channel stops playback.
		 */
		public function play(source:*, startTime:Number = 0, loops:int = 1):SoundChannel
		{
			//var my_sound:Sound = new Sound();
			
			//trace('exec Audio.playSound: '+source+', '+startTime+', '+loops);
			
			var s:Sound;
			var c:SoundChannel;
			
			if(source is Sound)
			{
				s = source;
			} 
			else if (source is URLRequest)
			{
				s = new Sound( source );
			} 
			else if (source is String) 
			{
				s = new Sound( new URLRequest( source ) );
			} 
			else 
			{
				throw new Error('Error: Audio.play: The source supplied is not valid');
			}
			
			c = s.play(startTime, loops);
			
			return c;
		}
		
		public function get volume():Number
		{
			return SoundMixer.soundTransform.volume;
		}
	}


}



internal class SingletonBlocker
{
	
}
