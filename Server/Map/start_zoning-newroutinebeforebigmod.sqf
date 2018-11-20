/*
	File: start_zoning.sqf
	Description: BRGH Blue and Black Zoning System
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

_roundMinutes = 30; // was 20
_roundZoneChanges = 6; // was 7

_zoneSizeScaling = 35;
_zoneDamageDuration = 10;

// DO NOT CHANGE ANYTHING BELOW!
///////////////////////////////////////////////////////////////////////////////////////////////////

_roundSeconds = (_roundMinutes * 60);
_changeTime = round (_roundSeconds / _roundZoneChanges);
_zoneCenter = (getMarkerPos BRMini_CurrZone);
_nextZoneCenter = [0,0,0];
_zoneLock = false;
_zoneJustUpdated = true;

_blueMarker = "";
_tempMarker = "";

_zoneSize = BRMini_ZoneSize;

if (_zoneSizeScaling >= 1) then
{
	_zoneSizeScaling = _zoneSizeScaling / 100; 
};
_timeTillChange = _changeTime;
_sleepTime = 0; // init sleep time

// _time = time;
// diag_log format ["--- ZONING START ->>>_TIME IS %1 && TIME IS %2 <<<- ZONING START ---",_time,time];
///////////////////////////////////////////////////////////////////////////////////////////////////
// for "_i" from 1 to _roundMinutes do
// while {(time < _time)} do

_loopTicks = 0;
_initTicks = round(diag_tickTime);

/// LOOP INDEFINITLY FOR THE TIME BEING...
while {(BRMini_InGame)} do
{
	///////////////////////////////////////////////////////////////////////////////////////////////////
	_roundTicks = (round(diag_TickTime) - _initTicks); // SECONDS PASSED SINCE INITIATION
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	_timeTillChange = _timeTillChange - _loopTicks - _sleepTime; // CORRECT CALCULATION
	_sleepTime = 0; // reset sleep time each loop
	_nextZoneCheckTime = _roundTicks + _zoneDamageDuration;
	///////////////////////////////////////////////////////////////////////////////////////////////////
	if (BRMini_InGame) then
	{
		/// TOTAL /////////////////////////////////////////////////////////////////////////////////
		// COMPILE A LIST OF ALL PLAYERS RELATIVE TO THE CURRENT ZONE SIZE * 2
		_total = [];
		{
			if (isPlayer _x && alive _x) then
			{
				_total set [count(_total),_x];
			};
		} forEach (_zoneCenter nearObjects ["Man",(_zoneSize * 2)]);
		////////////////////////////////////////////////////////////////////////////////////////////
		/// INSIDE /////////////////////////////////////////////////////////////////////////////////
		/// COMPILE A LIST OF PLAYERS INSIDE THE CURRENT ZONE + 1 METER (FOR CLEARANCE)
		_inside = [];
		{
			if (isPlayer _x && alive _x) then
			{
				_inside set [count(_inside),_x];
			};
		} forEach (_zoneCenter nearObjects ["Man",(_zoneSize + 1)]);
		///////////////////////////////////////////////////////////////////////////////////////////
		/// OUTSIDE ///////////////////////////////////////////////////////////////////////////////
		/// SUBTRACT THE PLAYERS INSIDE THE ZONE FROM THE TOTAL, WHICH LEAVES ALL PLAYERS CURRENTLY OUTSIDE THE ZONE
		_outside = _total - _inside;
		///////////////////////////////////////////////////////////////////////////////////////////
		// CHECK IF OUTSIDE, IF SO, DAMAGE
		if (!_zoneJustUpdated) then
		{
			{
				_x setDamage (damage _x + (1/5));
				_x setVariable ["outside",true,false];
				BR_DT_PVAR = ["YOU ARE OUTSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.7,(_zoneDamageDuration / 2),0];
				(owner _x) publicVariableClient "BR_DT_PVAR";
				_x setVariable ["outside",true];
			} forEach _outside;
		};
		///////////////////////////////////////////////////////////////////////////////////////////
		if (_roundTicks >= _nextZoneCheckTime) then
		{
			if (_zoneLock) then
			{
				///////////////////////////////////////////////////////////////////////////////////////////
				/// TOTAL
				_total = [];
				{
					if (isPlayer _x && alive _x) then
					{
						_total set [count(_total),_x];
						
					};
				} forEach (_zoneCenter nearObjects ["Man",(_zoneSize * 2)]);
				///////////////////////////////////////////////////////////////////////////////////////////
				/// INSIDE
				_inside = [];
				{
					if (isPlayer _x && alive _x) then
					{
						_inside set [count(_inside),_x];
						_x setVariable ["outside",false,false];
						_x setVariable ["outside",false];
						
					};
				} forEach (_zoneCenter nearObjects ["Man",(_zoneSize + 1)]);
				///////////////////////////////////////////////////////////////////////////////////////////
				/// OUTSIDE
				_outside = _total - _inside;
				
				///////////////////////////////////////////////////////////////////////////////////////////
				/// SET NEXT TIME TO CHECK IF OUTSIDE THE ZONE
				_nextZoneCheckTime = _roundTicks + _zoneDamageDuration;
				///////////////////////////////////////////////////////////////////////////////////////////
				// CHECK IF OUTSIDE, IF SO, DAMAGE
				{
					_x setDamage (damage _x + (1/5));
					_x setVariable ["outside",true,false];
					BR_DT_PVAR = ["YOU ARE OUTSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.7,(_zoneDamageDuration / 2),0];
					(owner _x) publicVariableClient "BR_DT_PVAR";
					_x setVariable ["outside",true];
				} forEach _outside;
				///////////////////////////////////////////////////////////////////////////////////////////
			};
		};
	};
///////////////////////////////////////////////////////////////////////////////////////////////////
	if (BRMini_InGame) then
	{
		_isZoneChange = _timeTillChange == 0;
		// if (_roundTicks <= _changeTime) then
		if (_timeTillChange <= _changeTime) then
		{
			if (_isZoneChange) then
			{
				_zoneCenter = _nextZoneCenter;
				_zoneSize = _zoneSize - (_zoneSize*_zoneSizeScaling);
				///////////////////////////////////////////////////////////////////////////////////////////
				_blueMarker = createMarker ["BLUEMARKER",_zoneCenter];
				_blueMarker setMarkerColor "ColorBlue";
				_blueMarker setMarkerShape "ELLIPSE";
				_blueMarker setMarkerBrush "BORDER";
				_blueMarker setMarkerSize [_zoneSize,_zoneSize];
				///////////////////////////////////////////////////////////////////////////////////////////
				deleteMarker _tempMarker;
				///////////////////////////////////////////////////////////////////////////////////////////
				BRMini_ZoneStarted = true;
				publicVariable "BRMini_ZoneStarted";
				BR_DT_PVAR = ["PLAY IS NOW RESTRICTED<br/>TO THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,_zoneDamageDuration,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = true;
				_zoneJustUpdated = false;
				uiSleep _zoneDamageDuration; _sleepTime = _sleepTime + _zoneDamageDuration;
			}
			else
			{
				if (_timeTillChange == round (_changeTime / 2)) then // if time till change == 150
				{
				
					_scaleChange = (_zoneSize*_zoneSizeScaling);
					_tempSize = _zoneSize - _scaleChange;
					_nextZoneCenter = [(_zoneCenter select 0) + floor(random(_scaleChange*2)-(_scaleChange)),(_zoneCenter select 1) + floor(random(_scaleChange*2)-(_scaleChange)),0];
					///////////////////////////////////////////////////////////////////////////////////////////
					_tempMarker = createMarker ["TEMPMARKER",_nextZoneCenter];
					_tempMarker setMarkerColor "ColorBlue";
					_tempMarker setMarkerShape "ELLIPSE";
					_tempMarker setMarkerBrush "BORDER";
					_tempMarker setMarkerSize [_tempSize,_tempSize];
					///////////////////////////////////////////////////////////////////////////////////////////
					/// IN GAME BLUE ZONE
					// _steps = floor ((2 * pi * _tempSize) / 15);
					// _radStep = 360 / _steps;
					// _data = [];
					// for [{_j = 0}, {_j < 360}, {_j = _j + _radStep}] do {
						// _pos2 = [_nextZoneCenter, _tempSize, _j] call BIS_fnc_relPos;
						// _pos2 set [2, 0];
						// _data set[count(_data),["UserTexture10m_F",_pos2,_j,"#(argb,8,8,3)color(0,0,1,0.4)"]];
						// _data set[count(_data),["UserTexture10m_F",_pos2,(_j + 180),"#(argb,8,8,3)color(0,0,1,0.4)"]];
					// };
					// BR_DRAWZONE = _data;
					// publicVariable "BR_DRAWZONE";
					///////////////////////////////////////////////////////////////////////////////////////////
					uiSleep 3; _sleepTime = _sleepTime + 3;
					BR_DT_PVAR = ["YOUR MAP HAS BEEN UPDATED WITH THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
					uiSleep 5; _sleepTime = _sleepTime + 5;
					BR_DT_PVAR = [format["IN %1 MINUTES THE PLAY AREA<br/>WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",(_timeTillChange / 60)],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
					_zoneLock = false;
					_zoneJustUpdated = true;
				};
				if (_timeTillChange == round (_changeTime / 4) then // if time till change == 75
				{
					BR_DT_PVAR = [format["IN %1 SECONDS<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_timeTillChange],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
					_zoneLock = false;
					_zoneJustUpdated = false;
				};
			};
		}
		else
		{
			///////////////////////////////////////////////////////////////////////////////////////////////////
		//	IF (secondspassed <= (1800 - 300)) THEN
			// if (_time <= (_roundSeconds-_changeTime)) then
			if (_roundTicks <= (_roundSeconds-_changeTime)) then
			{
				// IF SECONDS ARE LESS THAN OR EQUAL TO 1500 (1800 - 300)
				if (_isZoneChange) then
				{
					// IF TIMETILLCHANGE == 0
					_zoneCenter = _nextZoneCenter;
					_zoneSize = _zoneSize - (_zoneSize*_zoneSizeScaling);
					_blueMarker setMarkerPos _zoneCenter;
					_blueMarker setMarkerSize [_zoneSize,_zoneSize];
					// _blueMarker setMarkerColor "ColorBlue";
					_blueMarker setMarkerAlpha 1;
					///////////////////////////////////////////////////////////////////////////////////////////
					deleteMarker _tempMarker;
					BR_DT_PVAR = ["PLAY IS NOW RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,_zoneDamageDuration,0];
					publicVariable "BR_DT_PVAR";
					_zoneLock = true;
					_zoneJustUpdated = false;
					uiSleep _zoneDamageDuration; _sleepTime = _sleepTime + _zoneDamageDuration;
				}
				else
				{
					if (_timeTillChange == round (_changeTime / 2)) then // IF TIMETILLCHANGE = 150
					{
						_scaleChange = (_zoneSize*_zoneSizeScaling);
						_tempSize = _zoneSize - _scaleChange;
						_nextZoneCenter = [(_zoneCenter select 0) + floor(random(_scaleChange*2)-(_scaleChange)),(_zoneCenter select 1) + floor(random(_scaleChange*2)-(_scaleChange)),0];
						///////////////////////////////////////////////////////////////////////////////////////////
						_tempMarker = createMarker ["TEMPMARKER",_nextZoneCenter];
						_tempMarker setMarkerColor "ColorBlue";
						_tempMarker setMarkerShape "ELLIPSE";
						_tempMarker setMarkerBrush "BORDER";
						_tempMarker setMarkerSize [_tempSize,_tempSize];
						///////////////////////////////////////////////////////////////////////////////////////////
						_blueMarker setMarkerAlpha 0;
						// _blueMarker setMarkerColor "ColorBlack";
						///////////////////////////////////////////////////////////////////////////////////////////
						/// IN GAME BLUE ZONE
						// _steps = floor ((2 * pi * _tempSize) / 15);
						// _radStep = 360 / _steps;
						// _data = [];
						// for [{_j = 0}, {_j < 360}, {_j = _j + _radStep}] do {
							// _pos2 = [_nextZoneCenter, _tempSize, _j] call BIS_fnc_relPos;
							// _pos2 set [2, 0];
							// _data set[count(_data),["UserTexture10m_F",_pos2,_j,"#(argb,8,8,3)color(0,0,1,0.4)"]];
							// _data set[count(_data),["UserTexture10m_F",_pos2,(_j + 180),"#(argb,8,8,3)color(0,0,1,0.4)"]];
						// };
						// BR_DRAWZONE = _data;
						// publicVariable "BR_DRAWZONE";
						///////////////////////////////////////////////////////////////////////////////////////////
						uiSleep 3; _sleepTime = _sleepTime + 3;
						BR_DT_PVAR = ["YOUR MAP HAS BEEN UPDATED WITH THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,10,0];
						publicVariable "BR_DT_PVAR";
						uiSleep 5; _sleepTime = _sleepTime + 5;
						BR_DT_PVAR = [format["IN %1 MINUTES<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",(_timeTillChange / 60)],0,0.7,10,0];
						publicVariable "BR_DT_PVAR";
						_zoneLock = false;
						_zoneJustUpdated = true;
					};
					if (_timeTillChange == round(_changeTime / 4)) then // IF TIMETILLCHANGE == 75
					{
						BR_DT_PVAR = [format["IN %1 SECONDS<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_timeTillChange],0,0.7,10,0];
						publicVariable "BR_DT_PVAR";
						_zoneLock = false;
						_zoneJustUpdated = false;
					};
				};
			}
			else
			{
				// IF SECONDS ARE HIGHER THAN 1500 (1800 - 300)
				_ticksLeft = (_roundSeconds-_changeTime);
				_ticksLeftText = "SECONDS";
				if (_ticksLeft > 60) then
				{
					_ticksLeft = (_secondsLeft / 60);
					_ticksLeftText = "MINUTES";
				};
				if (_roundTicks == (_roundSeconds-_changeTime)) then // 1800 - 300 == 1500 = 300 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
				if (_roundTicks == (_roundSeconds-(_changeTime / 2 ))) then // 1800 - 150 = 1650 = 150 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
				if (_roundTicks == (_roundSeconds-(_changeTime / 4 ))) then // 1800 - 75 = 1725 = 75 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
				if (_roundTicks == (_roundSeconds-(_changeTime / 6 ))) then // 1800 - 50 = 1750 = 50 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
				if (_roundTicks == (_roundSeconds-(_changeTime / 8 ))) then // 1800 - 37.5 = 1762.5 = 37.5 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
				if (_roundTicks == (_roundSeconds-(_changeTime / 10 ))) then // 1800 - 30 = 1770 = 30 seconds left
				{
					BR_DT_PVAR = [format["THERE ARE %1 %2 LEFT IN THE ROUND!",_ticksLeft,_ticksLeftText],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
			};
		};
		if (_isZoneChange) then
		{
			_timeTillChange = _changeTime;
		};
	};
	_endTicks = (round(diag_TickTime) - _initTicks);
	_loopTicks = round(_endTicks - _roundTicks);

	diag_log format ["--- ZONING ->>> _roundSeconds = %1, _roundTicks = %2, _loopTicks = %3, _changeTime = %4, _timeTillChange = %5 <<<- ZONING ---",_roundSeconds,_roundTicks,_loopTicks,_changeTime,_timeTillChange];
	
	///////////////////////////////////////////////////////////////////////////////////////////////////	
	// diag_log format ["--- ZONING ->>> SLEEPING %1 SECOND(S) <<<- ZONING ---",(60 - _loopTicks)];
	// uiSleep (60 - _loopTicks);
};
///////////////////////////////////////////////////////////////////////////////////////////////////
BRMini_InGame = false;
///////////////////////////////////////////////////////////////////////////////////////////////////
BR_DT_PVAR = ["",0,0,1,0]; // CLEARS THE TEXT ON THE SCREEN WHEN DEAD/TELEPORTED BACK TO SPAWN ZONE
publicVariable "BR_DT_PVAR";
///////////////////////////////////////////////////////////////////////////////////////////////////
diag_log "<BRMINI>: ROUND ENDED!";
///////////////////////////////////////////////////////////////////////////////////////////////////
deleteMarker _blueMarker;
deleteMarker _tempMarker;