#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>
#define UPDATE_URL    "http://bitbucket.toastdev.de/sourcemod-plugins/raw/master/CTAuth-Stamm.txt"
public Plugin:myinfo =
{
	name = "CT Auth",
	author = "Toast",
	description = "A stamm feature for joining CT Team",
	version = "1.0.0",
	url = "bitbucket.org/Toastbrot_290"
}

public OnAllPluginsLoaded()
{
	if (!STAMM_IsAvailable()) 
	{
		SetFailState("Can't Load Feature, Stamm is not installed!");
	}
	STAMM_LoadTranslation();
	decl String:Name[32];
	Format(Name, sizeof(Name), "%T", "Name", LANG_SERVER);
	STAMM_RegisterFeature(Name);
}
public STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array)
{
	decl String:description[256];
	Format(description, sizeof(description), "%T", "CTAuthDescription", LANG_SERVER);
	
	PushArrayString(array, description);
}
public OnPluginStart()
{
	AddCommandListener(TeamJoin, "jointeam");
	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
public Action:TeamJoin(client, const String:command[], args)
{
	if(!IsClientInGame(client) || !STAMM_IsClientValid(client)){
		return Plugin_Stop;
	}
	new String:Team[2];
	GetCmdArg(1, Team, sizeof(Team));
	new TargetTeam = StringToInt(Team);
	
	if(TargetTeam == 3 || TargetTeam == 0)
	{
		new String:StammTag[64];
		STAMM_GetTag(StammTag, sizeof(StammTag));
		new block = STAMM_GetBlockOfName("ctaccess");
		if(STAMM_HaveClientFeature(client, block) && STAMM_WantClientFeature(client)){
			return Plugin_Continue;
		}
		if(STAMM_GetClientLevel(client) >= STAMM_GetBlockLevel(block))
		{
			STAMM_PrintToChat(client, "%s %t", StammTag, "error_activate_feature");
			PrintCenterText(client, "%t %t", "StammTagPlain", "error_activate_feature_plain");
			
		}
		else{
			decl String:levelname[64];
			STAMM_GetLevelName(STAMM_GetBlockLevel(block), levelname, sizeof(levelname));
			STAMM_PrintToChat(client, "%s %t", StammTag, "error_no_level", levelname);
			PrintCenterText(client, "%t %t", "StammTagPlain", "error_no_level_plain", levelname);
		}
		if(TargetTeam == 0){
			ChangeClientTeam(client, 2);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
	
}