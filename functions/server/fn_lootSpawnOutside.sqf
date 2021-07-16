// original script by BangaBob, heavily modified by soulkobk

if (isServer) then
{
	_pos = (_this select 0);
	_pos0 = (_pos select 0);
	_pos1 = (_pos select 1);
	_pos2 = (_pos select 2);
	_showLoot = (_this select 1);
	
	_pos2 = 0.02; // reset and adjust it up slightly from 0m ATL

	_holder = createVehicle ["groundWeaponHolder",[_pos0,_pos1,_pos2], [], 0, "CAN_COLLIDE"];
	
	_debugLoot = "";
	
	_KK_fnc_arrayShuffle = {
		private "_cnt";
		_cnt = count _this;
		for "_i" from 1 to _cnt do {
			_this pushBack (_this deleteAt floor random _cnt);
		};
		_this
	};
	
	for "_i" from 0 to (floor(round(random 2) + 1)) do // min 1, max 3
	{
		_typeArr = [0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7] call _KK_fnc_arrayShuffle; // shuffle the array, thanks to KillzoneKid
		_type = selectRandom _typeArr; // select a random number from the shuffled array

		_debugLoot = format ["%1 - %2",_debugLoot,_type];
		
		switch (_type) do
		{
			case 0: { // weapon
				_weaponArr = weaponsLoot call _KK_fnc_arrayShuffle;
				_weapon = selectRandom _weaponArr;
				_magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
				_magazineClass = selectRandom _magazines; 
				_holder addWeaponCargoGlobal [_weapon, 1];
				_holder addMagazineCargoGlobal [_magazineClass, (round(random 2) + 1)]; // at least 1 magazine, max 3
			};
			case 1: { // item
				_itemArr = itemsLoot call _KK_fnc_arrayShuffle;
				_item = selectRandom _itemArr;
				_holder addItemCargoGlobal [_item, 1];
			};
			case 2: { // clothing
				_clothingArr = clothesLoot call _KK_fnc_arrayShuffle;
				_clothing = selectRandom _clothingArr;
				_holder addItemCargoGlobal [_clothing, 1];
			};
			case 3: { // vest
				_vestArr = vestsLoot call _KK_fnc_arrayShuffle;
				_vest = selectRandom _vestArr;
				_holder addItemCargoGlobal [_vest, 1];
			};
			case 4: { // medical
				_medicalArr = medicalLoot call _KK_fnc_arrayShuffle;
				_medical = selectRandom _medicalArr;
				_holder addItemCargoGlobal [_medical, 1];
			};
			case 5: { // grenades/mines
				_minesArr = grenadeMineLoot call _KK_fnc_arrayShuffle;
				_mine = selectRandom _minesArr;
				_holder addItemCargoGlobal [_mine, 1];
			};
			case 6: { // backpack
				_backpackArr = backpacksLoot call _KK_fnc_arrayShuffle;
				_backpack = selectRandom _backpackArr;
				_holder addBackpackCargoGlobal [_backpack, 1];
			};
			case 7: { // magazines
				_weaponArr = weaponsLoot call _KK_fnc_arrayShuffle;
				_weapon = selectRandom _weaponArr;
				_magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
				_magazineClass = selectRandom _magazines; 
				_holder addMagazineCargoGlobal [_magazineClass, (round(random 4) + 1)]; // at least 1 magazine, max 5
			};
		};
	};
	
	_holder enableSimulationGlobal false;
	_holder enableDynamicSimulation true;
	
	if (_showLoot) then
	{			
		_id = format ["LOOT_%1",_pos];
		_debug = createMarker [_id, getPos _holder];
		_debug setMarkerShape "ICON";
		_debug setMarkerType "hd_dot";
		_debug setMarkerColor "ColorRed";
		_txt = format ["%1",_debugLoot];
		_debug setMarkerText _txt;	
	};
};
