#pragma semicolon 1
#pragma newdecls required

static bool Change[MAXPLAYERS];
static Handle h_TimerMessengerWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_Messengerhuddelay[MAXPLAYERS+1]={0.0, ...};

#define SOUND_MES_IMPACT "weapons/cow_mangler_explode.wav"
#define SOUND_MES_SHOT_FIRE 	"misc/halloween/spell_fireball_cast.wav"
#define SOUND_MES_SHOT_ICE 	"weapons/doom_rocket_launcher.wav"
#define SOUND_MES_CHANGE 	"weapons/bumper_car_accelerate.wav"

void ResetMapStartMessengerWeapon()
{
	Zero(f_Messengerhuddelay);
	Messenger_Map_Precache();
}
void Messenger_Map_Precache()
{
	PrecacheSound(SOUND_MES_IMPACT);
	PrecacheSound(SOUND_MES_SHOT_FIRE);
	PrecacheSound(SOUND_MES_SHOT_ICE);
	PrecacheSound(SOUND_MES_CHANGE);
}

public void Enable_Messenger_Launcher_Ability(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerMessengerWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MESSENGER_LAUNCHER)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerMessengerWeaponManagement[client];
			h_TimerMessengerWeaponManagement[client] = null;
			DataPack pack;
			h_TimerMessengerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Messenger, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MESSENGER_LAUNCHER)
	{
		DataPack pack;
		h_TimerMessengerWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Messenger, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Management_Messenger(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Change[client] = false;
		return Plugin_Stop;
	}
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		MessengerHudShow(client);
	}
	return Plugin_Continue;
}

void MessengerHudShow(int client)
{
	if(f_Messengerhuddelay[client] < GetGameTime())
	{
		f_Messengerhuddelay[client] = GetGameTime() + 0.5;
		CheckMessengerMode(client);
	}
}

void CheckMessengerMode(int client)
{
	if (Change[client] == true )
	{
		PrintHintText(client,"Chaos Blaster");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
	else if (Change[client] == false)
	{
		PrintHintText(client,"Fire Blaster");
		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
	}
}

public void Weapon_Messenger(int client, int weapon, bool crit)
{
	float damage = 300.0;

	damage *= Attributes_GetOnPlayer(client, 2, true);
	if(Change[client] == true)
	{
		damage *= 0.8;
	}
			
	float speed = 1100.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	
	speed *= Attributes_Get(weapon, 104, 1.0);
	
	speed *= Attributes_Get(weapon, 475, 1.0);
		
	float time = 2.0; //Because of Particle Spam.
	
	if(Change[client] == true)
	{
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_MESSENGER_LAUNCHER, weapon, "spell_fireball_tendril_parent_blue",_,false);
		EmitSoundToAll(SOUND_MES_SHOT_ICE, client, SNDCHAN_AUTO, 65, _, 0.45, 115);
	}
	else if(Change[client] == false)
	{
		Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_MESSENGER_LAUNCHER, weapon, "spell_fireball_tendril_parent_red",_,false);
		EmitSoundToAll(SOUND_MES_SHOT_FIRE, client, SNDCHAN_AUTO, 65, _, 0.45, 115);
	}
}

public void Messenger_Modechange(int client, int weapon, bool crit, int slot)
{
	if(IsValidEntity(client))
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 7.5);
			EmitSoundToAll(SOUND_MES_CHANGE, client, SNDCHAN_AUTO, 65, _, 0.45, 115);
			if(Change[client])
			{
				Change[client]=false;
			}
			else
			{
				Change[client]=true;
			}
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
}


public void Gun_MessengerTouch(int entity, int target)
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
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		float pap = Attributes_Get(weapon, 122, 0.0);


		if(Change[owner] == false)
		{
			NPC_Ignite(target, owner, 3.0, weapon);
		}
		else if(Change[owner] && pap > 1)
		{
			if((f_LowIceDebuff[target] - 0.5) < GetGameTime())
			{
				f_LowIceDebuff[target] = GetGameTime() + 0.6;
			}
		}
		else if(Change[owner] == true && pap <= 1)
		{
			if((f_VeryLowIceDebuff[target] - 0.5) < GetGameTime())
			{
				f_VeryLowIceDebuff[target] = GetGameTime() + 0.6;
			}
		}
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_BULLET, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		EmitSoundToAll(SOUND_MES_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		EmitSoundToAll(SOUND_MES_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}