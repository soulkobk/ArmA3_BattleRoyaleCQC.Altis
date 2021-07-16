// fn_locationInit.sqf 18:38 PM 12/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_mkr_blackZone"};
waitUntil {!isNil "BRCQC_var_playZoneSize"};

_playZoneMarker = selectRandom (allMapMarkers select {["BRCQC_mkr_playZone_",_x,true] call BIS_fnc_inString});
_playZoneSize = missionNamespace getVariable ["BRCQC_var_playZoneSize",0];

BRCQC_mkr_blackZone setMarkerPos (markerPos _playZoneMarker);
BRCQC_mkr_blackZone setMarkerSize [_playZoneSize,_playZoneSize];
BRCQC_mkr_blackZone setMarkerAlpha 0.5;

BRCQC_mkr_greenZone setMarkerPos (markerPos _playZoneMarker);
BRCQC_mkr_greenZone setMarkerSize [_playZoneSize * 4,_playZoneSize * 4];
BRCQC_mkr_greenZone setMarkerAlpha 0;

sleep 1;

BRCQC_var_playZoneLocationText = toUpperANSI (text ((nearestLocations [markerPos BRCQC_mkr_blackZone, ["NameCityCapital","NameCity","NameVillage","NameLocal"], BRCQC_var_playZoneSize]) select 0));

BRCQC_var_playZoneLocation = false;
