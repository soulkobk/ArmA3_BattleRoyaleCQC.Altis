// fn_serverInit.sqf 16:29 PM 14/07/2021

_backSlash = "";
if (!hasInterface) then
{
    _backSlash = "\";
};

if (loadFile (_backSlash + "OWP_Server\init.sqf") != "") then
{
	[] execVM (_backSlash + "OWP_Server\init.sqf");
	diag_log format ["[OWP] [OWP EDIT] %1OWP_Server\init.sqf FOUND, EXECUTED!",_backSlash];
}
else
{
	diag_log format ["[OWP] [OWP EDIT] %1OWP_Server\init.sqf NOT FOUND, ERROR!",_backSlash];
};
