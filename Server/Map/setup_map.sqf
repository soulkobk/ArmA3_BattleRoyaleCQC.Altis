/*
	File: setup_map.sqf
	Description: Map Setup for BRGH
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

/// RESET ZONE SIZE BACK TO DEFAULT ON EACH ROUND
BRMini_ZoneSize = 500;
PublicVariable "BRMini_ZoneSize";

/// SETUP RANDOM PLAY ZONE ////////////////////////////////////////////////////////////////////////
_allZoneCentersArr = [];

{
	_markerFound = ["BRMini_SafeZone_",_x,true] call BIS_fnc_inString;
	if (_markerFound) then
	{
		_allZoneCentersArr pushBack _x;
	};
} forEach allMapMarkers;

BRMini_CurrZone = _allZoneCentersArr call BIS_fnc_selectrandom;
publicVariable "BRMini_CurrZone";
BRMini_CurrZoneName = toUpper (markerText BRMini_CurrZone);
publicVariable "BRMini_CurrZoneName";

diag_log format ["<BRMINI>: %1 IS THE CURRENT ROUND LOCATION",BRMini_CurrZoneName];

///////////////////////////////////////////////////////////////////////////////////////////////////
_nextZoneCenter = getMarkerPos BRMini_CurrZone;
///////////////////////////////////////////////////////////////////////////////////////////////////
/// CREATE BLACK VISUAL BORDER IN GAME
// _steps = floor ((2 * pi * BRMini_ZoneSize) / 15);
// _radStep = 360 / _steps;
// _data = [];
// for [{_j = 0}, {_j < 360}, {_j = _j + _radStep}] do {
	// _pos2 = [_nextZoneCenter, BRMini_ZoneSize, _j] call BIS_fnc_relPos;
	// _pos2 set [2, 0];
	// _data set[count(_data),["UserTexture10m_F",_pos2,_j,"#(argb,8,8,3)color(0,0,0,0.6)"]];
	// _data set[count(_data),["UserTexture10m_F",_pos2,(_j + 180),"#(argb,8,8,3)color(0,0,0,0.6)"]];
// };
// BR_DRAWBLACKZONE = _data;
// publicVariable "BR_DRAWBLACKZONE";
///////////////////////////////////////////////////////////////////////////////////////////////////
/// CREATE BLACK CIRCLE ON MAP
// _blackMarkerID = format ["BLACKZONE_%1_%2",_nextZoneCenter,BRMini_ZoneSize];
// _blackMarker = createMarker ["blackZone",_nextZoneCenter];
// _blackMarker setMarkerColor "ColorBlack";
// _blackMarker setMarkerShape "ELLIPSE";
// _blackMarker setMarkerBrush "BORDER";
// _blackMarker setMarkerSize [BRMini_ZoneSize,BRMini_ZoneSize];
BRMini_BlackZone = createMarker ["blackZone",_nextZoneCenter];
BRMini_BlackZone setMarkerColor "ColorBlack";
BRMini_BlackZone setMarkerShape "ELLIPSE";
BRMini_BlackZone setMarkerBrush "BORDER";
BRMini_BlackZone setMarkerSize [BRMini_ZoneSize,BRMini_ZoneSize];
///////////////////////////////////////////////////////////////////////////////////////////////////
// spawn loot!
[] spawn {[BRMini_BlackZone] execVM "Server\Loot\LootInit.sqf";};