#pragma semicolon 1
#pragma newdecls required

#define SOUND_WAND_SHOT_DIM	"misc/doomsday_lift_stop.wav"
#define SOUND_DIM_IMPACT "weapons/cow_mangler_explosion_normal_01.wav"
#define SOUND_ABILITY "misc/rd_points_return01.wav"
#define MAX_DIMENSION_CHARGE 40
static Handle h_TimerDimensionWeaponManagement[MAXPLAYERS+1]={null, ...};
static int how_many_times_swinged[MAXTF2PLAYERS];
static float f_DIMAbilityActive[MAXPLAYERS+1]={0.0, ...};
static float f_DIMhuddelay[MAXPLAYERS+1]={0.0, ...};


void ResetMapStartDimWeapon()
{
	Zero(f_DIMhuddelay);
	Wand_Dimension_Map_Precache();
}
void Wand_Dimension_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_DIM);
	PrecacheSound(SOUND_DIM_IMPACT);
	PrecacheSound(SOUND_ABILITY);
}

public void Enable_Dimension_Wand(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerDimensionWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_DIMENSION_RIPPER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerDimensionWeaponManagement[client];
			h_TimerDimensionWeaponManagement[client] = null;
			DataPack pack;
			h_TimerDimensionWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Dimension, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_DIMENSION_RIPPER)
	{
		DataPack pack;
		h_TimerDimensionWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Dimension, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Dimension(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerDimensionWeaponManagement[client] = null;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{	
		Dimension_Cooldown_Logic(client, weapon);
	}	
	return Plugin_Continue;
}

public void Dimension_Cooldown_Logic(int client, int weapon)
{
	if(f_DIMhuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_DIMAbilityActive[client] < GetGameTime())
			{
				if(how_many_times_swinged[client] < MAX_DIMENSION_CHARGE)
				{
					PrintHintText(client,"Dimension power [%i%/%i]", how_many_times_swinged[client], MAX_DIMENSION_CHARGE);
				}
				else
				{
					PrintHintText(client,"Summon Ready");
				}
			}
			else
			{
				PrintHintText(client,"Hi ;D");
			}
			
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			f_DIMhuddelay[client] = GetGameTime() + 0.5;
		}
	}
}

public void Weapon_Dimension_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 100.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1200.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		
		speed *= Attributes_Get(weapon, 104, 1.0);
		
		speed *= Attributes_Get(weapon, 475, 1.0);
		
		float time = 500.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		
		time *= Attributes_Get(weapon, 102, 1.0);
		

		EmitSoundToAll(SOUND_WAND_SHOT_DIM, client, SNDCHAN_WEAPON, 65, _, 0.4, 100);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_blue_trail");
			}
			case 2:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_blue_crit_trail");
			}
			case 3:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_red_trail");
			}
			case 4:
			{
				Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "raygun_projectile_red_crit_trail");
			}
			default: //This should not happen
			{
				ShowSyncHudText(client,  SyncHud_Notifaction, "An error occured. Scream at devs");//none
			}
		}

	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Wand_DimensionTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		Entity_Position = WorldSpaceCenterOld(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForceOld(vecForward, 10000.0), Entity_Position, false);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_DIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_DIM_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
}

public Action Dimension_KillNPC(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && !b_NpcHasDied[entity])
	{
		SmiteNpcToDeath(entity);
	}
	
	return Plugin_Stop;
}



void Npc_OnTakeDamage_DimensionalRipper(int attacker, int victim)
{
	/*
		++ add charge code xd
	*/
	if(how_many_times_swinged[attacker] <= MAX_DIMENSION_CHARGE)
	{
		how_many_times_swinged[attacker] += 1;
	}
	if(b_thisNpcIsARaid[victim])
	{
		how_many_times_swinged[attacker] += 1;
	}
}



public void Weapon_Dimension_Summon_Normal(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 19))
	{
		case 1:
			Dimension_Summon_Npc(client, HEADCRAB_ZOMBIE ,weapon, 0.85, 0.85, "ghost_appearation");
		case 2:
			Dimension_Summon_Npc(client, FORTIFIED_HEADCRAB_ZOMBIE ,weapon, 0.9, 0.9, "ghost_appearation");
		case 3:
			Dimension_Summon_Npc(client, FASTZOMBIE ,weapon, 0.8, 0.8, "ghost_appearation");
		case 4:
			Dimension_Summon_Npc(client, FORTIFIED_FASTZOMBIE ,weapon, 0.85, 0.85, "ghost_appearation");
		case 5:
			Dimension_Summon_Npc(client, TORSOLESS_HEADCRAB_ZOMBIE ,weapon, 0.85, 0.85, "ghost_appearation");
		case 6:
			Dimension_Summon_Npc(client, FORTIFIED_GIANT_POISON_ZOMBIE ,weapon, 1.2, 1.2, "ghost_appearation");
		case 7:
			Dimension_Summon_Npc(client, POISON_ZOMBIE ,weapon, 1.0, 1.0, "ghost_appearation");
		case 8:
			Dimension_Summon_Npc(client, FORTIFIED_POISON_ZOMBIE ,weapon, 1.1, 1.1, "ghost_appearation");
		case 9:
			Dimension_Summon_Npc(client, FATHER_GRIGORI ,weapon, 1.9, 1.5, "ghost_appearation");
		case 10:
			Dimension_Summon_Npc(client, COMBINE_POLICE_PISTOL ,weapon, 1.0, 1.0, "ghost_appearation");
		case 11:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_AR2 ,weapon, 1.1, 1.1, "ghost_appearation");
		case 12:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_SHOTGUN ,weapon, 1.1, 1.2, "ghost_appearation");
		case 13:
			Dimension_Summon_Npc(client, COMBINE_POLICE_SMG ,weapon, 1.1, 1.1, "ghost_appearation");
		case 14:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_SWORDSMAN ,weapon, 1.1, 1.1, "ghost_appearation");
		case 15:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_ELITE ,weapon, 1.1, 1.25, "ghost_appearation");	
		case 16:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_GIANT_SWORDSMAN ,weapon, 1.5, 1.2, "ghost_appearation");
		case 17:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_DDT ,weapon, 1.0, 1.1, "ghost_appearation");
		case 18:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_COLLOSS ,weapon, 1.75, 1.3, "ghost_appearation");
		case 19:
			Dimension_Summon_Npc(client, COMBINE_OVERLORD ,weapon, 2.0, 1.5, "ghost_appearation");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Normal_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 23))
	{
		case 1:
			Dimension_Summon_Npc(client, SPY_MAIN_BOSS ,weapon, 2.5, 2.0, "ghost_appearation");
		case 2:
			Dimension_Summon_Npc(client, ENGINEER_ZOMBIE ,weapon, 1.1, 1.1, "ghost_appearation");
		case 3:
			Dimension_Summon_Npc(client, HEAVY_ZOMBIE ,weapon, 1.3, 1.0, "ghost_appearation");
		case 4:
			Dimension_Summon_Npc(client, KAMIKAZE_DEMO ,weapon, 0.5, 3.0, "ghost_appearation");
		case 5:
			Dimension_Summon_Npc(client, MEDIC_HEALER ,weapon, 0.8, 1.25, "ghost_appearation");
		case 6:
			Dimension_Summon_Npc(client, HEAVY_ZOMBIE_GIANT ,weapon, 1.5, 1.2, "ghost_appearation");
		case 7:
			Dimension_Summon_Npc(client, SPY_FACESTABBER ,weapon, 1.2, 1.1, "ghost_appearation");
		case 8:
			Dimension_Summon_Npc(client, SOLDIER_ROCKET_ZOMBIE ,weapon, 1.0, 1.2, "ghost_appearation");
		case 9:
			Dimension_Summon_Npc(client, FATHER_GRIGORI ,weapon, 1.9, 1.5, "ghost_appearation");
		case 10:
			Dimension_Summon_Npc(client, SOLDIER_ZOMBIE_MINION ,weapon, 1.2, 1.2, "ghost_appearation");
		case 11:
			Dimension_Summon_Npc(client, SPY_THIEF ,weapon, 1.2, 1.1, "ghost_appearation");
		case 12:
			Dimension_Summon_Npc(client, SPY_TRICKSTABBER ,weapon, 1.2, 1.2, "ghost_appearation");
		case 13:
			Dimension_Summon_Npc(client, SPY_HALF_CLOACKED ,weapon, 1.2, 1.1, "ghost_appearation");
		case 14:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_SWORDSMAN ,weapon, 1.1, 1.1, "ghost_appearation");
		case 15:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_ELITE ,weapon, 1.1, 1.25, "ghost_appearation");	
		case 16:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_GIANT_SWORDSMAN ,weapon, 1.5, 1.2, "ghost_appearation");
		case 17:
			Dimension_Summon_Npc(client, SNIPER_MAIN ,weapon, 1.2, 1.2, "ghost_appearation");
		case 18:
			Dimension_Summon_Npc(client, COMBINE_SOLDIER_COLLOSS ,weapon, 1.75, 1.3, "ghost_appearation");
		case 19:
			Dimension_Summon_Npc(client, COMBINE_OVERLORD ,weapon, 2.0, 1.5, "ghost_appearation");
		case 20:
			Dimension_Summon_Npc(client, DEMO_MAIN ,weapon, 1.2, 1.2, "ghost_appearation");
		case 21:
			Dimension_Summon_Npc(client, BATTLE_MEDIC_MAIN ,weapon, 1.3, 1.2, "ghost_appearation");
		case 22:
			Dimension_Summon_Npc(client, GIANT_PYRO_MAIN ,weapon, 1.75, 1.2, "ghost_appearation");
		case 23:
			Dimension_Summon_Npc(client, COMBINE_DEUTSCH_RITTER ,weapon, 1.5, 1.2, "ghost_appearation");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Blitz(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 12))
	{
		case 1:
			Dimension_Summon_Npc(client, ALT_COMBINE_MAGE ,weapon, 1.1, 1.15, "eyeboss_tp_player");
		case 2:
			Dimension_Summon_Npc(client, ALT_MEDIC_APPRENTICE_MAGE ,weapon, 1.1, 1.15, "eyeboss_tp_player");
		case 3:
			Dimension_Summon_Npc(client, ALT_MEDIC_CHARGER ,weapon, 1.3, 1.2, "eyeboss_tp_player");
		case 4:
			Dimension_Summon_Npc(client, ALT_MEDIC_BERSERKER ,weapon, 1.3, 1.2, "eyeboss_tp_player");
		case 5:
			Dimension_Summon_Npc(client, ALT_MEDIC_SUPPERIOR_MAGE ,weapon, 1.6, 1.2, "eyeboss_tp_player");
		case 6:
			Dimension_Summon_Npc(client, ALT_SNIPER_RAILGUNNER ,weapon, 0.7, 1.3, "eyeboss_tp_player");
		case 7:
			Dimension_Summon_Npc(client, ALT_SOLDIER_BARRAGER ,weapon, 1.1, 1.2, "eyeboss_tp_player");
		case 8:
			Dimension_Summon_Npc(client, ALT_The_Shit_Slapper ,weapon, 1.75, 1.2, "eyeboss_tp_player");
		case 9:
			Dimension_Summon_Npc(client, ALT_MECHA_ENGINEER ,weapon, 1.2, 1.1, "eyeboss_tp_player");
		case 10:
			Dimension_Summon_Npc(client, ALT_MECHA_HEAVY ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		case 11:
			Dimension_Summon_Npc(client, ALT_MECHA_SCOUT ,weapon, 1.1, 1.1, "eyeboss_tp_player");
		case 12:
			Dimension_Summon_Npc(client, ALT_MECHASOLDIER_BARRAGER ,weapon, 1.1, 1.2, "eyeboss_tp_player");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Blitz_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 14))
	{
		case 1:
			Dimension_Summon_Npc(client, ALT_MECHA_HEAVYGIANT ,weapon, 1.5, 1.2, "eyeboss_tp_player");
		case 2:
			Dimension_Summon_Npc(client, ALT_MECHA_PYROGIANT ,weapon, 1.55, 1.2, "eyeboss_tp_player");
		case 3:
			Dimension_Summon_Npc(client, ALT_MEDIC_CHARGER ,weapon, 1.3, 1.2, "eyeboss_tp_player");
		case 4:
			Dimension_Summon_Npc(client, ALT_MEDIC_BERSERKER ,weapon, 1.3, 1.2, "eyeboss_tp_player");
		case 5:
			Dimension_Summon_Npc(client, ALT_MEDIC_SUPPERIOR_MAGE ,weapon, 1.6, 1.2, "eyeboss_tp_player");
		case 6:
			Dimension_Summon_Npc(client, ALT_SNIPER_RAILGUNNER ,weapon, 0.7, 1.3, "eyeboss_tp_player");
		case 7:
			Dimension_Summon_Npc(client, ALT_SOLDIER_BARRAGER ,weapon, 1.1, 1.2, "eyeboss_tp_player");
		case 8:
			Dimension_Summon_Npc(client, ALT_The_Shit_Slapper ,weapon, 1.75, 1.2, "eyeboss_tp_player");
		case 9:
			Dimension_Summon_Npc(client, ALT_MECHA_ENGINEER ,weapon, 1.2, 1.1, "eyeboss_tp_player");
		case 10:
			Dimension_Summon_Npc(client, ALT_MECHA_HEAVY ,weapon, 1.4, 1.2, "eyeboss_tp_player");
		case 11:
			Dimension_Summon_Npc(client, ALT_COMBINE_DEUTSCH_RITTER ,weapon, 1.4, 1.25, "eyeboss_tp_player");
		case 12:
			Dimension_Summon_Npc(client, ALT_MECHASOLDIER_BARRAGER ,weapon, 1.1, 1.2, "eyeboss_tp_player");
		case 13:
			Dimension_Summon_Npc(client, ALT_MEDIC_HEALER_3 ,weapon, 1.0, 1.25, "eyeboss_tp_player");
		case 14:
			Dimension_Summon_Npc(client, ALT_SCHWERTKRIEG ,weapon, 2.25, 1.5, "eyeboss_tp_player");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Xeno(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 30))
	{
		case 1:
			Dimension_Summon_Npc(client, XENO_HEADCRAB_ZOMBIE ,weapon, 0.85, 0.85, "utaunt_smoke_floor1_green");
		case 2:
			Dimension_Summon_Npc(client, XENO_FORTIFIED_HEADCRAB_ZOMBIE ,weapon, 0.9, 0.9, "utaunt_smoke_floor1_green");
		case 3:
			Dimension_Summon_Npc(client, XENO_FASTZOMBIE ,weapon, 0.8, 0.8, "utaunt_smoke_floor1_green");
		case 4:
			Dimension_Summon_Npc(client, XENO_FORTIFIED_FASTZOMBIE ,weapon, 0.9, 0.9, "utaunt_smoke_floor1_green");
		case 5:
			Dimension_Summon_Npc(client, XENO_TORSOLESS_HEADCRAB_ZOMBIE ,weapon, 0.8, 0.8, "utaunt_smoke_floor1_green");
		case 6:
			Dimension_Summon_Npc(client, XENO_FORTIFIED_GIANT_POISON_ZOMBIE ,weapon, 1.5, 1.2, "utaunt_smoke_floor1_green");
		case 7:
			Dimension_Summon_Npc(client, XENO_POISON_ZOMBIE ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 8:
			Dimension_Summon_Npc(client, XENO_FORTIFIED_POISON_ZOMBIE ,weapon, 1.3, 1.1, "utaunt_smoke_floor1_green");
		case 9:
			Dimension_Summon_Npc(client, XENO_COMBINE_POLICE_PISTOL ,weapon, 1.0, 1.0, "utaunt_smoke_floor1_green");
		case 10:
			Dimension_Summon_Npc(client, XENO_COMBINE_POLICE_SMG ,weapon, 1.1, 1.1, "utaunt_smoke_floor1_green");
		case 11:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_AR2 ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 12:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_SHOTGUN ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 13:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_SWORDSMAN ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 14:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_ELITE ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 15:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN ,weapon, 1.5, 1.2, "utaunt_smoke_floor1_green");
		case 16:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_DDT ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 17:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_COLLOSS ,weapon, 1.75, 1.2, "utaunt_smoke_floor1_green");
		case 18:
			Dimension_Summon_Npc(client, XENO_SCOUT_ZOMBIE ,weapon, 1.1, 1.1, "utaunt_smoke_floor1_green");
		case 19:
			Dimension_Summon_Npc(client, XENO_ENGINEER_ZOMBIE ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 20:
			Dimension_Summon_Npc(client, XENO_HEAVY_ZOMBIE ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 21:
			Dimension_Summon_Npc(client, XENO_KAMIKAZE_DEMO ,weapon, 0.5, 3.0, "utaunt_smoke_floor1_green");
		case 22:
			Dimension_Summon_Npc(client, XENO_SPY_FACESTABBER ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 23:
			Dimension_Summon_Npc(client, XENO_SOLDIER_ROCKET_ZOMBIE ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 24:
			Dimension_Summon_Npc(client, XENO_SPY_THIEF ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 25:
			Dimension_Summon_Npc(client, XENO_SPY_TRICKSTABBER ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 26:
			Dimension_Summon_Npc(client, XENO_KAMIKAZE_DEMO ,weapon, 0.5, 3.0, "utaunt_smoke_floor1_green");
		case 27:
			Dimension_Summon_Npc(client, XENO_SPY_FACESTABBER ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 28:
			Dimension_Summon_Npc(client, XENO_SPY_HALF_CLOACKED ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 29:
			Dimension_Summon_Npc(client, XENO_SNIPER_MAIN ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 30:
			Dimension_Summon_Npc(client, XENO_DEMO_MAIN ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Xeno_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 30))
	{
		case 1:
			Dimension_Summon_Npc(client, XENO_COMBINE_OVERLORD ,weapon, 2.0, 1.5, "utaunt_smoke_floor1_green");
		case 2:
			Dimension_Summon_Npc(client, XENO_FATHER_GRIGORI ,weapon, 1.9, 1.5, "utaunt_smoke_floor1_green");
		case 3:
			Dimension_Summon_Npc(client, XENO_MEDIC_HEALER ,weapon, 0.8, 1.2, "utaunt_smoke_floor1_green");
		case 4:
			Dimension_Summon_Npc(client, XENO_BATTLE_MEDIC_MAIN ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 5:
			Dimension_Summon_Npc(client, XENO_GIANT_PYRO_MAIN ,weapon, 1.6, 1.2, "utaunt_smoke_floor1_green");
		case 6:
			Dimension_Summon_Npc(client, XENO_COMBINE_DEUTSCH_RITTER ,weapon, 1.5, 1.3, "utaunt_smoke_floor1_green");
		case 7:
			Dimension_Summon_Npc(client, XENO_SPY_MAIN_BOSS ,weapon, 2.5, 1.4, "utaunt_smoke_floor1_green");
		case 8:
			Dimension_Summon_Npc(client, XENO_FORTIFIED_POISON_ZOMBIE ,weapon, 1.3, 1.1, "utaunt_smoke_floor1_green");
		case 9:
			Dimension_Summon_Npc(client, XENO_COMBINE_POLICE_PISTOL ,weapon, 1.0, 1.0, "utaunt_smoke_floor1_green");
		case 10:
			Dimension_Summon_Npc(client, XENO_COMBINE_POLICE_SMG ,weapon, 1.1, 1.1, "utaunt_smoke_floor1_green");
		case 11:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_AR2 ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 12:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_SHOTGUN ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 13:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_SWORDSMAN ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 14:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_ELITE ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 15:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_GIANT_SWORDSMAN ,weapon, 1.5, 1.2, "utaunt_smoke_floor1_green");
		case 16:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_DDT ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 17:
			Dimension_Summon_Npc(client, XENO_COMBINE_SOLDIER_COLLOSS ,weapon, 1.75, 1.2, "utaunt_smoke_floor1_green");
		case 18:
			Dimension_Summon_Npc(client, XENO_SCOUT_ZOMBIE ,weapon, 1.1, 1.1, "utaunt_smoke_floor1_green");
		case 19:
			Dimension_Summon_Npc(client, XENO_ENGINEER_ZOMBIE ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 20:
			Dimension_Summon_Npc(client, XENO_HEAVY_ZOMBIE ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		case 21:
			Dimension_Summon_Npc(client, XENO_KAMIKAZE_DEMO ,weapon, 0.5, 3.0, "utaunt_smoke_floor1_green");
		case 22:
			Dimension_Summon_Npc(client, XENO_SPY_FACESTABBER ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 23:
			Dimension_Summon_Npc(client, XENO_SOLDIER_ROCKET_ZOMBIE ,weapon, 1.1, 1.2, "utaunt_smoke_floor1_green");
		case 24:
			Dimension_Summon_Npc(client, XENO_SPY_THIEF ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 25:
			Dimension_Summon_Npc(client, XENO_SPY_TRICKSTABBER ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 26:
			Dimension_Summon_Npc(client, XENO_KAMIKAZE_DEMO ,weapon, 0.5, 3.0, "utaunt_smoke_floor1_green");
		case 27:
			Dimension_Summon_Npc(client, XENO_SPY_FACESTABBER ,weapon, 1.2, 1.1, "utaunt_smoke_floor1_green");
		case 28:
			Dimension_Summon_Npc(client, XENO_SPY_HALF_CLOACKED ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 29:
			Dimension_Summon_Npc(client, XENO_SNIPER_MAIN ,weapon, 1.2, 1.2, "utaunt_smoke_floor1_green");
		case 30:
			Dimension_Summon_Npc(client, XENO_DEMO_MAIN ,weapon, 1.3, 1.2, "utaunt_smoke_floor1_green");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Medeival(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 21))
	{
		case 1:
			Dimension_Summon_Npc(client, MEDIVAL_MILITIA ,weapon, 0.9, 0.9, "npc_boss_bomb_alert");
		case 2:
			Dimension_Summon_Npc(client, MEDIVAL_ARCHER ,weapon, 0.8, 1.0, "npc_boss_bomb_alert");
		case 3:
			Dimension_Summon_Npc(client, MEDIVAL_MAN_AT_ARMS ,weapon, 1.0, 1.0, "npc_boss_bomb_alert");
		case 4:
			Dimension_Summon_Npc(client, MEDIVAL_SWORDSMAN ,weapon, 1.1, 1.1, "npc_boss_bomb_alert");
		case 5:
			Dimension_Summon_Npc(client, MEDIVAL_TWOHANDED_SWORDSMAN ,weapon, 1.25, 1.2, "npc_boss_bomb_alert");
		case 6:
			Dimension_Summon_Npc(client, MEDIVAL_CROSSBOW_MAN ,weapon, 1.0, 1.1, "npc_boss_bomb_alert");
		case 7:
			Dimension_Summon_Npc(client, MEDIVAL_LIGHT_CAV ,weapon, 1.0, 1.1, "npc_boss_bomb_alert");
		case 8:
			Dimension_Summon_Npc(client, MEDIVAL_SPEARMEN ,weapon, 1.0, 1.1, "npc_boss_bomb_alert");
		case 9:
			Dimension_Summon_Npc(client, MEDIVAL_HANDCANNONEER ,weapon, 1.0, 1.2, "npc_boss_bomb_alert");
		case 10:
			Dimension_Summon_Npc(client, MEDIVAL_ELITE_SKIRMISHER ,weapon, 1.1, 1.2, "npc_boss_bomb_alert");
		case 11:
			Dimension_Summon_Npc(client, MEDIVAL_EAGLE_SCOUT ,weapon, 1.1, 1.1, "npc_boss_bomb_alert");
		case 12:
			Dimension_Summon_Npc(client, MEDIVAL_SAMURAI ,weapon, 1.3, 1.2, "npc_boss_bomb_alert");
		case 13:
			Dimension_Summon_Npc(client, MEDIVAL_CHAMPION ,weapon, 1.3, 1.3, "npc_boss_bomb_alert");
		case 14:
			Dimension_Summon_Npc(client, MEDIVAL_BRAWLER ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 15:
			Dimension_Summon_Npc(client, MEDIVAL_EAGLE_WARRIOR ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 16:
			Dimension_Summon_Npc(client, MEDIVAL_CAVALARY ,weapon, 1.1, 1.2, "npc_boss_bomb_alert");
		case 17:
			Dimension_Summon_Npc(client, MEDIVAL_HALB ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 18:
			Dimension_Summon_Npc(client, MEDIVAL_LONGBOWMEN ,weapon, 1.1, 1.2, "npc_boss_bomb_alert");
		case 19:
			Dimension_Summon_Npc(client, MEDIVAL_ARBALEST ,weapon, 1.0, 1.2, "npc_boss_bomb_alert");
		case 20:
			Dimension_Summon_Npc(client, MEDIVAL_PALADIN ,weapon, 1.4, 1.2, "npc_boss_bomb_alert");
		case 21:
			Dimension_Summon_Npc(client, MEDIVAL_RIDDENARCHER ,weapon, 1.1, 1.2, "npc_boss_bomb_alert");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Medeival_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 20))
	{
		case 1:
			Dimension_Summon_Npc(client, MEDIVAL_CONSTRUCT ,weapon, 1.9, 1.4, "npc_boss_bomb_alert");
		case 2:
			Dimension_Summon_Npc(client, MEDIVAL_RAM ,weapon, 0.8, 1.0, "npc_boss_bomb_alert");
		case 3:
			Dimension_Summon_Npc(client, MEDIVAL_SCOUT ,weapon, 1.2, 1.0, "npc_boss_bomb_alert");
		case 4:
			Dimension_Summon_Npc(client, MEDIVAL_HUSSAR ,weapon, 1.3, 1.2, "npc_boss_bomb_alert");
		case 5:
			Dimension_Summon_Npc(client, MEDIVAL_OBUCH ,weapon, 1.4, 1.2, "npc_boss_bomb_alert");
		case 6:
			Dimension_Summon_Npc(client, MEDIVAL_MONK ,weapon, 1.2, 1.5, "npc_boss_bomb_alert");
		case 7:
			Dimension_Summon_Npc(client, MEDIVAL_CROSSBOW_GIANT ,weapon, 1.5, 1.3, "npc_boss_bomb_alert");
		case 8:
			Dimension_Summon_Npc(client, MEDIVAL_SWORDSMAN_GIANT ,weapon, 1.5, 1.3, "npc_boss_bomb_alert");
		case 9:
			Dimension_Summon_Npc(client, MEDIVAL_HANDCANNONEER ,weapon, 1.0, 1.2, "npc_boss_bomb_alert");
		case 10:
			Dimension_Summon_Npc(client, MEDIVAL_ELITE_SKIRMISHER ,weapon, 1.1, 1.2, "npc_boss_bomb_alert");
		case 11:
			Dimension_Summon_Npc(client, MEDIVAL_EAGLE_GIANT ,weapon, 1.5, 1.1, "npc_boss_bomb_alert");
		case 12:
			Dimension_Summon_Npc(client, MEDIVAL_SAMURAI ,weapon, 1.3, 1.2, "npc_boss_bomb_alert");
		case 13:
			Dimension_Summon_Npc(client, MEDIVAL_CHAMPION ,weapon, 1.3, 1.3, "npc_boss_bomb_alert");
		case 14:
			Dimension_Summon_Npc(client, MEDIVAL_BRAWLER ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 15:
			Dimension_Summon_Npc(client, MEDIVAL_EAGLE_WARRIOR ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 16:
			Dimension_Summon_Npc(client, MEDIVAL_ACHILLES ,weapon, 2.0, 1.3, "npc_boss_bomb_alert");
		case 17:
			Dimension_Summon_Npc(client, MEDIVAL_HALB ,weapon, 1.2, 1.2, "npc_boss_bomb_alert");
		case 18:
			Dimension_Summon_Npc(client, MEDIVAL_SON_OF_OSIRIS ,weapon, 2.5, 1.3, "npc_boss_bomb_alert");
		case 19:
			Dimension_Summon_Npc(client, MEDIVAL_ARBALEST ,weapon, 1.0, 1.2, "npc_boss_bomb_alert");
		case 20:
			Dimension_Summon_Npc(client, MEDIVAL_PALADIN ,weapon, 1.4, 1.2, "npc_boss_bomb_alert");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Seaborn(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 10))
	{
		case 1:
			Dimension_Summon_Npc(client, SEARUNNER ,weapon, 0.8, 0.8, "utaunt_constellations_blue_base");
		case 2:
			Dimension_Summon_Npc(client, SEASLIDER ,weapon, 1.1, 1.0, "utaunt_constellations_blue_base");
		case 3:
			Dimension_Summon_Npc(client, SEASPITTER ,weapon, 1.0, 1.1, "utaunt_constellations_blue_base");
		case 4:
			Dimension_Summon_Npc(client, SEAREAPER ,weapon, 1.5, 1.2, "utaunt_constellations_blue_base");
		case 5:
			Dimension_Summon_Npc(client, SEACRAWLER ,weapon, 0.8, 0.8, "utaunt_constellations_blue_base");
		case 6:
			Dimension_Summon_Npc(client, SEAPIERCER ,weapon, 1.2, 1.1, "utaunt_constellations_blue_base");
		case 7:
			Dimension_Summon_Npc(client, SEAPREDATOR ,weapon, 1.0, 1.1, "utaunt_constellations_blue_base");
		case 8:
			Dimension_Summon_Npc(client, SEASPEWER ,weapon, 1.2, 1.3, "utaunt_constellations_blue_base");
		case 9:
			Dimension_Summon_Npc(client, SEASWARMCALLER ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 10:
			Dimension_Summon_Npc(client, SEAREEFBREAKER ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}
public void Weapon_Dimension_Summon_Seaborn_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 21))
	{
		case 1:
			Dimension_Summon_Npc(client, SEABORN_KAZIMIERZ_KNIGHT ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 2:
			Dimension_Summon_Npc(client, SEABORN_KAZIMIERZ_KNIGHT_ARCHER ,weapon, 1.1, 1.2, "utaunt_constellations_blue_base");
		case 3:
			Dimension_Summon_Npc(client, SEABORN_KAZIMIERZ_LONGARCHER ,weapon, 1.1, 1.3, "utaunt_constellations_blue_base");
		case 4:
			Dimension_Summon_Npc(client, SEABORN_KAZIMIERZ_ASSASIN_MELEE ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 5:
			Dimension_Summon_Npc(client, SEABORN_SCOUT ,weapon, 1.1, 1.1, "utaunt_constellations_blue_base");
		case 6:
			Dimension_Summon_Npc(client, SEAPIERCER_ALT ,weapon, 1.2, 1.1, "utaunt_constellations_blue_base");
		case 7:
			Dimension_Summon_Npc(client, SEAPREDATOR_ALT ,weapon, 1.0, 1.1, "utaunt_constellations_blue_base");
		case 8:
			Dimension_Summon_Npc(client, SEASPEWER_ALT ,weapon, 1.2, 1.3, "utaunt_constellations_blue_base");
		case 9:
			Dimension_Summon_Npc(client, SEASWARMCALLER_ALT ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 10:
			Dimension_Summon_Npc(client, SEAREEFBREAKER_ALT ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 11:
			Dimension_Summon_Npc(client, SEABORN_PYRO ,weapon, 1.2, 1.1, "utaunt_constellations_blue_base");
		case 12:
			Dimension_Summon_Npc(client, SEABORN_DEMO ,weapon, 0.5, 3.0, "utaunt_constellations_blue_base");
		case 13:
			Dimension_Summon_Npc(client, SEABORN_HEAVY ,weapon, 1.3, 1.2, "utaunt_constellations_blue_base");
		case 14:
			Dimension_Summon_Npc(client, SEABORN_MEDIC ,weapon, 1.0, 1.2, "utaunt_constellations_blue_base");
		case 15:
			Dimension_Summon_Npc(client, SEABORN_SNIPER ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 16:
			Dimension_Summon_Npc(client, SEABORN_SPY ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 17:
			Dimension_Summon_Npc(client, SEABORN_GUARD ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 18:
			Dimension_Summon_Npc(client, SEABORN_DEFENDER ,weapon, 1.5, 1.1, "utaunt_constellations_blue_base");
		case 19:
			Dimension_Summon_Npc(client, SEABORN_CASTER ,weapon, 1.1, 1.3, "utaunt_constellations_blue_base");
		case 20:
			Dimension_Summon_Npc(client, SEABORN_SPECIALIST ,weapon, 1.2, 1.2, "utaunt_constellations_blue_base");
		case 21:
			Dimension_Summon_Npc(client, FIRSTTOTALK ,weapon, 2.0, 1.3, "utaunt_constellations_blue_base");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Expidonsa(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 14))
	{
		case 1:
			Dimension_Summon_Npc(client, EXPIDONSA_BENERA ,weapon, 0.9, 0.9, "eyeboss_death_vortex");
		case 2:
			Dimension_Summon_Npc(client, EXPIDONSA_PENTAL ,weapon, 1.0, 1.0, "eyeboss_death_vortex");
		case 3:
			Dimension_Summon_Npc(client, EXPIDONSA_DEFANDA ,weapon, 1.2, 1.0, "eyeboss_death_vortex");
		case 4:
			Dimension_Summon_Npc(client, EXPIDONSA_SELFAM_IRE ,weapon, 1.1, 1.1, "eyeboss_death_vortex");
		case 5:
			Dimension_Summon_Npc(client, EXPIDONSA_VAUSMAGICA ,weapon, 1.1, 1.0, "eyeboss_death_vortex");
		case 6:
			Dimension_Summon_Npc(client, EXPIDONSA_PISTOLEER ,weapon, 0.8, 1.3, "eyeboss_death_vortex");
		case 7:
			Dimension_Summon_Npc(client, EXPIDONSA_DIVERSIONISTICO ,weapon, 1.1, 1.2, "eyeboss_death_vortex");
		case 8:
			Dimension_Summon_Npc(client, EXPIDONSA_RIFALMANU ,weapon, 1.1, 1.2, "eyeboss_death_vortex");
		case 9:
			Dimension_Summon_Npc(client, EXPIDONSA_SICCERINO ,weapon, 1.1, 1.1, "eyeboss_death_vortex");
		case 10:
			Dimension_Summon_Npc(client, EXPIDONSA_SOLDINE_PROTOTYPE ,weapon, 1.4, 1.25, "eyeboss_death_vortex");
		case 11:
			Dimension_Summon_Npc(client, EXPIDONSA_PROTECTA ,weapon, 1.3, 1.1, "eyeboss_death_vortex");
		case 12:
			Dimension_Summon_Npc(client, EXPIDONSA_EGABUNAR ,weapon, 1.2, 1.2, "eyeboss_death_vortex");
		case 13:
			Dimension_Summon_Npc(client, EXPIDONSA_ENEGAKAPUS ,weapon, 1.1, 1.1, "eyeboss_death_vortex");
		case 14:
			Dimension_Summon_Npc(client, EXPIDONSA_VAUSTECHICUS ,weapon, 1.2, 1.1, "eyeboss_death_vortex");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}

public void Weapon_Dimension_Summon_Expidonsa_PAP(int client, int weapon, bool &result, int slot, int pap_logic)
{
	switch(GetRandomInt(1, 16))
	{
		case 1:
			Dimension_Summon_Npc(client, EXPIDONSA_HEAVYPUNUEL ,weapon, 1.5, 1.2, "eyeboss_death_vortex");
		case 2:
			Dimension_Summon_Npc(client, EXPIDONSA_DUALREA ,weapon, 1.3, 1.3, "eyeboss_death_vortex");
		case 3:
			Dimension_Summon_Npc(client, EXPIDONSA_GUARDUS ,weapon, 1.6, 1.2, "eyeboss_death_vortex");
		case 4:
			Dimension_Summon_Npc(client, EXPIDONSA_IGNITUS ,weapon, 1.5, 1.2, "eyeboss_death_vortex");
		case 5:
			Dimension_Summon_Npc(client, EXPIDONSA_GIANTTANKUS ,weapon, 1.75, 1.2, "eyeboss_death_vortex");
		case 6:
			Dimension_Summon_Npc(client, EXPIDONSA_SNIPONEER ,weapon, 0.8, 1.4, "eyeboss_death_vortex");
		case 7:
			Dimension_Summon_Npc(client, EXPIDONSA_DIVERSIONISTICO ,weapon, 1.1, 1.2, "eyeboss_death_vortex");
		case 8:
			Dimension_Summon_Npc(client, EXPIDONSA_MINIGUNASSISA ,weapon, 1.2, 1.2, "eyeboss_death_vortex");
		case 9:
			Dimension_Summon_Npc(client, EXPIDONSA_SPEEDUSADIVUS ,weapon, 1.2, 1.1, "eyeboss_death_vortex");
		case 10:
			Dimension_Summon_Npc(client, EXPIDONSA_SOLDINE_PROTOTYPE ,weapon, 1.4, 1.25, "eyeboss_death_vortex");
		case 11:
			Dimension_Summon_Npc(client, EXPIDONSA_HELENA ,weapon, 1.0, 1.2, "eyeboss_death_vortex");
		case 12:
			Dimension_Summon_Npc(client, EXPIDONSA_ERASUS ,weapon, 1.4, 1.3, "eyeboss_death_vortex");
		case 13:
			Dimension_Summon_Npc(client, EXPIDONSA_ENEGAKAPUS ,weapon, 1.1, 1.1, "eyeboss_death_vortex");
		case 14:
			Dimension_Summon_Npc(client, EXPIDONSA_VAUSTECHICUS ,weapon, 1.2, 1.1, "eyeboss_death_vortex");
		case 15:
			Dimension_Summon_Npc(client, EXPIDONSA_SOLDINE ,weapon, 2.0, 1.5, "eyeboss_death_vortex");
		case 16:
			Dimension_Summon_Npc(client, EXPIDONSA_SEARGENTIDEAL ,weapon, 3.0, 1.3, "eyeboss_death_vortex");
		default: //This should not happen
		{
			ShowSyncHudText(client,  SyncHud_Notifaction, "Summon Failed. Scream at devs");//none
		}
	}
}



void Dimension_Summon_Npc(int client, int NpcId, int weapon, float HealthMulti, float DamageMulti, char[] ParticleEffect)
{
	
	if(weapon >= MaxClients)
	{
		if (how_many_times_swinged[client] >= MAX_DIMENSION_CHARGE)
		{
			int mana_cost = 150;
			if(mana_cost <= Current_Mana[client])
			{
				Rogue_OnAbilityUse(weapon);
				float pos1[3], ang[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos1);
				GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
				float Dimension_Loc[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Dimension_Loc);
				if(ParticleEffect[0])
					ParticleEffectAt(Dimension_Loc, ParticleEffect, 1.5);
				EmitSoundToAll(SOUND_ABILITY, client, SNDCHAN_STATIC, 70, _, 1.0);
				int entity = Npc_Create(NpcId, client, pos1, ang, TFTeam_Red);
				if(entity > MaxClients)
				{
					//30 as a starting value.
					
					float f_MaxHealth = 30.0;
					f_MaxHealth *= Attributes_Get(weapon, 410, 1.0);
					f_MaxHealth *= HealthMulti;
					SetEntProp(entity, Prop_Data, "m_iHealth", RoundToNearest(f_MaxHealth));
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToNearest(f_MaxHealth));
					
					float ExtraDamage = Attributes_Get(weapon, 410, 1.0);
					ExtraDamage *= DamageMulti;
					fl_Extra_Damage[entity] *= ExtraDamage;
					CreateTimer(45.0, Dimension_KillNPC, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(4.0, Dimension_GiveStrength, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					i_NpcOverrideAttacker[entity] = EntIndexToEntRef(client);
					b_thisNpcIsABoss[entity] = false;
					b_thisNpcIsARaid[entity] = false;
					b_ShowNpcHealthbar[entity] = true;
					if(EntRefToEntIndex(RaidBossActive) == entity)
						RaidBossActive = INVALID_ENT_REFERENCE;
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough Charges");
		}
	}
}

public Action Dimension_GiveStrength(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && !b_NpcHasDied[entity])
	{
		fl_Extra_MeleeArmor[entity] *= 0.75;
		fl_Extra_RangedArmor[entity] *= 0.75;	
		fl_Extra_Damage[entity] *= 1.25;	
	}
	
	return Plugin_Stop;
}
