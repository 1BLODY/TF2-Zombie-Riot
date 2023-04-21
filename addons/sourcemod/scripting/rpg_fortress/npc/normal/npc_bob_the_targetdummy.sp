#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static float DamageDealt[MAXTF2PLAYERS];
static float DamageTime[MAXTF2PLAYERS];
static float DamageExpire[MAXTF2PLAYERS];
static bool DamageUpdate[MAXTF2PLAYERS];

static const char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
};

void BobTheTargetDummy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
}

methodmap BobTheTargetDummy < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,100);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public BobTheTargetDummy(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BobTheTargetDummy npc = view_as<BobTheTargetDummy>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));
		
		i_NpcInternalId[npc.index] = BOB_THE_TARGETDUMMY;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = 0; //No bleed.
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, BobTheTargetDummy_OnTakeDamage);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BobTheTargetDummy_OnTakeDamagePost);
		SDKHook(npc.index, SDKHook_Think, BobTheTargetDummy_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 200, 255, 200, 255);

		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 200, 255, 200, 255);

		PF_StopPathing(npc.index);
		npc.m_bPathing = false;	

		npc.RemovePather(npc.index);
		//He wont move!
		
		return npc;
	}
	
}

//TODO 
//Rewrite
public void BobTheTargetDummy_ClotThink(int iNPC)
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(iNPC);

//	SetVariantInt(1);
//	AcceptEntityInput(iNPC, "SetBodyGroup");

	float gameTime = GetGameTime();

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
	//	npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
	//	npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	for(int client=1; client<=MaxClients; client++)
	{
		if(DamageDealt[client])
		{
			if(!IsClientInGame(client))
			{
				DamageDealt[client] = 0.0;
			}
			else if(DamageExpire[client] < gameTime)
			{
				PrintCenterText(client, "");
				DamageDealt[client] = 0.0;
			}
			else if(DamageUpdate[client])
			{
				float time = gameTime - DamageTime[client];
				if(time < 1.0)
					time = 1.0;
				
				PrintCenterText(client, "Your DPS is around %.0f!", DamageDealt[client] / time);
				DamageUpdate[client] = false;
			}
		}
	}	

	if(IsValidEntity(npc.m_iTextEntity1))
		DispatchKeyValue(npc.m_iTextEntity1, "rainbow", "1");
	if(IsValidEntity(npc.m_iTextEntity2))
		DispatchKeyValue(npc.m_iTextEntity2, "rainbow", "1");
	if(IsValidEntity(npc.m_iTextEntity3))
		DispatchKeyValue(npc.m_iTextEntity3, "rainbow", "1");

	npc.PlayIdleSound();
}


public Action BobTheTargetDummy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void BobTheTargetDummy_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(victim);

	if(attacker > 0 && attacker <= MaxClients)
	{
		DamageLastHit[attacker] = GetGameTime();

		if(!DamageDealt[attacker])
			DamageTime[attacker] = DamageLastHit[attacker];

		DamageLastHit[attacker] += 4.0;	
		DamageDealt[attacker] += damage;
		DamageUpdate[attacker] = true;
	}

	SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
}

public void BobTheTargetDummy_NPCDeath(int entity)
{
	BobTheTargetDummy npc = view_as<BobTheTargetDummy>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, BobTheTargetDummy_OnTakeDamagePost);
	SDKUnhook(entity, SDKHook_OnTakeDamage, BobTheTargetDummy_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, BobTheTargetDummy_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


