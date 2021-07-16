// fn_winnerInit.sqf 19:35 PM 13/07/2021

_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};

_playerFinalScoreArr = [];
{
	if ((isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_blackZone)) then
	{
		_playerObject = _x;
		_playerName = name _x;
		_playerUID = getPlayerUID _x;
		_playerFinalScore = getPlayerScores _x select 5;
		_playerFinalScoreArr pushBackUnique [_playerObject,_playerName,_playerUID,_playerFinalScore];
	};
} forEach _playZonePlayers;

_finalWinners = [_playerFinalScoreArr,[],{_x select 3},"DESCEND"] call BIS_fnc_sortBy;
if ((count _finalWinners) > 1) then
{
	for "_i" from 1 to (count _finalWinners) do
	{
		_runnerUpDetails = _finalWinners select _i;
		_runnerUpObject = _runnerUpDetails select 0;
		if ((alive _runnerUpObject) && (isPlayer _runnerUpObject) && (_runnerUpObject inArea BRCQC_mkr_blackZone)) then
		{
			_runnerUpObject setDamage 1;
		};
	};
};

_waitTime = time + 5;
waitUntil {time >= _waitTime};

BRCQC_var_announcingWinner = true;

if ((count _finalWinners) isNotEqualTo 0) then
{
	_finalWinner = _finalWinners select 0;
	_finalWinnerObject = _finalWinner select 0;
	_finalWinnerName = _finalWinner select 1;
	_finalWinnerUID = _finalWinner select 2;
	_finalWinnerScore = _finalWinner select 3;
	
	if (isNil "_finalWinnerName") exitWith {};
	
	[_finalWinnerName,_finalWinnerObject] spawn
	{
		params ["_finalWinnerName","_finalWinnerObject"];
	
		_finalWinnerObject setVariable ["BRCQC_var_isWinner",true,true];

		_onScreenMessages =
		[
			[format ["CONGRATULATIONS<br/>%1<br/>YOU ARE A<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>%2 AT ALTIS<br/>WINNER!",_finalWinnerName,BRCQC_var_playZoneLocationText],15]
		];
		{
			_currentMessage = _x select 0;
			_currentSleep = _x select 1;
			_currentLines = _x select 2;
			BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
			if (isServer && hasInterface) then {if ((alive player) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"; publicVariableServer "BRCQC_pve_roundWinner"}} else {(owner _finalWinnerObject) publicVariableClient "BRCQC_pve_dynamicText"; (owner _finalWinnerObject) publicVariableClient "BRCQC_pve_roundWinner"};
			uiSleep _currentSleep;
		} forEach _onScreenMessages;
		_finalWinnerObject setDamage 1;
	};
	
	diag_log format ["[BRCQC] ROUND WINNER WAS %1 (%2)",_finalWinnerName,getPlayerUID _finalWinnerObject];

	[_finalWinnerName] spawn
	{
		params ["_finalWinnerName"];
	
		_onScreenMessages =
		[
			[format ["THE ROUND WINNER OF<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>%2 IN ALTIS<br/>WAS<br/>%1",_finalWinnerName,BRCQC_var_playZoneLocationText],15]
		];
		{
			_currentMessage = _x select 0;
			_currentSleep = _x select 1;
			_currentLines = _x select 2;
			BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
			_spawnZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (_x inArea BRCQC_mkr_spawnZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			uiSleep _currentSleep;
		} forEach _onScreenMessages;
	};
}
else
{
	diag_log "[BRCQC] ROUND WINNER WAS NOONE, EVERYONE DIED";
	[] spawn
	{
		_onScreenMessages =
		[
			[format ["NO ONE WON THE ROUND OF<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>%1 IN ALTIS<br/>AS EVERYONE DIED!",BRCQC_var_playZoneLocationText],15,4]
		];
		{
			_currentMessage = _x select 0;
			_currentSleep = _x select 1;
			BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
			_spawnZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (_x inArea BRCQC_mkr_spawnZone)};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo faLse) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
			uiSleep _currentSleep;
		} forEach _onScreenMessages;
	};
};

BRCQC_var_announcingWinner = false;

sleep 10;

BRCQC_var_playZoneWinner = false;
