#pragma semicolon 1
#pragma newdecls required

#define BOB_FIRST_LIGHTNING_RANGE 100.0

#define BOB_CHARGE_TIME 1.5
#define BOB_CHARGE_SPAN 0.5

static const char g_IntroStartSounds[][] =
{
	"npc/combine_soldier/vo/overwatchtargetcontained.wav",
	"npc/combine_soldier/vo/overwatchtarget1sterilized.wav"
};

static const char g_IntroEndSounds[][] =
{
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav"
};

static const char g_SummonSounds[][] =
{
	"npc/combine_soldier/vo/overwatchrequestreinforcement.wav"
};

static const char g_SkyShieldSounds[][] =
{
	"npc/combine_soldier/vo/overwatchrequestskyshield.wav"
};

static const char g_SpeedUpSounds[][] =
{
	"npc/combine_soldier/vo/ovewatchorders3ccstimboost.wav"
};

static const char g_SummonDiedSounds[][] =
{
	"npc/combine_soldier/vo/overwatchteamisdown.wav"
};

static const char PullRandomEnemyAttack[][] =
{
	"weapons/physcannon/energy_sing_explosion2.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/physcannon/physcannon_claws_close.wav"
};

static const char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static const char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static const char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static const char g_FireRocketHoming[][] =
{
	"weapons/cow_mangler_explosion_charge_04.wav",
	"weapons/cow_mangler_explosion_charge_05.wav",
	"weapons/cow_mangler_explosion_charge_06.wav",
};

static int BobHitDetected[MAXENTITIES];

void RaidbossBobTheFirst_OnMapStart()
{
	PrecacheSoundArray(g_IntroStartSounds);
	PrecacheSoundArray(g_IntroEndSounds);
	PrecacheSoundArray(g_SummonSounds);
	PrecacheSoundArray(g_SkyShieldSounds);
	PrecacheSoundArray(g_SpeedUpSounds);
	PrecacheSoundArray(g_SummonDiedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_BuffSounds);
	PrecacheSoundArray(PullRandomEnemyAttack);
	PrecacheSoundArray(g_FireRocketHoming);
	
	PrecacheSoundCustom("#zombiesurvival/bob_raid/bob.mp3");
}

methodmap RaidbossBobTheFirst < CClotBody
{
	public void PlayIntroStartSound()
	{
		EmitSoundToAll(g_IntroStartSounds[GetRandomInt(0, sizeof(g_IntroStartSounds) - 1)]);
	}
	public void PlayIntroEndSound()
	{
		EmitSoundToAll(g_IntroStartSounds[GetRandomInt(0, sizeof(g_IntroStartSounds) - 1)]);
	}
	public void PlaySummonSound()
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)]);
	}
	public void PlaySkyShieldSound()
	{
		EmitSoundToAll(g_SkyShieldSounds[GetRandomInt(0, sizeof(g_SkyShieldSounds) - 1)]);
	}
	public void PlaySpeedUpSound()
	{
		EmitSoundToAll(g_SpeedUpSounds[GetRandomInt(0, sizeof(g_SpeedUpSounds) - 1)]);
	}
	public void PlaySummonDeadSound()
	{
		EmitSoundToAll(g_SummonDiedSounds[GetRandomInt(0, sizeof(g_SummonDiedSounds) - 1)]);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSpecialSound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRandomEnemyPullSound()
	{
		EmitSoundToAll(PullRandomEnemyAttack[GetRandomInt(0, sizeof(PullRandomEnemyAttack) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRocketHoming()
	{
		EmitSoundToAll(g_FireRocketHoming[GetRandomInt(0, sizeof(g_FireRocketHoming) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property int m_iPullCount
	{
		public get()		{	return this.m_iMedkitAnnoyance;	}
		public set(int value) 	{	this.m_iMedkitAnnoyance = value;	}
	}
	property bool m_bSecondPhase
	{
		public get()		{	return i_NpcInternalId[this.index] == BOB_THE_FIRST_S;	}
		public set(bool value)	{	i_NpcInternalId[this.index] = value ? BOB_THE_FIRST_S : BOB_THE_FIRST;	}
	}

	public RaidbossBobTheFirst(float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		float pos[3];
		pos = vecPos;
		
		for(int i; i < i_MaxcountNpc; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(entity != INVALID_ENT_REFERENCE && (i_NpcInternalId[entity] == SEA_RAIDBOSS_DONNERKRIEG || i_NpcInternalId[entity] == SEA_RAIDBOSS_SCHWERTKRIEG) && IsEntityAlive(entity))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
				SmiteNpcToDeath(entity);
			}
		}

		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(CClotBody(pos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "20000000", ally, _, _, true, true));
		
		i_NpcInternalId[npc.index] = BOB_THE_FIRST;
		i_NpcWeight[npc.index] = 4;
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MUDROCK_RAGE");
	//	npc.m_flNextDelayTime = GetGameTime(npc.index) + 10.0;
		b_NpcIsInvulnerable[npc.index] = true;

		npc.PlayIntroStartSound();

		SDKHook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
		
		if(StrContains(data, "final_item") != -1)
			i_RaidGrantExtra[npc.index] = 1;

		/*
			Cosmetics
		*/
		
		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		/*
			Variables
		*/

		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		npc.m_bThisNpcIsABoss = true;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_flMeleeArmor = 1.25;

		npc.Anger = false;
		npc.m_flSpeed = 340.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_iAttackType = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iPullCount = 0;
		
		strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), "??????????????????????????????????");
		Music_SetRaidMusic("#zombiesurvival/bob_raid/bob.mp3", 697, true, 1.99);
		npc.StopPathing();

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_stunbaton.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Disable");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime() + 292.0;
		RaidModeScaling = 9999999.99;

		Zombies_Currently_Still_Ongoing--;

		return npc;
	}
}

public void RaidbossBobTheFirst_ClotThink(int iNPC)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
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

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
				ForcePlayerSuicide(client);
		}

		char buffer[64];
		if(c_NpcCustomNameOverride[npc.index][0])
		{
			strcopy(buffer, sizeof(buffer), c_NpcCustomNameOverride[npc.index]);
		}
		else
		{
			strcopy(buffer, sizeof(buffer), NPC_Names[i_NpcInternalId[npc.index]]);
		}

		switch(GetURandomInt() % 3)
		{
			case 0:
				CPrintToChatAll("{white}%s{default}: You weren't supposed to have this infection.", buffer);
			
			case 1:
				CPrintToChatAll("{white}%s{default}: No choice but to kill you, it consumes you.", buffer);
			
			case 2:
				CPrintToChatAll("{white}%s{default}: Nobody wins.", buffer);
		}
		
		// Play funny animation intro
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.SetActivity("ACT_IDLE_ZOMBIE");
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	//npc.m_flNextThinkTime = gameTime + 0.05;

	if(i_RaidGrantExtra[npc.index] > 1)
	{
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.SetActivity("ACT_IDLE_SHIELDZOBIE");

		if(XenoExtraLogic())
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					ReviveAll(true);
					CPrintToChatAll("{white}Bob the First{default}: So...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}Bob the First{default}: What do you think will happpen..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}Bob the First{default}: What if you killed Seaborn before Xeno..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}Bob the First{default}: Well nothing is holding this one back now...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}Bob the First{default}: ...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 7:
				{
					GiveProgressDelay(1.0);
					SmiteNpcToDeath(npc.index);

					Enemy enemy;

					enemy.Index = XENO_RAIDBOSS_NEMESIS;
					enemy.Health = 30000000;
					enemy.Is_Boss = 2;
					enemy.ExtraSpeed = 1.5;
					enemy.ExtraDamage = 3.0;
					enemy.ExtraSize = 1.0;

					Waves_AddNextEnemy(enemy);

					Zombies_Currently_Still_Ongoing++;

					CreateTimer(0.9, Bob_DeathCutsceneCheck, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}
			}
		}
		else
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					ReviveAll(true);
					CPrintToChatAll("{white}Bob the First{default}: No...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}Bob the First{default}: This infection...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}Bob the First{default}: How did this thing make you thing powerful..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}Bob the First{default}: Took out every single Seaborn and took the infection in yourselves...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}Bob the First{default}: You people fighting these cities and infections...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 7:
				{
					CPrintToChatAll("{white}Bob the First{default}: However...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 8:
				{
					CPrintToChatAll("{white}Bob the First{default}: I will remove what does not belong to you...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 9:
				{
					npc.m_flNextThinkTime = gameTime + 1.25;

					GiveProgressDelay(1.5);
					Waves_ForceSetup(1.5);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && !IsFakeClient(client))
						{
							if(IsPlayerAlive(client))
								ForcePlayerSuicide(client);
							
							ApplyLastmanOrDyingOverlay(client);
							SendConVarValue(client, sv_cheats, "1");
						}
					}

					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.5, SetTimeBack);
				}
				case 10:
				{
					SmiteNpcToDeath(npc.index);
					GivePlayerItems();
				}
			}
		}

		i_RaidGrantExtra[npc.index]++;
		return;
	}

	if(npc.Anger)	// Waiting for enemies to die off
	{
		float enemies = float(Zombies_Currently_Still_Ongoing);

		for(int i; i < i_MaxcountNpc; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				int maxhealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
				if(maxhealth)
					enemies += float(GetEntProp(victim, Prop_Data, "m_iHealth")) / float(maxhealth);
			}
		}

		if(enemies > 3.0)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * (enemies + 1.0) / 485.0));
			return;
		}

		GiveOneRevive();
		RaidModeTime += 140.0;

		npc.m_flRangedArmor = 0.9;
		npc.m_flMeleeArmor = 1.125;

		npc.PlaySummonDeadSound();
		
		npc.Anger = false;
		npc.m_bSecondPhase = true;
		c_NpcCustomNameOverride[npc.index][0] = 0;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 17 / 20);

		if(XenoExtraLogic())
		{
			switch(GetURandomInt() % 3)
			{
				case 0:
					CPrintToChatAll("{white}Bob the First{default}: Your in the wrong place in the wrong time!");
				
				case 1:
					CPrintToChatAll("{white}Bob the First{default}: This is not how it goes!");
				
				case 2:
					CPrintToChatAll("{white}Bob the First{default}: Stop trying to change fate!");
			}
		}
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
					CPrintToChatAll("{white}Bob the First{default}: Enough of this!");
				
				case 1:
					CPrintToChatAll("{white}Bob the First{default}: Do you see yourself? Your slaughter?");
				
				case 2:
					CPrintToChatAll("{white}Bob the First{default}: You are no god.");
				
				case 3:
					CPrintToChatAll("{white}Bob the First{default}: Xeno. Seaborn. Then there's you.");
			}
		}

		npc.m_flNextMeleeAttack = gameTime + 2.0;
	}

	if(b_NpcIsInvulnerable[npc.index] || npc.m_flGetClosestTargetTime < gameTime || !IsEntityAlive(npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(b_NpcIsInvulnerable[npc.index])
		{
			b_NpcIsInvulnerable[npc.index] = false;
			npc.PlayIntroEndSound();
		}
	}

	int healthPoints = GetEntProp(npc.index, Prop_Data, "m_iHealth") * 20 / GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	if(!npc.m_bSecondPhase)
	{
		if(healthPoints < 15 && !c_NpcCustomNameOverride[npc.index][0])
		{
			strcopy(c_NpcCustomNameOverride[npc.index], sizeof(c_NpcCustomNameOverride[]), "??????? First");
		}
		else if(healthPoints < 9)
		{
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			
			GiveOneRevive();
			RaidModeTime += 260.0;

			npc.Anger = true;
			npc.SetActivity("ACT_IDLE_ZOMBIE");
			strcopy(c_NpcCustomNameOverride[npc.index], sizeof(c_NpcCustomNameOverride[]), "??? the First");

			npc.PlaySummonSound();
			
			SetupMidWave();
			return;
		}
	}

	if(npc.m_iTarget > 0 && healthPoints < 20)
	{
		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

		switch(npc.m_iAttackType)
		{
			case 2:	// COMBO1 - Frame 54
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 1.333);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 2.333;
				}
			}
			case 4:	// COMBO2 - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833);
					
					npc.m_iAttackType = 5;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 5:	// COMBO2 - Frame 52
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833);
					
					npc.m_iAttackType = 6;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 6:	// COMBO2 - Frame 73
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.875);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.083;
				}
			}
			case 8:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;

					int projectile = npc.FireParticleRocket(vecTarget, 3000.0, 200.0, 150.0, "unusual_robot_time_warp", true);
					npc.DispatchParticleEffect(npc.index, "rd_robot_explosion_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						
					npc.PlayRocketHoming();
					float ang_Look[3];
					GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
					Initiate_HomingProjectile(projectile,
						npc.index,
						70.0,			// float lockonAngleMax,
						10.0,				//float homingaSec,
						false,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						ang_Look);// float AnglesInitiate[3]);
				}
			}
			case 9:
			{
				vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vecTarget);

				npc.FaceTowards(vecTarget, 20000.0);
				
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;

					KillFeed_SetKillIcon(npc.index, "fists");

					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					bool PlaySound = false;
					for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
					{
						if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
						{
							if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
							{
								PlaySound = true;
								int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								vecHit = WorldSpaceCenter(target);

								SDKHooks_TakeDamage(target, npc.index, npc.index, 250.0, DMG_CLUB, -1, _, vecHit);	
								
								bool Knocked = false;
								
								if(IsValidClient(target))
								{
									if (IsInvuln(target))
									{
										Knocked = true;
										Custom_Knockback(npc.index, target, 1000.0, true);
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
									else
									{
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
								}
								
								if(!Knocked)
									Custom_Knockback(npc.index, target, 750.0);
							}
						} 
					}

					if(PlaySound)
						npc.PlayMeleeSound();

					KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
				}
			}
			case 10:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;

					int ref = EntIndexToEntRef(npc.index);

					Handle data = CreateDataPack();
					WritePackFloat(data, vecMe[0]);
					WritePackFloat(data, vecMe[1]);
					WritePackFloat(data, vecMe[2]);
					WritePackCell(data, 47.0); // Distance
					WritePackFloat(data, 0.0); // nphi
					WritePackCell(data, 250.0); // Range
					WritePackCell(data, 1000.0); // Damge
					WritePackCell(data, ref);
					ResetPack(data);
					TrueFusionwarrior_IonAttack(data);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && IsPlayerAlive(client))
						{
							GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecTarget);
							
							data = CreateDataPack();
							WritePackFloat(data, vecTarget[0]);
							WritePackFloat(data, vecTarget[1]);
							WritePackFloat(data, vecTarget[2]);
							WritePackCell(data, 87.0); // Distance
							WritePackFloat(data, 0.0); // nphi
							WritePackCell(data, 250.0); // Range
							WritePackCell(data, 1000.0); // Damge
							WritePackCell(data, ref);
							ResetPack(data);
							TrueFusionwarrior_IonAttack(data);
						}
					}
				}
			}
			case 11, 12:
			{
				float distance = GetVectorDistance(vecTarget, vecMe, true);
				if(distance < npc.GetLeadRadius()) 
				{
					vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
					NPC_SetGoalVector(npc.index, vecTarget);
				}
				else
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}

				npc.StartPathing();
				npc.SetActivity("ACT_DARIO_WALK");

				if(npc.m_iAttackType == 12)
					npc.m_flSpeed = 192.0;
				
				if(npc.m_flAttackHappens < gameTime)
				{
					if(npc.m_iAttackType == 11)
					{
						npc.m_iAttackType = 12;
						npc.AddGesture("ACT_DARIO_ATTACK_GUN_1");
						npc.m_flAttackHappens = gameTime + 0.4;
					}
					else
					{
						npc.m_iAttackType = 11;
						npc.m_flAttackHappens = gameTime + 0.5;
						
						vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0);
						npc.FireRocket(vecTarget, 400.0, 1200.0, "models/weapons/w_bullet.mdl", 2.0);
					}
				}

				npc.FaceTowards(vecTarget, 2500.0);
			}
			case 13, 14:
			{
				npc.StopPathing();
				//npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				if(npc.m_flAttackHappens < gameTime)
				{
					if(npc.m_iAttackType == 13)
					{
						npc.m_iAttackType = 14;
						npc.m_iState = -1;	// Replay the animation regardless
						npc.SetActivity("ACT_PUSH_PLAYER");
						npc.SetPlaybackRate(2.0);
						npc.m_flAttackHappens = gameTime + 0.2;
					}
					else
					{
						static bool ClientTargeted[MAXENTITIES];
						static int TotalEnemeisInSight;


						//initiate only once per ability
						UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
						if(npc.m_iPullCount == 0)
						{
							Zero(ClientTargeted);
							TotalEnemeisInSight = 0;
							int enemy_2[MAXENTITIES];
							GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
							for(int i; i < sizeof(enemy_2); i++)
							{
								if(enemy_2[i])
								{
									TotalEnemeisInSight++;
								}
							}
							TotalEnemeisInSight /= 2;
							if(TotalEnemeisInSight <= 1)
							{
								TotalEnemeisInSight = 1;
							}
						}


						int enemy_2[MAXENTITIES];
						int EnemyToPull = 0;
						GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
						for(int i; i < sizeof(enemy_2); i++)
						{
							if(enemy_2[i] && !ClientTargeted[enemy_2[i]])
							{
								EnemyToPull = enemy_2[i];
								ClientTargeted[enemy_2[i]] = true;
								break;
							}
						}

						npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						npc.PlayRandomEnemyPullSound();

						if(npc.m_iPullCount > TotalEnemeisInSight)
						{
							// After X pulls, revert to normal
							npc.m_iAttackType = 0;
							npc.m_flAttackHappens = gameTime + 0.2;
						}
						else
						{
							// Play animation delay
							npc.m_iAttackType = 13;
							npc.m_flAttackHappens = gameTime + 0.2;
							npc.m_iPullCount++;
						}

						if(EnemyToPull)
						{
							vecTarget = PredictSubjectPosition(npc, EnemyToPull);
							npc.FaceTowards(vecTarget, 50000.0);
							BobPullTarget(npc.index, EnemyToPull);
							//We succsssfully pulled someone.
							//Take their old position and nuke it.
							float vEnd[3];
					
							vEnd = GetAbsOrigin(EnemyToPull);
							Handle pack;
							CreateDataTimer(BOB_CHARGE_SPAN, Smite_Timer_Bob, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							WritePackCell(pack, EntIndexToEntRef(npc.index));
							WritePackFloat(pack, 0.0);
							WritePackFloat(pack, vEnd[0]);
							WritePackFloat(pack, vEnd[1]);
							WritePackFloat(pack, vEnd[2]);
							WritePackFloat(pack, 1000.0);
							spawnRing_Vectors(vEnd, BOB_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, BOB_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
						}
					}
				}
			}
			default:
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					if(healthPoints < 19 && npc.m_flNextMeleeAttack < gameTime)
					{
						AcceptEntityInput(npc.m_iWearable1, "Disable");
						
						npc.m_flNextMeleeAttack = gameTime + 10.0;
						npc.StopPathing();
						float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);

						switch(GetURandomInt() % 3)
						{
							case 0:
							{
								npc.SetActivity("ACT_COMBO1_BOBPRIME");
								npc.m_iAttackType = 2;
								npc.m_flAttackHappens = gameTime + 0.916;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.916);
							}
							case 1:
							{
								npc.SetActivity("ACT_COMBO2_BOBPRIME");
								npc.m_iAttackType = 4;
								npc.m_flAttackHappens = gameTime + 0.5;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5);
							}
							case 2:
							{
								npc.SetActivity("ACT_COMBO3_BOBPRIME");
								npc.m_flAttackHappens = gameTime + 3.25;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 2.125);
							}
						}
					}
					else if(healthPoints < 17 && npc.m_flNextRangedAttack < gameTime)
					{
						npc.m_flNextRangedAttack = gameTime + (healthPoints < 9 ? 6.0 : 12.0);
						npc.PlayRangedSound();
						npc.StopPathing();

						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 8;
						npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 11 && npc.m_flNextRangedSpecialAttack < gameTime)
					{
						npc.m_flNextRangedSpecialAttack = gameTime + (healthPoints < 7 ? 15.0 : 27.0);
						npc.StopPathing();
						npc.PlaySkyShieldSound();

						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 10;
						npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 15 && npc.m_flNextChargeSpecialAttack < gameTime)
					{
						// Start pull attack chain
						npc.m_flNextChargeSpecialAttack = gameTime + (healthPoints < 7 ? 15.0 : 27.0);
						npc.StopPathing();

						npc.m_iAttackType = 13;
						npc.m_iPullCount = 0;
						//npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 3)
					{
						npc.m_flSpeed = 1.0;
						npc.m_iAttackType = 11;
						npc.m_flAttackHappens = gameTime + 1.333;

						npc.AddGesture("ACT_METROCOP_DEPLOY_PISTOL");
						
						if(IsValidEntity(npc.m_iWearable1))
							RemoveEntity(npc.m_iWearable1);
						
						npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
						SetVariantString("1.15");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}
					else
					{
						float speed = healthPoints < 13 ? 330.0 : 290.0;
						if(npc.m_flSpeed != speed)
						{
							npc.m_flSpeed = speed;
							if(healthPoints == 12)
								npc.PlaySpeedUpSound();
						}
						
						float distance = GetVectorDistance(vecTarget, vecMe, true);
						if(distance < npc.GetLeadRadius()) 
						{
							vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
							NPC_SetGoalVector(npc.index, vecTarget);
						}
						else
						{
							NPC_SetGoalEntity(npc.index, npc.m_iTarget);
						}

						npc.StartPathing();
						
						if(distance < 10000.0)	// 100 HU
						{
							npc.StopPathing();
							
							AcceptEntityInput(npc.m_iWearable1, "Enable");
							
							npc.SetActivity("ACT_IDLE_BOBPRIME");
							npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
							npc.m_iAttackType = 9;
							npc.m_flAttackHappens = gameTime + 0.667;
						}
						else
						{
							npc.SetActivity("ACT_RUN_PANICKED");
						}
					}
				}
			}
		}
	}
	else
	{
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		
		npc.StopPathing();
		npc.SetActivity("ACT_IDLE_BOBPRIME");
	}
}

static void GiveOneRevive()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			int glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);
			
			glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);
			
			if(IsPlayerAlive(client))
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
			}
			
			ForcePlayerCrouch(client, false);
			//just make visible.
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			
			i_AmountDowned[client]--;
			if(i_AmountDowned[client] < 0)
				i_AmountDowned[client] = 0;
			
			DoOverlay(client, "", 2);
			if(GetClientTeam(client) == 2)
			{
				if((!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD))
				{
					DHook_RespawnPlayer(client);
					GiveCompleteInvul(client, 2.0);
				}
				else if(dieingstate[client] > 0)
				{
					GiveCompleteInvul(client, 2.0);

					if(b_LeftForDead[client])
					{
						dieingstate[client] = -8; //-8 for incode reasons, check dieing timer.
					}
					else
					{
						dieingstate[client] = 0;
					}

					Store_ApplyAttribs(client);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);

					int entity, i;
					while(TF2U_GetWearable(client, entity, i))
					{
						SetEntityRenderMode(entity, RENDER_NORMAL);
						SetEntityRenderColor(entity, 255, 255, 255, 255);
					}

					SetEntityRenderMode(client, RENDER_NORMAL);
					SetEntityRenderColor(client, 255, 255, 255, 255);
					SetEntityCollisionGroup(client, 5);

					SetEntityHealth(client, 50);
					RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(client));
				}
			}
		}
	}

	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[entity] == CITIZEN)
		{
			Citizen npc = view_as<Citizen>(entity);
			if(npc.m_nDowned && npc.m_iWearable3 > 0)
				npc.SetDowned(false);
		}
	}

	CheckAlivePlayers();
}
/*
static bool RowAttack(RaidbossBobTheFirst npc, const float vecMe[3], float damage, float range, bool kick, float TimeUntillHurt)
{
	float vecAngles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAngles);

	// Lock to 90 angles
	vecAngles[1] = (((vecAngles[1] > 0.0 ? 45 : -45) + RoundFloat(vecAngles[1])) / 90) * 90.0;
	
	float vecForward[3], vecTarget[3];
	GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);

	for(int i; i < 3; i++)
	{
		vecTarget[i] = vecMe[i] + vecForward[i];
	}

	npc.FaceTowards(vecTarget, 1000.0);

	if(npc.m_iPullCount == 0)	// First frame
	{
		//todo: Make it a trace beacuse thats better
		//make it a better laser to represent where he will hit, maybe static or something, a box whatever it is.
		//do a circular around him cus that also hurts
		//the delay is via frames, and add the delay from initiate to attack here via frames, or convert.
		
		float time = GetGameTime(npc.index) -
		float VectorGive[3];
		
		VectorGive = vecMe;
		BobInitiatePunch(npc.index, WorldSpaceCenter(target), VectorGiveLastStoreMenu);
	}
	
	npc.m_iPullCount++;
	
	if(npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		KillFeed_SetKillIcon(npc.index, kick ? "mantreads" : "fists");

		if(NpcStats_IsEnemySilenced(npc.index))
			kick = false;
		
		Zero(BobHitDetected);

		Handle trace;
		trace = TR_TraceHullFilterEx(vecMe, VectorTarget, hullMin, hullMax, 1073741824, Bob_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
				
		float CloseDamage = 70.0 * RaidModeScaling;
		float FarDamage = 60.0 * RaidModeScaling;
		float MaxDistance = 5000.0;
		float playerPos[3];
		for(int victim = 1; victim < MAXENTITIES; victim++)
		{
			if(SensalHitDetected[victim] && GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
			{
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
				float distance = GetVectorDistance(VectorStart, playerPos, false);
				float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
				if (damage < 0)
					damage *= -1.0;

				
				if(victim > MaxClients) //make sure barracks units arent bad
					damage *= 0.5;

				SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
					
			}
		}
		delete pack;

		
		for(int victim = 1; victim <= MaxClients; victim++)
		{
			if(IsClientInGame(victim) && IsPlayerAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET);
					if(kick)
					{
						vecTarget[0] = 0.0;
						vecTarget[1] = 0.0;
						vecTarget[2] = 500.0;//400.0;
						TeleportEntity(victim, _, _, vecTarget, true);

						TF2_StunPlayer(victim, 1.5, 0.5, TF_STUNFLAGS_NORMALBONK, victim);
					}
				}
			}
		}
		
		for(int i; i < i_MaxcountNpc; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET);
					if(kick)
					{
						FreezeNpcInTime(victim, 1.5);
						
						vecTarget = WorldSpaceCenter(victim);
						vecTarget[2] += 100.0; //Jump up.
						PluginBot_Jump(victim, vecTarget);
					}
				}
			}
		}
		
		for(int i; i < i_MaxcountNpc_Allied; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB);
					if(kick)
					{
						FreezeNpcInTime(victim, 1.5);
						
						vecTarget = WorldSpaceCenter(victim);
						vecTarget[2] += 100.0; //Jump up.
						PluginBot_Jump(victim, vecTarget);
					}
				}
			}
		}

		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

		return true;
	}

	return false;
}

static bool Bob_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if(IsEntityAlive(entity))
		BobHitDetected[entity] = true;
	
	return false;
}

static bool Bob_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
*/
static bool HitByForward(int entity, const float vecCenter[3], const float vecForward[3], float range)
{
	float vecMe[3];
	vecMe = WorldSpaceCenter(entity);

	for(int i; i < 2; i++)
	{
		// Check if in pathway
		if(vecForward[i] > 0.8)
		{
			if((vecCenter[i] - range) > vecMe[i])
				return false;
		}
		else if(vecForward[i] < -0.8)
		{
			if((vecCenter[i] + range) < vecMe[i])
				return false;
		}
		else
		{
			continue;
		}

		// Left/right check
		i = i == 0 ? 1 : 0;
		if(fabs(vecCenter[i] - vecMe[i]) > 80.0)
			return false;
		
		// Up/down check
		if(fabs(vecCenter[2] - vecMe[2]) > 250.0)//175.0)
			return false;
		
		return true;
	}
	
	return false;
}

static void SetupMidWave()
{
	AddBobEnemy(COMBINE_SOLDIER_ELITE, 20);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 20);
	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 40);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 15);
	AddBobEnemy(COMBINE_SOLDIER_COLLOSS, 2, 1);

	AddBobEnemy(COMBINE_SOLDIER_DDT, 30);
	AddBobEnemy(COMBINE_SOLDIER_ELITE, 20);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 20);

	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 40);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 10);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 20);

	AddBobEnemy(COMBINE_SOLDIER_ELITE, 50);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 50);
	AddBobEnemy(COMBINE_SOLDIER_SHOTGUN, 50);

	AddBobEnemy(COMBINE_SOLDIER_ELITE, 10);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 10);
	AddBobEnemy(COMBINE_SOLDIER_AR2, 10);
	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 10);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 10);
	AddBobEnemy(COMBINE_SOLDIER_SHOTGUN, 10);
	AddBobEnemy(COMBINE_SOLDIER_AR2, 10);
	AddBobEnemy(COMBINE_POLICE_SMG, 10);
	AddBobEnemy(COMBINE_POLICE_PISTOL, 10);
}

static void AddBobEnemy(int id, int count, int boss = 0)
{
	Enemy enemy;

	enemy.Index = id;
	enemy.Is_Boss = boss;
	enemy.Is_Health_Scaled = 1;
	enemy.ExtraMeleeRes = 0.05;
	enemy.ExtraRangedRes = 0.05;
	enemy.ExtraSpeed = 1.5;
	enemy.ExtraDamage = 4.0;
	enemy.ExtraSize = 1.0;

	for(int i; i < count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}

	Zombies_Currently_Still_Ongoing += count;
}

Action RaidbossBobTheFirst_OnTakeDamage(int victim, int &attacker, float &damage)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(victim);
	
	if(npc.Anger || i_RaidGrantExtra[npc.index] > 1)
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if(i_RaidGrantExtra[npc.index] == 1 && Waves_GetRound() > 55)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			Music_SetRaidMusic("vo/null.mp3", 30, false, 0.5);
			npc.StopPathing();

			RaidBossActive = -1;

			i_RaidGrantExtra[npc.index] = 2;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(30.0);
			damage = 0.0;
			
			return Plugin_Handled;
		}
	}

	return Plugin_Changed;
}

void RaidbossBobTheFirst_NPCDeath(int entity)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	SDKUnhook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
	
	Zombies_Currently_Still_Ongoing++;	// Because it was decreased before

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static Action Bob_DeathCutsceneCheck(Handle timer)
{
	if(!LastMann)
		return Plugin_Continue;
	
	for(int i; i < i_MaxcountNpc; i++)
	{
		int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(victim != INVALID_ENT_REFERENCE && IsEntityAlive(victim))
			SmiteNpcToDeath(victim);
	}
	
	GiveProgressDelay(1.5);
	Waves_ForceSetup(1.5);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			if(IsPlayerAlive(client))
				ForcePlayerSuicide(client);
			
			ApplyLastmanOrDyingOverlay(client);
			SendConVarValue(client, sv_cheats, "1");
		}
	}

	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);

	GivePlayerItems();
	return Plugin_Stop;
}

static void GivePlayerItems()
{
	/*
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
		{
			Items_GiveNamedItem(client, "Cured Silvester");
			CPrintToChat(client, "{default}You gained his favor, you obtained: {yellow}''Cured Silvester''{default}!");
		}
	}
	*/
}

public Action Smite_Timer_Bob(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= BOB_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.4, 1, (BOB_FIRST_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 120);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		 
		CreateEarthquake(spawnLoc, 1.0, BOB_FIRST_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, BOB_FIRST_LIGHTNING_RANGE * 1.4,_,0.8, true);  //Explosion range increace
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, BOB_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + BOB_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
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

static void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
			
	int ICE_INT = PrecacheModel(sprite);
		
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
		
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}

void BobPullTarget(int bobnpc, int enemy)
{
	CClotBody npc = view_as<CClotBody>(bobnpc);
	//pull player
	float vecMe[3];
	float vecTarget[3];
	vecMe = WorldSpaceCenter(npc.index);
	if(enemy <= MaxClients)
	{
		static float angles[3];
		
		vecTarget = WorldSpaceCenter(enemy);
		GetVectorAnglesTwoPoints(vecTarget, vecMe, angles);
		
		if(GetEntityFlags(enemy) & FL_ONGROUND)
			angles[0] = 0.0; // toss out pitch if on ground

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		static float velocity[3];
		GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(velocity, Pow(distance, 0.5) * 2.15);
		
		// min Z if on ground
		if(GetEntityFlags(enemy) & FL_ONGROUND)
			velocity[2] = fmax(400.0, velocity[2]);
		
		// apply velocity
		TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, velocity);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);	
	}
	else
	{
		CClotBody npcenemy = view_as<CClotBody>(enemy);

		PluginBot_Jump(npcenemy.index, vecMe);
	}
}

static int SensalHitDetected_2[MAXENTITIES];

void BobInitiatePunch(int entity, float VectorTarget[3], float VectorStart[3], float TimeUntillHit)
{

	CClotBody npc = view_as<CClotBody>(entity);
	npc.FaceTowards(VectorTarget, 20000.0);
	int FramesUntillHit = RoundToNearest(TimeUntillHit * 66.0);

	float vecForward[3], vecRight[3], Angles[3];

	GetVectorAnglesTwoPoints(VectorStart, VectorTarget, Angles);

	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);

	float VectorTarget_2[3];
	float VectorForward = 5000.0; //a really high number.
	
	VectorTarget_2[0] = VectorStart[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = VectorStart[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = VectorStart[2] + vecForward[2] * VectorForward;


	int red = 255;
	int green = 255;
	int blue = 255;
	int Alpha = 255;

	int colorLayer4[4];
	float diameter = float(25 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];

	for(int BeamCube = 0; BeamCube < 4 ; BeamCube++)
	{
		float OffsetFromMiddle[3];
		switch(BeamCube)
		{
			case 0:
			{
				OffsetFromMiddle = {0.0, 25.0,25.0};
			}
			case 1:
			{
				OffsetFromMiddle = {0.0, -25.0,-25.0};
			}
			case 2:
			{
				OffsetFromMiddle = {0.0, 25.0,-25.0};
			}
			case 3:
			{
				OffsetFromMiddle = {0.0, -25.0,25.0};
			}
		}
		float AnglesEdit[3];
		AnglesEdit[0] = Angles[0];
		AnglesEdit[1] = Angles[1];
		AnglesEdit[2] = Angles[2];

		float VectorStartEdit[3];
		VectorStartEdit[0] = VectorStart[0];
		VectorStartEdit[1] = VectorStart[1];
		VectorStartEdit[2] = VectorStart[2];

		GetBeamDrawStartPoint_Stock(entity, VectorStartEdit,OffsetFromMiddle, AnglesEdit);

		SetColorRGBA(glowColor, red, green, blue, Alpha);
		TE_SetupBeamPoints(VectorStartEdit, VectorTarget_2, Shared_BEAM_Laser, 0, 0, 0, TimeUntillHit, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.0, glowColor, 0);
		TE_SendToAll(0.0);
	}
	
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget_2[0]);
	pack.WriteFloat(VectorTarget_2[1]);
	pack.WriteFloat(VectorTarget_2[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(BobInitiatePunch_DamagePart, FramesUntillHit, pack);
}

void BobInitiatePunch_DamagePart(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	for (int i = 1; i < MAXENTITIES; i++)
	{
		SensalHitDetected_2[i] = false;
	}
	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 50;
	int green = 50;
	int blue = 255;
	int Alpha = 222;
	int colorLayer4[4];

	float diameter = float(25 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(25);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers_2, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 70.0 * RaidModeScaling;
	float FarDamage = 60.0 * RaidModeScaling;
	float MaxDistance = 5000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (SensalHitDetected_2[victim] && GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			
			if(victim > MaxClients) //make sure barracks units arent bad
				damage *= 0.5;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


public bool Sensal_BEAM_TraceUsers_2(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		SensalHitDetected_2[entity] = true;
	}
	return false;
}
