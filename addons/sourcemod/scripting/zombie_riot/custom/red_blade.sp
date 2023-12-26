#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerRedBladeWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_RedBladehuddelay[MAXPLAYERS+1]={0.0, ...};
static bool HALFORNO[MAXPLAYERS];
static int i_RedBladeFireParticle[MAXPLAYERS+1][2];
static int i_RedBladeNpcToCharge[MAXPLAYERS+1];
static float f_RedBladeChargeDuration[MAXPLAYERS+1];

void ResetMapStartRedBladeWeapon()
{
	Zero(f_RedBladehuddelay);
	Zero(f_RedBladeChargeDuration);
	RedBlade_Map_Precache();
}

void RedBlade_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("ambient/cp_harbor/furnace_1_shot_02.wav");
	PrecacheSound("items/powerup_pickup_supernova_activate.wav");

}

public void Red_charge_ability(int client, int weapon, bool crit, int slot) // the main ability used to recover the unique mana needed to for the weapon to fire projectiles
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 1500.0, false, 45.0, true); //infinite range, and ignore walls!
		FinishLagCompensation_Base_boss();

		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		if(!IsValidEnemy(client, target, true))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		i_RedBladeNpcToCharge[client] = EntIndexToEntRef(target);

		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 10.0);
		EmitSoundToAll("items/powerup_pickup_supernova_activate.wav", client, _, 80, _, 0.8, 100);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 300.0;
		// knockback is the overall force with which you be pushed, don't touch other stuff
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 100.0;    // a little boost to alleviate arcing issues

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		
	//	ApplyTempAttrib(weapon, 852, 0.5, 5.0);
		TF2_AddCondition(client, TFCond_Charging, 2.0, client);
		f_RedBladeChargeDuration[client] = GetGameTime() + 2.0;

	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}
public void Enable_RedBladeWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerRedBladeWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RED_BLADE)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerRedBladeWeaponManagement[client];
			h_TimerRedBladeWeaponManagement[client] = null;
			DataPack pack;
			h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_RED_BLADE)
	{
		DataPack pack;
		h_TimerRedBladeWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_RedBlade, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_RedBlade(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		DestroyRedBladeEffect(client);
		HALFORNO[client] = false;
		h_TimerRedBladeWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		RedBladeHudShow(client, weapon);
	}
	else
	{
		HALFORNO[client] = false;
		DestroyRedBladeEffect(client);
	}
		
	return Plugin_Continue;
}

void RedBladeHudShow(int client, int weapon)
{
	if(f_RedBladeChargeDuration[client] > GetGameTime())
	{
		int ChargeEnemy = EntRefToEntIndex(i_RedBladeNpcToCharge[client]);
		if(IsValidEnemy(client, ChargeEnemy, true))
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Charging))
			{
				LookAtTarget(client, ChargeEnemy);
			}
		}
		else if(!TF2_IsPlayerInCondition(client, TFCond_Charging))
		{
			f_RedBladeChargeDuration[client] = 0.0;
		}
	}
	else
	{
		TF2_RemoveCondition(client, TFCond_Charging);
		f_RedBladeChargeDuration[client] = 0.0;
	}
	if(f_RedBladehuddelay[client] < GetGameTime())
	{
		f_RedBladehuddelay[client] = GetGameTime() + 0.5;
		CheckRedBladeBelowHalfHealth(client, weapon);
	}
}

void CheckRedBladeBelowHalfHealth(int client, int weapon)
{
	float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
	float flpercenthpfrommax = flHealth / SDKCall_GetMaxHealth(client);

	if (flpercenthpfrommax <= 0.5 && !HALFORNO[client])
	{
		EmitSoundToAll("ambient/cp_harbor/furnace_1_shot_02.wav", client, SNDCHAN_STATIC, 70, _, 0.35);
		HALFORNO[client] = true;
		MakeBladeBloddy(client, true, weapon);
	}
	if (flpercenthpfrommax <= 0.5)
	{
		PrintHintText(client,"Rage Activated");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		if(!IsRedBladeEffectSpawned(client))
		{
			CreateRedBladeEffect(client);
		}
		MakeBladeBloddy(client, true, weapon);
	}
	else if (HALFORNO[client])
	{
		PrintHintText(client,"Rage Deactivated");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		HALFORNO[client]=false;
		DestroyRedBladeEffect(client);
		MakeBladeBloddy(client, false, weapon);
	}
}
void WeaponRedBlade_OnTakeDamage(int victim, float &damage)
{
	if(f_RedBladeChargeDuration[victim] > GetGameTime())
	{
		damage *= 0.25;
	}
	if(HALFORNO[victim])
	{
		damage *= 0.35;
	}
}
void WeaponRedBlade_OnTakeDamage_Post(int victim, int weapon)
{
	CheckRedBladeBelowHalfHealth(victim, weapon);
}
void MakeBladeBloddy(int client, bool ignite, int weapon)
{
	return;
	//note: Doesnt work:
	int Weaponviewmodel = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	int view_Weaponviewmodel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(!IsValidEntity(Weaponviewmodel) || !IsValidEntity(view_Weaponviewmodel))
		return;
		
	if(ignite)
	{
		SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
		SetEntProp(Weaponviewmodel, Prop_Send, "m_nSkin", 3);
		SetEntProp(view_Weaponviewmodel, Prop_Send, "m_nSkin", 3);
	}
	else
	{
		SetEntProp(weapon, Prop_Send, "m_bIsBloody",0);
		SetEntProp(Weaponviewmodel, Prop_Send, "m_nSkin", 0);
		SetEntProp(view_Weaponviewmodel, Prop_Send, "m_nSkin", 0);
	}
}

void CreateRedBladeEffect(int client)
{
	
	DestroyRedBladeEffect(client);
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);

	
	int particle = ParticleEffectAt(flPos, "utaunt_hellpit_middlebase", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle);
	i_RedBladeFireParticle[client][0] = EntIndexToEntRef(particle);

	particle = ParticleEffectAt(flPos, "utaunt_tarotcard_red_glow", 0.0);
	AddEntityToThirdPersonTransitMode(client, particle);
	SetParent(client, particle);
	i_RedBladeFireParticle[client][1] = EntIndexToEntRef(particle);
}

bool IsRedBladeEffectSpawned(int client)
{
	for(int loop = 0; loop<2; loop++)
	{
		int entity = EntRefToEntIndex(i_RedBladeFireParticle[client][loop]);
		if(!IsValidEntity(entity))
		{
			return false;
		}
	}
	return true;
}

void DestroyRedBladeEffect(int client)
{
	for(int loop = 0; loop<2; loop++)
	{
		int entity = EntRefToEntIndex(i_RedBladeFireParticle[client][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_RedBladeFireParticle[client][loop] = INVALID_ENT_REFERENCE;
	}
}
