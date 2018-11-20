/*
	File: start.sqf
	Description: Client initialiaztion for BRGH
	Created By: PlayerUnknown & Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/
call BRGH_fnc_playerSetup;

diag_log "<START>: START VON";
call BRGH_fnc_startVON;

// start player map marker - soulkobk
[] execVM "Clients\Scripts\playerMarker.sqf"; // soulkobk

player setVariable ["isPlaying", false, true]; // soulkobk
5 enableChannel [true, true]; // enable direct channel for text and voice

[] spawn {
	while {!(player getVariable "isPlaying")} do // JIP players were stuck out at sea.
	{
		if !(player inArea "spawnArea") then
		{
			_pos = (getMarkerPos "spawnArea");
			_posX = (_pos select 0) + (random(20)-10);
			_posY = (_pos select 1) + (random(20)-10);
			player setPosATL [_posX,_posY,0];
		};
		player allowDamage false; // keep player invincible whilst in spawnArea
		uiSleep 0.1;
	};
};

uiSleep 5;

waitUntil{!(isNil 'BRMini_CurrZone')};

diag_log "<START>: CHECK GAME IN PROGRESS";

_count = ({alive _x && isPlayer _x} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize]));
if (_count > 0) exitWith
{
	// ["THE GAME IS IN PROGRESS! PLEASE WAIT!",0,0.45,5,0] call BIS_fnc_dynamicText;
	// hintSilent "Press TAB To enter spectator mode!";
	
	_keybinds = (findDisplay 46) displayAddEventHandler ["KeyDown",{
		if((_this select 1) == 15) then
		{
			(getMarkerPos BRMini_CurrZone) spawn fnc_BRCamera;
		};
		false
	}];
	
	// waitUntil {uiSleep 0.1; [] call BRGH_fnc_updateInGameGUI; ({alive _x && isplayer _x} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize])) == 0 || !(alive player)};

	updateInGameGUI = true;
	
	[] spawn { // spawn a separate thread for updating top of screen text every second
		while {updateInGameGUI} do
		{
			_nextLoop = time + 1;
			[] call BRGH_fnc_updateInGameGUI;
			waitUntil {time >= _nextLoop};
		};
	};
	
	// while {({alive _x && isplayer _x} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize])) != 0 && (alive player)} do
	while {({alive _x && isplayer _x} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize])) != 0} do
	{
		_nextLoop = time + 30;
		if !(BRMini_WinnerAnnounce) then // if winner is announcing, don't display anything here!
		{
			["WELCOME TO<br/><t color='#FF0000'>BATTLE ROYALE CQC</t>",0,0.45,5,0] call BIS_fnc_dynamicText;
		};
		if !(BRMini_WinnerAnnounce) then // if winner is announcing, don't display anything here!
		{
			[format ["CURRENT ROUND LOCATION IS<br/>- %1 IN ALTIS -",BRMini_CurrZoneName],0,0.45,5,0] call BIS_fnc_dynamicText;
		};
		if !(BRMini_WinnerAnnounce) then // if winner is announcing, don't display anything here!
		{
			["A ROUND IS CURRENTLY IN PROGRESS, PLEASE WAIT FOR THE NEXT ONE!",0,0.45,5,0] call BIS_fnc_dynamicText;
		};
		if (player getVariable ["BRMini_canSpectate",false]) then
		{
			hintSilent "Press TAB To enter spectator mode!"; // if true/BRMini_canSpectate then hint.
		};
		waitUntil {time >= _nextLoop || ({alive _x && isplayer _x} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize])) == 0 || !(alive player)};
	};
	
	updateInGameGUI = false;
	
	(findDisplay 46) displayRemoveEventHandler ["KeyDown",_keybinds];
	
	call BRGH_fnc_endVON;
	call BRGH_fnc_endSpectate;
	
	if !(alive player) exitWith {};
	
	player setDamage 1;
};

[] spawn {
	["<t align='center' color='#FF0000'>WAITING FOR PLAYERS</t>"] call BRGH_fnc_updateInGameGUI;
	waitUntil {!(BRMini_WaitingForPlayers)};

	if !(BRMini_LootSpawned) then
	{
		["<t align='center' color='#FF9D00'>WAITING FOR LOOT SPAWN</t>"] call BRGH_fnc_updateInGameGUI;
		waitUntil {BRMini_LootSpawned};
	};

	["<t align='center' color='#00FF00'>STARTING THE ROUND</t>"] call BRGH_fnc_updateInGameGUI;
	waitUntil {BRMini_GameStarted};
};

waitUntil {BRMini_GameStarted};

while {!(player getVariable ["isPlaying", false])} do // loop this shit... damn parsing issues
{
	[""] call BRGH_fnc_updateInGameGUI;
	5 enableChannel [false, false]; // disable direct channel for text and voice
	player setVariable ["isPlaying", true, true]; // set player to isPlaying true (is playing in current round)
	player setVariable ["BRMini_isWINNER",false,true]; // reset the player uniform (non winner)
};

[] spawn {
	while {(player getVariable "isPlaying")} do
	{
		player allowDamage true; // enforce player damage once moved to the play zone
		uiSleep 0.1;
	};
};

closeDialog 0; // soulkobk
openMap false; // soulkobk

call BRGH_fnc_endVON;
diag_log "<START>: VON STOPPED";

diag_log "<START>: CLEANING BLUEZONE";

_old = BRMINI_ZoneObjects;
BRMINI_ZoneObjects = [];

{
	deleteVehicle _x;
} forEach _old;

// waitUntil{(player distance (getMarkerPos BRMini_CurrZone)) < BRMini_ZoneSize};
waitUntil{(player inArea "blackZone")}; // wait until player is inside the black zone

[""] call BRGH_fnc_updateInGameGUI;

[10,40] call BRGH_fnc_AntiTP; //--- [Distance(m),MaxVelocity(km/h)] (OMG SUCH BUGS)
diag_log "<START>: ROUND STARTED";