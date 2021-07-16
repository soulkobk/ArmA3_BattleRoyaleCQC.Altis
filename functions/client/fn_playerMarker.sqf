// fn_playerMarker.sqf 16:32 PM 12/07/2021

if (!hasInterface) exitWith {};

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
			_color = [1,1,1,1];
			(_this select 0) drawIcon [_icon, _color, [(_pos select 0),(_pos select 1)], _iconScale, _iconScale, _dir, "", 0, 0, "RobotoCondensed", "right"];
		};
	}];
};
	
[] spawn {
	waitUntil {!(isNull (uiNamespace getVariable ["RscCustomInfoMiniMap",displayNull] displayCtrl 101))};
	disableSerialization;
	_mapCtrl = uiNamespace getVariable ["RscCustomInfoMiniMap",displayNull] displayCtrl 101;
	unitMarkersGPS = _mapCtrl ctrlAddEventHandler ["Draw", {
		if (isPlayer player) then
		{
			_pos = visiblePosition player;
			_dir = getDir player;
			_icon = getText (configfile >> "CfgVehicles" >> (typeOf player) >> "icon");
			_iconScale = (1 - ctrlMapScale (_this select 0)) min 24 max 24;
			_color = [1,1,1,1];
			(_this select 0) drawIcon [_icon, _color, [(_pos select 0),(_pos select 1)], _iconScale, _iconScale, _dir, "", 0, 0, "RobotoCondensed", "right"];
		};
	}];
};
