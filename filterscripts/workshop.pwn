/*
----------------------------------------------------------------------------
							======================
							| 	 Base Workshop   |
							| 	   by 0x1E4      |
							======================


Description:
Buatan sendiri, mikir pake otak..
Kadang juga gua ngambil sample dari gamemode orang.
Ya suka suka sih, yang penting gua ga copy paste whole script :P


Fitur:
* Build-in basic car management.
* Ready to use.
* Gampang di setting.
* Kode rapih ga ribet.


Credits:
* 0x1E4 selaku pengembang filterscript ini.
* SA-MP Forum tempat terwujudnya sebuah "logika".


Plugin by:
* Kalcor (a_samp, dll)
* Y_Less, Emmet_, Missiur, Kar, and Team (YSI pack, sscanf, foreach, dll)
* Incognito and Yashas (streamer)
* Zeex and Yashas (i-ZCMD)
* Gammix (dini2)


Tolong untuk tidak mengklaim hak cipta, hargai saya gara gara ini
windows jadi overload tau >:(

Sekiranya donasi kek, kalau mau dipake buat komersial dan ingin
mencabut credits.
----------------------------------------------------------------------------
*/


//Kalcor
#include <a_samp>

//Y_Less, Emmet_, and Maddinat0r
#include <sscanf2>

//Y_Less, Kar
#include <foreach>

//Incognito
#include <streamer>

//Gammix
#include <dini2>

//Zeex & Yashas
#include <izcmd>

//Kalau gak mau dijadikan filterscript, hapus aja!
//#define FILTERSCRIPT

//paths (bisa diganti sesuka hati!)
#define USER_PATH       "Accounts/%s.ini"
#define WORKSHOP_PATH   "Workshops/%d.ini"
#define CAR_PATH        "Car/%d.ini"

//debug (toggle 0 untuk mematikan mode debug)
#define ON_DEBUG        (1)

//maxes
#define MAX_WORKSHOP    (12)
#define MAX_CAR         (12)
#define MAX_CAR_OBJ     (3)

//colors
#define COL_WHITE       0xFFFFFFAA
#define COL_RED			0xAA3333AA

//prices
#define MIN_WORKSHOP_PRICE  (100000) //$1,000.00
#define MIN_COMPONENT_PRICE (1000) //$10.00

//default format
#define WORKSHOP_FORMAT "moechan"

//just make things nicer <3
#define POS_TYPE_ICON   (1)
#define POS_TYPE_PICKUP	(2)

//color hex
#define RED             "{800020}"
#define YELLOW          "{EED200}"
#define GREEN           "{008989}"
#define BLUE            "{3FC9F2}"
#define ORANGE          "{E34500}"
#define BLACK           "{000000}"
#define WHITE           "{FFFFFF}"

//macro defines (jangan coba coba ganti kalau gak mau nemuin endless error)
#define SameWith(%0,%1) !strcmp(%0,%1,true)
#define Input:%0(%1)    format(%0,sizeof(%0),%1)
#define Class:%0(%1)  	forward %0(%1); public %0(%1)
#define Scope:%0(%1)  	public %0(%1)
#define Private:%0(%1)  stock %0(%1)

#define Error(%0,%1)  	Pesan(%0,""RED"ERROR"WHITE": "%1)
#define Usage(%0,%1)    Pesan(%0,""BLUE"USAGE"WHITE": "%1)

//enum player
enum E_PLAYER_INFO {
	pName[DINI_MAX_FIELD_VALUE],
	pAdminLevel,
	pCash,
	pCar,
	pWorkshop
};

//enum mobil
enum E_CAR_INFO {
	bool:carExists,
	carVehicle,
	carID,
	carOwner,
	carModel,
	carEngine,
	carLock,
	carSiren,
	Float:carPos[4],
	carColor[2],
	carPlate[11],
	carMod,
	carCustomMod[MAX_CAR_OBJ]
};

//enum core mobil
enum E_CORE_INFO {
	bool:carRepairing,
	bool:carSpraying,
	bool:carModInstall,
	carObjectMod[MAX_CAR_OBJ]
};

//enum mobil object
enum E_CAROBJ_INFO {
	carPos[3],
	carRotatePos[3]
};

//enum workshop
enum E_WORKSHOP_INFO {
	bool:wsExists,
	wsID,
	wsName[DINI_MAX_FIELD_VALUE],
	wsOwner,
	wsOwnerName[DINI_MAX_FIELD_VALUE],
	wsPrice,
	wsLock,
	wsIcon,
	wsPickup,
	Float:wsIconPos[3],
	Float:wsPickupPos[3],
	Text3D:wsIconText,
	Text3D:wsPickupText
};

//stock deklarasi array
new stock VEHICLE_NAME_INFO[][] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",
    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
};

//deklarasi untuk dipake bersama sama!
new
	Players[MAX_PLAYERS][E_PLAYER_INFO],
	Car[MAX_CAR][E_CAR_INFO],
	Workshop[MAX_WORKSHOP][E_WORKSHOP_INFO],
	CoreVehicle[MAX_CAR][E_CORE_INFO],
	CarObject[MAX_CAR][E_CAROBJ_INFO]
;

//scope gamemode
#if defined FILTERSCRIPT
	Scope:OnFilterScriptInit()
	{
		print("===============================================");
		print("                                               ");
		print("       Workshop System v0.1 Beta Alpaca        ");
		print("      		  Made by: 0x1E4				  ");
		print("  Please don't sell it without my permissions  ");
		print("                                               ");
		print("===============================================");
		print("                                               ");
		print("                 Load Status                   ");
	 	print("                                               ");
		Workshop_Load();
		Car_Load();
		print("===============================================");

		#if ON_DEBUG == 1
			print("                                               ");
			print("                Debug Status                   ");
		 	print("                                               ");
		    print("* [DEBUG] OnFilterScriptInit terpanggil");
		#endif
		return 1;
	}

	Scope:OnFilterScriptExit()
	{
		print("===============================================");
		print("                                               ");
		print("      Workshop System v0.1 Beta Alpaca         ");
		print("      		  Made by: 0x1E4				  ");
		print("  Please don't sell it without my permissions  ");
		print("                                               ");
		print("===============================================");
		print("                                               ");
		print("                Unload Status                  ");
	 	print("                                               ");
		Workshop_Unload();
		Car_Unload();
		print("===============================================");

		#if ON_DEBUG == 1
		    print("* [DEBUG] OnFilterScriptExit terpanggil");
		    print("===============================================");
		#endif
		return 1;
	}
#else
	main()
	{
		print("Initializing data...");
		return 1;
	}

	Scope:OnGameModeInit()
	{
		print("===============================================");
		print("                                               ");
		print("       Workshop System v0.1 Beta Alpaca        ");
		print("      		  Made by: 0x1E4				  ");
		print("  Please don't sell it without my permissions  ");
		print("                                               ");
		print("===============================================");
		print("                                               ");
		print("                 Load Status                   ");
	 	print("                                               ");
		Workshop_Load();
		Car_Load();
		print("===============================================");
		ShowPlayerMarkers(1);
		ShowNameTags(1);
		AllowAdminTeleport(1);

		AddPlayerClass(265,1958.3783,1343.1572,15.3746,270.1425,0,0,0,0,-1,-1);

		#if ON_DEBUG == 1
			print("                                               ");
			print("                Debug Status                   ");
		 	print("                                               ");
		    print("* [DEBUG] OnGameModeInit terpanggil");
		#endif

		return 1;
	}

	Scope:OnGameModeExit()
	{
		print("===============================================");
		print("                                               ");
		print("      Workshop System v0.1 Beta Alpaca         ");
		print("      		  Made by: 0x1E4				  ");
		print("  Please don't sell it without my permissions  ");
		print("                                               ");
		print("===============================================");
		print("                                               ");
		print("                Unload Status                  ");
	 	print("                                               ");
		Workshop_Unload();
		Car_Unload();
		print("===============================================");

		#if ON_DEBUG == 1
		    print("* [DEBUG] OnGameModeExit terpanggil");
		    print("===============================================");
		#endif

		return 1;
	}
#endif

//scope player connect
Scope:OnPlayerConnect(playerid)
{
	Player_Load(playerid);

	#if ON_DEBUG == 1
	    print("* [DEBUG] OnPlayerConnect terpanggil");
	#endif
	return 1;
}

Scope:OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);

	#if ON_DEBUG == 1
	    print("* [DEBUG] OnPlayerSpawn terpanggil");
	#endif

	return 1;
}

Scope:OnPlayerDeath(playerid, killerid, reason)
{
	#if ON_DEBUG == 1
	    print("* [DEBUG] OnPlayerDeath terpanggil");
	#endif

   	return 1;
}

Scope:OnPlayerRequestClass(playerid, classid)
{
	SetupPlayerForClassSelection(playerid);

	#if ON_DEBUG == 1
	    print("* [DEBUG] OnPlayerRequestClass terpanggil");
	#endif

	return 1;
}

Class:Player_Load(kazuma)
{
	new stuff[64], carid = Players[kazuma][pCar];
	Input:stuff(USER_PATH, ReturnName(kazuma, 1));
	if(!fexist(stuff))
	{
		dini_Create(stuff);
		dini_Set(stuff, "Name", ReturnName(kazuma, 1));
		dini_IntSet(stuff,"AdminLevel", 0);
		dini_IntSet(stuff,"Cash", 1000000);
		dini_IntSet(stuff, "Car", 0);
		dini_IntSet(stuff, "Workshop", 0);
		GivePlayerMoney(kazuma, 1000000);
		return 1;
	}
    Players[kazuma][pName] = dini_Get(stuff, "Name");
    Players[kazuma][pAdminLevel] = dini_Int(stuff, "AdminLevel");
    Players[kazuma][pCash] = dini_Int(stuff, "Cash");
    Players[kazuma][pCar] = dini_Int(stuff, "CarID");
	Players[kazuma][pWorkshop] = dini_Int(stuff, "WorkshopID");
	GivePlayerMoney(kazuma, Players[kazuma][pCash]);

	if(carid != -1) {
		CreateVehicle(Car[carid][carModel], Car[carid][carPos][0], Car[carid][carPos][1], Car[carid][carPos][2], Car[carid][carPos][3], Car[carid][carColor][0], Car[carid][carColor][1], -1, 0);
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Player_Load terpanggil");
	#endif

	return 1;
}

Class:Workshop_Load()
{
    static File[23], wscuk;
    for(new i = 0; i < MAX_WORKSHOP; i++)
    {
        Input:File(WORKSHOP_PATH, i);
        if(fexist(File))
        {
			Workshop[i][wsExists] = true;

            Workshop[i][wsName] = dini_Get(File, "Name");
            Workshop[i][wsOwnerName] = dini_Get(File, "OwnerName");

            Workshop[i][wsID] = dini_Int(File, "ID");
			Workshop[i][wsOwner] = dini_Int(File, "Owner");
			Workshop[i][wsPrice] = dini_Int(File, "Price");
			Workshop[i][wsLock] = dini_Int(File, "Locked");

			Workshop[i][wsIconPos][0] = dini_Float(File, "PosIconX");
			Workshop[i][wsIconPos][1] = dini_Float(File, "PosIconY");
			Workshop[i][wsIconPos][2] = dini_Float(File, "PosIconZ");

			Workshop[i][wsIconPos][0] = dini_Float(File, "PosPickupX");
			Workshop[i][wsIconPos][1] = dini_Float(File, "PosPickupY");
			Workshop[i][wsIconPos][2] = dini_Float(File, "PosPickupZ");

            wscuk++;
        }
	}
	printf("%d workshop berhasil di load", wscuk);
	return 1;
}

Class:Car_Load()
{
	static File[23], timpa[15], carcuk;
	for(new i = 0; i < MAX_CAR; i++)
	{
        Input:File(CAR_PATH, i);
	 	if(fexist(File))
		{
		    Car[i][carExists] = true;
			
		    Car[i][carID] = dini_Int(File, "ID");
			Car[i][carOwner] = dini_Int(File, "Owner");
		    Car[i][carModel] = dini_Int(File, "Models");
			Car[i][carLock] = dini_Int(File, "Lock");

			Car[i][carPos][0] = dini_Float(File, "CarPosX");
			Car[i][carPos][1] = dini_Float(File, "CarPosY");
			Car[i][carPos][2] = dini_Float(File, "CarPosZ");

			Car[i][carColor][0] = dini_Int(File, "Color1");
			Car[i][carColor][1] = dini_Int(File, "Color2");

			Car[i][carMod] = dini_Int(File, "Modification");

			for(new a; a < Car[i][carMod]; a++)
			{
			    Input:timpa("objModel_%d", a);
				Car[i][carCustomMod][a] = dini_Int(File, timpa);
				timpa[0] = EOS;
			}
			carcuk++;
		}
	}
	printf("%d mobil berhasil di load", carcuk);
	return 1;
}

Class:Workshop_Unload()
{
    for(new i = 0; i < MAX_WORKSHOP; i++) {
		Workshop_Delete(i);
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Workshop_Unload terpanggil");
	#endif

	return 1;
}

Class:Car_Unload()
{
    for(new i = 0; i < MAX_CAR; i++) {
		Car_Delete(i);
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Car_Unload terpanggil");
	#endif


	return 1;
}

Class:Workshop_Create(kazuma, const name[], price)
{
	new
		Float:pX,
	 	Float:pY,
	 	Float:pZ,
	 	stuff[23];

    for(new i = 0; i < MAX_WORKSHOP; i++) if(!Workshop[i][wsExists])
    {
 		Input:stuff(WORKSHOP_PATH, i);
  		dini_Create(stuff);
  		
		Workshop[i][wsExists] = true;
		Workshop[i][wsID] = i;

	    format(Workshop[i][wsName], 32, name);
	    format(Workshop[i][wsOwnerName], 32, WORKSHOP_FORMAT);

		Workshop[i][wsOwner] = -1;
		Workshop[i][wsPrice] = price;
		Workshop[i][wsLock] = 0;

		GetPlayerPos(kazuma, pX, pY, pZ);
		SetWorkshopPos(i, POS_TYPE_ICON, pX, pY, pZ);

		Workshop[i][wsPickupPos][0] = 0.0;
		Workshop[i][wsPickupPos][1] = 0.0;
		Workshop[i][wsPickupPos][2] = 0.0;

		Workshop_Refresh(i);
		Workshop_Save(i);
		return i;
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Workshop_Create terpanggil");
	#endif

	return -1;
}

Class:Car_Create(kazuma, classid, Float:vX, Float:vY, Float:vZ, Float:vAng, col1, col2, addsiren, plate[])
{
	new
		stuff[23];
		
	for(new i; i < MAX_CAR; i++) if(!Car[i][carExists])
	{
		Input:stuff(CAR_PATH, classid);
		dini_Create(stuff);
		
	    Car[i][carID] = i;
	    Car[i][carModel] = classid;
		Car[i][carLock] = 0;

		Car[i][carPos][0] = vX;
		Car[i][carPos][1] = vY;
		Car[i][carPos][2] = vZ;
		Car[i][carPos][3] = vAng;

	    if (col1 == -1)
	        col1 = random(127);

		if (col2 == -1)
		    col2 = random(127);

		Car[i][carColor][0] = col1;
		Car[i][carColor][1] = col2;
		
		Car[i][carSiren] = addsiren;
		Car[i][carMod] = 0;
		
		format(Car[i][carPlate], 11, plate);

		for(new a; a < MAX_CAR_OBJ; a++) {
			Car[i][carCustomMod][a] = 0;
		}
		Car[i][carVehicle] = CreateVehicle(classid, vX, vY, vZ, vAng, col1, col2, -1, addsiren);
		SetVehicleNumberPlate(Car[i][carVehicle], Car[i][carPlate]);
		Car_Save(i);

		#if ON_DEBUG == 1
		    print("* [DEBUG] Car_Create terpanggil");
		#endif
		
		return i;
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Car_Create terpanggil");
	#endif

	return -1;
}

Class:Workshop_Refresh(classid)
{
	new
		arOutput[128];

	if(!Workshop[classid][wsExists])
	    return 0;

	if(IsValidDynamicPickup(Workshop[classid][wsIcon]))
		DestroyDynamicPickup(Workshop[classid][wsIcon]);

	if(IsValidDynamic3DTextLabel(Workshop[classid][wsIconText]))
	    DestroyDynamic3DTextLabel(Workshop[classid][wsIconText]);

	if(IsValidDynamicPickup(Workshop[classid][wsPickup]))
		DestroyDynamicPickup(Workshop[classid][wsPickup]);

	if(IsValidDynamic3DTextLabel(Workshop[classid][wsPickupText]))
	    DestroyDynamic3DTextLabel(Workshop[classid][wsPickupText]);

	if(Workshop[classid][wsOwner] != 0) {
	    Input:arOutput("[Workshop ID:%d]\n%s\nWorkshop Owner: %s\n Workshop Type: Transfender", classid, Workshop[classid][wsName], Workshop[classid][wsOwnerName]);
		Workshop[classid][wsIconText] = CreateDynamic3DTextLabel(arOutput, COL_WHITE, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsIcon] = CreateDynamicPickup(1083, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}
	else {
		Input:arOutput("[Workshop ID:%d]\n%s\nWorkshop Owner: None\n Workshop Type: Transfender\nSilahkan ketik (/buy) untuk membeli workshop ini.", classid, Workshop[classid][wsName]);
		Workshop[classid][wsIconText] = CreateDynamic3DTextLabel(arOutput, COL_WHITE, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsIcon] = CreateDynamicPickup(1083, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}

	if(Workshop[classid][wsPickupPos][0] != 0.0 && Workshop[classid][wsPickupPos][1] != 0.0 && Workshop[classid][wsPickupPos][2] != 0.0)
	{
		Workshop[classid][wsPickupText] = CreateDynamic3DTextLabel(arOutput, COL_WHITE, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsPickup] = CreateDynamicPickup(1239, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}
	Workshop[classid][wsIconText] = CreateDynamic3DTextLabel(arOutput, COL_WHITE, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	Workshop[classid][wsIcon] = CreateDynamicPickup(1083, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	#if ON_DEBUG == 1
	    print("* [DEBUG] Workshop_Refresh terpanggil");
	#endif

	return 1;
}

Class:Car_Refresh(classid)
{
	new
		 Float:vX,
		 Float:vY,
		 Float:vZ;

	if(!Car[classid][carExists])
	    return 0;

	GetVehiclePos(classid, vX, vY, vZ);
	if(Car[classid][carMod] > 0) {
		for(new a = 0; a < Car[classid][carMod]; a++) {
			DestroyDynamicObject(CoreVehicle[classid][carObjectMod][a]);
		}
	}

	SetVehicleToRespawn(classid);
	Car_Save(classid);

	if(Car[classid][carMod] > 0) {
		for(new a = 0; a < Car[classid][carMod]; a++) {
			CoreVehicle[classid][carObjectMod][a] = CreateDynamicObject(Car[classid][carCustomMod][a], 0.0+random(10), 0.0, 0.0+random(10), 0.0, 0.0, 0.0, 0);
			AttachDynamicObjectToVehicle(CoreVehicle[classid][carObjectMod][a], classid, CarObject[a][carPos][0], CarObject[a][carPos][1], CarObject[a][carPos][2], CarObject[a][carRotatePos][0], CarObject[a][carRotatePos][1], CarObject[a][carRotatePos][2]);
		}
	}

	#if ON_DEBUG == 1
	    print("* [DEBUG] Car_Refresh terpanggil");
	#endif


	return 1;
}

Class:Workshop_Delete(classid)
{
	DestroyDynamicPickup(Workshop[classid][wsIcon]);
	DestroyDynamicPickup(Workshop[classid][wsPickup]);
	DestroyDynamic3DTextLabel(Workshop[classid][wsIconText]);
	DestroyDynamic3DTextLabel(Workshop[classid][wsPickupText]);

	Workshop[classid][wsName][0] = EOS;
	Workshop[classid][wsOwnerName][0] = EOS;

	Workshop[classid][wsID] = -1;
	Workshop[classid][wsOwner] = -1;
	Workshop[classid][wsPrice] = 0;
	Workshop[classid][wsLock] = 0;

	Workshop[classid][wsIconPos][0] = 0.0;
	Workshop[classid][wsIconPos][1] = 0.0;
	Workshop[classid][wsIconPos][2] = 0.0;

	Workshop[classid][wsPickupPos][0] = 0.0;
	Workshop[classid][wsPickupPos][1] = 0.0;
	Workshop[classid][wsPickupPos][2] = 0.0;

	new File[23];
	Input:File(WORKSHOP_PATH, classid);

	if(fexist(File))
        fremove(File);

	Workshop[classid][wsExists] = false;

 	#if ON_DEBUG == 1
	    print("* [DEBUG] Workshop_Delete terpanggil");
	#endif

	return 1;
}

Class:Car_Delete(classid)
{
    Car[classid][carID] = -1;
    Car[classid][carModel] = -1;
	Car[classid][carLock] = 0;

	Car[classid][carPos][0] = 0.0;
	Car[classid][carPos][1] = 0.0;
	Car[classid][carPos][2] = 0.0;

	Car[classid][carColor][0] = 0;
	Car[classid][carColor][1] = 0;

	for(new a; a < Car[classid][carMod]; a++) {
		Car[classid][carCustomMod][a] = 0;
	}
	Car[classid][carMod] = 0;

	static File[23];
	Input:File(CAR_PATH, classid);

	if(fexist(File))
        fremove(File);

    DestroyVehicle(classid);
    Car[classid][carExists] = false;
    
 	#if ON_DEBUG == 1
	    print("* [DEBUG] Car_Delete terpanggil");
	#endif

	return 1;
}

Class:Workshop_Save(classid)
{
	new stuff[23];
	if(!Workshop[classid][wsExists])
	    return 0;

	Input:stuff(WORKSHOP_PATH, classid);
	
	if(fexist(stuff))
	{
		dini_Set(stuff, "Name", Workshop[classid][wsName]);
		dini_Set(stuff, "OwnerName", Workshop[classid][wsOwnerName]);

		dini_IntSet(stuff, "ID", Workshop[classid][wsID]);
		dini_IntSet(stuff, "Owner", Workshop[classid][wsOwner]);
		dini_IntSet(stuff, "Price", Workshop[classid][wsPrice]);
		dini_IntSet(stuff, "Locked", Workshop[classid][wsLock]);

		dini_FloatSet(stuff, "PosIconX", Workshop[classid][wsIconPos][0]);
		dini_FloatSet(stuff, "PosIconY", Workshop[classid][wsIconPos][1]);
		dini_FloatSet(stuff, "PosIconZ", Workshop[classid][wsIconPos][2]);

		dini_FloatSet(stuff, "PosPickupX", Workshop[classid][wsPickupPos][0]);
		dini_FloatSet(stuff, "PosPickupY", Workshop[classid][wsPickupPos][1]);
		dini_FloatSet(stuff, "PosPickupZ", Workshop[classid][wsPickupPos][2]);
	}
 	#if ON_DEBUG == 1
	    print("* [DEBUG] Workshop_Save terpanggil");
	#endif
	
	return 1;
}

Class:Car_Save(classid)
{
	if(!Car[classid][carExists])
		return 0;
		
	new stuff[23], timpa[15];
	Input:stuff(CAR_PATH, classid);

    dini_IntSet(stuff, "ID", Car[classid][carID]);
    dini_IntSet(stuff, "Models", Car[classid][carModel]);
	dini_IntSet(stuff, "Lock", Car[classid][carLock]);
    
	dini_FloatSet(stuff, "CarPosX", Car[classid][carPos][0]);
	dini_FloatSet(stuff, "CarPosY", Car[classid][carPos][0]);
	dini_FloatSet(stuff, "CarPosZ", Car[classid][carPos][0]);

	dini_IntSet(stuff, "Modification", Car[classid][carMod]);

	for(new a; a < Car[classid][carMod]; a++)
	{
	    Input:timpa("objModel_%d", a);
		dini_IntSet(stuff, timpa, Car[classid][carCustomMod][a]);
		timpa[0] = EOS;
	}

 	#if ON_DEBUG == 1
	    print("* [DEBUG] Car_Save terpanggil");
	#endif

	return 1;
}

CMD:makeadmin(megumin, stuff[])
{
	#pragma unused stuff
	Players[megumin][pAdminLevel] = 10;
	Pesan(megumin, ""WHITE"["RED"PROMOTION"WHITE"] Selamat anda sudah menjadi admin tingkat tinggi!");
	return 1;
}

CMD:veh(megumin, stuff[])
{
	new model[32], col1, col2;
	if(Players[megumin][pAdminLevel] < 10)
	    return Error(megumin, "Kamu tidak memiliki kuasa untuk memakai ini!");

	if(sscanf(stuff, "s[32]I(-1)I(-1)", model, col1, col2))
	    return Usage(megumin, "/veh [model] [color 1] [color 2]");

	if((model[0] = GetModelName(model)) == 0)
	    return Error(megumin, "Model apaan nih, cih");
	    
	    
	static
		Float:vX,
		Float:vY,
		Float:vZ,
		Float:vAng,
		chl;
		
    chl = Car_Create(megumin, model[0], vX+1, vY+2, vZ, vAng, col1, col2, 0, "LSPD-221"); //RandomPlate()
    
	if(chl == -1)
	    return Error(megumin, "Tidak bisa membuat mobil karena sudah full!");
	    
	Pesan(megumin, "Berhasil membuat mobil ID: %d", chl);
	return 1;
}
	

CMD:createworkshop(megumin, stuff[])
{
	static
		name[18],
		price,
		chl;

	if(Players[megumin][pAdminLevel] < 10)
	    return Error(megumin, "Kamu tidak memiliki kuasa untuk memakai ini!");

	if(sscanf(stuff, "s[18]d", name, price))
		return Pesan(megumin, "/createworkshop [namanya] [harga]");

	if(strlen(name) > 18)
	    return Pesan(megumin, "Namanya kepanjangan! (Maksimal 18 kata)");

	if(price < 100000)
	    return Pesan(megumin, "tidak boleh kurang dari $1,000.00!");

	chl = Workshop_Create(megumin, name, price);

	if(chl == -1)
		return Pesan(megumin, "Tidak bisa membuat workshop (Workshop sudah terisi penuh)");

	Pesan(megumin, "Sukses membuat workshop (ID: %d)", chl);
	return 1;
}

CMD:editworkshop(megumin, stuff[])
{
	static
		id,
		type[32],
		string[128];

	if(Players[megumin][pAdminLevel] < 10)
	    return Error(megumin, "Kamu tidak memiliki kuasa untuk memakai ini!");

	if (sscanf(stuff, "ds[24]S()[128]", id, type, string))
 	{
 	    Pesan(megumin, "/editworkshop [workshop id] [type]");
 	    Pesan(megumin, ""BLUE"LIST TYPE:"WHITE" nama, type, pos, point, harga");
 	    return 1;
	}
	
	if(!Workshop[id][wsExists])
	    return Pesan(megumin, "Invalid workshop ID.");
	
	if(SameWith(type, "nama"))
	{
		new
			beingcuteaf[18];

	    if(sscanf(string, "s[18]", beingcuteaf))
	        return Pesan(megumin, "/editworkshop [workshop id] [nama] [nama baru]");

		if(strlen(beingcuteaf) < 3)
			return Pesan(megumin, "Terlalu pendek!");

		format(Workshop[id][wsName], 18, beingcuteaf);
		Workshop_Refresh(id);
		Workshop_Save(id);

		Pesan(megumin, "Nama workshop berhasil diganti!");
	}
	else if(SameWith(type, "type"))
	{
	    new
			tokawaii;

	    if(sscanf(string, "d", tokawaii))
 		{
		 	Pesan(megumin, "/editworkshop [workshop id] [type] [1 - 3]");
		 	Pesan(megumin, ""BLUE"LIST:"WHITE"1 = TransFender, 2 = Wheel Arch Angels, 3 = Loco Low Co.");
			return 1;
		}

		if(tokawaii > 3 || tokawaii < 1)
		    return Pesan(megumin, "Type hanya ada 1 sampai 3 saja tidak lebih dan tidak kurang!");

		//workshop type code here
		Pesan(megumin, "Tipe workshop berhasil diganti");
	}
	else if(SameWith(type, "pos"))
	{
	    new
			Float:pX,
			Float:pY,
			Float:pZ;

	    GetPlayerPos(megumin, pX, pY, pZ);
	    SetWorkshopPos(id, POS_TYPE_ICON, pX, pY, pZ);

	    Pesan(megumin, "Posisi workshop berhasil diganti!");
	}
	else if(SameWith(type, "point"))
	{
		new
			Float:pX,
			Float:pY,
			Float:pZ;

	    GetPlayerPos(megumin, pX, pY, pZ);
	    SetWorkshopPos(id, POS_TYPE_PICKUP, pX, pY, pZ);

	    Pesan(megumin, "Posisi point workshop berhasil diganti!");
	}
	else if(SameWith(type, "harga"))
	{
		new
		    daisukidesu;

	    if(sscanf(string, "d", daisukidesu))
	        return Pesan(megumin, "/editworkshop [workshop id] [harga] [jumlah]");

		if(daisukidesu < MIN_WORKSHOP_PRICE)
		    return Pesan(megumin, "tidak boleh kurang dari %s!", Formatted(MIN_WORKSHOP_PRICE));

		Workshop[id][wsPrice] = daisukidesu;
		Workshop_Refresh(id);
		Workshop_Save(id);

		Pesan(megumin, "Harga workshop berhasil diganti!");
	}
	return 1;
}

CMD:deleteworkshop(megumin, stuff[])
{
	static
		id;

	if(Players[megumin][pAdminLevel] < 10)
	    return Error(megumin, "Kamu tidak memiliki kuasa untuk memakai ini!");

	if(sscanf(stuff, "d", id))
	    return Pesan(megumin, "/deleteworkshop [workshop id]");

	if(!Workshop[id][wsExists])
		return Pesan(megumin, "ID Workshop yang anda masukan sudah tidak ada di server");

	Workshop_Delete(id);
	Pesan(megumin, "Berhasil menghapus workhop ID %d", id);
	return 1;
}

//private section, donot touch!
Private:SetWorkshopPos(privateid, type, Float:wsX, Float:wsY, Float:wsZ)
{
	switch(type)
	{
	    case POS_TYPE_ICON:
		{
			Workshop[privateid][wsIconPos][0] = wsX;
			Workshop[privateid][wsIconPos][1] = wsY;
			Workshop[privateid][wsIconPos][2] = wsZ;
		}
		case POS_TYPE_PICKUP:
		{
			Workshop[privateid][wsPickupPos][0] = wsX;
			Workshop[privateid][wsPickupPos][1] = wsY;
			Workshop[privateid][wsPickupPos][2] = wsZ;
		}
	}
	Workshop_Refresh(privateid);
	Workshop_Save(privateid);
	return 1;
}

Private:IsRoleplayName(unz[])
{
	if(strfind(unz, "_") != -1)
		return true;

	return false;
}

Private:ReturnName(aqua, _und = 0)
{
	static
		a[MAX_PLAYER_NAME+1];

	GetPlayerName(aqua, a, sizeof(a));
	if(_und == 0) {
	    for (new i = 0, au = strlen(a); i < au; i ++) {
	        if (a[i] == '_') a[i] = ' ';
		}
	}
	return a;
}

Private:Pesan(aqua, text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	/*
     *  Custom function that uses #emit to format variables into a string.
     *  This code is very fragile; touching any code here will cause crashing!
	*/
	
	if ((args = numargs()) == 2)
	    return SendClientMessage(aqua, COL_WHITE, text);

	while (--args >= 2)
	{
		#emit LCTRL 5
		#emit LOAD.alt args
		#emit SHL.C.alt 2
		#emit ADD.C 12
		#emit ADD
		#emit LOAD.I
		#emit PUSH.pri
	}
	#emit PUSH.S text
	#emit PUSH.C 128 //144
	#emit PUSH.C str
	#emit LOAD.S.pri 8
	#emit ADD.C 4
	#emit PUSH.pri
	#emit SYSREQ.C format
	#emit LCTRL 5
	#emit SCTRL 4

	SendClientMessage(aqua, COL_WHITE, str);

	#emit RETN
	return 1;
}

Private:Formatted(money)
{
	new
		neg,
		nd,
		str[32];

	if(money < 0) neg = 1;
	format(str, sizeof(str), "$%i", money);
	nd = strlen(str);
	if((nd -= 2) > neg) strins(str, ".", nd);
	while((nd -= 3) > neg) strins(str, ",", nd);
	return str;
}

//RandomPlate()

Private:GetModelName(veh[])
{
	if (isnumber(veh) && (strval(veh) >= 400 && strval(veh) <= 611))
	    return strval(veh);

	for (new i = 400; i < sizeof(VEHICLE_NAME_INFO); i ++)
	{
	    if (strfind(VEHICLE_NAME_INFO[i], veh, true) != -1)
	        return i;
	}
	return 0;
}

Private:isnumber(val[])
{
	for(new i; i < strlen(val); i++)
		if(('a' <= val[i] <= 'z') || ('A' <= val[i] <= 'Z')) return false;

	return true;
}

SetupPlayerForClassSelection(darkness)
{
 	SetPlayerInterior(darkness,14);
	SetPlayerPos(darkness,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(darkness, 270.0);
	SetPlayerCameraPos(darkness,256.0815,-43.0475,1004.0234);
	SetPlayerCameraLookAt(darkness,258.4893,-41.4008,1002.0234);
}
