
// player setPos [((getPos player) select 0),((getPos player) select 1),1000];

_autoChute = true;
_autoChuteAltituteTrigger = 100;
_allowLandOnRoof = false;
_allowDamageAltitude = 50;

private ["_parachute"];

player addBackpack "B_Parachute";

[_allowDamageAltitude] spawn {
	params ["_allowDamageAltitude"];
	player allowDamage false;
	waitUntil {position player select 2 < _allowDamageAltitude};
	player allowDamage true;
};

if (_autoChute) then
{
	if (_allowLandOnRoof) then
	{
		waitUntil {position player select 2 < _autoChuteAltituteTrigger}; player action ["openParachute"];
	}
	else
	{
		waitUntil {getPosASL player select 2 < _autoChuteAltituteTrigger || getPosATL player select 2 < _autoChuteAltituteTrigger}; player action ["openParachute"];
	};
};

if (_allowLandOnRoof) then
{
	waitUntil {position player select 2 < 1};
}
else
{
	waitUntil {getPosASL player select 2 < 1 || getPosATL player select 2 < 1};
};

moveOut player;
player allowDamage true;

player switchMove "AmovPercMstpSnonWnonDnon";

uiSleep 0.5;
