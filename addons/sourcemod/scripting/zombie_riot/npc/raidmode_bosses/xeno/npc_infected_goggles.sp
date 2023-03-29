#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3"
};

static char g_HurtSounds[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3"
};

static char g_IdleAlertedSounds[][] =
{
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static char g_RangedAttackSounds[][] =
{
	"weapons/breadmonster/throwable/bm_throwable_throw.wav",
};

static char g_TeleportSounds[][] =
{
	"misc/halloween/spell_teleport.wav",
};

static char g_AngerSounds[][] =
{
	"vo/taunts/sniper_taunts05.mp3",
	"vo/taunts/sniper_taunts06.mp3",
	"vo/taunts/sniper_taunts08.mp3",
	"vo/taunts/sniper_taunts11.mp3",
	"vo/taunts/sniper_taunts12.mp3",
	"vo/taunts/sniper_taunts14.mp3"
};

static char g_HappySounds[][] =
{
	"vo/taunts/sniper/sniper_taunt_admire_02.mp3",
	"vo/compmode/cm_sniper_pregamefirst_6s_05.mp3",
	"vo/compmode/cm_sniper_matchwon_02.mp3",
	"vo/compmode/cm_sniper_matchwon_07.mp3",
	"vo/compmode/cm_sniper_matchwon_10.mp3",
	"vo/compmode/cm_sniper_matchwon_11.mp3",
	"vo/compmode/cm_sniper_matchwon_14.mp3"
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

#define LASERBEAM "sprites/laserbeam.vmt"

static int i_TargetToWalkTo[MAXENTITIES];
static float f_TargetToWalkToDelay[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static int i_RaidDuoAllyIndex = INVALID_ENT_REFERENCE;

public void RaidbossBlueGoggles_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheSound("player/flow.wav");
}

#define EMPOWER_SOUND "items/powerup_pickup_king.wav"
#define EMPOWER_MATERIAL "materials/sprites/laserbeam.vmt"
#define EMPOWER_WIDTH 5.0
#define EMPOWER_HIGHT_OFFSET 20.0

static float f_HurtRecentlyAndRedirected[MAXENTITIES]={-1.0, ...};

methodmap RaidbossBlueGoggles < CClotBody
{
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevengeSound()
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "vo/sniper_revenge%02d.mp3", (GetURandomInt() % 25) + 1);
		EmitSoundToAll(buffer, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHappySound()
	{
		EmitSoundToAll(g_HappySounds[GetRandomInt(0, sizeof(g_HappySounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayPullSound()
	{
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iGunType	// 0 = Melee, 1 = Sniper, 2 = SMG
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}
	property float m_flBuffCooldown	// Stage 2: Delay between buffing Silvester
	{
		public get()			{	return this.m_flCharge_delay;	}
		public set(float value) 	{	this.m_flCharge_delay = value;	}
	}
	property float m_flPiggyCooldown	// Stage 3: Delay between piggybacking Silvester
	{
		public get()			{	return this.m_flNextTeleport;	}
		public set(float value) 	{	this.m_flNextTeleport = value;	}
	}
	property float m_flPiggyFor	// Stage 3: Time until piggybacking ends
	{
		public get()			{	return this.m_flJumpCooldown;	}
		public set(float value) 	{	this.m_flJumpCooldown = value;	}
	}

	public RaidbossBlueGoggles(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcInternalId[npc.index] = XENO_RAIDBOSS_BLUE_GOGGLES;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		SDKHook(npc.index, SDKHook_Think, RaidbossBlueGoggles_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamage, RaidbossBlueGoggles_ClotDamaged);

		/*
			Cosmetics
		*/

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
	//	SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
	//	SetEntityRenderColor(npc.m_iWearable4, 65, 65, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		/*
			Variables
		*/

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 200.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iGunType = 0;
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 6.0;
		npc.m_flBuffCooldown = GetGameTime(npc.index) + GetRandomFloat(10.0, 12.5);
		npc.m_flPiggyCooldown = GetGameTime(npc.index) + GetRandomFloat(70.0, 100.0);
		npc.m_flPiggyFor = 0.0;

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		f_HurtRecentlyAndRedirected[npc.index] = 0.0;
		
		Citizen_MiniBossSpawn(npc.index);
		npc.StartPathing();

		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		return npc;
	}
}

public void RaidbossBlueGoggles_ClotThink(int iNPC)
{
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsEntityAlive(EntRefToEntIndex(i_RaidDuoAllyIndex)))
		{
			npc.PlayHappySound();
		}
		else
		{
			npc.PlayAngerSound();
		}

		if(RaidBossActive != INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("game_round_win"); 
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
		}

		//SDKUnhook(npc.index, SDKHook_Think, RaidbossBlueGoggles_ClotThink);
		
		// Play funny animation intro
		PF_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");

		// Give time to blend our current anim and intro then swap to this idle
		npc.m_flNextDelayTime = gameTime + 0.4;
	}


	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	if(npc.m_flNextThinkTime == FAR_FUTURE)
		npc.SetActivity("ACT_MP_CYOA_PDA_IDLE");

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.10;

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop < MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(!IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	
	if(!IsEntityAlive(i_TargetToWalkTo[npc.index]))
		f_TargetToWalkToDelay[npc.index] = 0.0;
	
	if(f_TargetToWalkToDelay[npc.index] < gameTime)
	{
		i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = gameTime + 1.0;
	}

	int ally = EntRefToEntIndex(i_RaidDuoAllyIndex);
	bool alone = !IsEntityAlive(ally);

	if(npc.m_flPiggyFor)
	{
		if(npc.m_flPiggyFor < gameTime || alone)
		{
			// Disable Piggyback Stuff
			npc.m_flPiggyFor = 0.0;
		}
	}

	if(i_TargetToWalkTo[npc.index] > 0)
	{
		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		float vecAlly[3];
		float vecTarget[3]; vecTarget = WorldSpaceCenter(i_TargetToWalkTo[npc.index]);
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < npc.GetLeadRadius()) 
		{
			vecTarget = PredictSubjectPosition(npc, i_TargetToWalkTo[npc.index]);
			PF_SetGoalVector(npc.index, vecTarget);
		}
		else
		{
			PF_SetGoalEntity(npc.index, i_TargetToWalkTo[npc.index]);
		}

		int tier = (Waves_GetRound() / 15);
		if(alone)
			tier++;

		if(npc.m_flSwitchCooldown < gameTime)
		{
			if(distance > 500000 || !(GetURandomInt() % (tier + 2)))	// 700 HU
			{
				if(npc.m_iGunType == 1)
				{
					npc.m_flSwitchCooldown = gameTime + 1.0;
				}
				else
				{
					npc.m_flSwitchCooldown = gameTime + 8.0;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iGunType = 1;

					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
					SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				}
			}
			else if(distance > 100000 || !(GetURandomInt() % (tier + 3)))	// 300 HU
			{
				if(npc.m_iGunType == 2)
				{
					npc.m_flSwitchCooldown = gameTime + 1.0;
				}
				else
				{
					npc.m_flSwitchCooldown = gameTime + 8.0;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iGunType = 2;

					if(IsValidEntity(npc.m_iWearable3))
						RemoveEntity(npc.m_iWearable3);
					
					npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
					SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
				}
			}
			else if(npc.m_iGunType == 0)
			{
				npc.m_flSwitchCooldown = gameTime + 1.0;
			}
			else
			{
				npc.m_flSwitchCooldown = gameTime + 5.0;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				npc.m_iGunType = 0;

				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
				SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
			}
		}

		if(!alone && tier > 0 && npc.m_flBuffCooldown < gameTime && !NpcStats_IsEnemySilenced(npc.index))
		{
			vecAlly = WorldSpaceCenter(ally);
			if(GetVectorDistance(vecAlly, vecMe, true) < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 5.0, 2.0) && Can_I_See_Enemy_Only(npc.index, ally))
			{
				// Buff Silver
				npc.m_flBuffCooldown = gameTime + GetRandomFloat(20.0, 25.0);

				spawnBeam(0.8, 50, 255, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 255, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
				spawnBeam(0.8, 50, 255, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);

				f_NpcImmuneToBleed[ally] = GetGameTime(ally) + 2.0;
				f_HussarBuff[ally] = GetGameTime(ally) + 2.0;
				f_HighTeslarDebuff[ally] = 0.0;
				f_LowTeslarDebuff[ally] = 0.0;
				IgniteFor[ally] = 0;
				f_HighIceDebuff[ally] = 0.0;
				f_LowIceDebuff[ally] = 0.0;
				f_VeryLowIceDebuff[ally] = 0.0;
				f_WidowsWineDebuff[ally] = 0.0;
				f_CrippleDebuff[ally] = 0.0;
				f_MaimDebuff[ally] = 0.0;
				f_SpecterDyingDebuff[ally] = 0.0;
				f_PassangerDebuff[ally] = 0.0;
			}
			else
			{
				npc.m_flBuffCooldown = gameTime + 2.0;
			}
		}
		else if(!alone && tier > 1 && npc.m_iGunType > 0 && npc.m_flPiggyCooldown < gameTime)
		{
			vecAlly = WorldSpaceCenter(ally);
			if(GetVectorDistance(vecAlly, vecMe, true) < 20000.0)	// 140 HU
			{
				// Enable piggyback
				npc.m_flPiggyCooldown = FAR_FUTURE;
				npc.m_flPiggyFor = gameTime + 8.0;
				npc.m_flSwitchCooldown = gameTime + 10.0;
			}
			else
			{
				npc.m_flPiggyCooldown = gameTime + 1.0;
			}
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.SetActivity("ACT_MP_COMPETITIVE_LOSERSTATE");
	}
}

	
public Action RaidbossBlueGoggles_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	//redirect damage and reduce it if in range.
	int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
	if(IsEntityAlive(AllyEntity) && !b_NpcIsInvulnerable[AllyEntity])
	{
		static float victimPos[3];
		static float partnerPos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
		GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
		float Distance = GetVectorDistance(victimPos, partnerPos, true);
		if(Distance < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 5.0, 2.0) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
		{	
			damage *= 0.8;
			SDKHooks_TakeDamage(AllyEntity, attacker, inflictor, damage * 0.75, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED);
			damage *= 0.25;
			f_HurtRecentlyAndRedirected[npc.index] = GetGameTime() + 0.15;
		}
	}

	return Plugin_Changed;
}

public void RaidbossBlueGoggles_NPCDeath(int entity)
{
	RaidbossBlueGoggles npc = view_as<RaidbossBlueGoggles>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(npc.index, SDKHook_Think, RaidbossBlueGoggles_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, RaidbossBlueGoggles_ClotDamaged);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}	
		if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
		{
			RemoveHudCooldown(EnemyLoop);
			Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
		}						
	}
	Citizen_MiniBossDeath(entity);
}


bool Goggles_TookDamageRecently(int entity)
{
	if(f_HurtRecentlyAndRedirected[entity] > GetGameTime())
	{
		return true;
	}
	return false;
}

void Goggles_SetRaidPartner(int partner)
{
	i_RaidDuoAllyIndex = EntIndexToEntRef(partner);
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}