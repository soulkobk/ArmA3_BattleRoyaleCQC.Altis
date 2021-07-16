// fn_playZoneLoop.sqf 17:01 PM 12/07/2021

if (!isServer) exitWith {};

waitUntil {!isNil "BRCQC_var_initServerComplete"};

BRCQC_var_playZoneLoopText = "";

while {true} do
{
//////////////////////////////////////////////////////////////////////////////

	diag_log "[BRCQC] ---------------------------------------------------------";

	// init location
	BRCQC_var_playZoneLocation = true;
	[] spawn BRCQC_fnc_locationInit;
	BRCQC_var_playZoneLoopText = "locationInit";
	waitUntil {BRCQC_var_playZoneLocation isEqualTo false};

	diag_log format ["[BRCQC] LOCATION CHOSEN FOR ROUND IS %1",BRCQC_var_playZoneLocationText];

	// init loot
	BRCQC_var_playZoneLoot = true;
	[] spawn BRCQC_fnc_lootInit;
	BRCQC_var_playZoneLoopText = "lootInit";
	waitUntil {BRCQC_var_playZoneLoot isEqualTo false};

///////////////////////////////////////////////////////////////////////////////

	// wait for min num of players...
	diag_log format ["[BRCQC] WAITING FOR MINIMUM NUMBER OF PLAYERS (%1)",BRCQC_var_minPlayers];

	BRCQC_var_playZoneLoopText = "playersInit";
	waitUntil {BRCQC_var_playZoneInProgress isEqualTo true};

	diag_log "[BRCQC] ROUND INITIATED";

///////////////////////////////////////////////////////////////////////////////

	// init setup players
	BRCQC_var_playZoneSetupPlayers = true;
	[] spawn BRCQC_fnc_playersSetupInit;
	BRCQC_var_playZoneLoopText = "playersSetupInit";
	waitUntil {BRCQC_var_playZoneSetupPlayers isEqualTo false};

///////////////////////////////////////////////////////////////////////////////

	// init death messages
	BRCQC_var_playZoneDeathMessages = true;
	[] spawn BRCQC_fnc_deathMessagesInit;
	BRCQC_var_playZoneLoopText = "DeathMessagesInit";
	waitUntil {BRCQC_var_playZoneDeathMessages isEqualTo false};

	diag_log "[BRCQC] ZONING INITIATED";

	// init zoning
	BRCQC_var_playZoneZoning = true;
	// diag_log "[BRCQC] ZONING IS INITIATED";
	[] spawn BRCQC_fnc_zoningInit;
	BRCQC_var_playZoneLoopText = "zoningInit";
	waitUntil {BRCQC_var_playZoneZoning isEqualTo false};
	
	diag_log "[BRCQC] ZONING COMPLETE";

///////////////////////////////////////////////////////////////////////////////

	// init winner
	BRCQC_var_playZoneWinner = true;
	[] spawn BRCQC_fnc_winnerInit;
	BRCQC_var_playZoneLoopText = "winnerInit";
	waitUntil {BRCQC_var_playZoneWinner isEqualTo false};

	// init clean up
	BRCQC_var_playZoneCleanUp = true;
	[] spawn BRCQC_fnc_cleanUpInit;
	BRCQC_var_playZoneLoopText = "cleanUpInit";
	waitUntil {BRCQC_var_playZoneCleanUp isEqualTo false};
	
	diag_log "[BRCQC] CLEAN UP COMPLETE";

///////////////////////////////////////////////////////////////////////////////

	diag_log "[BRCQC] ROUND COMPLETE";

	BRCQC_var_playZoneInProgress = false;

///////////////////////////////////////////////////////////////////////////////
};