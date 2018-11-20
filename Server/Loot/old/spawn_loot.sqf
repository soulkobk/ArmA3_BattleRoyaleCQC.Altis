/*
	Modified By: soulkobk (2015-11-25)
*/

_showLoot = true;
_markerColor = "colorBlack";

BRMini_LootSpawned = false;
LOOT_OBJECTS = [];

_startTime = round(diag_tickTime);

// _buildingArr = (getMarkerPos BRMini_CurrZone) nearObjects ["HouseBase",BRMini_ZoneSize];
_buildingArr = nearestObjects [(getMarkerPos BRMini_CurrZone),["House","HouseBase","Ruins","House_F","Ruins_F"],BRMini_ZoneSize];
// _buildingArr = nearestObjects [(getMarkerPos BRMini_CurrZone),["ALL"],BRMini_ZoneSize];
_buildingPosArr = [];

// {
	// _numBuildingPos = count (_x buildingPos -1);
	// for [{_y = 0},{_y < (_numBuildingPos -1)},{_y =_y + 1}] do
	// {
		// _buildingPos = _x buildingPos _y;
		// if (str _buildingPos != "[0,0,0]") then
		// {
			// if (!(_buildingPos in _buildingPosArr)) then
			// {
				// _buildingPosArr pushBack _buildingPos;
			// };
		// };
	// };
// } forEach _buildingArr;

{
	_numBuildingPos = count (_x buildingPos -1);
	if (_numBuildingPos > 0) then
	{
		for [{_y = 0},{_y < (_numBuildingPos -1)},{_y =_y + 1}] do
		{
			_buildingPos = _x buildingPos _y;
			if !(_buildingPos isEqualTo [0,0,0]) then
			{
				_buildingPosArr pushBackUnique _buildingPos;
			};
		};
	};
} forEach _buildingArr;

_weaponHolder = "";
_objBase = "";

diag_log format ["<BRMINI>: %1 SPAWNING LOOT AT %2 POSITIONS...",BRMini_CurrZoneName,(count _buildingPosArr)];

// for [{_i = 0},{_i < (count _buildingPosArr)},{_i =_i + 1}] do
// {
	// LOOT_OBJECTS set [count(LOOT_OBJECTS),_weaponHolder];
	// _pos = _buildingPosArr select _i;
	// _pos set [2,(_pos select 2) - 0.1];
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	// _pos set [2,(_pos select 2) + 0.1];
	// _placementObject = createVehicle ["Land_BarrelEmpty_F",_pos, [], 0, "CAN_COLLIDE"];
	// _placementObject setVelocity [0,0,0.5];
	// uiSleep 0.1;
	// _pos = getPosATL _placementObject;
	// deleteVehicle _placementObject;
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	// if !(_pos isEqualTo [0,0,0]) then
	// {
		// _weaponHolder = createVehicle ["groundWeaponHolder",_pos, [], 0, "CAN_COLLIDE"];
		// _weaponHolder = createVehicle ["weaponHolderSimulated",_pos, [], 0, "CAN_COLLIDE"];
		// _usedTypes = [];
		// for "_j" from 1 to (2 max floor(random(5))) do
		// {
			// _loot = BRMini_Loot select floor(random(count(BRMini_Loot)));
	/////////////////////////////////////////////////////////////////////////////////////////////			
			// _loot = selectRandom BRMini_Loot; // soulkobk
			// _lootName = _loot select 0;
			// _lootType = _loot select 1;
			// _lootChance = _loot select 2;
			// _lootAmount = _loot select 3;
			// switch (_lootChance) do // soulkobk
			// {
				// case 0:{_lootChance = 0}; // (100%) soulkobk
				// case 1:{_lootChance = floor(round(random(2 - 1)));}; // 2 - 1 = 0,1 (50%) soulkobk
				// case 2:{_lootChance = floor(round(random(4 - 1)));}; // 4 - 1 = 0,1,2,3 (25%) soulkobk
				// case 3:{_lootChance = floor(round(random(8 - 1)));}; // 8 - 1 = 0,1,2,3,4,5,6,7 (12.5%) soulkobk
			// };
	/////////////////////////////////////////////////////////////////////////////////////////////
			// if (_lootChance == 0 && !(_lootType in _usedTypes)) then
			// {
				// _usedTypes set [count(_usedTypes),_lootType];
				// switch (_lootType) do {
					// case 0: {_weaponHolder addMagazineCargoGlobal[_lootName,_lootAmount];};
					// case 1: {
						// _weaponHolder addWeaponCargoGlobal[_lootName,_lootAmount];
						// _magArray = getArray(configFile >> "cfgWeapons" >> _lootName >> "Magazines");
						// _magType = _magArray select floor(random(count(_magArray)));
						// _weaponHolder addMagazineCargoGlobal[_magType,3];
					// };
					// case 2: {_weaponHolder addItemCargoGlobal[_lootName,_lootAmount];};
					// case 3: {_weaponHolder addBackpackCargoGlobal[_lootName,_lootAmount];};
				// };
			// };
		// };
		// _pos set [2, (_pos select 2) - ((getPos _weaponHolder) select 2)];
		// _weaponHolder setPosATL _pos;
	// };
// };

getRandomLoot = {

		_loot = selectRandom BRMini_Loot; // soulkobk
		_lootName = _loot select 0;
		_lootType = _loot select 1;
		// _lootChance = _loot select 2;
		_lootChance = 0; // force set to 100%
		_lootAmount = _loot select 3;
		switch (_lootChance) do // soulkobk
		{
			case 0:{_lootChance = 0}; // (100%) soulkobk
			case 1:{_lootChance = floor(round(random(2 - 1)));}; // 2 - 1 = 0,1 (50%) soulkobk
			case 2:{_lootChance = floor(round(random(4 - 1)));}; // 4 - 1 = 0,1,2,3 (25%) soulkobk
			case 3:{_lootChance = floor(round(random(8 - 1)));}; // 8 - 1 = 0,1,2,3,4,5,6,7 (12.5%) soulkobk
		};
		// return the array
		[_lootChance,_lootName,_lootType,_lootAmount]
};

spawnWeaponHolder = {
	for "_i" from 1 to 5 do // loop max 5 times to create a weapon holder due to engine issues deleting the holder on first attempt
	{
		_weaponHolder = objNull;
		while {_weaponHolder isEqualTo objNull} do
		{
			_weaponHolder = createVehicle ["weaponHolderSimulated", _pos, [], 0, "CAN_COLLIDE"];
		};
		
		if !(_weaponHolder isEqualTo objNull) exitWith // exit loop if _weaponHolder exists
		{
			_weaponHolder allowDamage false;
			_weaponHolder setDir round(random 360);
			_weaponHolder setVectorUP (surfaceNormal [(getPosATL _weaponHolder select 0),(getPosATL _weaponHolder select 1)]);
			diag_log format ["[!] CRATE HOLDER SPAWNED! LOOP %1 (%2)",_i,_weaponHolder];
		};
	};
	_weaponHolder
};

	///////////////////////////////////////////////////////////////////////////////////////////////		
	_cfgEntry = [];
	
	for "_i" from 0 to count (configFile / "CfgWeapons") - 1 do 
	{
		_entry = ((configFile / "CfgWeapons") select _i);
		_cfgEntry pushBackUnique (configName _entry);
		
	};
	
	for "_i" from 0 to count (configFile / "CfgMagazines") - 1 do 
	{
		// store current config entry
		_entry = ((configFile / "CfgMagazines") select _i);
		_cfgEntry pushBackUnique (configName _entry);
	};
	
	for "_i" from 0 to count (configFile / "CfgVehicles") - 1 do 
	{
		_entry = ((configFile / "CfgVehicles") select _i);
		_cfgEntry pushBackUnique (configName _entry);
	};

	///////////////////////////////////////////////////////////////////////////////////////////////		

for [{_i = 0},{_i < (count _buildingPosArr)},{_i =_i + 1}] do
{
	_markerText = "";
	LOOT_OBJECTS set [count(LOOT_OBJECTS),_weaponHolder];
	_pos = _buildingPosArr select _i;
	if !(_pos isEqualTo [0,0,0]) then
	{
		_weaponHolder = call spawnWeaponHolder;
		_weaponHolder addItemCargoGlobal ["ItemGPS", 1]; // add something to it so it doesnt disappear

		for "_lootLoop" from 1 to 3 do // do 3 loops per loot position
		{
			///////////////////////////////////////////////////////////////////////////////////////////////
			_lootChance = 1;
			_randomLoot = [];
			_loopedTimes = 0;
			while {!(_lootChance isEqualTo 0)} do // make sure EVERY possible spot has loot
			{
				_randomLoot = call getRandomLoot;
				_lootChance = _randomLoot select 0;
				_loopedTimes = _loopedTimes + 1;
				uiSleep 0.1;
			};
			_lootName = _randomLoot select 1;
			_lootType = _randomLoot select 2;
			_lootAmount = _randomLoot select 3;
			
			if !(_lootName in _cfgEntry) then
			{
				diag_log format ["<LOOT SPAWN> %1 is an invalid class name!",_lootName];
			};
			
			///////////////////////////////////////////////////////////////////////////////////////////////

			// if (_weaponHolder isEqualTo objNull) then
			// {
				// diag_log format ["[X] CRATE HOLDER SPAWNED, DISAPPEARED, ATTEMPTING TO RESPAWN! (%1)",_weaponHolder];
				
				// _weaponHolder = objNull;
				// while {_weaponHolder isEqualTo objNull} do
				// {
					// _weaponHolder = call spawnWeaponHolder;
				// };
				
				// if (_weaponHolder isEqualTo objNull) then
				// {
					// diag_log format ["[X] CRATE HOLDER SPAWNED, FAILED! (%1)",_weaponHolder];
				// }
				// else
				// {
					// diag_log format ["[!] CRATE HOLDER SPAWNED, SUCCESS! (%1)",_weaponHolder];
				// };
				
			// };
			
			// if (_lootType isEqualTo 0) then
			// {
				// _weaponHolder = call spawnWeaponHolder;
				// _weaponHolder addMagazineCargoGlobal [_lootName,_lootAmount];
			// };
			// if (_lootType isEqualTo 1) then
			// {
				// _weaponHolder = call spawnWeaponHolder;
				// _weaponHolder addWeaponCargoGlobal [_lootName,_lootAmount];
				// _magArray = getArray(configFile >> "cfgWeapons" >> _lootName >> "Magazines");
				// _magType = _magArray select floor(random(count(_magArray)));
				// _weaponHolder addMagazineCargoGlobal [_magType,3];
			// };
			// if (_lootType isEqualTo 2) then
			// {
				// _weaponHolder = call spawnWeaponHolder;
				// _weaponHolder addItemCargoGlobal [_lootName,_lootAmount];
			// };
			// if (_lootType isEqualTo 3) then
			// {
				// _weaponHolder = call spawnWeaponHolder;
				// _weaponHolder addBackpackCargoGlobal [_lootName,_lootAmount];
			// };
			
			// if (_weaponHolder isEqualTo objNull) then
			// {
				// _weaponHolder = call spawnWeaponHolder;
				// diag_log format ["[X] CRATE HOLDER SPAWNED, DISAPPEARED, ATTEMPTING TO RESPAWN! (%1)",_weaponHolder];
			// };
			_markerText = format ["%1 - %2",_markerText,_lootName];
			clearItemCargoGlobal _weaponHolder; // clear the item cargo before adding other items
			switch (_lootType) do
			{
				case 0: {
					// _weaponHolder = call spawnWeaponHolder;
					_weaponHolder addMagazineCargoGlobal [_lootName,_lootAmount];
				};
				case 1: {
					// _weaponHolder = call spawnWeaponHolder;
					_weaponHolder addWeaponCargoGlobal [_lootName,_lootAmount];
					_magArray = getArray(configFile >> "cfgWeapons" >> _lootName >> "Magazines");
					_magType = _magArray select floor(random(count(_magArray)));
					_weaponHolder addMagazineCargoGlobal [_magType,3];
				};
				case 2: {
					// _weaponHolder = call spawnWeaponHolder;
					_weaponHolder addItemCargoGlobal [_lootName,_lootAmount];
				};
				case 3: {
					// _weaponHolder = call spawnWeaponHolder;
					_weaponHolder addBackpackCargoGlobal [_lootName,_lootAmount];
				};
			};
		};
			
			if (_showLoot) then
			{
				_posLoot = (getPosATL _weaponHolder);
				_id = format ["%1-LOOT",_posLoot];
				_mkrLoot = createMarker [_id,_posLoot];
				_mkrLoot setMarkerShape "ICON";
				_mkrLoot setMarkerType "mil_dot";
				_txt = format ["%1",_markerText];
				_mkrLoot setMarkerText _txt;
				_mkrLoot setMarkerColor _markerColor;
				_mkrLoot setMarkerAlpha 1;
				_mkrLoot setMarkerSize [1,1];
			};

	};
};

_endTime = round(diag_tickTime);
_totalTime = round(_endTime - _startTime);

diag_log format ["<BRMINI>: %1 SPAWNED LOOT IN %2 SECOND(S)",BRMini_CurrZoneName,_totalTime];
// hint format ["<BRMINI>: Spawned loot in %1 second(s)",_totalTime];
BRMini_LootSpawned = true;