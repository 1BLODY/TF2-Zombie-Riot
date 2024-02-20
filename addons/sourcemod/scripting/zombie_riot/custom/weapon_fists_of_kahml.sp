#pragma semicolon 1
#pragma newdecls required

static int how_many_times_fisted[MAXTF2PLAYERS];
static float f_DurationOfProjectileAttack[MAXTF2PLAYERS];
static int HHH_SkeletonOverride;

#define SOUND_AUTOAIM_IMPACT_FLESH_1 		"physics/flesh/flesh_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_2 		"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_3 		"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_4 		"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_AUTOAIM_IMPACT_FLESH_5 		"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_AUTOAIM_IMPACT_CONCRETE_1 		"physics/concrete/concrete_impact_bullet1.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_AUTOAIM_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

void KahmlFistMapStart()
{
	Zero(f_DurationOfProjectileAttack);
	HHH_SkeletonOverride = PrecacheModel("models/bots/headless_hatman.mdl");
}

public void Enable_HHH_Axe_Ability(int client, int weapon) 
{
	if(i_CustomWeaponEquipLogic[weapon] != WEAPON_HHH_AXE)
		return;

	if(i_PlayerModelOverrideIndexWearable[client] == 0)
		OverridePlayerModel(client, HHH_SkeletonOverride, true);
}

public void Fists_of_Kahml(int client, int weapon, bool crit, int slot)
{
	if(f_DurationOfProjectileAttack[client] > GetGameTime())
	{
		i_InternalMeleeTrace[weapon] = false;
		Attributes_Set(weapon, 396, 0.25);
		Handle swingTrace;
		float vecSwingForward[3];
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
					
		int target = TR_GetEntityIndex(swingTrace);	
		delete swingTrace;
		
		EmitSoundToAll("weapons/gauss/fire1.wav", client, _, 75, _, 0.25, GetRandomInt(90, 110));

		float damage = 30.0;
				
		float speed = 1100.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= Attributes_Get(weapon, 1, 1.0);
		speed *= Attributes_Get(weapon, 103, 1.0);

		speed *= Attributes_Get(weapon, 104, 1.0);

		speed *= Attributes_Get(weapon, 475, 1.0);


		float time = 2000.0/speed;
		time *= Attributes_Get(weapon, 101, 1.0);

		time *= Attributes_Get(weapon, 102, 1.0);
		char ProjectileParticle[32];
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				Format(ProjectileParticle, sizeof(ProjectileParticle), "%s", "raygun_projectile_blue_crit");
			}
			case 2:
			{
				Format(ProjectileParticle, sizeof(ProjectileParticle), "%s", "raygun_projectile_red_crit");
			}
		}
		if(IsValidEnemy(client, target))
		{

			int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_KAHMLFIST, weapon, ProjectileParticle);
			

			if(Can_I_See_Enemy_Only(target,projectile)) //Insta home!
			{
				HomingProjectile_TurnToTarget(target, projectile);
			}

			DataPack pack;
			CreateDataTimer(0.1, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(projectile)); //projectile
			pack.WriteCell(EntIndexToEntRef(target));		//victim to annihilate :)
			//We have found a victim.
		}
		else
		{
			Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_KAHMLFIST, weapon, ProjectileParticle);
			//no enemy, fire projectile blindly!, maybe itll hit an enemy!
		}



		return;
	}
	i_InternalMeleeTrace[weapon] = true;
	Attributes_Set(weapon, 396, 1.0);
	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		
	float flPos[3]; // original
	float flAng[3]; // original

	if(how_many_times_fisted[client] >= 3)
	{
		Rogue_OnAbilityUse(weapon);
		if(IsValidEntity(viewmodelModel))
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
					
			int particler = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.25);
					
			SetParent(viewmodelModel, particler, "effect_hand_r");
			
			GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
			
			int particlel = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.25);
			
					
			SetParent(viewmodelModel, particlel, "effect_hand_l");			
		}
		Attributes_Set(weapon, 1, 3.0);
		
		CreateTimer(0.2, Apply_cool_effects_kahml, client, TIMER_FLAG_NO_MAPCHANGE);
		Attributes_Set(weapon, 1, 3.0);
		how_many_times_fisted[client] = 0;
	}
	else
	{
		if(IsValidEntity(viewmodelModel))
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
					
			int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
					
			SetParent(viewmodelModel, particler, "effect_hand_r");
			
			GetAttachment(viewmodelModel, "effect_hand_l", flPos, flAng);
			
			int particlel = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
					
			SetParent(viewmodelModel, particlel, "effect_hand_l");	
		}
				
		Attributes_Set(weapon, 1, 1.0);
		how_many_times_fisted[client] += 1;
	}
}

public Action Apply_cool_effects_kahml(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		EmitSoundToAll("items/powerup_pickup_knockout_melee_hit.wav", client, SNDCHAN_STATIC, 70, _, 0.35);
		Client_Shake(client, 0, 25.0, 15.0, 0.25);
	}
	return Plugin_Handled;
}



public void Fists_of_Kahml_Ablity_2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0 && !(GetClientButtons(client) & IN_DUCK))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Crouch for ability");	
		return;
	}
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 60.0);
		Attributes_Set(weapon, 396, 0.25);

		float fAng[3];
		float flPos[3];
		GetClientEyeAngles(client, fAng);
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
		float damage = 15.0;
		fAng[0] = 0.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		int spawn_index = NPC_CreateById(WEAPON_KAHML_AFTERIMAGE, client, flPos, fAng, GetTeam(client));
		f_DurationOfProjectileAttack[client] = GetGameTime() + 10.0;
		if(spawn_index > 0)
		{
			EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", spawn_index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
			ParticleEffectAt(WorldSpaceCenterOld(spawn_index), "teleported_blue", 0.5);
			//this is the damage
			fl_heal_cooldown[spawn_index] = damage;
			i_Changed_WalkCycle[spawn_index] = EntIndexToEntRef(weapon);
		}
	}
}

public void Enable_Kahml_Fist_Ability(int client, int weapon) 
{
	if(i_CustomWeaponEquipLogic[weapon] != WEAPON_KAHMLFIST)
		return;

	if(Items_HasNamedItem(client, "Kahml's Contained Chaos"))
	{
		if(f_DurationOfProjectileAttack[client] > GetGameTime())
		{
			i_InternalMeleeTrace[weapon] = false;
			Attributes_Set(weapon, 396, 0.25);
		}

		i_Hex_WeaponUsesTheseAbilities[weapon] |= ABILITY_R;  //R status to weapon
		EntityFuncAttack3[weapon] = view_as<Function>(Fists_of_Kahml_Ablity_2);
	}
}


public void Melee_KahmlFistTouch(int entity, int target)
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

		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_CLUB, weapon, CalculateDamageForceOld(vecForward, 10000.0), Entity_Position);	// 2048 is DMG_NOGIB?
		
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		switch(GetRandomInt(1,4)) 
		{
			case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		}
		RemoveEntity(entity);
	}
}