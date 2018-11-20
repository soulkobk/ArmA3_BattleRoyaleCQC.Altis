/*
	File: player_eventHandlers.sqf
	Description: Setup Unit EventHandlers
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

diag_log "<PEH>: ADDING EVENT HANDLERS";

player addEventHandler ["Respawn",{
	_this spawn BRGH_fnc_clientReset; // _this is parsed to script but not used in the script itself?!?

	_unit = _this select 0;
	[_unit] spawn
	{ // for uniform sync
		params ["_unit"];
		waitUntil {((alive _unit) && !(_unit getVariable "isPlaying") && (_unit inArea "spawnArea"))};
		if ((uniform _unit == SL_customUniformClassBRCQCWINNER) && (_unit getVariable ["BRMini_isWINNER",false])) exitWith
		{
			_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCWINNER];
		};
		if ((uniform _unit == SL_customUniformClassBRCQCADMIN) && (_unit getVariable ["BRMini_isADMIN",false])) exitWith
		{
			_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCADMIN];
		};
		if ((uniform _unit == SL_customUniformClassBRCQCVIP) && (_unit getVariable ["BRMini_isVIP",false])) exitWith
		{
			_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCVIP];
		};
		if (uniform _unit == SL_customUniformClassBRCQCCONTENDER) exitWith
		{
			_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCCONTENDER];
		};
	};
}];

//--- spectator unit coloring features
player addEventHandler ["Hit",{
	[] spawn
	{
		player setVariable ["BRHit",true,true];
		uiSleep 5;
		player setVariable ["BRHit",false,true];
	};
}];

player addEventHandler ["Fired",{
	[] spawn
	{
		player setVariable ["BRFired",true,true];
		uiSleep 5;
		player setVariable ["BRFired",false,true];
	};
}];

player addEventHandler ["Killed",{
	_unit = _this select 0; // unit who died
	_killer = _this select 1; // killer of the unit who died
	_instigator = _this select 2; // instigator of the killed unit
	if (_unit != _killer) then // don't add score for own death
	{
		BRMini_AddScore = [_killer];
		publicVariableServer "BRMini_AddScore";
	};
	1 cutText ["","BLACK OUT",2];
}];

[] execVM "Clients\Scripts\playerJump.sqf"; // soulkobk

[] spawn
{
	// disallow showing of leaderboard (network stats)
	SL_fn_netWorkStats = {
		params ["_displayCode","_keyCode","_isShift","_isCtrl","_isAlt"];
		_handled = false;
		if (_keyCode in actionKeys "NetworkStats") then {
			_handled = true;
		};
		_handled
	};
	waituntil {!(isNull (findDisplay 46))};
	(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call SL_fn_netWorkStats;"];
};

// event handler for kill feed. - soulkobk
player addMPEventHandler ["MPKilled",{
	_unit = _this select 0;
	_killer = _this select 1;
	_instigator = _this select 2;
	if (!(_unit inArea "spawnArea") && (_unit getVariable "isPlaying")) then
	{
		if (player getVariable "isPlaying") then
		{
			_text = "";
			if (_unit isEqualTo _killer) then
			{
				_text = [format ["%1 WAS KILLED",name _unit],0,-0.35,5,0,0,9877]; // 9876 = death messages, 9877 = kill feed
			}
			else
			{
				_text = [format ["%1 WAS KILLED BY %2",name _unit,name _killer],0,-0.35,5,0,0,9877]; // 9876 = death messages, 9877 = kill feed
			};
			_text spawn BIS_fnc_dynamicText;
		};
	};
}];
