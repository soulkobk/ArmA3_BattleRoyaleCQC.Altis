/*
	File: setup_player.sqf
	Description: Initialize unit on server join
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

call BRGH_fnc_playerEvents;

removeAllContainers player;
removeAllWeapons player;
removeAllAssignedItems player;
removeHeadgear player;
removeGoggles player;
removeAllItems player;
player setVariable ["BIS_noCoreConversations", true];
player setVariable ["JoinedGame",true,true];
player disableConversation true;
player enableFatigue false;
player enableStamina false;
player setCustomAimCoef 0.2;

_adminUids =
[
	"76561198044020915" // soulkobk
];
_vips =
[
	"76561198074403824" // stickofish
];

fnc_BRCamera = {};

player linkItem "ItemMap";
player linkItem "ItemGPS";
player linkItem "ItemCompass";
player linkItem "ItemWatch";
player linkItem "NVGoggles_INDEP";

if !((getplayeruid player) in _adminUids) then {
	// player addUniform "U_B_CombatUniform_mcam";
	player addUniform "U_I_CombatUniform";
	if((getplayeruid player) in _vips) then {
		// player addHeadgear "H_Hat_tan";
		fnc_BRCamera = BRGH_fnc_spectate;
		player setVariable ["BRMini_canSpectate",true,true]; // for spectate
		player setVariable ["BRMini_isVIP",true]; // for uniform
	} else {
		fnc_BRCamera = {};
		player setVariable ["BRMini_canSpectate",false,true]; // for spectate
		player setVariable ["BRMini_isCONTENDER",true]; // for uniform
	};	
	// [player,"MANW"] call BIS_fnc_setUnitInsignia;
} else {
	// player addUniform "U_B_CombatUniform_mcam_tshirt";
	player addUniform "U_I_CombatUniform";
	// player addHeadgear "H_Hat_tan";
	fnc_BRCamera = BRGH_fnc_spectate;
	player setVariable ["BRMini_canSpectate",true,true]; // for spectate
	player setVariable ["BRMini_isADMIN",true]; // for uniform
	// [player,"brghID"] call BIS_fnc_setUnitInsignia;
};

[] spawn {
	waitUntil {!isNil "SL_customUniformCheck"};
	waitUntil {((alive player) && !(player getVariable "isPlaying") && (player inArea "spawnArea"))};
	_whileTime = time + 10;
	while {time < _whileTime} do // loop this shit....? buggy af.
	{
		[] spawn SL_customUniformCheck; // custom uniforms
		uiSleep 0.5;
	};
};

diag_log "<PSETUP>: PLAYER SETUP COMPLETE";

