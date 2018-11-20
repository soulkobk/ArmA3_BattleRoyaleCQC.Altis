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
// [] spawn {
	// for "_i" from 0 to 9 do // make sure this shit parses to the client... fucking clunky shit
	// {
		BRMini_GameStarted = true;
		publicVariable "BRMini_GameStarted";
		BRMini_LootSpawned = true;
		publicVariable "BRMini_LootSpawned";
		BRMini_WaitingForPlayers = false;
		publicVariable "BRMini_WaitingForPlayers";

		publicVariable "BR_FADEINBLACK";
	// };
// };

_waitTime = time + 2;
waitUntil {time >= _waitTime};

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

_players = [];
_numPlayers = 0;
{
	if ((alive _x) && (isPlayer _x) && (_x getVariable "isPlaying")) then
	{
		_players pushBackUnique _x;
		_numPlayers = _numPlayers + 1;
	};
} forEach ((getMarkerPos "spawnArea") nearObjects ["Man",100]);

_degreeStep = 360 / _numPlayers;

_pos = (getMarkerPos BRMini_CurrZone);
_degreeCurrent = 0;
{
	if ((alive _x) && (isPlayer _x) && (_x getVariable "isPlaying")) then
	{
		_initialPos = [_pos, (BRMini_ZoneSize - 100), _degreeCurrent] call BIS_fnc_relPos;
		if (surfaceIsWater _initialPos) then
		{
			_landPos = [];
			while {_landPos isEqualTo []} do
			{
				// _landPos = _initialPos findEmptyPosition [1,200];
				_landPos = [_initialPos,10,100,0,1,1,1] call BIS_fnc_findSafePos; // so players don't spawn in water surrounded by piers.
				uiSleep 0.1;
			};
			_landPos set [2,0]; // reset height back to 0 to avoid underwater to in-air glitch.
			_x setPosATL _landPos;
		}
		else
		{
			_x setPosATL _initialPos;
		};
		_x setDir round(random 360);
		_degreeCurrent = _degreeCurrent + _degreeStep;
	};
} forEach _players;
// } forEach ((getMarkerPos "spawnArea") nearObjects ["Man",100]); // max 100m from spawnArea center, default circle is 50m

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

BR_DT_PVAR = ["GO!",0,0.35,5,0];
publicVariable "BR_DT_PVAR";	

"(findDisplay 46) displayRemoveEventHandler ['KeyDown',DISABLE_EVENTS];" call BRMini_RE;

// constantly check for existing players, else end game - soulkobk
// [] spawn {
	// while {BRMini_InGame} do
	// {
		// _waitTime = time + 10;
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// _playerCount = {alive _x && isPlayer _x;} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]);
		// if (_playerCount <= 1) exitWith { BRMini_InGame = false; };
		/////////////////////////////////////////////////////////////////////////////////////////////////
		// waitUntil {time >= _waitTime};
	// };
// };

[] spawn BRGH_fnc_deathMessages;

[] spawn BRGH_fnc_startZoning;

waitUntil {!BRMini_InGame}; // wait until the round has ended!

BRMini_ServerOn = false;

_waitTime = time + 10;
waitUntil {time >= _waitTime};

///////////////////////////////////////////////////////////////////////////////////////////////////
_leftInRound = (getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize];
if ((count _leftInRound) >= 1) then
{
	_playerFinalScoreArr = [];
	{
		if (alive _x && isPlayer _x && _x inArea BRMini_BlackZone) then
		{
			_playerObject = _x;
			_playerName = name _x;
			_playerUID = getPlayerUID _x;
			// _playerKills = getPlayerScores _x select 0;
			// _playerScore = getPlayerScores _x select 5;
			// _playerFinalScore = _playerScore * _playerKills;
			_playerFinalScore = getPlayerScores _x select 5;
			_playerFinalScoreArr pushBackUnique [_playerObject,_playerName,_playerUID,_playerFinalScore];
		};
	} forEach _leftInRound;
///////////////////////////////////////////////////////////////////////////////////////////////////	
	_finalWinners = [_playerFinalScoreArr,[],{_x select 3},"DESCEND"] call BIS_fnc_sortBy;
///////////////////////////////////////////////////////////////////////////////////////////////////	
	if ((count _finalWinners) > 1) then
	{
		for "_i" from 1 to (count _finalWinners) do
		{
			_runnerUpDetails = _finalWinners select _i;
			_runnerUpObject = _runnerUpDetails select 0;
			if (alive _runnerUpObject && isPlayer _runnerUpObject && _runnerUpObject inArea BRMini_BlackZone) then
			{
				_runnerUpObject setDamage 1; // kill the remaining alive players that did not win the round.
			};
		};
	};
///////////////////////////////////////////////////////////////////////////////////////////////////
	_waitTime = time + 5;
	waitUntil {time >= _waitTime}; // wait 5 seconds for killed players to respawn at "spawnArea"
///////////////////////////////////////////////////////////////////////////////////////////////////	
	BRMini_WinnerAnnounce = false; // turn off announcements
	publicVariable "BRMini_WinnerAnnounce";
///////////////////////////////////////////////////////////////////////////////////////////////////	
	if !((count _finalWinners) isEqualTo 0) then
	{
		_finalWinner = _finalWinners select 0;
		_finalWinnerObject = _finalWinner select 0;
		_finalWinnerName = _finalWinner select 1;
		_finalWinnerUID = _finalWinner select 2;
		_finalWinnerScore = _finalWinner select 3;
		///////////////////////////////////////////////////////////////////////////////////////////////////
		diag_log format ["<BRMINI>: %1 ROUND WINNER IS %2 (%3) WITH %4 KILLS",BRMini_CurrZoneName,_finalWinnerName,_finalWinnerUID,_finalWinnerScore];
		///////////////////////////////////////////////////////////////////////////////////////////////////
		_finalWinnerObject setVariable ["BRMini_isWINNER",true,true]; // set the player uniform (winner)
		///////////////////////////////////////////////////////////////////////////////////////////////////
		[_finalWinnerName,_finalWinnerObject] spawn {
			params ["_finalWinnerName","_finalWinnerObject"];
			
			if (isNil "_finalWinnerName") exitWith {}; // if no winner, exit.
			
			_onScreenMessages =
			[
				[format ["CONGRATULATIONS<br/>%1<br/>YOU ARE A<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>- %2 IN ALTIS -<br/>WINNER!",_finalWinnerName,BRMini_CurrZoneName],15]
			];
			
			waitUntil {BRMini_WinnerAnnounce};
			
			(owner _finalWinnerObject) publicVariableClient "BR_WINNER"; // do perty smoke stuff for winner
			
			{
				_currentMessage = _x select 0;
				_currentSleep = _x select 1;
				BR_DT_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
				(owner _finalWinnerObject) publicVariableClient "BR_DT_PVAR"; // to winning client only
				uiSleep _currentSleep;
			} forEach _onScreenMessages;
		};
		///////////////////////////////////////////////////////////////////////////////////////////////////
		[_finalWinnerName] spawn {
			params ["_finalWinnerName"];
			
			if (isNil "_finalWinnerName") exitWith {}; // if no winner, exit.
			
			_onScreenMessages =
			[
				[format ["THE ROUND WINNER OF<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>- %2 IN ALTIS -<br/>WAS<br/>%1",_finalWinnerName,BRMini_CurrZoneName],15]
			];
			
			waitUntil {BRMini_WinnerAnnounce};
			
			{
				_currentMessage = _x select 0;
				_currentSleep = _x select 1;
				BR_RW_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
				publicVariable "BR_RW_PVAR"; // to all players
				uiSleep _currentSleep;
			} forEach _onScreenMessages;
		};
	}
	else
	{
		diag_log format ["<BRMINI>: %1 ROUND WINNER IS NO ONE, EVERYONE DIED!",BRMini_CurrZoneName];
		[] spawn {
			_onScreenMessages =
			[
				[format ["NO ONE WON THE ROUND OF<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>- %1 IN ALTIS -<br/>AS EVERYONE DIED!",BRMini_CurrZoneName],15]
			];
			
			waitUntil {BRMini_WinnerAnnounce};
			
			{
				_currentMessage = _x select 0;
				_currentSleep = _x select 1;
				BR_RW_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
				publicVariable "BR_RW_PVAR"; // to all players
				uiSleep _currentSleep;
			} forEach _onScreenMessages;
		};
	};
///////////////////////////////////////////////////////////////////////////////////////////////////
	_waitTime = time + 5;
	waitUntil {time >= _waitTime}; // wait 5 seconds for threads to spawn
///////////////////////////////////////////////////////////////////////////////////////////////////
	BRMini_WinnerAnnounce = true; // turn on announcements
	publicVariable "BRMini_WinnerAnnounce";
///////////////////////////////////////////////////////////////////////////////////////////////////
	_waitTime = time + 20;
	waitUntil {time >= _waitTime}; // wait 20 seconds after announcement
///////////////////////////////////////////////////////////////////////////////////////////////////
	BRMini_WinnerAnnounce = false; // turn off announcements
	publicVariable "BRMini_WinnerAnnounce";
///////////////////////////////////////////////////////////////////////////////////////////////////
	{
		if (alive _x && isPlayer _x && _x inArea BRMini_BlackZone) then
		{
			_x setDamage 1;
		};
	} forEach _leftInRound; // kill the winning (and remaining/glitched?) players in the round
};
///////////////////////////////////////////////////////////////////////////////////////////////////

// _winners = (getMarkerPos BRMini_CurrZone) nearObjects ["Man",BRMini_ZoneSize];
// {
	// if (alive _x && isplayer _x && _x inArea BRMini_BlackZone) then // winner must be within the black circle aka BRMini_BlackZone
	// {
		// _name = name _x;
		// _uid = getPlayerUID _x;
		
		// diag_log format ["<BRMINI>: %1 ROUND WINNER IS %2 (%3)",BRMini_CurrZoneName,_name,_uid];
		
		// _index = BRMini_Winners find _name;
		// if (_index == -1) then
		// {
			// _index = count(BRMini_Winners);
			// BRMini_Winners set[count(BRMini_Winners),_name];
		// };
		// _score = 0;
		// if (_index < count(BRMini_WinnerScores)) then
		// {
			// _score = (BRMini_WinnerScores select _index);
		// };
		// _score = _score + 1;
		// BRMini_WinnerScores set[_index,_score];
		
		// publicVariable "BR_WINNER"; // initiate celebration smoke client side
		
		// _onScreenMessages =
		// [
			// [format ["CONGRATULATIONS<br/>%1<br/>YOU ARE A<br/><t color='#FF0000'>BATTLE ROYALE CQC</t><br/>- %2 IN ALTIS -<br/>WINNER!",_name,BRMini_CurrZoneName],15]
		// ];
		
		// {
			// _currentMessage = _x select 0;
			// _currentSleep = _x select 1;
			// BR_DT_PVAR = [format ["%1",_currentMessage],0,0.35,_currentSleep,0];
			// publicVariable "BR_DT_PVAR";	
			// uiSleep _currentSleep;
		// } forEach _onScreenMessages;
		
		// uiSleep 10;
		
		// _x setDamage 1;
		
	// };
// } forEach _winners;

_waitTime = time + 10;
waitUntil {time >= _waitTime}; // wait 10 seconds

diag_log "<RESET>: SERVER RESETTING!";

// [[_fogThread,_weatherThread],[]] spawn BRGH_fnc_serverReset;
[[],[]] spawn BRGH_fnc_serverReset;