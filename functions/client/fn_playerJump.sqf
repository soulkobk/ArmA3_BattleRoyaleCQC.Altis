// fn_playerJump.sqf 16:32 PM 12/07/2021

if (!hasInterface) exitWith {};

BRCQC_jumpBaseHeight = 1.80;
BRCQC_jumpMaxHeight = 3.50;
BRCQC_jumpBaseSpeed = 0.40;
BRCQC_jumpAnimation = "AovrPercMrunSrasWrflDf";

"BRCQC_fn_jumpOverAnim" addPublicVariableEventHandler {
	(_this select 1) spawn BRCQC_fn_doAnim;
};

BRCQC_fn_doAnim =
{    
    params ["_unit","_velocity","_direction","_speed","_height","_anim"];
	_unit setVelocity [(_velocity select 0) + (sin _direction * _speed), (_velocity select 1) + (cos _direction * _speed), ((_velocity select 2) * _speed) + _height];
	_unit switchMove _anim;
};

BRCQC_fn_jumpOver = {
	params ["_displayCode","_keyCode","_isShift","_isCtrl","_isAlt"];
	_handled = false;
	if ((_keyCode in actionKeys "GetOver" && _isShift) && (animationState player != BRCQC_jumpAnimation)) then {
		private ["_height","_velocity","_direction","_speed"];
		if ((player == vehicle player) && (isTouchingGround player) && ((stance player == "STAND") || (stance player == "CROUCH"))) exitWith
		{
			_height = (BRCQC_jumpBaseHeight - (load player)) max BRCQC_jumpMaxHeight;
			_velocity = velocity player;
			_direction = direction player;
			_speed = BRCQC_jumpBaseSpeed;
			player setVelocity [(_velocity select 0) + (sin _direction * _speed), (_velocity select 1) + (cos _direction * _speed), ((_velocity select 2) * _speed) + _height];
			BRCQC_fn_jumpOverAnim = [player,_velocity,_direction,_speed,_height,BRCQC_jumpAnimation];
			publicVariable "BRCQC_fn_jumpOverAnim";
			if (currentWeapon player == "") then // half working buggy 'fix' for having no weapon in hands (no animation available for it... BIS!!)
			{
				player switchMove BRCQC_jumpAnimation;
				player playMoveNow BRCQC_jumpAnimation;
			}
			else
			{
				player switchMove BRCQC_jumpAnimation;
			};
			_handled = true;
		};
	};
	_handled
};

waituntil {!(isNull (findDisplay 46))};
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call BRCQC_fn_jumpOver;"];
