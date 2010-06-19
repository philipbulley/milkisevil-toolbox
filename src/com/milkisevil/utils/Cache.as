package com.milkisevil.utils
{
	import flash.net.SharedObject;
	
	/**
	* Cache.as
	*
	* @author 		Philip Bulley <philip@milkisevil.com>
	* @version 		2.0.1
	* @usage		
	* 				
	* 				import com.milkisevil.utils.Cache;
	* 				import com.milkisevil.utils.DateEnhanced;
	* 
	* 				// To add stuff (will expire at the end of current session):
	* 
	* 					Cache.getInstance().set('userData', 'email', 'philip@milkisevil.com');
	* 
	* 				// To add stuff (with an expiry date):
	* 					
	* 					Cache.getInstance().set('userData', 'email', 'philip@milkisevil.com', new DateEnhanced().addTime('wk', 1) );
	* 
	* 				// To get stuff:
	* 
	* 					Cache.getInstance().get('userData', 'email');
	* 
	* 
	* 
	* History *******
	* 
	* v2.0.1
	* Various bugfixes in retriviing data
	*
	* v2.0
	* Ported to AS3, but had to make irritating changes to the way it works with Date class, as it can't be extended
	* 
	* 
	* v1.0r1
	* Renamed 'add' function to 'set' to bring it in line with the Registry class, why I didn't do this b4 i do not know???
	* 
	*/
	public class Cache
	{
		
		private static var instance:Cache;
		private var cacheObject:Object;
		private var so:SharedObject;
		private var enableLocalSave:Boolean;
		
		public function Cache(blocker:SingletonBlocker, cacheId:String)
		{
			
			//trace("exec Cache: global cacheId: "+cacheId);
			this.enableLocalSave = true;
			
			if(this.enableLocalSave)
			{				
				so = SharedObject.getLocal(cacheId, "/");
				
				//delete this.so.data.cacheObject;
				this.so.flush();
			}
			
			if(this.enableLocalSave && this.so.data.cacheObject)
			{
				//trace("FOUND IN SHARED OBJECT: "+this.so.data.cacheObject);
				cacheObject = this.so.data.cacheObject;
				
				// Remove expired items
				cacheObject = this.getCacheObjectWithoutExpired();
			}
			else
			{
				//trace("CRAP NOT FOUND IN SHARED OBJECT: "+this.so.data.cacheObject+"   this.enableLocalSave: "+this.enableLocalSave);
				cacheObject = new Object();
			}
			
		}
		
		
		/**
		 * Gets the global instance of Cache
		 * 
		 * @param	cacheId			Usually the name of the application or website. Should only be supplied on the first call, will be ignored subsequently
		 * @return
		 */
		public static function getInstance(cacheId:String = null):Cache
		{
			if (instance == null) 
			{
				if (!cacheId) throw new Error('ERROR: Cache.getInstance: You must supply a cacheId when calling getInstance for the first time');
				instance = new Cache(new SingletonBlocker(), cacheId);
			}
			return instance;
		}
		
		public function set(cacheNamespace:String, key:*, value:*, expiry:Date = null):void
		{
			//trace("exec Cache.set: " + cacheNamespace + ": " + key + "[" + value + "] - expiry:" + expiry);
			
			if(cacheObject[cacheNamespace] == undefined) cacheObject[cacheNamespace] = {};
			if(cacheObject[cacheNamespace][key] == undefined) cacheObject[cacheNamespace][key] = {};

			cacheObject[cacheNamespace][key]['value'] = value;
			cacheObject[cacheNamespace][key]['expiry'] = expiry;
			
			this.saveToSharedObject();
		}
		
		public function get(cacheNamespace:String, key:*):Object
		{
			//trace("exec Cache.get: " + cacheNamespace + ":" + key);
			
			var r:Object;
			
			this.refresh();
			
			for (var ns:String in cacheObject) 
			{				
				//trace('   - Cache.get: check cacheNamespace: ' + ns);
				for(var k:* in cacheObject[ns]) 
				{					
					//trace('     - Cache.get: check key: ' + k);
					if(ns == cacheNamespace && k == key)
					{
						r = cacheObject[ns][k]['value'];		
						break;
					}		
				}
				
				if(ns == cacheNamespace) break;			
			}
			
			//trace(' - Cache.get: ' + r);
			//MonsterDebugger.trace(this, r);
			
			return r;			
		}
		
		public function getExpiry(cacheNamespace:String, key:*):Date
		{
			return cacheObject[cacheNamespace][key]['expiry'];			
		}
		
		private function saveToSharedObject():void
		{
			if (this.enableLocalSave) 
			{				
				this.so.data.cacheObject = this.getCacheObjectWithoutExpired();
				this.so.flush();				
			}		
		}
		
		
		private function refresh():void
		{
			cacheObject = this.getCacheObjectWithoutExpired();
		}
		
		
		private function getCacheObjectWithoutExpired():Object
		{
			
			var cacheObjectClean:Object = {};
			var nowDate:DateEnhanced = new DateEnhanced();
			
			for (var cacheNamespace:String in cacheObject) 
			{
				for (var key:* in cacheObject[cacheNamespace]) 
				{
					//if (nowDate.getTimeDiff( cacheObject[cacheNamespace][key]['expiry'] ) <= 0) {
					if(nowDate.getDate() >= cacheObject[cacheNamespace][key]['expiry'])
					{						
						//trace("Cache.getCacheObjectWithoutExpired: cacheObject["+cacheNamespace+"]["+key+"] HAS expired on "+cacheObject[cacheNamespace][key]['expiry']);
					} 
					else 
					{
						//trace("Cache.getCacheObjectWithoutExpired: cacheObject["+cacheNamespace+"]["+key+"] hasn't expired! "+cacheObject[cacheNamespace][key]['expiry']);
						
						if(cacheObjectClean[cacheNamespace] == undefined) cacheObjectClean[cacheNamespace] = {};
						cacheObjectClean[cacheNamespace][key] = cacheObject[cacheNamespace][key];
					}
					//MonsterDebugger.trace(this, cacheObject[cacheNamespace][key]);
				}
			}
			
			return cacheObjectClean;
		}
		
	}
}

internal class SingletonBlocker
{
	
}