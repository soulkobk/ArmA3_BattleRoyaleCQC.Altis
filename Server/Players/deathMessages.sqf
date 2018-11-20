/*
	File: deathMessages.sqf
	Description: Player death messages for BRGH
	Created By: Lystic
	Date: 10/20/2014
	Parameters: n/a
	Returns: n/a
	Modified By: soulkobk (2015-11-25)
*/

uiSleep 10;

_count = {alive _x && isPlayer _x;} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]);
_original = _count;

while {true} do
{
	waitUntil {!BRMini_InGame || _count != ({alive _x && isplayer _x;} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]))};
	
	_count = {alive _x && isplayer _x;} count((getMarkerPos BRMini_CurrZone) nearObjects ["Man",(BRMini_ZoneSize * 2)]); // update count
	
	if (!BRMini_InGame || _count <= 1) exitWith {}; // if game ended or lessthan or equal to 1 player, exit routine.
	// BR_DT_PVAR = [format["%2 DEAD, %1 TO GO!",_count,_original - _count],0,0.45,5,0,0,9876]; // layer 9876 so to not conflict with zoning messages.
	// BR_DT_PVAR = [format["%2 DEAD, %1 TO GO!",_count,_original - _count],0,-0.35,5,0,0,9876]; // layer 9876 so to not conflict with zoning messages.
	BR_DT_PVAR = [format["%2 DEAD, %1 TO GO!",_count,_original - _count],0,-0.30,5,0,0,9876]; // layer 9876 so to not conflict with zoning messages.
	publicVariable "BR_DT_PVAR"; // pubvar that shiz

};

BRMini_InGame = false;
