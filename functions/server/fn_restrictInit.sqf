// fn_spawnZoneRestrict.sqf 15:42 PM 12/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};
waitUntil {!isNil "BRCQC_mkr_spawnZone"};

BRQCQ_var_spawnZoneRestrict = true;
while {BRQCQ_var_spawnZoneRestrict} do
{
	_spawnZoneRestrict = allUnits select {(isPlayer _x) && (alive _x) && (_x getVariable ["BRCQC_var_isPlaying",false] isEqualTo false) && !(_x inArea BRCQC_mkr_spawnZone)};
	_spawnZoneRestrict apply
	{
		_spawnZoneRestrictRelPos = BRCQC_var_spawnZonePos findEmptyPosition [2,25,"C_MAN_1"];
		if (_spawnZoneRestrictRelPos inArea BRCQC_mkr_spawnZone) then
		{
			_x setPosATL _spawnZoneRestrictRelPos;
		};
	};
	sleep 0.1;
};
