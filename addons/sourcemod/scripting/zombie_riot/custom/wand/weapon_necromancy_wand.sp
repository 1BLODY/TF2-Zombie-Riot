#pragma semicolon 1
#pragma newdecls required

#define SOUND_WAND_SHOT_NECRO	"weapons/dragons_fury_shoot.wav"
#define SOUND_NECRO_IMPACT "misc/halloween/spell_lightning_ball_impact.wav"

void Wand_Necro_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_NECRO);
	PrecacheSound(SOUND_NECRO_IMPACT);
}

public void Weapon_Necro_Wand(int client, int weapon, bool crit)
{
	int mana_cost;
	Address address = TF2Attrib_GetByDefIndex(weapon, 733);
	if(address != Address_Null)
		mana_cost = RoundToCeil(TF2Attrib_GetValue(address));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		address = TF2Attrib_GetByDefIndex(weapon, 410);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
			
		float speed = 1100.0;
		address = TF2Attrib_GetByDefIndex(weapon, 103);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 104);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 475);
		if(address != Address_Null)
			speed *= TF2Attrib_GetValue(address);
	
	
		float time = 500.0/speed;
		address = TF2Attrib_GetByDefIndex(weapon, 101);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
	
		address = TF2Attrib_GetByDefIndex(weapon, 102);
		if(address != Address_Null)
			time *= TF2Attrib_GetValue(address);
			
		EmitSoundToAll(SOUND_WAND_SHOT_NECRO, client, SNDCHAN_WEAPON, 65, _, 0.45, 100);
		//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
		Wand_Projectile_Spawn(client, speed, time, damage, 3/*Default wand*/, weapon, "eyeboss_projectile");
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}


public void Want_NecroTouch(int entity, int target)
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
		Entity_Position = WorldSpaceCenter(target);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, CalculateDamageForce(vecForward, 10000.0), Entity_Position, false);	// 2048 is DMG_NOGIB?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_NECRO_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		EmitSoundToAll(SOUND_NECRO_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
	}
}