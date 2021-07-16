// fn_cleanUpInit.sqf 18:53 PM 13/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_mkr_greenZone"};

{
	deleteMarker _x;
} forEach (allMapMarkers select {["_USER_DEFINED",_x,true] call BIS_fnc_inString}); // delete all user placed markers

{
	deleteVehicle _x;
} forEach allDead; // delete all dead over entire map

{
	deleteVehicle _x;
} forEach ((getMarkerPos BRCQC_mkr_greenZone) nearObjects ["GroundWeaponHolder",(selectMax (getMarkerSize BRCQC_mkr_greenZone))]); // delete weapon holders

{
	deleteVehicle _x;
} forEach ((getMarkerPos BRCQC_mkr_greenZone) nearObjects ["WeaponHolderSimulated",(selectMax (getMarkerSize BRCQC_mkr_greenZone))]); // delete weapon holders

{
	deleteVehicle _x;
} forEach ((getMarkerPos BRCQC_mkr_greenZone) nearObjects ["TimeBombCore",(selectMax (getMarkerSize BRCQC_mkr_greenZone))]); // delete mines
{
	deleteVehicle _x;
} forEach ((getMarkerPos BRCQC_mkr_greenZone) nearObjects ["MineBase",(selectMax (getMarkerSize BRCQC_mkr_greenZone))]); // delete mines

{
	_x setDamage 0;
	_buildingType = typeOf _x;
	_numDoors = getNumber (configFile / "CfgVehicles" / _buildingType / "numberOfDoors");
	if (_numDoors > 0) then
	{
		for [{_door = 0},{_door < _numDoors},{_door =_door + 1}] do
		{
			_x animate ["door_" + str _door + "_rot",0];
		};
	};
} forEach ((getMarkerPos BRCQC_mkr_greenZone) nearObjects ["House",(selectMax (getMarkerSize BRCQC_mkr_greenZone))]);

BRCQC_var_playZoneCleanUp = false;
