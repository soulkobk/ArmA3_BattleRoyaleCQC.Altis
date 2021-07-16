// fn_zoningInit.sqf 13:12 PM 14/07/2021

if (!isServer) exitWith {};

_ticksLootMax = (BRCQC_var_zoneLootMinutes * 60);
_ticksRoundMax = (BRCQC_var_zoneRoundMinutes * 60);

_zoneCenter = (getMarkerPos BRCQC_mkr_blackZone);

_zoneChangeTicks = round(_ticksRoundMax / BRCQC_var_zoneNumChanges);
_zoneSize = BRCQC_var_playZoneSize;
_zoneCenterNext = [0,0,0];
_zoneLock = false;
_zoneStop = false;
_zoneNextCheckTicks = 0;

_zoneAnnounce8 = false;
_zoneAnnounce6 = false;
_zoneAnnounce4 = false;
_zoneAnnounce2 = false;

BRCQC_mkr_blueZone = createMarker ["BRCQC_mkr_blueZone",_zoneCenter];
BRCQC_mkr_blueZone setMarkerColor "ColorBlue";
BRCQC_mkr_blueZone setMarkerShape "ELLIPSE";
BRCQC_mkr_blueZone setMarkerBrush "SOLIDBORDER";
BRCQC_mkr_blueZone setMarkerPos _zoneCenter;
BRCQC_mkr_blueZone setMarkerSize [_zoneSize,_zoneSize];
BRCQC_mkr_blueZone setMarkerAlpha 0;

_ticksTillZoneLock = _zoneChangeTicks;
_ticksTillRoundLeft = _ticksRoundMax;
_ticksLoopExec = 0;
_ticksLoot = 0;
_ticksRound = 0;

if (BRCQC_var_zoneSizeMetersScaling >= 1) then
{
	BRCQC_var_zoneSizeMetersScaling = BRCQC_var_zoneSizeMetersScaling / 100; 
};

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

_ticksLootInit = round(diag_tickTime);
while {(_ticksLoot < _ticksLootMax) && BRCQC_var_playZoneInProgress} do
{
	_ticksLoot = (round(diag_TickTime) - _ticksLootInit);
	if (_ticksLoot >= _zoneNextCheckTicks) then
	{
		_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
		_playZonePlayersNum = count _playZonePlayers;
		if (_playZonePlayersNum <= 1) exitWith {BRCQC_var_playZoneInProgress = false};
		{
			if !(_x inArea BRCQC_mkr_blackZone) then
			{
				_x setDamage (damage _x + (1/3));
				_x setVariable ["outsideBlackZone",true,false];
				BRCQC_pve_dynamicText = ["YOU ARE OUTSIDE THE<br/><t color='#000000'>BLACK ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.45,(BRCQC_var_zoneDamageDuration / 2),0];
				if (isServer && hasInterface) then {if ((alive player) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"};
			};
		} forEach _playZonePlayers;
		_zoneNextCheckTicks = _ticksLoot + BRCQC_var_zoneDamageDuration;
	};
	uiSleep BRCQC_var_zoneLoopSleep;
	_endTicks = (round(diag_TickTime) - _ticksLootInit);
	_ticksLoopExec = round(_endTicks - _ticksLoot);
};

_ticksRoundInit = round(diag_tickTime);
while {(_ticksRound < _ticksRoundMax) && BRCQC_var_playZoneInProgress} do
{
	_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
	_playZonePlayersNum = count _playZonePlayers;
	if (_playZonePlayersNum <= 1) exitWith {BRCQC_var_playZoneInProgress = false};

	_ticksRound = (round(diag_TickTime) - _ticksRoundInit);
	_ticksTillZoneLock = _ticksTillZoneLock - _ticksLoopExec;
	if (_ticksRound >= _zoneNextCheckTicks) then
	{
		_totalGreen = [];
		_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
		{
			_totalGreen set [count(_totalGreen),_x];
		} forEach _playZonePlayers;
		_insideBlack = [];
		_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_blackZone)};
		{
			_insideBlack set [count(_insideBlack),_x];
			_x setVariable ["outsideBlackZone",false,false];
		} forEach _playZonePlayers;
		_outsideBlack = _totalGreen - _insideBlack;
		if (_zoneLock) then
		{
			_totalGreen = [];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			{
				_totalGreen set [count(_totalGreen),_x];
			} forEach _playZonePlayers;
			_insideBlue = [];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_blueZone)};
			{
				_insideBlue set [count(_insideBlue),_x];
				_x setVariable ["outsideBlueZone",false,false];
			} forEach _playZonePlayers;
			_outsideBlue = _totalGreen - _insideBlue;
			{
				if (_x in _outsideBlack) then
				{
					_x setDamage (damage _x + (1/3));
					_x setVariable ["outsideBlackZone",false,false];
					BRCQC_pve_dynamicText = ["YOU ARE OUTSIDE THE<br/><t color='#000000'>BLACK ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.45,(BRCQC_var_zoneDamageDuration / 2),0];
					if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"};
				}
				else
				{
					_x setDamage (damage _x + (1/5));
					_x setVariable ["outsideBlueZone",true,false];
					BRCQC_pve_dynamicText = ["YOU ARE OUTSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.45,(BRCQC_var_zoneDamageDuration / 2),0];
					if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"};
				};
			} forEach _outsideBlue;
		}
		else
		{
			{
				_x setDamage (damage _x + (1/3));
				_x setVariable ["outsideBlackZone",true,false];
				BRCQC_pve_dynamicText = ["YOU ARE OUTSIDE THE<br/><t color='#000000'>BLACK ZONE!</t><br/>MOVE INSIDE NOW!<br/><br/><t color='#ff0000'>*DAMAGE INFLICTED*</t>",0,0.45,(BRCQC_var_zoneDamageDuration / 2),0];
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"};
			} forEach _outsideBlack;
		};
		_zoneNextCheckTicks = _ticksRound + BRCQC_var_zoneDamageDuration;
	};

	_isZoneLock = _ticksTillZoneLock <= 0;
	if (_isZoneLock) then
	{
		_ticksTillZoneLock = _zoneChangeTicks;
		_zoneCenter = _zoneCenterNext;
		_zoneSizeScaleChange = (_zoneSize * BRCQC_var_zoneSizeMetersScaling);
		_zoneSize = _zoneSize - _zoneSizeScaleChange;

		BRCQC_mkr_blueZone setMarkerBrush "SOLIDBORDER";
		BRCQC_mkr_blueZone setMarkerAlpha 1;
		BRCQC_mkr_blueZone setMarkerText "BLUE ZONE IS LOCKED!";

		BRCQC_pve_dynamicText = ["PLAY IS NOW RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
		_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
		if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		
		_zoneLock = true;
		_zoneAnnounce8 = false;
		_zoneAnnounce6 = false;
		_zoneAnnounce4 = false;
		_zoneAnnounce2 = false;
		
		uiSleep BRCQC_var_zoneMessageOnScreenDuration;
	}
	else
	{
		if (!_zoneStop) then
		{
			[_ticksTillZoneLock] call _timingText;

			if ((_ticksTillZoneLock <= round(_zoneChangeTicks / 2)) && !_zoneAnnounce2) then
			{
				_zoneSizeScaleChange = (_zoneSize*BRCQC_var_zoneSizeMetersScaling);
				_zoneSizeNext = _zoneSize - _zoneSizeScaleChange;
				_zoneCenterNext = [(_zoneCenter select 0) + floor(random(_zoneSizeScaleChange*2)-(_zoneSizeScaleChange)),(_zoneCenter select 1) + floor(random(_zoneSizeScaleChange*2)-(_zoneSizeScaleChange)),0];

				BRCQC_mkr_blueZone setMarkerPos _zoneCenterNext;
				BRCQC_mkr_blueZone setMarkerSize [_zoneSizeNext,_zoneSizeNext];
				BRCQC_mkr_blueZone setMarkerBrush "SOLIDBORDER";
				BRCQC_mkr_blueZone setMarkerAlpha 0.25;
				BRCQC_mkr_blueZone setMarkerText "BLUE ZONE IS UNLOCKED!";

				uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 4);

				BRCQC_pve_dynamicText = ["YOUR MAP HAS BEEN UPDATED WITH THE<br/><t color='#0000ff'>BLUE ZONE!</t>",0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
				_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};

				uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);

				BRCQC_pve_dynamicText = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
				_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};

				_zoneLock = false;
				_zoneAnnounce2 = true;

				uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
			};
			if ((_ticksTillZoneLock <= round(_zoneChangeTicks / 4)) && !_zoneAnnounce4) then
			{
				BRCQC_pve_dynamicText = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
				_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				
				_zoneLock = false;
				_zoneAnnounce4 = true;
				
				uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
			};
			if ((_ticksTillZoneLock <= round(_zoneChangeTicks / 8)) && !_zoneAnnounce8) then
			{
				BRCQC_pve_dynamicText = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
				_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				
				_zoneLock = false;
				_zoneAnnounce8 = true;
				
				uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
			};
			if (_ticksTillZoneLock <= 10) then
			{
				BRCQC_pve_dynamicText = [format["IN %1 %2<br/>PLAY WILL BE RESTRICTED<br/>TO INSIDE THE<br/><t color='#0000ff'>BLUE ZONE!</t>",_secMinTicks,_secMinText],0,0.45,1,0];
				_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				
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
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};

			uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 2)) then
		{
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			
			uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 4)) then
		{
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			
			uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 6)) then
		{
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			
			uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
		};
		if (_ticksTillRoundLeft == round(_zoneChangeTicks / 8)) then
		{
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,BRCQC_var_zoneMessageOnScreenDuration,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			
			uiSleep (BRCQC_var_zoneMessageOnScreenDuration / 2);
		};
		if ((_ticksTillRoundLeft <= 10) && (!(_ticksRoundMax == _ticksRound))) then
		{
			BRCQC_pve_dynamicText = [format["THERE %1<br/>%2 %3<br/>LEFT IN THE ROUND!",_isAreText,_secMinTicks,_secMinText],0,0.45,1,0];
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
		if (_ticksRoundMax == _ticksRound) then
		{
			BRCQC_pve_dynamicText = ["<t color='#FF0000'>THE GAME ROUND IS OVER</t>",0,0.45,(BRCQC_var_zoneMessageOnScreenDuration * 2),0];
			uiSleep (BRCQC_var_zoneMessageOnScreenDuration * 2);
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
	};
	uiSleep BRCQC_var_zoneLoopSleep;
	_endTicks = (round(diag_TickTime) - _ticksRoundInit);
	_ticksLoopExec = round(_endTicks - _ticksRound);
	// diag_log format ["--- ZONING ->>> _ticksRoundMax = %1, _ticksRound = %2, _ticksLoopExec = %3, _zoneChangeTicks = %4, _ticksTillZoneLock = %5, _zoneNextCheckTicks = %6 <<<- ZONING ---",_ticksRoundMax,_ticksRound,_ticksLoopExec,_zoneChangeTicks,_ticksTillZoneLock,_zoneNextCheckTicks];
};

BRCQC_pve_dynamicText = ["",0,0,1,0]; // CLEARS THE TEXT ON THE SCREEN WHEN DEAD/TELEPORTED BACK TO SPAWN ZONE
_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};

uiSleep	BRCQC_var_zoneMessageOnScreenDuration;

deleteMarker BRCQC_mkr_blueZone;

BRCQC_var_playZoneZoning = false;
