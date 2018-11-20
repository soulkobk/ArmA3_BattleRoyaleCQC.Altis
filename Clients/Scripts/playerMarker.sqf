// ************************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2016 soulkobk.blogspot.com *
// ************************************************************************************************
//	@file Version: 1.0
//	@file Name: playerMarkers.sqf
//	@file Author: soulkobk (soulkobk.blogspot.com)
//	@file Created: 8:50 PM 20/05/2016
//	@file Modified: 8:50 PM 20/05/2016
//	@file Args:

[] spawn {
	waitUntil {(!isNull (findDisplay 12 displayCtrl 51))};
	disableSerialization;
	_mapCtrl = findDisplay 12 displayCtrl 51;
	unitMarkersMap = _mapCtrl ctrlAddEventHandler ["Draw", {
		if (isPlayer player) then
		{
			_pos = visiblePosition player;
			_dir = getDir player;
			_icon = getText (configfile >> "CfgVehicles" >> (typeOf player) >> "icon");
			_iconScale = (1 - ctrlMapScale (_this select 0)) min 24 max 24;
			_color = [0,0.501961,0,1];
			(_this select 0) drawIcon [_icon, _color, [(_pos select 0),(_pos select 1)], _iconScale, _iconScale, _dir, "", 0, 0, "RobotoCondensed", "right"];
		};
	}];
};
	
[] spawn {
	waitUntil {(!isNull (uiNamespace getVariable ["RscMiniMap", displayNull]))};
	disableSerialization;
	_mapCtrl = uiNamespace getVariable ["RscMiniMap", displayNull] displayCtrl 101;
	unitMarkersGPS = _mapCtrl ctrlAddEventHandler ["Draw", {
		if (isPlayer player) then
		{
			_pos = visiblePosition player;
			_dir = getDir player;
			_icon = getText (configfile >> "CfgVehicles" >> (typeOf player) >> "icon");
			_iconScale = (1 - ctrlMapScale (_this select 0)) min 24 max 24;
			_color = [0,0.501961,0,1];
			(_this select 0) drawIcon [_icon, _color, [(_pos select 0),(_pos select 1)], _iconScale, _iconScale, _dir, "", 0, 0, "RobotoCondensed", "right"];
		};
	}];
};
