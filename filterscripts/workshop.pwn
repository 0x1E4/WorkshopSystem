/*
----------------------------------------------------------------------------
							======================
							| 	 Base Workshop   |
							| 	   by 0x1E4      |
							======================


Description:
Buatan sendiri, mikir pake otak..
Kadang juga gua ngambil sample dari gamemode orang.
Ya suka suka sih, yang penting gua ga copy paste :P


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

//wajib!
#define FILTERSCRIPT

//maxes
#define MAX_WORKSHOP    (12)
#define MAX_CAR         (12)
#define MAX_CAR_OBJ     (3)

//default format
#define WORKSHOP_FORMAT "moechan"

//color hex
#define RED             "{800020}"
#define YELLOW          "{EED200}"
#define GREEN           "{008989}"
#define BLUE            "{3FC9F2}"
#define ORANGE          "{E34500}"
#define BLACK           "{000000}"
#define WHITE           "{FFFFFF}"

//macro defines (jangan coba coba ganti kalau gak mau nemuin endless error)
#define Pesan(%0,%1)   	SendClientMessage(%0,0xFFFFFF,%1)
#define SameWith(%0,%1) !strcmp(%0,%1,true)
#define Format:%0(%1)   format(%0,sizeof(%0),%1)
#define Class:%0(%1)  	forward %0(%1); public %0(%1)
#define Scope:%0(%1)  	public %0(%1)
#define Private:%0(%1)  stock %0(%1)


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
	carID,
	carModel[DINI_MAX_FIELD_VALUE],
	carEngine,
	carLock,
	Float:carPos[4],
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

//deklarasi untuk dipake bersama sama!
new
	Players[MAX_PLAYERS][E_PLAYER_INFO],
	Car[MAX_CAR][E_CAR_INFO],
	Workshop[MAX_WORKSHOP][E_WORKSHOP_INFO],
	CoreVehicle[MAX_CAR][E_CORE_INFO],
	CarObject[MAX_CAR][E_CAROBJ_INFO]
;

//scope filterscript
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
	return 1;
}

//scope player connect
Scope:OnPlayerConnect(playerid)
{
	Player_Load(playerid);
	return 1;
}

Class:Player_Load(kazuma)
{
	new stuff[64];
	Format:stuff("Accounts/%s.ini", ReturnName(kazuma, 1));
	if(!fexist(stuff))
	{
		dini_Create(stuff);
		dini_Set(stuff, "Name", ReturnName(kazuma, 1));
		dini_IntSet(stuff,"AdminLevel", 0);
		dini_IntSet(stuff,"Cash", 1000000);
		dini_IntSet(stuff, "Car", 0);
		dini_IntSet(stuff, "Workshop", 0);
	}
	else
	{
	    Players[kazuma][pName] = dini_Get(stuff, "Name");
	    Players[kazuma][pAdminLevel] = dini_Int(stuff, "AdminLevel");
	    Players[kazuma][pCash] = dini_Int(stuff, "Cash");
	    Players[kazuma][pCar] = dini_Int(stuff, "CarID");
		Players[kazuma][pWorkshop] = dini_Int(stuff, "WorkshopID");
		
		GivePlayerMoney(kazuma, Players[kazuma][pCash]);
		
		if(Players[kazuma][pCar] != -1) {
			Car_Create(kazuma);
		}
	}
	return 1;
}

Class:Workshop_Load()
{
    new File[23], wscuk;
    for(new i = 1; i < MAX_WORKSHOP; i++)
    {
        Format:File("Workshops/%d.ini", i);
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
	new File[23], carcuk;
	for(new i = 1; i < MAX_CAR; i++)
	{
        Format:File("Cars/%d.ini", i);
	 	if(fexist(File))
		{
		    Car[i][carExists] = true;

		    Car[i][carModel] = dini_Int(File, "Models");
		    Car[i][carID] = dini_Int(File, "ID");
			Car[i][carLock] = dini_Int(File, "Lock");

			Car[i][carPos][0] = dini_Float(File, "CarPosX");
			Car[i][carPos][1] = dini_Float(File, "CarPosY");
			Car[i][carPos][2] = dini_Float(File, "CarPosZ");

			carcuk++;
		}
	}
	printf("%d mobl berhasil di load", carcuk);
	return 1;
}

Class:Workshop_Unload()
{
    for(new i = 0; i < MAX_WORKSHOP; i++) {
		Workshop_Delete(i);
	}
	return 1;
}

Class:Car_Unload()
{
    for(new i = 0; i < MAX_CAR; i++) {
		Car_Delete(i);
	}
	return 1;
}

Class:Workshop_Create(const name[], price)
{
    for(new i = 1; i < MAX_WORKSHOP; i++) if(!Workshop[i][wsExists])
    {
		Workshop[i][wsExists] = true;
		Workshop[i][wsID] = i;
		
	    format(Workshop[i][wsName], 32, name);
	    format(Workshop[i][wsOwnerName], 32, WORKSHOP_FORMAT);

		Workshop[i][wsOwner] = 0;
		Workshop[i][wsPrice] = price;
		Workshop[i][wsLock] = 0;

		Workshop[i][wsIconPos][0] = 0.0;
		Workshop[i][wsIconPos][1] = 0.0;
		Workshop[i][wsIconPos][2] = 0.0;

		Workshop[i][wsIconPos][0] = 0.0;
		Workshop[i][wsIconPos][1] = 0.0;
		Workshop[i][wsIconPos][2] = 0.0;
		
		Workshop_Refresh(i);
		Workshop_Save(i);
		return 1;
	}
	return -1;
}

Class:Car_Create(kazuma)
{
	return 1;
}

Class:Workshop_Refresh(classid)
{
	static
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

	if(Workshop[classid][wsOwner] != 0)
	{
	    Format:arOutput("[Workshop ID:%d]\n%s\nWorkshop Owner: %s\n Workshop Type: Transfender", classid, Workshop[classid][wsOwnerName]);
		Workshop[classid][wsIconText] = CreateDynamic3DTextLabel(arOutput, 0xFFFFFF, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsIcon] = CreateDynamicPickup(1083, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}
	else
	{
		Format:arOutput("[Workshop ID:%d]\n%s\nWorkshop Owner: None\n Workshop Type: Transfender\nSilahkan ketik (/buy) untuk membeli workshop ini.", classid, Workshop[classid][wsOwnerName]);
		Workshop[classid][wsIconText] = CreateDynamic3DTextLabel(arOutput, 0xFFFFFF, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsIcon] = CreateDynamicPickup(1083, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}
	
	if(Workshop[classid][wsPickupPos][0] != 0.0 && Workshop[classid][wsPickupPos][1] != 0.0 && Workshop[classid][wsPickupPos][2] != 0.0)
	{
		Workshop[classid][wsPickupText] = CreateDynamic3DTextLabel(arOutput, 0xFFFFFF, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Workshop[classid][wsPickup] = CreateDynamicPickup(1239, 23, Workshop[classid][wsIconPos][0], Workshop[classid][wsIconPos][1], Workshop[classid][wsIconPos][2]);
	}
	return 1;
}

Class:Car_Refresh(classid)
{
	static
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
	if(Car[classid][carMod] > 0) {
		for(new a = 0; a < Car[classid][carMod]; a++) {
			CoreVehicle[classid][carObjectMod][a] = CreateDynamicObject(Car[classid][carCustomMod][a], 0.0+random(10), 0.0, 0.0+random(10), 0.0, 0.0, 0.0, 0);
			AttachDynamicObjectToVehicle(CoreVehicle[classid][carObjectMod][a], classid, CarObject[a][carPos][0], CarObject[a][carPos][1], CarObject[a][carPos][2], CarObject[a][carRotatePos][0], CarObject[a][carRotatePos][1], CarObject[a][carRotatePos][2]);
		}
	}
	return 1;
}

Class:Workshop_Delete(classid)
{
	return 1;
}

Class:Car_Delete(classid)
{
	return 1;
}

Class:Workshop_Save(classid)
{
	return 1;
}

Class:Car_Save(classid)
{
	return 1;
}

CMD:makeadmin(megumin, stuff[])
{
	#pragma unused stuff
	Players[megumin][pAdminLevel] = 10;
	Pesan(megumin, ""WHITE"["RED"PROMOTION"WHITE"] Selamat anda sudah menjadi admin tingkat tinggi!");
	return 1;
}

CMD:createworkshop(megumin, stuff[])
{
	static
		name[18],
		price,
		chl;
		
	if(sscanf(stuff, "s[18]d", name, price))
		return Pesan(megumin, "/createworkshop [namanya] [harga]");
	    
	if(strlen(name) > 18)
	    return Pesan(megumin, "Namanya kepanjangan! (Maksimal 18 kata)");
	    
	if(price < 100000)
	    return Pesan(megumin, "tidak boleh kurang dari $1,000.00!");
	    
	chl = Workshop_Create(name, price);
	
	if(chl == -1)
		return Pesan(megumin, "Tidak bisa membuat workshop (Workshop sudah terisi penuh)");
		
	Pesan(megumin, "Sukses membuat workshop!, sekarang tinggal /editworkshop ya");
	return 1;
}

CMD:editworkshop(megumin, stuff[])
{
	static
		id,
		type[32],
		string[128];
		
	if (sscanf(stuff, "ds[24]S()[128]", id, type, string))
 	{
 	    Pesan(megumin, "/editworkshop [workshop id] [type]");
 	    Pesan(megumin, ""BLUE"LIST TYPE:"WHITE" nama, type, pos, point, harga");
 	    return 1;
	}
	if(!strcmp(type, "nama", true))
	{
		static
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
	else if(!strcmp(type, "type", true))
	{
	    static
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
	else if(!strcmp(type, "pos", true))
	{
	    static
			Float:pX,
			Float:pY,
			Float:pZ;
			
	    GetPlayerPos(megumin, pX, pY, pZ);
	    SetWorkshopPos(id, 1, pX, pY, pZ);
	    
	    Pesan(megumin, "Posisi workshop berhasil diganti!");
	}
	else if(!strcmp(type, "point", true))
	{
	    static
			Float:pX,
			Float:pY,
			Float:pZ;

	    GetPlayerPos(megumin, pX, pY, pZ);
	    SetWorkshopPos(id, 2, pX, pY, pZ);

	    Pesan(megumin, "Posisi point workshop berhasil diganti!");
	}
	else if(!strcmp(type, "harga", true))
	{
		static
		    daisukidesu;
		    
	    if(sscanf(string, "d", daisukidesu))
	        return Pesan(megumin, "/editworkshop [workshop id] [harga] [jumlah]");
	        
		if(daisukidesu < 100000)
		    return Pesan(megumin, "tidak boleh kurang dari $1,000.00!");
		    
		Workshop[id][wsPrice] = daisukidesu;
		Workshop_Refresh(id);
		Workshop_Save(id);
		
		Pesan(megumin, "Harga workshop berhasil diganti!");
	}
	return 1;
}

//private section, donot touch!
Private:SetWorkshopPos(privateid, type, Float:wsX, Float:wsY, Float:wsZ)
{
	switch(type)
	{
	    case 1:
		{
			Workshop[privateid][wsIconPos][0] = wsX;
			Workshop[privateid][wsIconPos][1] = wsY;
			Workshop[privateid][wsIconPos][2] = wsZ;
		}
		case 2:
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

Private:ReturnName(kazuma, _und = 0)
{
	static
		name[MAX_PLAYER_NAME+1];
		
	GetPlayerName(kazuma, name, sizeof(name));
	
	if(_und == 0) {
	    for (new i = 0, len = strlen(name); i < len; i ++) {
	        if (name[i] == '_') name[i] = ' ';
		}
	}
	return name;
}
