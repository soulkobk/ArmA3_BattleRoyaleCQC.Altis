// fn_markerSetup.sqf 15:42 PM 12/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_var_spawnZonePos"};
waitUntil {!isNil "BRCQC_var_spawnZoneSize"};

BRCQC_obj_spawnZone = "Land_HeliPadEmpty_F" createVehicle BRCQC_var_spawnZonePos;

BRCQC_mkr_spawnZone = createMarker ["BRCQC_mkr_spawnZone",BRCQC_var_spawnZonePos];
BRCQC_mkr_spawnZone setMarkerColor "ColorRed";
BRCQC_mkr_spawnZone setMarkerShape "ELLIPSE";
BRCQC_mkr_spawnZone setMarkerBrush "SOLIDBORDER";
BRCQC_mkr_spawnZone setMarkerSize [BRCQC_var_spawnZoneSize,BRCQC_var_spawnZoneSize];
BRCQC_mkr_spawnZone setMarkerAlpha 0.5;

BRCQC_mkr_blackZone = createMarker ["BRCQC_mkr_blackZone",BRCQC_var_spawnZonePos];
BRCQC_mkr_blackZone setMarkerColor "ColorBlack";
BRCQC_mkr_blackZone setMarkerShape "ELLIPSE";
BRCQC_mkr_blackZone setMarkerBrush "SOLIDBORDER";
BRCQC_mkr_blackZone setMarkerSize [0,0];
BRCQC_mkr_blackZone setMarkerAlpha 0;

BRCQC_mkr_greenZone = createMarker ["BRCQC_mkr_greenZone",BRCQC_var_spawnZonePos];
BRCQC_mkr_greenZone setMarkerColor "ColorGreen";
BRCQC_mkr_greenZone setMarkerShape "ELLIPSE";
BRCQC_mkr_greenZone setMarkerBrush "SOLIDBORDER";
BRCQC_mkr_greenZone setMarkerSize [0,0];
BRCQC_mkr_greenZone setMarkerAlpha 0;

missionNamespace setVariable ["BRCQC_var_markerSetupUpdated",true,false];
