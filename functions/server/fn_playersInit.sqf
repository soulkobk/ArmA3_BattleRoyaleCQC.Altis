// fn_playZoneWaitForPlayers.sqf 17:47 PM 12/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};

waitUntil {!isNil "BRCQC_var_playZoneLocationText"};
waitUntil {!isNil "BRCQC_var_playZoneLoopText"};

sleep 30;

BRCQC_var_waitingForPlayers = true;
while {BRCQC_var_waitingForPlayers isEqualTo true} do
{
	_spawnZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (_x inArea BRCQC_mkr_spawnZone)};
	_spawnZoneNumPlayers = count _spawnZonePlayers;

	if ((_spawnZoneNumPlayers >= BRCQC_var_minPlayers) && (BRCQC_var_playZoneInProgress isEqualTo false)) then
	{
		BRCQC_var_playZoneInProgress = true;
	};

	_onScreenMessages =
	[
		["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t>",5],
		[format ["CURRENT ROUND LOCATION IS<br/><t color='#00FF00'>%1 AT %2</t>",BRCQC_var_playZoneLocationText,toUpperANSI worldName],5]
	];

	{
		_currentMessage = _x select 0;
		_currentSleep = _x select 1;
		BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
		waitUntil {BRCQC_var_announcingWinner isEqualTo false};
		if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		uiSleep _currentSleep;
	} forEach _onScreenMessages;

	switch (BRCQC_var_playZoneLoopText) do
	{
		case "locationInit": {
			BRCQC_pve_dynamicText = ["INITIALIZING<br/><t color='#000000'>PLAY ZONE LOCATION</t>",0,0.45,5,0];
			waitUntil {BRCQC_var_announcingWinner isEqualTo false};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
		case "lootInit": {
			BRCQC_pve_dynamicText = ["INITIALIZING<br/><t color='#000000'>PLAY ZONE LOOT</t>",0,0.45,5,0];
			waitUntil {BRCQC_var_announcingWinner isEqualTo false};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
		case "playersInit": {
				_spawnZoneWaitPlayers = BRCQC_var_minPlayers - _spawnZoneNumPlayers;
				if (_spawnZoneWaitPlayers isEqualTo 1) then
				{
					BRCQC_pve_dynamicText = [format ["WAITING FOR<br/><t color='#FF0000'>%1 MORE PLAYER</t>",_spawnZoneWaitPlayers],0,0.45,5,0];
					waitUntil {BRCQC_var_announcingWinner isEqualTo false};
					if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				}
				else
				{
					BRCQC_pve_dynamicText = [format ["WAITING FOR<br/><t color='#FF0000'>%1 MORE PLAYERS</t>",_spawnZoneWaitPlayers],0,0.45,5,0];
					waitUntil {BRCQC_var_announcingWinner isEqualTo false};
					if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				};
		};
		case "playersSetupInit": {
			BRCQC_pve_dynamicText = ["INITIALIZING<br/><t color='#000000'>PLAY ZONE PLAYERS</t>",0,0.45,5,0];
			waitUntil {BRCQC_var_announcingWinner isEqualTo false};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
		case "zoningInit": {
			_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
			_playZoneNumPlayers = count _playZonePlayers;
			_playerPlayersText = "PLAYERS";

			if (_playZoneNumPlayers isEqualTo 1) then
			{
				_playerPlayersText = "PLAYER";
			}
			else
			{
				_playerPlayersText = "PLAYERS";
			};

			_onScreenMessages =
			[
				[format ["ROUND IN PROGRESS WITH<br/><t color='#000000'>%1 %2 REMAINING</t>",_playZoneNumPlayers,_playerPlayersText],5],
				["PLEASE WAIT FOR THE<br/><t color='#00FF00'>NEXT ROUND</t>",5]
			];

			{
				_currentMessage = _x select 0;
				_currentSleep = _x select 1;
				BRCQC_pve_dynamicText = [format ["%1",_currentMessage],0,0.45,_currentSleep,0];
				waitUntil {BRCQC_var_announcingWinner isEqualTo false};
				if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
				uiSleep _currentSleep;
			} forEach _onScreenMessages;
		};
		case "cleanUpInit": {
			BRCQC_pve_dynamicText = ["INITIALIZING<br/><t color='#000000'>PLAY ZONE CLEAN UP</t>",0,0.45,5,0];
			waitUntil {BRCQC_var_announcingWinner isEqualTo false};
			if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo false) && (player inArea BRCQC_mkr_spawnZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_spawnZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
		};
	};
	_time = time + 30;
	waitUntil {time >= _time};
};
