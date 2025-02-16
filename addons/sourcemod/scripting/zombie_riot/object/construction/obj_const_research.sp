#pragma semicolon 1
#pragma newdecls required

static const char Artifacts[][] =
{
	"Founder Fondue",
	"Predator Pancakes",
	"Brandguider Brunch",
	"Spewer Spewers",
	"Swarmcaller Sandwich",
	"Reefbreaker Ravioli"
};

static const int WaterCost = 10;
static const int BofaCost = 30;

static int NPCId;
static float GlobalCooldown;
static bool Shuffled;
static bool Enabled[sizeof(Artifacts)];

void ObjectResearch_MapStart()
{
	Shuffled = false;
	GlobalCooldown = 0.0;
	PrecacheModel("models/props_combine/masterinterface.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Research Station");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_const_research");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);

	BuildingInfo build;
	build.Section = 2;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_const_research");
	build.Cost = 1000;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ClotCanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectResearch(client, vecPos, vecAng);
}

methodmap ObjectResearch < ObjectGeneric
{
	public ObjectResearch(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectResearch npc = view_as<ObjectResearch>(ObjectGeneric(client, vecPos, vecAng, "models/props_combine/masterinterface.mdl", _, "600", {110.0, 129.0, 197.0}));
		
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		npc.FuncCanBuild = ClotCanBuild;
		func_NPCInteract[npc.index] = ClotInteract;

		return npc;
	}
}

static bool ClotCanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = CountBuildings();
		maxcount = 1;
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

static int CountBuildings()
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(NPCId == i_NpcInternalId[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
			count++;
	}

	return count;
}

static bool ClotCanUse(ObjectResearch npc, int client)
{
	if(GlobalCooldown > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectTinkerBrew npc, int client)
{
	if(GlobalCooldown > GetGameTime())
	{
		PrintCenterText(client, "%t", "Object Cooldown", GlobalCooldown - GetGameTime());
	}
	else
	{
		PrintCenterText(client, "Press [T (spray)] to cook something using materials.");
	}
}

static bool ClotInteract(int client, int weapon, ObjectResearch npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	ThisBuildingMenu(client);
	return true;
}

static void ThisBuildingMenu(int client)
{
	if(!Shuffled)
	{
		Zero(Enabled);
		Shuffled = true;

		for(int i; i < 4; i++)
		{
			Enabled[GetURandomInt() % sizeof(Enabled)] = true;
		}
	}

	int water = Construction_GetMaterial("water");
	int bofazem = Construction_GetMaterial("bofazem");
	bool disabled = (water < WaterCost || bofazem < BofaCost);

	SetGlobalTransTarget(client);

	Menu menu = new Menu(ThisBuildingMenuH);

	menu.SetTitle("%t\n%d / %d %t\n%d / %d %t\n \nCrouch to see descriptions", "Cooking Stove", water, WaterCost, "Material water", bofazem, BofaCost, "Material bofazem");

	char buffer[64];
	for(int i; i < Enabled; i++)
	{
		FormatEx(buffer, sizeof(buffer), "%t", Artifacts[i]);
		menu.AddItem(Artifacts[i], buffer);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

static int ThisBuildingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			if(GetClientButtons(client) & IN_DUCK)
			{
				char desc[64];
				FormatEx(desc, sizeof(desc), "%s Desc", buffer);
				CPrintToChat(client, "%t", "Artifact Info", buffer, desc);

				ThisBuildingMenu(client);
			}
			else if(GlobalCooldown < GetGameTime() && Construction_GetMaterial("water") >= WaterCost && Construction_GetMaterial("bofazem") >= BofaCost)
			{
				GlobalCooldown = Construction_GetNextAttack() + 120.0;
				Shuffled = false;

				CPrintToChatAll("%t", "Player Used 2 to", client, WaterCost, "Material water", BofaCost, "Material bofazem");
				
				Construction_AddMaterial("water", -WaterCost, true);
				Construction_AddMaterial("bofazem", -BofaCost, true);
				Rogue_GiveNamedArtifact(buffer);
			}
		}
	}
	return 0;
}