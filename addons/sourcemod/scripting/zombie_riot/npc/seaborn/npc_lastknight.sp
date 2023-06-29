#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static bool PeaceKnight;

methodmap LastKnight < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public LastKnight(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		if(data[0])
		{
			PeaceKnight = false;
		}
		else if(PeaceKnight)
		{
			return view_as<LastKnight>(-1);
		}
		
		LastKnight npc = view_as<LastKnight>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.35", "125000", ally, false));
		// 125000 x 1.0

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = LASTKNIGHT;
		i_NpcWeight[npc.index] = 5;
		npc.SetActivity("ACT_PRINCE_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SDKHook(npc.index, SDKHook_Think, LastKnight_ClotThink);
		
		npc.m_flSpeed = 150.0;	// 0.6 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iPhase = 0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		vecMe[2] += 100.0;

		npc.m_iWearable4 = ParticleEffectAt(vecMe, "powerup_icon_reflect", -1.0);
		SetParent(npc.index, npc.m_iWearable4);
		
		return npc;
	}
	property int m_iPhase
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
}

public void LastKnight_ClotThink(int iNPC)
{
	LastKnight npc = view_as<LastKnight>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(b_NpcIsInvulnerable[npc.index])
	{
		b_NpcIsInvulnerable[npc.index] = false;
		npc.SetActivity("ACT_RIDER_RUN");

		if(!IsValidEntity(npc.m_iWearable3))
		{
			npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2022_pony_express/hwn2022_pony_express.mdl");
			SetVariantString("1.1");
			AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 55, 55, 55, 255);
		}
	}

	bool aggressive = CitizenRunner_WasKilled();

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		if(!aggressive)
		{
			bool found;

			for(int i; i < i_MaxcountNpc; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
				if(entity != INVALID_ENT_REFERENCE && entity != npc.index && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
				{
					found = true;
					break;
				}
			}

			if(!found)
			{
				PeaceKnight = true;
				CPrintToChatAll("{gray}The Last Knight{default}: You have proven yourself, you're against the ocean, and you're not my enemy.");

				int owner;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && GetClientTeam(client) == 2)
					{
						int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
						if(entity != INVALID_ENT_REFERENCE && i_WhatBuilding[entity] == BuildingSummoner)
						{
							owner = client;
							break;
						}
					}
				}

				float pos[3], ang[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

				int ally = Npc_Create(BARRACK_LASTKNIGHT, owner, pos, ang, true);
				view_as<BarrackBody>(ally).BonusDamageBonus = 1.0;
				view_as<BarrackBody>(ally).BonusFireRate = 1.0;
				view_as<BarrackBody>(ally).m_iSupplyCount = 0;

				npc.m_bDissapearOnDeath = true;
				npc.m_flNextDelayTime = FAR_FUTURE;
				SDKHooks_TakeDamage(npc.index, 0, 0, 999999999.0, DMG_GENERIC);
				return;
			}
		}

		npc.m_iTarget = GetClosestTarget(npc.index, npc.m_iPhase == 2, 500.0, true, _, _, _, _, 125.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(npc.m_iTarget < 1)
		{
			// No nearby targets, kill the ocean
			npc.m_iTarget = GetClosestAlly(npc.index, 100.0);
		}

		// Won't attack runners, find players
		if(npc.m_iTarget < 1 || i_NpcInternalId[npc.m_iTarget] == CITIZEN_RUNNER)
			npc.m_iTarget = GetClosestTarget(npc.index, npc.m_iPhase == 2, _, true, true);
	}

	if(aggressive)
	{
		npc.m_flMeleeArmor = 0.5;
		npc.m_flRangedArmor = 0.5;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(npc.m_flAttackHappens)
		{
			npc.FaceTowards(vecTarget, 15000.0);
			
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
				SetEntProp(npc.index, Prop_Send, "m_iTeamNum", 0);

				Handle swingTrace;
				bool result = npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _);

				SetEntProp(npc.index, Prop_Send, "m_iTeamNum", team);

				if(result)
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0)
					{
						float damage = 1000.0;
						if(target > MaxClients)
						{
							damage = 3000.0;

							if(f_TimeFrozenStill[target] > gameTime)
								damage *= 1.75;
						}
						else if(TF2_IsPlayerInCondition(target, TFCond_Dazed))
						{
							damage *= 1.75;
						}

						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						npc.PlayMeleeHitSound();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(npc.m_iPhase == 2)
			{
				if(distance < 5000.0)
				{
					int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					if(IsValidEnemy(npc.index, target, true))
					{
						npc.m_iTarget = target;
						npc.m_flNextMeleeAttack = gameTime;
						npc.m_flAttackHappens = gameTime;
					}
				}
			}
			else if(distance < 10000.0)
			{
				//int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//if(IsValidEnemy(npc.index, target, true))
				{
					//npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_CUSTOM_ATTACK_LUCIAN");
					npc.m_flAttackHappens = gameTime + 0.45;
					npc.m_flDoingAnimation = gameTime + 0.55;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			}

			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void LastKnight_OnTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	LastKnight npc = view_as<LastKnight>(victim);

	if(b_NpcIsInvulnerable[npc.index])
	{
		damage = 0.0;
		return;
	}

	if(attacker < 1)
		return;

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	gameTime = GetGameTime();
	if(f_VeryLowIceDebuff[attacker] < gameTime)
	{
		f_VeryLowIceDebuff[attacker] = gameTime + (npc.m_iPhase ? 2.0 : 1.0);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 0.9, npc.m_iPhase ? 2.0 : 1.0);
		}
	}
	else if(f_LowIceDebuff[attacker] < gameTime)
	{
		f_LowIceDebuff[attacker] = f_VeryLowIceDebuff[attacker];
		f_VeryLowIceDebuff[attacker] += (npc.m_iPhase ? 2.0 : 1.0);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 0.9, npc.m_iPhase ? 2.0 : 1.0);
		}
	}
	else if(f_HighIceDebuff[attacker] < gameTime)
	{
		f_HighIceDebuff[attacker] = f_LowIceDebuff[attacker];
		f_LowIceDebuff[attacker] += (npc.m_iPhase ? 2.0 : 1.0);
		f_VeryLowIceDebuff[attacker] += (npc.m_iPhase ? 2.0 : 1.0);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 0.9, npc.m_iPhase ? 2.0 : 1.0);
		}
	}
	else if(attacker > MaxClients)
	{
		if(!b_NpcHasDied[attacker] && f_TimeFrozenStill[attacker] < gameTime)
			Cryo_FreezeZombie(attacker);
	}
	else if(!TF2_IsPlayerInCondition(attacker, TFCond_Dazed))
	{
		TF2_StunPlayer(attacker, f_HighIceDebuff[attacker] - gameTime, 0.8, TF_STUNFLAG_SLOWDOWN);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 0.75, f_HighIceDebuff[attacker] - gameTime);
		}
	}

	int ratio = GetEntProp(npc.index, Prop_Data, "m_iHealth") * 5 / GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

	switch(npc.m_iPhase)
	{
		case 0:
		{
			if(ratio < 3)
				npc.m_iPhase = 1;
		}
		case 1:
		{
			if(ratio < 1)
			{
				npc.m_iPhase = 2;
				npc.m_flSpeed = 75.0;
				Change_Npc_Collision(npc.index, 1);	// Ignore buildings
				b_NpcIsInvulnerable[npc.index] = true;
				FreezeNpcInTime(npc.index, 5.0);
			}
		}
	}
}

void LastKnight_NPCDeath(int entity)
{
	LastKnight npc = view_as<LastKnight>(entity);
	if(!npc.m_bGib && !npc.m_bDissapearOnDeath)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, LastKnight_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
