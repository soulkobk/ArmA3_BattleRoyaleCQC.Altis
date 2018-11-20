/*
	File: cleanup_map.sqf
	Description: Map Cleanup Script
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

{deleteVehicle _x;} forEach allDead; // delete all dead over entire map
{deleteVehicle _x;} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["GroundWeaponHolder",(BRMini_ZoneSize * 2)]); // delete weapon holders
{deleteVehicle _x;} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["WeaponHolderSimulated",(BRMini_ZoneSize * 2)]); // delete weapon holders
{deleteVehicle _x;} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["TimeBombCore",(BRMini_ZoneSize * 2)]); // delete mines
{deleteVehicle _x;} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["MineBase",(BRMini_ZoneSize * 2)]); // delete mines

{deleteVehicle _x;} forEach ([0,0,0] nearObjects 100); // delete glitched items (no building pos, returned [0,0,0], put in for safe measure).
///////////////////////////////////////////////////////////////////////////////////////////
/// CLEAN UP ALL BLACK AND BLUE ZONE MARKERS FOUND ON MAP
{
	_markerFoundBlack = ["blackZone",_x,true] call BIS_fnc_inString;
	_markerFoundBlue = ["blueZone",_x,true] call BIS_fnc_inString;
	if ((_markerFoundBlack) || (_markerFoundBlue)) then
	{
		deleteMarker _x;
	};
} forEach allMapMarkers;
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
// {
	// _x setDamage 0; 
	// _config = configFile >> "CfgVehicles" >> (typeof _x);
	// _userActions = _config >> "UserActions";
	// if(isClass _userActions) then {
		// _doorNum = 1;
		// for "_i" from 0 to count(_userActions)-1 do {
			// _action = _userActions select _i;
			// if(isClass _action) then {
				// _name = configName _action;
				// if(["OpenDoor",_name] call BIS_fnc_inString) then {
					 // [_x, format['Door_%1_rot',_doorNum], format['Door_Handle_%1_rot_1',_doorNum], format['Door_Handle_%1_rot_2',_doorNum]] execVM "\A3\Structures_F\scripts\Door_close.sqf";
					// _doorNum = _doorNum + 1;
				// };
			// };
		// };
	// };
// } forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["House",(BRMini_ZoneSize * 2)]);
///////////////////////////////////////////////////////////////////////////////////////////
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
} forEach ((getMarkerPos BRMini_CurrZone) nearObjects ["House",(BRMini_ZoneSize * 2)]);

diag_log "<RESET>: MAP CLEANED";