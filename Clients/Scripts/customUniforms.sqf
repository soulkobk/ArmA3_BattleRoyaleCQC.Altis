/*
	----------------------------------------------------------------------------------------------

	Copyright © 2016 soulkobk (soulkobk.blogspot.com)

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as
	published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.

	----------------------------------------------------------------------------------------------

	Name: customUniforms.sqf
	Version: 1.0.0
	Author: soulkobk (soulkobk.blogspot.com)
	Creation Date: 4:47 PM 27/11/2016
	Modification Date: 4:47 PM 27/11/2016

	Parameter(s): none

	Example: none
	
	Change Log:
	1.0.0 -	original base script.
	
	----------------------------------------------------------------------------------------------
*/

if (!hasInterface) exitWith {};  // DO NOT DELETE THIS LINE!

_playerCustomUniforms =
[
	["BRCQCWINNER","U_I_CombatUniform","Images\BRCQCUniformWINNER.jpg"],
	["BRCQCADMIN","U_I_CombatUniform","Images\BRCQCUniformADMIN.jpg"],
	["BRCQCVIP","U_I_CombatUniform","Images\BRCQCUniformVIP.jpg"],
	["BRCQCCONTENDER","U_I_CombatUniform","Images\BRCQCUniformCONTENDER.jpg"]
];

/*	------------------------------------------------------------------------------------------
	DO NOT EDIT BELOW HERE!
	------------------------------------------------------------------------------------------	*/

SL_customUniformCheck = {
	waitUntil {((alive player) && !(player getVariable "isPlaying") && (player inArea "spawnArea"))};
	if ((uniform player == SL_customUniformClassBRCQCWINNER) && (player getVariable ["BRMini_isWINNER",false])) exitWith
	{
		player setObjectTextureGlobal [0,SL_customUniformTextureBRCQCWINNER];
	};
	if ((uniform player == SL_customUniformClassBRCQCADMIN) && (player getVariable ["BRMini_isADMIN",false])) exitWith
	{
		player setObjectTextureGlobal [0,SL_customUniformTextureBRCQCADMIN];
	};
	if ((uniform player == SL_customUniformClassBRCQCVIP) && (player getVariable ["BRMini_isVIP",false])) exitWith
	{
		player setObjectTextureGlobal [0,SL_customUniformTextureBRCQCVIP];
	};
	if (uniform player == SL_customUniformClassBRCQCCONTENDER) exitWith
	{
		player setObjectTextureGlobal [0,SL_customUniformTextureBRCQCCONTENDER];
	};
};
	
if !(_playerCustomUniforms isEqualTo []) then
{
	{
		_customUniformSide = _x select 0;
		switch (_customUniformSide) do
		{
			case "BRCQCWINNER": {
				SL_customUniformClassBRCQCWINNER = _x select 1;
				SL_customUniformTextureBRCQCWINNER = _x select 2;
				};
			case "BRCQCADMIN": {
				SL_customUniformClassBRCQCADMIN = _x select 1;
				SL_customUniformTextureBRCQCADMIN = _x select 2;
				};
			case "BRCQCVIP": {
				SL_customUniformClassBRCQCVIP = _x select 1;
				SL_customUniformTextureBRCQCVIP = _x select 2;
				};
			case "BRCQCCONTENDER": {
				SL_customUniformClassBRCQCCONTENDER = _x select 1;
				SL_customUniformTextureBRCQCCONTENDER = _x select 2;
				};
		};
		player addEventHandler ["Take", {
			_unit = _this select 0;
			_container = _this select 1;
			_item = _this select 2;
			if ((_item == SL_customUniformClassBRCQCWINNER) && (uniform _unit == SL_customUniformClassBRCQCWINNER) && (_unit getVariable ["BRMini_isWINNER",false])) exitWith
			{
				_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCWINNER];
			};
			if ((_item == SL_customUniformClassBRCQCADMIN) && (uniform _unit == SL_customUniformClassBRCQCADMIN) && (_unit getVariable ["BRMini_isADMIN",false])) exitWith
			{
				_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCADMIN];
			};
			if ((_item == SL_customUniformClassBRCQCVIP) && (uniform _unit == SL_customUniformClassBRCQCVIP) && (_unit getVariable ["BRMini_isVIP",false])) exitWith
			{
				_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCVIP];
			};
			if ((_item == SL_customUniformClassBRCQCCONTENDER) && (uniform _unit == SL_customUniformClassBRCQCCONTENDER)) exitWith
			{
				_unit setObjectTextureGlobal [0,SL_customUniformTextureBRCQCCONTENDER];
			};
		}];
		[] spawn SL_customUniformCheck;
	} forEach _playerCustomUniforms;
};
