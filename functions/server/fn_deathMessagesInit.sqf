// fn_playZoneDeathMessagesInit.sqf 18:26 PM 13/07/2021

if (!isServer) exitWith {};

BRCQC_var_playZoneDeathMessages = false;

BRCQC_var_announcingDeaths = true;

_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
_playZonePlayersNum = count (allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)});
_playZonePlayersNumOriginal = _playZonePlayersNum;

while {BRCQC_var_playZoneInProgress isEqualTo true} do
{
	waitUntil {(BRCQC_var_playZoneInProgress isEqualTo false) || (_playZonePlayersNum isNotEqualTo (count (allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)})))};
	_playZonePlayersNum = count (allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)});	
	if (_playZonePlayersNum > 1) then
	{
		BRCQC_pve_dynamicText = [format ["%2 DEAD, %1 TO GO!",_playZonePlayersNum,_playZonePlayersNumOriginal - _playZonePlayersNum],0,-0.30,5,0,0,9876];
		_playZonePlayers = allUnits select {(isPlayer _x) && (alive _x) && ((_x getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_x inArea BRCQC_mkr_greenZone)};
		if (isServer && hasInterface) then {if ((isPlayer player) && (alive player) && ((player getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (player inArea BRCQC_mkr_greenZone)) then {publicVariableServer "BRCQC_pve_dynamicText"}} else {_playZonePlayers apply {(owner _x) publicVariableClient "BRCQC_pve_dynamicText"}};
	};
};

BRCQC_var_announcingDeaths = false;
