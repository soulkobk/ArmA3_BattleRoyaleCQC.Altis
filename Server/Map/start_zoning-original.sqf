/*
	File: start_zoning.sqf
	Description: BRCQC Blue and Black Zoning System
	Created By: soulkobk (2015-11-25)
	Date: 29/11/2015
	Parameters: n/a
	Returns: n/a
*/

_roundMinutes = 24; // was 20
_roundZoneChanges = 6; // was 7
// _roundMinutes = 12; // was 20
// _roundZoneChanges = 6; // was 7

_zoneSizeScaling = 35;
_zoneDamageDuration = 10; // SECONDS TO WAIT UNTIL EACH CHECK

_messageOnScreenDuration = 10; // HOW LONG TO DISPLAY ON SCREEN MESSAGES FOR

_loopSleepTime = 1; // MINUMUM SECONDS TO SLEEP PER LOOP

///////////////////////////////////////////////////////////////////////////////////////////////////
// DO NOT CHANGE ANYTHING BELOW!
///////////////////////////////////////////////////////////////////////////////////////////////////
_ticksRoundMax = (_roundMinutes * 60);
///////////////////////////////////////////////////////////////////////////////////////////////////
_zoneChangeTicks = round(_ticksRoundMax / _roundZoneChanges);
_zoneCenter = (getMarkerPos BRMini_CurrZone);
_zoneSize = BRMini_ZoneSize;
_zoneCenterNext = [0,0,0];
_zoneLock = false;
_zoneStop = false;
_zoneNextCheckTicks = 0;
///////////////////////////////////////////////////////////////////////////////////////////////////
_blueMarker = createMarker ["BLUEMARKER",_zoneCenter];
_blueMarker setMarkerColor "ColorBlue";
_blueMarker setMarkerShape "ELLIPSE";
_blueMarker setMarkerBrush "BORDER";
_blueMarker setMarkerPos _zoneCenter;
_blueMarker setMarkerSize [_zoneSize,_zoneSize];
_blueMarker setMarkerAlpha 0;
///////////////////////////////////////////////////////////////////////////////////////////////////
_ticksTillZoneLock = _zoneChangeTicks;
_ticksTillRoundLeft = _ticksRoundMax;
_ticksLoopExec = 0;
_ticksRound = 0;
_ticksRoundInit = round(diag_tickTime);
///////////////////////////////////////////////////////////////////////////////////////////////////
if (_zoneSizeScaling >= 1) then
{
	_zoneSizeScaling = _zoneSizeScaling / 100; 
};
///////////////////////////////////////////////////////////////////////////////////////////////////
_secMinText = "";
_isAreText = "";
_secMinTicks = "";
_timingText = {
		_toTestSeconds = _this select 0;
		_toTestMinutes = (_toTestSeconds / 60);
		if (_toTestMinutes < 1) then
		{
			_isTesting = _toTestSeconds;
			if (_isTesting == 1) then
			{
				_isAreText = "IS";
				_secMinText = "SECOND";
			}
			else
			{
				_isAreText = "ARE";
				_secMinText = "SECONDS";
			};
			_secMinTicks = _toTestSeconds;
		}
		else
		{
			_isTesting = _toTestMinutes;
			if (_isTesting == 1) then
			{
				_isAreText = "IS";
				_secMinText = "MINUTE";
			}
			else
			{
				_isAreText = "ARE";
				_secMinText = "MINUTES";
			};
			_secMinTicks = _toTestMinutes;
		};
		_secMinText;
		_isAreText;
		_secMinTicks = (round(_secMinTicks * (10 ^ 1)) / (10 ^ 1)); // ROUND TICKS TO 1 DECIMAL PLACE
};
///////////////////////////////////////////////////////////////////////////////////////////////////
diag_log format ["<BRMINI>: %1 ROUND STARTED!",BRMini_CurrZoneName];
while {(_ticksRound < _ticksRoundMax) && BRMini_InGame} do
{
	///////////////////////////////////////////////////////////////////////////////////////////////////
	_playerCount = {alive _x && isPlayer _x;} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]);
	if (_playerCount <= 1) exitWith { BRMini_InGame = false; };
	///////////////////////////////////////////////////////////////////////////////////////////////////
	_ticksRound = (round(diag_TickTime) - _ticksRoundInit);
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	_ticksTillZoneLock = _ticksTillZoneLock - _ticksLoopExec;
	///////////////////////////////////////////////////////////////////////////////////////////////////
	if (_ticksRound >= _zoneNextCheckTicks) then
	{
		/// TOTAL
		_totalBlack = [];
		{
			if (isPlayer _x && alive _x) then
			{
				_totalBlack set [count(_totalBlack),_x];
			};
		} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]);
		/// INSIDE
		_insideBlack = [];
		{
			if (isPlayer _x && alive _x) then
			{
				_insideBlack set [count(_insideBlack),_x];
				_x setVariable ["outsideBlackZone",false,false];
				_x setVariable ["outsideBlackZone",false];
			};
		} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize + 1)]); // GIVE 1 METER ALLOWANCE
		/// OUTSIDE
		_outsideBlack = _totalBlack - _insideBlack;
		///////////////////////////////////////////////////////////////////////////////////////////
		if (_zoneLock) then
		{
			/// TOTAL
			_totalBlue = [];
			{
				if (isPlayer _x && alive _x) then
				{
					_totalBlue set [count(_totalBlue),_x];
				};
			} forEach (_zoneCenter nearObjects ["Man",(_zoneSize * 2)]);
			/// INSIDE
			_insideBlue = [];
			{
				if (isPlayer _x && alive _x) then
				{
					_insideBlue set [count(_insideBlue),_x];
					_x setVariable ["outsideBlueZone",false,false];
					_x setVariable ["outsideBlueZone",false];
				};
			} forEach (_zoneCenter nearObjects ["Man",(_zoneSize + 1)]); // GIVE 1 METER ALLOWANCE
			/// OUTSIDE
			_outsideBlue = _totalBlue - _insideBlue;
			{
				if (_x in _outsideBlack) then
				{
					_x setDamage (damage _x + (1/3));
					_x setVariable ["outsideBlackZone",false,false];
					BR_DT_PVAR = ["YOU ARE OUTSIDE THE<br/><t color='#000000'>BLACK ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.7,(_zoneDamageDuration / 2),0];
					(owner _x) publicVariableClient "BR_DT_PVAR";
					_x setVariable ["outsideBlackZone",false];
				}
				else
				{
					_x setDamage (damage _x + (1/5));
					_x setVariable ["outsideBlueZone",true,false];
					BR_DT_PVAR = ["YOU ARE OUTSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.7,(_zoneDamageDuration / 2),0];
					(owner _x) publicVariableClient "BR_DT_PVAR";
					_x setVariable ["outsideBlueZone",true];
				};
			} forEach _outsideBlue;
			///////////////////////////////////////////////////////////////////////////////////////////
		}
		else
		{
			{
				_x setDamage (damage _x + (1/3));
				_x setVariable ["outsideBlackZone",true,false];
				BR_DT_PVAR = ["YOU ARE OUTSIDE THE<br/><t color='#000000'>BLACK ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.7,(_zoneDamageDuration / 2),0];
				(owner _x) publicVariableClient "BR_DT_PVAR";
				_x setVariable ["outsideBlackZone",true];
			} forEach _outsideBlack;
		};
		_zoneNextCheckTicks = _ticksRound + _zoneDamageDuration;
	};

	_isZoneLock = _ticksTillZoneLock <= 0;
	if (_isZoneLock) then
	{
		_ticksTillZoneLock = _zoneChangeTicks;
		_zoneCenter = _zoneCenterNext;
		_zoneSizeScaleChange = (_zoneSize*_zoneSizeScaling);
		_zoneSize = _zoneSize - _zoneSizeScaleChange;
		///////////////////////////////////////////////////////////////////////////////////////////
		_blueMarker setMarkerBrush "SOLIDBORDER";
		_blueMarker setMarkerAlpha 1;
		_blueMarker setMarkerText "BLUE ZONE IS LOCKED!";
		///////////////////////////////////////////////////////////////////////////////////////////
		BR_DT_PVAR = ["PLAY IS NOW RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,_messageOnScreenDuration,0];
		publicVariable "BR_DT_PVAR";
		_zoneLock = true;
		uiSleep _messageOnScreenDuration;
		///////////////////////////////////////////////////////////////////////////////////////////
	}
	else
	{
		if (!_zoneStop) then
		{

			[_ticksTillZoneLock] call _timingText;
			
			if (_ticksTillZoneLock == round(_zoneChangeTicks / 2)) then
			{
				_zoneSizeScaleChange = (_zoneSize*_zoneSizeScaling);
				_zoneSizeNext = _zoneSize - _zoneSizeScaleChange;
				_zoneCenterNext = [(_zoneCenter select 0) + floor(random(_zoneSizeScaleChange*2)-(_zoneSizeScaleChange)),(_zoneCenter select 1) + floor(random(_zoneSizeScaleChange*2)-(_zoneSizeScaleChange)),0];
				///////////////////////////////////////////////////////////////////////////////////////////
				_blueMarker setMarkerPos _zoneCenterNext;
				_blueMarker setMarkerSize [_zoneSizeNext,_zoneSizeNext];
				_blueMarker setMarkerBrush "BORDER";
				_blueMarker setMarkerAlpha 1;
				_blueMarker setMarkerText "BLUE ZONE IS UNLOCKED!";
				///////////////////////////////////////////////////////////////////////////////////////////
				uiSleep (_messageOnScreenDuration / 4);
				BR_DT_PVAR = ["YOUR MAP HAS BEEN UPDATED WITH THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,_messageOnScreenDuration,0];
				publicVariable "BR_DT_PVAR";
				uiSleep (_messageOnScreenDuration / 2);
				BR_DT_PVAR = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
				uiSleep (_messageOnScreenDuration / 2);
			};
			if (_ticksTillZoneLock == round(_zoneChangeTicks / 4)) then
			{
				BR_DT_PVAR = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
				uiSleep (_messageOnScreenDuration / 2);
			};
			if (_ticksTillZoneLock == round(_zoneChangeTicks / 8)) then
			{
				BR_DT_PVAR = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
				uiSleep (_messageOnScreenDuration / 2);
			};
			if (_ticksTillZoneLock <= 10) then
			{
				BR_DT_PVAR = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.7,1,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
			};
		};
	};
	_ticksTillRoundLeft = (_ticksRoundMax-_ticksRound);
	if ((_ticksTillRoundLeft <= _zoneChangeTicks) && _zoneLock) then
	{
		_ticksTillZoneLock = _zoneChangeTicks;
		_zoneStop = true;
		
		[_ticksTillRoundLeft] call _timingText;
		
		if (_ticksTillRoundLeft == round(_zoneChangeTicks)) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
			publicVariable "BR_DT_PVAR";
			uiSleep (_messageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 2)) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
			publicVariable "BR_DT_PVAR";
			uiSleep (_messageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 4)) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
			publicVariable "BR_DT_PVAR";
			uiSleep (_messageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 6)) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
			publicVariable "BR_DT_PVAR";
			uiSleep (_messageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 8)) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,_messageOnScreenDuration,0];
			publicVariable "BR_DT_PVAR";
			uiSleep (_messageOnScreenDuration / 2);
		};
		if ((_ticksTillRoundLeft <= 10) && (!(_ticksRoundMax == _ticksRound))) then
		{
			BR_DT_PVAR = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.7,1,0];
			publicVariable "BR_DT_PVAR";
		};
		if (_ticksRoundMax == _ticksRound) then
		{
			BR_DT_PVAR = ["<t color='#FF0000'>THE GAME ROUND IS OVER</t>",0,0.7,(_messageOnScreenDuration * 2),0];
			uiSleep (_messageOnScreenDuration * 2);
			publicVariable "BR_DT_PVAR";
		};
	};
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	uiSleep _loopSleepTime;
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	_endTicks = (round(diag_TickTime) - _ticksRoundInit);
	_ticksLoopExec = round(_endTicks - _ticksRound);
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	// diag_log format ["--- ZONING ->>> _ticksRoundMax = %1, _ticksRound = %2, _ticksLoopExec = %3, _zoneChangeTicks = %4, _ticksTillZoneLock = %5, _zoneNextCheckTicks = %6 <<<- ZONING ---",_ticksRoundMax,_ticksRound,_ticksLoopExec,_zoneChangeTicks,_ticksTillZoneLock,_zoneNextCheckTicks];
	///////////////////////////////////////////////////////////////////////////////////////////////////	
};
///////////////////////////////////////////////////////////////////////////////////////////////////
BR_DT_PVAR = ["",0,0,1,0]; // CLEARS THE TEXT ON THE SCREEN WHEN DEAD/TELEPORTED BACK TO SPAWN ZONE
publicVariable "BR_DT_PVAR";
uiSleep	_messageOnScreenDuration;
///////////////////////////////////////////////////////////////////////////////////////////////////
BRMini_InGame = false;
diag_log format ["<BRMINI>: %1 ROUND ENDED!",BRMini_CurrZoneName];
///////////////////////////////////////////////////////////////////////////////////////////////////
deleteMarker _blueMarker;
