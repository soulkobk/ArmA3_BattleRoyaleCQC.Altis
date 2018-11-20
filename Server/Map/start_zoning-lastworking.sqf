/*
	File: start_zoning.sqf
	Description: BRGH Blue and Black Zoning System
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

_minutes = 30; // was 20
_zoneChange = 6; // was 7
_changeTime = round (_minutes / _zoneChange);

_zoneCenter = (getMarkerPos BRMini_CurrZone);

_nextZoneCenter = [0,0,0];
_zoneLock = false;
_zoneJustUpdated = true;
	
_zoneSizeScaling = 35;

_zoneDamageDuration = 10;

_blueMarker = "";
_tempMarker = "";

_zoneSize = BRMini_ZoneSize;

if (_zoneSizeScaling >= 1) then
{
	_zoneSizeScaling = _zoneSizeScaling / 100; 
};
_timeTillChange = _changeTime;
_sleepTime = 0; // init sleep time

_startTime = round(diag_tickTime);
for "_i" from 1 to _minutes do
{
_endTime = round(diag_tickTime);
_totalTime = round(_endTime - _startTime);
diag_log format ["--- ZONING ->>> %1 MINUTE ROUND TIME, %2 MINUTES PASSED <<<- ZONING ---",_minutes,_i];
	_timeTillChange = _timeTillChange - 1;
	_time = ((time + 60) - _sleepTime); // sleeptime is in seconds
	_sleepTime = 0; // reset sleep time each loop
	_nextTime = time + _zoneDamageDuration;
	
	/// TOTAL /////////////////////////////////////////////////////////////////////////////////
	_total = [];
	{
		if (isPlayer _x && alive _x) then
		{
			_total set [count(_total),_x];
		};
	} forEach (_zoneCenter nearObjects ["Man",(_zoneSize * 2)]);
	////////////////////////////////////////////////////////////////////////////////////////////
	/// INSIDE ////////////////////////////////////////////////////////////////////////////////
	_inside = [];
	{
		if (isPlayer _x && alive _x) then
		{
			_inside set [count(_inside),_x];
		};
	} forEach (_zoneCenter nearObjects ["Man",(_zoneSize + 0.75)]);
	///////////////////////////////////////////////////////////////////////////////////////////
	/// OUTSIDE ///////////////////////////////////////////////////////////////////////////////
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
	while{true} do {
		if (time >= _time) exitWith {};
		if (!BRMini_InGame) exitWith {};
		if (time >= _nextTime) then
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
				} forEach (_zoneCenter nearObjects ["Man",(_zoneSize + 0.75)]);
				///////////////////////////////////////////////////////////////////////////////////////////
				/// OUTSIDE
				_outside = _total - _inside;
				
				_nextTime = time + _zoneDamageDuration;
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
	if (!BRMini_InGame) exitWith {};
	_isZoneChange = _timeTillChange == 0;
	if (_i <= _changeTime) then
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
			BR_DT_PVAR = ["PLAY IS NOW RESTRICTED<br/>TO THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,10,0];
			publicVariable "BR_DT_PVAR";
			_zoneLock = true;
			_zoneJustUpdated = false;
			uiSleep 10; _sleepTime = _sleepTime + 10;
		} else {
			if (_timeTillChange == round (_changeTime / 2)) then
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
				BR_DT_PVAR = [format["IN %1 MINUTES THE PLAY AREA<br/>WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_timeTillChange],0,0.7,10,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
				_zoneJustUpdated = true;
			};
			if (_timeTillChange == round ((_changeTime / 2) / 2)) then
			{
				BR_DT_PVAR = [format["IN %1 SECONDS<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",(_timeTillChange * 60)],0,0.7,10,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = false;
				_zoneJustUpdated = false;
			};
		};
	} else {
		if (_i <= (_minutes-_changeTime)) then
		{
			if (_isZoneChange) then
			{
				_zoneCenter = _nextZoneCenter;
				_zoneSize = _zoneSize - (_zoneSize*_zoneSizeScaling);
				_blueMarker setMarkerPos _zoneCenter;
				_blueMarker setMarkerSize [_zoneSize,_zoneSize];
				// _blueMarker setMarkerColor "ColorBlue";
				_blueMarker setMarkerAlpha 1;
				///////////////////////////////////////////////////////////////////////////////////////////
				deleteMarker _tempMarker;
				BR_DT_PVAR = ["PLAY IS NOW RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.7,10,0];
				publicVariable "BR_DT_PVAR";
				_zoneLock = true;
				_zoneJustUpdated = false;
				uiSleep 10; _sleepTime = _sleepTime + 10;
			} else {
				if (_timeTillChange == round (_changeTime / 2)) then
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
					BR_DT_PVAR = [format["IN %1 MINUTES<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_timeTillChange],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
					_zoneLock = false;
					_zoneJustUpdated = true;
				};
				if (_timeTillChange == round ((_changeTime / 2) / 2)) then
				{
					BR_DT_PVAR = [format["IN %1 SECONDS<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",(_timeTillChange * 60)],0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
					_zoneLock = false;
					_zoneJustUpdated = false;
				};
			};
		} else {
			if (_i < (_minutes-1)) then
			{
				BR_DT_PVAR = [format["THERE ARE %1 MINUTES LEFT IN THE ROUND!",_changeTime - _timeTillChange],0,0.7,10,0];
				publicVariable "BR_DT_PVAR";
			} else {
				if (_i != _minutes) then
				{
					BR_DT_PVAR = ["THERE IS 60 SECONDS LEFT IN THE ROUND!",0,0.7,10,0];
					publicVariable "BR_DT_PVAR";
				};
			};
		};
	};
	if (_isZoneChange) then
	{
		_timeTillChange = _changeTime;
	};
};
BRMini_InGame = false;
BR_DT_PVAR = ["",0,0.7,2,0]; // CLEARS THE TEXT ON THE SCREEN WHEN DEAD/TELEPORTED BACK TO SPAWN ZONE
publicVariable "BR_DT_PVAR";
diag_log "<BRMINI>: ROUND ENDED!";
deleteMarker _blueMarker;
deleteMarker _tempMarker;