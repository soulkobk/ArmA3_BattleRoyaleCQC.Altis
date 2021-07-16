// fn_playerSetup.sqf 15:55 PM 12/07/2021

if (!hasInterface) exitWith {};

player addRating 99999999999999999999;
player setDamage 0;
player allowDamage false;
player disableConversation true;
player enableAimPrecision false;
player enableFatigue false;
player enableStamina false;
player setCustomAimCoef 0.1;

player setUnitTrait ["loadCoef",9999];
player setUnitTrait ["medic",true];
player setUnitTrait ["engineer",true];

player setCaptive false;

player setVariable ["BRCQC_var_clientOwner",clientOwner,true];
player setVariable ["BRCQC_var_isPlaying",false,true];

player setVariable ["BIS_noCoreConversations",true,false];

player setSpeaker "NoVoice";

player switchCamera "External";
player switchMove "";

enableEnvironment [false,true];
enableSaving [false,false];
enableSentences false;
enableRadio false;

showSubtitles false;

setObjectViewDistance [1000,0];
setViewDistance 750;

removeAllContainers player;
removeAllWeapons player;
removeAllAssignedItems player;
removeHeadgear player;
removeGoggles player;
removeAllItems player;
player linkItem "ItemMap";
player linkItem "ItemGPS";
player linkItem "ItemCompass";
player linkItem "ItemWatch";
player linkItem "NVGoggles_INDEP";

if ((player getVariable ["BRCQC_var_isWinner",false]) isEqualTo true) then
{
	player forceAddUniform "U_O_R_Gorka_01_black_F";
}
else
{
	player forceAddUniform "U_O_R_Gorka_01_F";
};

// player forceAddUniform "U_I_CombatUniform";
// player forceAddUniform "U_C_ConstructionCoverall_Blue_F";
// player forceAddUniform "U_C_WorkerCoveralls";

0 enableChannel [true,false]; // global
1 enableChannel [false,false]; // side
2 enableChannel [false,false]; // command
3 enableChannel [false,false]; // group
4 enableChannel [false,false]; // vehicle
5 enableChannel [true,true]; // direct

if (score player < 0) then
{
	_score = abs(score player);
	[player,+_score] remoteExec ["addScore",2]; // reset score back to 0
}
else
{
	_score = abs(score player);
	[player,-_score] remoteExec ["addScore",2]; // reset score back to 0
};

[] spawn
{
	waitUntil {!isNull findDisplay 46};
	showGPS true;
};
