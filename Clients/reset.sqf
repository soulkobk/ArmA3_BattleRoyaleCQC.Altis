/*
	File: reset.sqf
	Description: Client reset code for BRGH
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

_unit = _this select 0;
_corpse = _this select 1;

diag_log "<START>: PLAYER RESPAWN SETUP STARTED";

1 cutText ["","BLACK OUT",0.001];

// use mission name space instead of setting variable + publicVariable

// BRMini_GameStarted = missionNamespace getVariable ["BRMini_GameStarted",false];
// BRMini_LootSpawned = missionNamespace getVariable ["BRMini_LootSpawned",false];
// BRMini_WaitingForPlayers = missionNamespace getVariable ["BRMini_WaitingForPlayers",true];
// BRMini_WinnerAnnounce = missionNamespace getVariable ["BRMini_WinnerAnnounce",false];

BRMini_GameStarted = false;
BRMini_LootSpawned = false;
BRMini_WaitingForPlayers = true;
BRMini_WinnerAnnounce = false;

[] spawn { // for spectate shit
	waitUntil{!isNull ((findDisplay 12) displayCtrl 51)};
	((findDisplay 12) displayCtrl 51) ctrlRemoveAllEventHandlers "Draw";
};

[] spawn { // for playerMarker.sqf by soulkobk
	disableSerialization;
	if (not isNil "unitMarkersGPS") then
	{
		_mapCtrl = findDisplay 12 displayCtrl 51;
		_mapCtrl ctrlRemoveEventHandler ["Draw", unitMarkersMap];
	};
	if ((!isNull (uiNamespace getVariable ["RscMiniMap", displayNull])) && (not isNil "unitMarkersGPS")) then
	{
		_mapCtrl = uiNamespace getVariable ["RscMiniMap", displayNull] displayCtrl 101;
		_mapCtrl ctrlRemoveEventHandler ["Draw", unitMarkersGPS];
	};
};

if(count(_this) > 1) then {
	if((_this select 0) distance (_this select 1) < 100 ) then {
		player setPosATL (getMarkerPos "respawn_civilian");
	};
};

if((_this select 0) distance (getMarkerPos "respawn_civilian") > 500) then {
	player setPosATL (getMarkerPos "respawn_civilian");
};

player removeAllEventHandlers "Respawn";
player removeAllEventHandlers "Fired";
player removeAllEventHandlers "Hit";
player removeAllEventHandlers "Killed"; // soulkobk

(findDisplay 46) displayRemoveAllEventHandlers "KeyDown"; // soulkobk

player setVariable ["isPlaying", false, true]; // soulkobk
5 enableChannel [true, true]; // enable direct channel for text and voice

///////////////////////////////////////////////////////////////////////////////////////////
/// CLEAN UP ALL USER DEFINED MAP MARKERS
{
	_markerFoundUserDefined = ["_USER_DEFINED",_x,true] call BIS_fnc_inString;
	if (_markerFoundUserDefined) then
	{
		deleteMarker _x;
	};
} forEach allMapMarkers;
///////////////////////////////////////////////////////////////////////////////////////////

call BRGH_fnc_endVON;
[] spawn BRGH_fnc_clientStart;

uiSleep 2;
1 cutText ["","BLACK IN",2];
