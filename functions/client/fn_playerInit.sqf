// fn_playerInit.sqf 16:04 PM 12/07/2021

if (!hasInterface) exitWith {};

[] spawn BRCQC_fnc_playerSetup;

[] spawn BRCQC_fnc_playerJump;
[] spawn BRCQC_fnc_playerMarker;
[] spawn BRCQC_fnc_playerAFKTimer;

player addMPEventHandler ["MPKilled",{
	params ["_unit","_killer","_instigator"];
	if (((_unit getVariable ["BRCQC_var_isPlaying",false]) isEqualTo true) && (_unit inArea BRCQC_mkr_greenZone)) then
	{
		_unit setVariable ["BRCQC_var_isPlaying",false,true];
		_text = "";
		if (_unit isEqualTo _killer) then
		{
			_text = [format ["%1 WAS KILLED",name _unit],0,-0.35,5,0,0,9877];
		}
		else
		{
			_text = [format ["%1 WAS KILLED BY %2",name _unit,name _killer],0,-0.35,5,0,0,9877];
			[_killer,2] remoteExec ["addScore",[0,2] select isDedicated];
		};
		_text spawn BIS_fnc_dynamicText;
	};
}];

"BRCQC_pve_dynamicText" addPublicVariableEventHandler {
	(_this select 1) spawn BIS_fnc_dynamicText;
};

"BRCQC_pve_roundWinner" addPublicVariableEventHandler {
	if (player inArea "BRCQC_mkr_greenZone") then
	{
		[] spawn
		{
			closeDialog 0;
			openMap false;
			_disableKeys = (findDisplay 46) displayAddEventHandler ['KeyDown',{true}];
			uiSleep 2;
			_pos = getPosATL player;
			_smokeArr = [];
			{
				_distance = _x select 0;
				_smokeShell = _x select 1;
				for "_i" from 0 to 359 step 15 do
				{
					_targetPos = [_pos, _distance, _i] call BIS_fnc_relPos; 
					_targetPos set [2,(_pos select 2) + 2];
					_smoke = _smokeShell createVehicleLocal _targetPos;
					_smokeArr pushBackUnique _smoke;
					sleep 0.1;
				};
			} forEach [[2.5,"smokeShellRed"],[5,"smokeShell"],[7.5,"smokeShellBlue"]];
			waitUntil {!(alive player)};
			(findDisplay 46) displayRemoveEventHandler ['KeyDown',_disableKeys];
			{
				deleteVehicle _x;
			} forEach _smokeArr;
		};
	};
};
