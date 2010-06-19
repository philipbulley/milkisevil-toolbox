
package com.milkisevil.utils
{
	
	/**
	* DateEnhanced.as
	*
	* @author 		Philip Bulley <philip@milkisevil.com>
	* 				Partly based on AS1 getTimeDiff, addTime, reoveTime functions by Luke Bayes <luke@lukebayes.com>
	* @version 		2.1
	* @usage		
	* 				
	* 				import com.milkisevil.utils.DateEnhanced;
	* 
	* 				var myDay = new DateEnhanced().addTime( DateEnhanced.UNIT_WEEKS , 1)
	* 
	*				myDay.addTime( DateEnhanced.UNIT_DAYS , 2);
	*				trace("myDay : " + myDay);
	* 
	*				myDay.addTime( DateEnhanced.UNIT_YEARS , 2);
	*				trace("myDay : " + myDay);
	* 
	*				myDay.removeTime( DateEnhanced.UNIT_MONTHS , 3);
	*				trace("myDay : " + myDay);
	* 
	* 
	* 
	* History *******
	* 
	* v2.1
	* getMonthOfYear and getDayOfWeek can now return based on supplied monthNum/dayNum
	* 
	* v2.0
	* Ported to AS3, but no longer extends Date as Date is final in AS3 
	* 
	*/
	public dynamic class DateEnhanced /*extends Proxy*/
	{
		
		public static var UNIT_MILLISECONDS:String 		= 'ms';
		public static var UNIT_SECONDS:String 			= 'ss';
		public static var UNIT_MINUTES:String 			= 'mi';
		public static var UNIT_HOURS:String 			= 'hh';
		public static var UNIT_DAYS:String 				= 'dd';
		public static var UNIT_WEEKS:String 			= 'wk';
		public static var UNIT_MONTHS:String 			= 'mm';
		public static var UNIT_YEARS:String 			= 'yyyy';
		public static var DAY_NAMES:Array 				= new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
		public static var MONTH_NAMES:Array 			= new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		
		private var date:Date;		
		private var customInited:Boolean;
		private var unitValues:Object;
		
		
		/**
		 * @param	date		Provide an existing Date object, otherise the current date will be used
		 */
		public function DateEnhanced(date:Date = null)
		{
			if (date) 
			{
				this.date = date;
			} 
			else
			{
				this.date = new Date();
			}			
		}
		
		
		/**
		 * Returns an instance of the Date object being used by
		 * this instance of DateEnhanced
		 * 
		 * @return		The Date instance being used by DateEnhanced
		 */
		public function getDate():Date
		{
			return this.date;
		}
		
		
		/**
		 * Gets a string representation of the minutes with a leading '0' if necessary
		 * 
		 * 	@return		Minutes with leading '0' if necessary
		 */
		public function getMinutesLeading():String
		{
			var m:String = this.date.getMinutes().toString();
			if(m.length == 1) m = '0'+m;
			return m;
		}
		
		
		/**
		 * Gets hours, but using the 12 hour clock system
		 * 
		 * 	@return		Number between 1 and 12
		 */
		public function getHours12():Number
		{
			var h:Number = this.date.getHours();
			if(h > 12) h = h-12;
			return h;
		}
		
		
		/**
		 * Gets the ante meridiem or post meridiem suffix depending on the time
		 * 
		 * 	@return		A string containing either 'am' or 'pm'
		 */
		public function getSuffix():String
		{
			var h:Number = this.date.getHours();
			if (h < 12)
			{
				return 'am';
			}
			else
			{
				return 'pm';
			}
		}
		
		/**
		 * Gets representation of the day of the week as a text string
		 * 
		 * @param	shortenTo		Shorten to the first x letters. (ie. 3 might return 'Mon')
		 * @param 	dayNum			Override the current Date within date enhanced to simply get the name of a 
		 * @return					A string representing the day of the week
		 */
		public function getDayOfWeek(shortenTo:Number = NaN, dayNum:int = -1):String
		{
			if(dayNum == -1) dayNum = this.date.getDay();
			
			var dayStr:String = DAY_NAMES[ dayNum ];
			if (!isNaN(shortenTo))
			{
				return dayStr.substr(0, shortenTo);
			}else
			{
				return dayStr;
			}
		}
		
		/**
		 * Gets representation of the month as a text string
		 * 
		 * @param	shortenTo		Shorten to the first x letters. (ie. 3 might return 'Jan')
		 * @param 	monthNum		Override the current Date within date enhanced to simply get the name of a 
		 * @return					A string representing the month
		 */
		public function getMonthOfYear(shortenTo:Number = NaN, monthNum:int = -1):String
		{
			if(monthNum == -1) monthNum = this.date.getMonth();
			
			var monthStr:String = MONTH_NAMES[ monthNum ];
			if (!isNaN(shortenTo))
			{
				return monthStr.substr(0, shortenTo);
			}
			else
			{
				return monthStr;
			}
		}
		
		
		
		/**
		 * Return the difference between the current date object and the one passed in as dateRef. Return value is in the
		 * unit specified. This will round results by default, pass boolean true in doNotRound argument to return complex numbers.
		 * 
		 * @param	dateRef					Date object to compare to
		 * @param	unit					Pass one of the DateEnhanced.UNIT_XXX static constants, the default is DateEnhanced.UNIT_MILLISECONDS
		 * @param	doNotRound = false
		 * @return
		 */
		public function getTimeDiff(dateRef:Date, unit:String = 'ms', doNotRound:Boolean = false):Number
		{
			if (!(dateRef is Date)) return NaN;
			
			if(!this.customInited) this.customInit();
			
			var oms:Number = dateRef.getTime();
			var mms:Number = this.date.getTime();
			var diff:Number = (mms - oms < 0) ? oms - mms : mms - oms;
			
			return (doNotRound) ? diff / this.unitValues[unit] : Math.round(diff / this.unitValues[unit]);
		}
		
		/**
		 * Add the amount of time specified to the current date object in the units passed in.
		 * 
		 * @param	unit		Pass one of the DateEnhanced.UNIT_XXX static constants, the default is DateEnhanced.UNIT_MILLISECONDS
		 * @param	amount		A numerical amount of time in the specified unit
		 * @return				A Date object representing the time requested
		 */
		public function addTime(unit:String = 'ms', amount:Number = 0):Date
		{
			if(!this.customInited) this.customInit();
			
			if (unit == "mm") 
			{
				this.date.setMonth( this.date.getMonth() + amount );
			} 
			else if (unit == "yyyy") 
			{
				this.date.setFullYear( this.date.getFullYear() + amount );
			} 
			else 
			{
				var actual:Number = this.unitValues[unit] * amount;
				this.date.setTime( this.date.getTime() + actual );
			}
			
			return this.getDate();
		}
		
		
		/**
		 * Remove time from the current date object in the units specified.
		 * 
		 * @param	unit		Pass one of the DateEnhanced.UNIT_XXX static constants, the default is DateEnhanced.UNIT_MILLISECONDS
		 * @param	amount		A numerical amount of time in the specified unit
		 * @return				A Date object representing the time requested
		 */
		public function removeTime(unit:String = 'ms', amount:Number = 0):Date
		{
			return this.addTime(unit, -amount);
		}
		
		
		
		
		
		

		//------------------------------------------------------
		// PRIVATE HELPER METHODS

		private function getUnitsInMilliseconds():Object
		{
			var obj:Object = new Object();
			obj.ms = 1;
			obj.ss = 1000;
			obj.mi = obj.ss * 60;
			obj.hh = obj.mi * 60;
			obj.dd = obj.hh * 24;
			obj.wk = obj.dd * 7;
			obj.mm = obj.dd * 30;
			obj.yyyy = obj.dd * 365;
			
			return obj;
		}
		
		//------------------------------------------------------
		
		private function customInit():void
		{
			this.unitValues = this.getUnitsInMilliseconds();
			this.customInited = true;
		}
		

	}
	
}