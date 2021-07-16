// fn_objectSetupInit.sqf 14:34 PM 15/07/2021

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_mkr_spawnZone"};
waitUntil {!isNil "BRCQC_var_spawnZonePos"};
waitUntil {!isNil "BRCQC_var_spawnZoneSize"};

_classes =
[
	"Land_Cargo_Tower_V2_F",
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_House_V2_F",
	"Land_Cargo_House_V2_F",
	"Land_LampStreet_small_F",
	"Land_LampStreet_small_F",
	"Land_LampStreet_small_F",
	"Land_LampStreet_small_F"
];

{
	_class = _x;
	_emptyPos = [BRCQC_var_spawnZonePos,(sizeOf _class),BRCQC_var_spawnZoneSize,(sizeOf _class),0,20,0] call BIS_fnc_findSafePos;
	if (_emptyPos isNotEqualTo []) then
	{
		if (_emptyPos inArea BRCQC_mkr_spawnZone) then
		{
			_object = _class createVehicle _emptyPos;
			_object setDir round(random 360);
			_object allowDamage false;
		};
	};
} forEach _classes;
