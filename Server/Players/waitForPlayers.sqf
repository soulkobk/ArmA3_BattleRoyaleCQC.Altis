/*
	File: waitForPlayers.sqf
	Description: Player connection delay for BRGH
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

_countPlayers = {
	_count = 0;
	{
		if (_x getVariable ["JoinedGame",false]) then {_count = _count + 1;};
	} forEach playableUnits;
	_count;
};

// set waiting to true
BRMini_WaitingForPlayers = true;
publicVariable "BRMini_WaitingForPlayers";

while {true} do {
	_players = call _countPlayers;
	_waitingForNumber = BRMini_Min_Players - _players;
	if (_players >= BRMini_Min_Players) exitWith {};
	while {true} do
	{
		if (_players >= BRMini_Min_Players) exitWith {};
		///////////////////////////////////////////////////////////////////////////////////////////////////
		_onScreenMessages =
		[
			["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>",5],
			[format ["CURRENT ROUND LOCATION IS<br/>- %1 IN ALTIS -",BRMini_CurrZoneName],5]
		];
		{
			_currentMessage = _x select 0;
			_currentSleep = _x select 1;
			BR_LB_PVAR = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
			publicVariable "BR_LB_PVAR";	
			uiSleep _currentSleep;
		} forEach _onScreenMessages;
		///////////////////////////////////////////////////////////////////////////////////////////////////
		if (_waitingForNumber isEqualTo 1) then {
			BR_LB_PVAR = [format[(localize "str_BRGH_waitingFor") + " %1 " + (localize "str_BRGH_1morePlayer") + "!",_waitingForNumber],0,0.45,5,0];
			publicVariable "BR_LB_PVAR";
		}
		else
		{
			BR_LB_PVAR = [format[(localize "str_BRGH_waitingFor") + " %1 " + (localize "str_BRGH_morePlayers") + "!",_waitingForNumber],0,0.45,5,0];
			publicVariable "BR_LB_PVAR";
		};
		_time = time + 30;
		waitUntil {_players != (call _countPlayers) || time >= _time};
		_players = call _countPlayers;
		_waitingForNumber = BRMini_Min_Players - _players;
	};
};

_time = time + 10;
waitUntil {time >= _time}; // sleep for 10 seconds due to glitched players at spawn area.

// set waiting to false
BRMini_WaitingForPlayers = false;
publicVariable "BRMini_WaitingForPlayers";

_time = time + 5;
waitUntil {time >= _time}; // sleep for 5 seconds.

while {!BRMini_LootSpawned} do // while waiting for loot to spawn, display these messages.
{
	publicVariable "BRMini_WaitingForPlayers";
	_onScreenMessages =
	[
		["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>",5],
		[format ["CURRENT ROUND LOCATION IS<br/>- %1 IN ALTIS -",BRMini_CurrZoneName],5],
		["WAITING FOR LOOT SPAWN",5]
	];
	{
		_currentMessage = _x select 0;
		_currentSleep = _x select 1;
		BR_LB_PVAR = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
		publicVariable "BR_LB_PVAR";	
		uiSleep _currentSleep;
	} forEach _onScreenMessages;
	_time = time + 30;
	waitUntil {time >= _time || BRMini_LootSpawned};
};

waitUntil {BRMini_LootSpawned};

_onScreenMessages =
[
	["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>",5],
	[format ["CURRENT ROUND LOCATION IS<br/>- %1 IN ALTIS -",BRMini_CurrZoneName],5],
	["STARTING THE ROUND!",5]
];
{
	_currentMessage = _x select 0;
	_currentSleep = _x select 1;
	BR_LB_PVAR = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
	publicVariable "BR_LB_PVAR";	
	uiSleep _currentSleep;
} forEach _onScreenMessages;
