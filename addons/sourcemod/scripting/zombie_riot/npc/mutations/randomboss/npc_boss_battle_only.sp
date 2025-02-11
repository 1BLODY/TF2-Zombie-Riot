#pragma semicolon 1
#pragma newdecls required


int PreviousRaid = 0;
void BossSummonRandom_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Random Boss");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_random_boss");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = 0; 
	data.Func = ClotSummon;
	NPC_Add(data);
	PreviousRaid = 0;
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return BossSummonRandom(vecPos, vecAng, team, data);
}
methodmap BossSummonRandom < CClotBody
{
	public BossSummonRandom(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		BossSummonRandom npc = view_as<BossSummonRandom>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally));
		
		i_NpcWeight[npc.index] = 1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(BossSummonRandom_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(BossSummonRandom_ClotThink);

		i_RaidGrantExtra[npc.index] = StringToInt(data);

		if(TeleportDiversioToRandLocation(npc.index,true,1500.0, 700.0) == 2)
		{
			TeleportDiversioToRandLocation(npc.index, true);
		}
		
		return npc;
	}
}

public void BossSummonRandom_ClotThink(int iNPC)
{
	SmiteNpcToDeath(iNPC);
}

public void BossSummonRandom_NPCDeath(int entity)
{
	BossSummonRandom npc = view_as<BossSummonRandom>(entity);
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	//Spawns a random raid.
	BossBattleSummonRaidboss(entity);
}


void BossBattleSummonRaidboss(int bosssummonbase)
{
	Enemy enemy;
	enemy.Health = ReturnEntityMaxHealth(bosssummonbase);
	enemy.Is_Boss = view_as<int>(b_thisNpcIsABoss[bosssummonbase]);
	enemy.Is_Immune_To_Nuke = true;
	enemy.ExtraMeleeRes = fl_Extra_MeleeArmor[bosssummonbase];
	enemy.ExtraRangedRes = fl_Extra_RangedArmor[bosssummonbase];
	enemy.ExtraSpeed = fl_Extra_Speed[bosssummonbase];
	enemy.ExtraDamage = fl_Extra_Damage[bosssummonbase];
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(bosssummonbase);
	enemy.Does_Not_Scale = 1; //scaling was already done.
	//18 is max bosses?
	char PluginName[255];
	char CharData[255];
	
	Format(CharData, sizeof(CharData), "sc%i;",i_RaidGrantExtra[bosssummonbase]);
	int NumberRand = GetRandomInt(1,26);
	while(PreviousRaid == NumberRand)
	{
		NumberRand = GetRandomInt(1,26);
	}
	switch(NumberRand)
	{
		case 1:
		{
			//needs buffs
			PluginName = "npc_true_fusion_warrior";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 1.20;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.65); 
		}
		case 2:
		{
			//needs buffs!!
			PluginName = "npc_blitzkrieg";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 1.4;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.85); 
		}
		case 3:
		{
			//needs buffs!!
			PluginName = "npc_xeno_raidboss_silvester";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 1.25;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.8); 
		}
		case 4:
		{
			//needs buffs!!
			PluginName = "npc_god_alaxios";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 1.15;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.9); 
		}
		case 5:
		{
			//needs buffs!!
			PluginName = "npc_sensal";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 1.05;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.0); 
		}
		case 6:
		{
			//needs buffs!!
			PluginName = "npc_stella";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "force60");
			
			enemy.ExtraDamage *= 0.75;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.5); 
		}
		case 7:
		{
			PluginName = "npc_the_purge";	
		//	Format(CharData, sizeof(CharData), "%s%s",CharData, "force60");
			
			enemy.ExtraDamage *= 1.15;
			enemy.Health = RoundToNearest(float(enemy.Health) * 2.3); 
		}
		case 8:
		{
			PluginName = "npc_the_messenger";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_30");
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.35); 
		}
		case 9:
		{
			PluginName = "npc_bob_the_first_last_savior";	
			
			enemy.ExtraDamage *= 1.1;
			//he doesnt really scale? i dont know what to do.
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.0); 
		}
		case 10:
		{
			PluginName = "npc_chaos_kahmlstein";	
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.45); 
		}
		case 11:
		{
			PluginName = "npc_xeno_raidboss_nemesis";	
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.2); 
			//he doesnt really scale? i dont know what to do.
		}
		case 12:
		{
			PluginName = "npc_corruptedbarney";	
			
			enemy.ExtraDamage *= 1.3;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.75); 
			//he doesnt really scale? i dont know what to do.
		}
		case 13:
		{
			PluginName = "npc_whiteflower_boss";	
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.25); 
			enemy.ExtraMeleeRes *= 3.0;
			enemy.ExtraRangedRes *= 3.0;
			//Maybe spawn flowering darkness with him?
		}
		case 14:
		{
			PluginName = "npc_void_unspeakable";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "forth");
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.9); 
		}
		case 15:
		{
			PluginName = "npc_vhxis";	
			
			enemy.ExtraDamage *= 0.7;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.5); 
		}
		case 16:
		{
			PluginName = "npc_nemal";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "wave_60");
			
			enemy.ExtraDamage *= 0.85;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.2); 
		}
		case 17:
		{
			PluginName = "npc_ruina_twirl";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "force60");
			
			enemy.ExtraDamage *= 0.85;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.1); 
		}
		case 18:
		{
			PluginName = "npc_agent_thompson";	
			
			enemy.ExtraDamage *= 0.75;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.1); 
		}
		case 19:
		{
			PluginName = "npc_twins";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "Im_The_raid;My_Twin");
			
			enemy.ExtraDamage *= 1.1;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.85); 
		}
		case 20:
		{
			PluginName = "npc_agent_smith";	
			Format(CharData, sizeof(CharData), "%s%s",CharData, "raid_time");
			
			enemy.ExtraDamage *= 1.0;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.95); 
		}
		case 21:
		{
			PluginName = "npc_atomizer";	
		//	Format(CharData, sizeof(CharData), "%s%s",CharData, "raid_time");
			
			enemy.ExtraDamage *= 0.8;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.2); 
		}
		case 22:
		{
			PluginName = "npc_the_wall";	
		//	Format(CharData, sizeof(CharData), "%s%s",CharData, "raid_time");
			
			enemy.ExtraDamage *= 1.1;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.5); 
		}
		case 23:
		{
			PluginName = "npc_harrison";	
		//	Format(CharData, sizeof(CharData), "%s%s",CharData, "raid_time");
			
			enemy.ExtraDamage *= 1.0;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.6); 
		}
		case 24:
		{
			PluginName = "npc_castellan";	
		//	Format(CharData, sizeof(CharData), "%s%s",CharData, "raid_time");
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.4); 
		}
		case 25:
		{
			PluginName = "npc_lelouch";	
			
			enemy.ExtraDamage *= 0.9;
			enemy.Health = RoundToNearest(float(enemy.Health) * 0.9); 
		}
		case 26:
		{
			PluginName = "npc_omega_raid";	
			
			enemy.ExtraDamage *= 1.1;
			enemy.Health = RoundToNearest(float(enemy.Health) * 1.3); 
		}
	}
	Format(enemy.Data, sizeof(enemy.Data), "%s",CharData);
	enemy.Index = NPC_GetByPlugin(PluginName);


	Waves_AddNextEnemy(enemy);
	Zombies_Currently_Still_Ongoing += 1;
}