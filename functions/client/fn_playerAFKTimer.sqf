// fn_afkTimer.sqf 19:01 PM 13/07/2021

if (!hasInterface) exitWith {};

waitUntil {!isNil "BRCQC_var_playerAFKTimeMax"};

waitUntil {alive player};

BRCQC_var_afkTimerCheck = true;

_timerAFK = nil;
_playerVelocity = vectorMagnitude velocity player * 3.6;
_playerlastViewDirection = round((((screenToWorld [0.5,0.5] select 0) - (position player select 0)) atan2 ((screenToWorld [0.5,0.5] select 1) - (position player select 1))) + 360) % 360;

while {BRCQC_var_afkTimerCheck} do
{
	_playerCurrViewDirection = round((((screenToWorld [0.5,0.5] select 0) - (position player select 0)) atan2 ((screenToWorld [0.5,0.5] select 1) - (position player select 1))) + 360) % 360;
	uiSleep 0.5;
	if (_playerVelocity isEqualTo 0) then
	{
		if (_playerCurrViewDirection isEqualTo _playerLastViewDirection) then
		{
			if (isNil "_timerAFK") then
			{
				_timerAFK = (diag_tickTime + BRCQC_var_playerAFKTimeMax);
			};
		}
		else
		{
			_timerAFK = nil;
		};
	}
	else
	{
		_timerAFK = nil;
	};
	_playerVelocity = vectorMagnitude velocity player * 3.6;
	_playerLastViewDirection = round((((screenToWorld [0.5,0.5] select 0) - (position player select 0)) atan2 ((screenToWorld [0.5,0.5] select 1) - (position player select 1))) + 360) % 360;
	if (["IsSpectating", [player]] call BIS_fnc_EGSpectator) then
	{
		_timerAFK = nil;
	};
	if (!isNil "_timerAFK") then
	{
		if (diag_tickTime >= _timerAFK) then
		{
			BRCQC_var_afkTimerCheck = false;
			9999 cutText ["", "BLACK", 0.01];
			0 fadeSound 0;
			uiNamespace setVariable ["BIS_fnc_guiMessage_status", false];
			_afkMessage = ["You Were Kicked For Being AFK For Too Long!","AFK KICK",true,false] spawn BIS_fnc_guiMessage;
			_afkMessageWait = diag_tickTime + 30;
			waitUntil {scriptDone _afkMessage || diag_tickTime >= _afkMessageWait};
			endMission "LOSER";
			waitUntil {uiNamespace setVariable ["BIS_fnc_guiMessage_status", false]; closeDialog 0; false};
		};
	};
	uiSleep 0.5;
};
