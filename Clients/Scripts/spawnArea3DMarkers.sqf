// soulkobk

unitSpawnAreaMarkers = addMissionEventHandler ["Draw3D", {
	if (alive player && player inArea "spawnArea" && !(player getVariable ["isPlaying",false])) then
	{
		{
			if (alive _x && _x inArea "spawnArea" && !(_x getVariable ["isPlaying",false])) then
			{
				drawIcon3D [
					'',
					getArray(configFile >> "CfgInGameUI" >> "SideColors" >> "colorFriendly"),
					[
						((ASLToAGL (eyePos _x)) select 0),
						((ASLToAGL (eyePos _x)) select 1),
						((ASLToAGL (eyePos _x) select 2)) + 0.5
					],
					0,
					0,
					0,
					(name _x),
					2,
					0.05,
					'PuristaMedium'
				];
			};
		} count allUnits;
	};
}];
