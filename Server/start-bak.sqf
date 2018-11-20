/*
	File: start.sqf
	Description: Server initialiaztion for BRGH
	Created By: PlayerUnknown & Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

BRMini_GamesPlayed = BRMini_GamesPlayed + 1;

// call BRGH_fnc_lootConfig;

// _fogThread = [] call BRGH_fnc_simpleFog;
// _weatherThread = [] spawn BRGH_fnc_startWeather;

// [] spawn BRGH_fnc_spawnLoot;
// [BRMini_CurrZone] spawn BRGH_fnc_spawnLoot;

call BRGH_fnc_waitForPlayers;

waitUntil {(!(BRMini_WaitingForPlayers) && (BRMini_LootSpawned))};

"DISABLE_EVENTS = (findDisplay 46) displayAddEventHandler ['KeyDown',{true}];" call BRMini_RE;

BRMini_GameStarted = true;
publicVariable "BRMini_GameStarted";
BRMini_LootSpawned = true;
publicVariable "BRMini_LootSpawned";
BRMini_WaitingForPlayers = false;
publicVariable "BRMini_WaitingForPlayers";

publicVariable "BR_FADEINBLACK";

uiSleep 2;

OSM_OK = false;
[] spawn
{
	_onScreenMessages =
	[
		[format ["<br/>THIS IS<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/> - %1 IN ALTIS -<br/>",BRMini_CurrZoneName],3],
		["",1],
		["A<br/><t color='#FF0000'>BATTLE ROYALE GAMES</t><br/>FT<br/><t color='#2E9AFE'>KOBK</t><br/>PRODUCTION<br/>",3],
		["",1],
		["<br/><br/>ORIGINAL SCRIPTING/CODING BY<br/><t color='#58FA58'>LYSTIC</t><br/>",3],
		["",1],
		["<br/><br/>SCRIPTING/CODING ENHANCMENTS BY<br/><t color='#2E9AFE'>SOULKOBK</t><br/>",3],
		["",1]
	];

	{
		_currentMessage = _x select 0;
		_currentSleep = _x select 1;
		BR_DT_PVAR = [format ["%1",_currentMessage],0,0.25,_currentSleep,0];
		publicVariable "BR_DT_PVAR";	
		uiSleep _currentSleep;

	} forEach _onScreenMessages;
	OSM_OK = true;
};
waitUntil {OSM_OK};

//// EDITED FOR THE NEW MAP MARKERS
// _pos = (getMarkerPos BRMini_CurrZone);
// position to place players...
// _roads = _pos nearRoads (BRMini_ZoneSize / 2);
// {
	// _pos = getposatl (_roads select floor(random(count(_roads))));
	// _x setposatl _pos;
// } forEach playableUnits;

/////////////////////////////////////////////////////////////////////////////////////////////////
// place all players at a distance from the center of the circle (relative position and distance)
_pos = (getMarkerPos BRMini_CurrZone);
// _numPlayers = count playableUnits;
_numPlayers = count ((getMarkerPos "spawnArea") nearObjects ["Man",100]);
_degreeStep = 360 / (_numPlayers + 1);

_degreeCurrent = 0;
{
	if ((alive _x) && (isPlayer _x) && (_x getVariable "isPlaying")) then
	{
		_landPos = [_pos, (BRMini_ZoneSize - 100), _degreeCurrent] call BIS_fnc_relPos;
		if (surfaceIsWater _landPos) then
		{
			// _landPos = [_landPos,1,200,5,0,1,0] call BIS_fnc_findSafePos;
			_landPos = [];
			while {_landPos isEqualTo []} do
			{
				_landPos = _landPos findEmptyPosition [1,200];
				uiSleep 0.1;
			};
		};
		// _x setVariable ["isPlaying",true,true]; // set player to isPlaying true (in current game round)
		// _landPos set [2,1000]; // adjust altitude for parachute drop (client side start.sqf)
		_x setPosATL _landPos;
		_x setDir round(random 360);
		_degreeCurrent = _degreeCurrent + _degreeStep;
	};
} forEach ((getMarkerPos "spawnArea") nearObjects ["Man",100]); // max 100m from spawnArea center, default circle is 50m
// } forEach playableUnits;
///////////////////////////////////////////////////////////////////////////////////////////////////

publicVariable "BR_FADEOUTBLACK";

uiSleep 2;

OSM_OK = false;
[] spawn
{
	_onScreenMessages =
	[
		["5",1],
		["4",1],
		["3",1],
		["2",1],
		["1",1]
	];

	_OSM = {
		_currentMessage = _x select 0;
		_currentSleep = _x select 1;
		BR_DT_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
		publicVariable "BR_DT_PVAR";	
		uiSleep _currentSleep;

	} forEach _onScreenMessages;
	OSM_OK = true;
};
waitUntil {OSM_OK};

BRMini_InGame = true;
// BR_DT_PVAR = ["GO!",0,0.35,1,0];
BR_DT_PVAR = ["GO!",0,0.35,5,0];
publicVariable "BR_DT_PVAR";	

"(findDisplay 46) displayRemoveEventHandler ['KeyDown',DISABLE_EVENTS];" call BRMini_RE;

[] spawn BRGH_fnc_deathMessages;

[] spawn BRGH_fnc_startZoning;

waitUntil {!BRMini_InGame};

BRMini_ServerOn = false;

_waitTime = time + 10;
waitUntil {time >= _waitTime};

_winners = (getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize];
{
	if (alive _x && isplayer _x && _x inArea BRMini_BlackZone) then // winner must be within the black circle aka BRMini_BlackZone
	{
		_name = name _x;
		_uid = getPlayerUID _x;
		
		diag_log format ["<BRMINI>: %1 ROUND WINNER IS %2 (%3)",BRMini_CurrZoneName,_name,_uid];
		
		_index = BRMini_Winners find _name;
		if (_index == -1) then
		{
			_index = count(BRMini_Winners);
			BRMini_Winners set[count(BRMini_Winners),_name];
		};
		_score = 0;
		if (_index < count(BRMini_WinnerScores)) then
		{
			_score = (BRMini_WinnerScores select _index);
		};
		_score = _score + 1;
		BRMini_WinnerScores set[_index,_score];
		
		publicVariable "BR_WINNER"; // initiate celebration smoke client side
		
		_onScreenMessages =
		[
			[format ["CONGRATULATIONS<br/>%1<br/>YOU ARE A<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>- %2 IN ALTIS -<br/>WINNER!",_name,BRMini_CurrZoneName],15]
		];
		
		{
			_currentMessage = _x select 0;
			_currentSleep = _x select 1;
			BR_DT_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
			publicVariable "BR_DT_PVAR";	
			uiSleep _currentSleep;
		} forEach _onScreenMessages;
		
		uiSleep 10;
		
		_x setDamage 1;
		
	};
} forEach _winners;

uiSleep 10;

diag_log "<RESET>: SERVER RESETTING!";

// [[_fogThread,_weatherThread],[]] spawn BRGH_fnc_serverReset;
[[],[]] spawn BRGH_fnc_serverReset;