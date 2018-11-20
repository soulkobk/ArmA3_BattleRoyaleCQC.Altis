/*
/*
	File: init.sqf
	Description: Client & Server initialiaztion code
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
*/

BRMini_GameStarted = false;
BRMini_WaitingForPlayers = true;

// Remove line drawings from map
(createTrigger ["EmptyDetector", [0,0,0]]) setTriggerStatements
[
    "!triggerActivated thisTrigger", 
    "thisTrigger setTriggerTimeout [5,5,5,false]",
    "{if (markerShape _x == 'POLYLINE') then {deleteMarker _x}} forEach allMapMarkers"
];
