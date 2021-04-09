
--
spacengine.vaisseaux_pirate={
{"pirate.we","x05y05z05v01331","A"},
{"linx.we","x09y07z07v04275","K"},
{"frelon.we","x05y05z07v01815","L"}
}
--]]
spacengine.vaisseaux={
{"navette","x05y05z05v01331","A",10000,"Navette x11 y11 z11"},
{"atlantis","x05y07z13v04455","C",150000,"Atlantis x11 y15 z27"},
{"pirate_spaceship","x05y05z05v01331","A",75000,"Pirate x11 y11 z11"},
{"voyager","x07y09z15v08835","J",250000,"Voyager x15 y19 z31"},
{"linx","x09y07z07v04275","K",125000,"LINX x19 y15 z15"},
{"frelon","x05y05z07v01815","L",85000,"Frelon x11 y11 z15"}
}

spacengine.upgrade={
--controler
{
{"1A",0,"Controler beta5","*¨250¨0¨^x05y05z05v01331¨*","Vaisseaux de base, X=11 Y=11 Z=11"},
{"1B",3000,"The Cube","*¨300¨0¨^x08y09z09v06859¨*","Vaisseaux cubique X=19 Y=19 Z=19"},
{"1C",2000,"Destroyer","*¨350¨0¨^x05y07z13v04455¨*","X=11 Y=15 Z=27"},
{"1D",2500,"VOYAGER","*¨350¨0¨^x07y05z15v05115¨*","Voyager X=15 Y=11 Z=31"},
{"1E",3500,"Cargo","*¨350¨0¨^x09y07z13v07695¨*","Cargo X=19 Y=15 Z=27"},
{"1F",2500,"Tower","*¨350¨0¨^x07y11z07v05175¨*","The TUBE X=15 Y=23 Z=15"},
{"1G",1500,"Discovery","*¨350¨0¨^x05y07z11v03795¨*","X=11 Y=15 Z=23"},
{"1H",2500,"Flat","*¨280¨0¨^x11y05z11v05819¨*","X=23 Y=11 Z=23"},
{"1I",3500,"Croiser","*¨350¨0¨^x09y05z13v07695¨*","Croiser X=19 Y=11 Z=27"},
{"1J",4500,"Star","*¨350¨0¨^x07y09z15v08835¨*","Star X=15 Y=19 Z=31"},
{"1K",2000,"Plane","*¨350¨0¨^x09y07z07v04275¨*","Plane X=19 Y=15 Z=15"},
{"1L",1500,"Capsule","*¨250¨0¨^x05y05z07v01815¨*","Capsule X=11 Y=11 Z=15"},
{"2a",0,"stock 6","*¨*¨*¨*¨6","Stockage de base 6 emplacements"},
{"2b",5000,"stock 12","*¨*¨*¨*¨12","Stockage 12 emplacements"},
{"2c",10000,"stock 24","*¨*¨*¨*¨24¨*","Stockage 24 emplacements"}
},
--battery
{
{"1A",0,"BATTERY 50","*¨50¨0¨5000","Capaciter 5000"},
{"1B",2500,"BATTERY 100","*¨100¨0¨10000","Capaciter 10000"},
{"1C",5000,"BATTERY Mega5","*¨150¨0¨50000","Capaciter 50000"},
{"1D",10000,"BATTERY SUPRA X10","*¨300¨0¨100000","Capaciter 100 KU"},
{"1E",100000,"BATTERY 1000KU","*¨1000¨0¨1000000","Capaciter 1000 KU"}
},
--power
{
{"1A",0,"Generator Charcoal","*¨100¨0¨250¨^default:coal_lump¨^battery¨10¨0¨0¨0","Generateur utilisant le charbon, il produit 250 U : 10 cycles 100Kg"},
{"1B",4000,"Generator Hydrogen","*¨150¨0¨500¨^spacengine:hydrogene_tank¨^battery¨15¨0¨0¨0","Generateur utilisant l'Hydrogene, production 500 U : 15 cycles 150Kg"},
{"1C",5000,"Generator petrol","*¨200¨0¨1000¨^espace:petrol_can¨^battery¨25¨0¨0¨0","Generateur utilisant du petrole, apporte une puissance de 1000 U / 25 Cycles. 200Kg"},
{"1D",5500,"Solar panel","*¨100¨0¨150¨^solar¨^battery¨10¨0¨0¨0","Generateur a energie solaire, produit jusqu'a 150 U en plein soleil 150Kg"},
{"1E",75000,"Generator Nuclear","*¨2500¨0¨2500¨^technic:uranium_block¨^battery¨150¨0¨0¨0","Nuclear reactor, generer de l'energie depuis l'uranium, grande puissance pendant longtemps, 2500 U : 150 cycles, son poids est problematique 2500 Kg"},
{"1F",2500,"Hydrogen","*¨200¨0¨-20¨^default:water_source¨^spacengine:hydrogene_tank¨20¨0¨0¨0","Fabriquer de l'hydrogene c'est possible a partir de l'electrolyse de l'eau, consomme -20 U / 20 cycles pour produire 1 bouteille d'hydrogene 200Kg"},
{"1G",2500,"Oxygen","*¨200¨0¨-4¨^default:water_source¨^spacengine:oxygene_tank¨10¨0¨0¨0","Besoin d'air, cette option est pour vous, le generateur utilise de l'eau et consomme -4 U / 10 cycles par bouteille d'oxygene 200Kg"},
{"1H",2500,"Water","*¨200¨0¨0¨^solar¨^default:water_source¨50¨0¨0¨0","Produire de l'eau a partir du soleil c'est simple mais long : 50 cycles. systeme qui ne consomme pas d'energie de la battery 200Kg"},
{"1I",4000,"Generator Hydra","*¨300¨0¨250¨^water¨^battery¨2¨0¨0¨0","Une generatrice a eau, immerger elle produit jusqu'a 250 U par cycle"},
{"1J",1500,"Biofuel","*¨300¨0¨-5¨^group:leave¨^biofuel:fuel_can¨10¨0¨0¨0","Transforme des feuilles en carburant Biofuel, consomme 5 U par cycle et genere en 10 cycles une bouteille de Biofuel 300Kg"},
{"1K",3000,"Generator Biofuel","*¨100¨0¨100¨^biofuel:fuel_can¨^battery¨10¨0¨0¨0","Generateur utilisant le Biofuel, il produit 100 U / 10 cycles 100Kg"},
{"1L",150000,"Generator AntiMatiere","*¨10000¨0¨10000¨^espace:antimatiere¨^battery¨300¨0¨0¨0","AntiMatiere Energy, generer de l'energie depuis l'antimatiere, 10000 U : 300 cycles, 10000 Kg"}
},
--engine
{
{"1A",0,"Rocket","*¨75¨0¨10¨50¨50¨500","10 Teslas 50R 50°/Cycl 500 Kg"},
{"1B",7500,"Magnetosphere","*¨350¨0¨25¨100¨100¨2500","Deplacement dans le systeme planetaire, 25 Teslas 100R 100°/Cycl 2500 Kg"},
{"1C",20000,"SpeedLight","*¨525¨0¨50¨500¨250¨5000","Voyage entre différent systeme, 50 Teslas 500R 250°/Cycl 5000 Kg"},
{"1D",40000,"Black_hole","*¨1500¨0¨80¨1500¨500¨10000","Ideal pour explorer les colonies éloignés, 80 Teslas 1500R 500°/Cycl 10000 Kg"},
{"1E",80000,"Galactica","*¨2055¨0¨100¨2500¨500¨20000","Traverser la galaxie, 100 Teslas 2500R 500°/Cycl 20000 Kg"},
{"2a",10000,"Booster","*¨^>100¨0¨^>20¨^>50¨*¨^>500","Une option pour booster votre moteur Weight+100 Power+20 Range+50 Storage+500Kg"},
{"2b",10000,"More weight","*¨^<10¨0¨^>10¨*¨*¨^>1500","Remplacement de certains organes du moteur par d'autre plus léger, gain de performance pour transporter des marchandises Weight-10 Power+10 Storage+1500Kg"},
{"2c",5000,"Freezer","*¨^>50¨0¨^>1¨*¨^>200¨^<25","Rajout d'un refroidisseur pour diminuer le temps d'attente entre chaque jump"}
},

--shield
{
{"1A",0,"Protector one","*¨100¨0¨100¨1","Protection basique contre les radiations cosmiques, 100P"},
{"1B",2500,"WatchDog","*¨125¨0¨625¨2","Un bouclier qui ammorti un peu les impacts des tirs ennemis, 625P"},
{"1D",5000,"Shield+","*¨125¨0¨1250¨3","1250P"},
{"1C",10000,"Guardian","*¨150¨0¨2500¨4","Guardian of the Galaxie, 2500P"},
{"2a",2500,"Protect +","*¨^>50¨*¨^>250¨^>1","+250 de protection"},
{"2b",2000,"ReGene","*¨^>50¨*¨*¨^>6","regeneration rapide"},
{"2a",2500,"HyperProtect","*¨^>50¨*¨^>500¨^>2","+500 de protection"}
},

--weapons
{
{"1A",0,"Laser","*¨100¨0¨750¨20¨5¨2","Un laser de tres courte porte et petite puissance 750U 20R 5S 2Z"},
{"1B",10000,"Canon Plasma","*¨100¨0¨2000¨30¨8¨4","Un canon puissant mais court 2000U 30R 8S 4Z"},
{"1C",20000,"Destroyer","*¨75¨0¨5000¨50¨10¨5","Pour infliger des degats aux vaisseaux 5000U 50R 10S 5Z"},
{"1D",50000,"Quantum light","*¨125¨0¨8000¨80¨9¨5","Le plus puissant 8000U 80R 9S 5Z"},
{"2a",2500,"Power","*¨^>10¨*¨^>2000¨*¨^<1¨*","Besoin de puissance ? +2000U"},
{"2b",1500,"Increase Speed","*¨^<50¨*¨^<25¨*¨^<5¨*","Rechargement plus rapide -5S"},
{"2c",3000,"Full range","*¨^>100¨*¨^<250¨^>20¨^>1¨*","Augmente la distance des tirs +20R"},
{"2d",4000,"ZONE extend I","*¨^>50¨*¨^<25¨*¨*¨^>5","Augmente la zone des tirs +5Z"},
{"2e",8000,"ZONE extend II","*¨^>50¨*¨^<25¨*¨*¨^>10","Augmente la zone des tirs +10Z"}
},

--radar
{
{"1A",0,"Stone","*¨50¨0¨300¨30¨^$group:stone","Detection courte porter du group stone"},
{"2B",7500,"Uranium","*¨^>5¨*¨^>150¨^>15¨^$technic:mineral_uranium","Detection de l'uranium, augmente de 15 bloc le range"},
{"2C",2000,"COAL","*¨^>5¨*¨*¨*¨^$default:stone_with_coal","Detection de coal"},
{"2D",5000,"COPPER","*¨^>10¨*¨^>300¨^>30¨^$default:stone_with_copper","Detection de copper, augmente de 30 le range"},
{"2E",4000,"Diamond","*¨^>15¨*¨^>300¨^>30¨^$default:stone_with_diamond","Detection de diamond, range = +30"},
{"2F",2000,"Spacengine","*¨^>5¨*¨*¨*¨^$group:spacengine","Detection d'autre vaisseaux"},
{"2G",2000,"Mobs","*¨^>5¨*¨*¨*¨^$mobs:all:mobs","Detection de mobs"},
{"2H",2000,"Player","*¨^>5¨*¨*¨*¨^$player:player","Detection d'autre player"},
{"2a",1000,"More Range","*¨^>55¨*¨^>200¨^>20¨*","Detection augmenter de 20 blocs"},
{"2b",4000,"More Range","*¨^>55¨*¨^>600¨^>60¨*","Detection augmenter de 60 blocs"},
{"2c",1000,"p-","*¨^>5¨*¨^<250¨*¨*","baisse la consommation d'energie -250U"}
},

--gravitation
{
{"1A",0,"Gforce","*¨100¨0¨4","Gravitation artificielle, permet dans l'espace d'avoir une gravitation de 0.4 G"},
{"1B",1000,"Gforce EARTH","*¨100¨0¨8","Gravitation artificielle, permet dans l'espace d'avoir une gravitation de 0.8 G"},
{"2a",2000,"+0.2 G","*¨^>200¨0¨^>2","Augmente la Gravitation artificielle de 0.2 G"}
},

--storage
{
{"1A",0,"Container 500Kg","*¨100¨0¨500","Container de base, capaciter de 500 Kg"},
{"1B",500,"Container 1000Kg","*¨150¨0¨1000","Container d'une capaciter de 1000 Kg"},
{"1C",1000,"Container 5000Kg","*¨200¨0¨5000","Container renforcer pour une capaciter de 5000 Kg"}
},

--passenger
{
{"1A",0,"Crew","*¨50¨0¨^c","Siege pour un membre d'equipage"},
{"1B",150,"Tourist","*¨50¨0¨^t","Siege pour un passager en vacance classe 1"},
{"1C",50,"Worker","*¨50¨0¨^w","Siege pour un travailleur classe 2"},
{"1D",200,"Scientist","*¨60¨0¨^s","Siege pour un scientifique, ingenieur, classe VIP"},
{"1E",100,"Military","*¨75¨0¨^m","Siege pour transport de troupe"}
},

--oxygene
{
{"1A",0,"Oxygene","*¨150¨0¨1¨50","Oxygene le vaisseaux, 1 stack d'air, temps entre chaque ventilation : 50 cycle"},
{"1B",5000,"OXYGEN II","*¨200¨0¨5¨100","Oxygene le vaisseaux, 5 stacks d'air, temps entre chaque ventilation : 100 cycle"},
{"2a",5000,"Oxygene+","*¨^>15¨0¨^>3¨*","Augmente le taux d'oxygene de 3 stacks d'air"},
{"2b",8000,"Full oxygen","*¨^>55¨0¨^>5¨*","Augmente le taux d'oxygene de 5 stacks d'air"},
{"2c",7500,"speed","*¨^>55¨0¨*¨^>50","Augmente le temps de cycle +50"}
},

--screen
{
{"1C",0,"Controler","*¨*¨0¨^bC0bJ0bM0aa0bi0¨1",""},
{"1B",0,"Battery","*¨*¨0¨^bM0¨1",""},
{"1P",0,"Power","*¨*¨0¨^bD0bP0bM0¨1",""},
{"1E",0,"Engine","*¨*¨0¨^bm0bm0bm0bM0aA0bk0bl0¨1¨^a06151-31000a06251-31000a06351-31000:00000000000:00000000000:00000000000:00000000000",""},
{"1S",0,"Shield","*¨*¨0¨^aB0bM0¨1",""},
{"1W",0,"Weapons","*¨*¨0¨^bF0aC0aD0aI0bM0¨1",""},
{"1R",0,"Radar","*¨*¨0¨^bS0aE0br0aI0bM0¨1",""},
{"1G",0,"Gforce","*¨*¨0¨^aF0bM0¨1",""},
{"1s",0,"Storage","*¨*¨0¨^aa0aa0aa0bM0¨1",""},
{"1i",0,"Info","*¨*¨0¨^bm0bm0bm0bm0bm0¨1¨^A00051129023B00021000095C00021000013D00021000095E00031000512¨0¨0¨0¨0¨0",""},
{"1O",0,"Oxygene","*¨*¨0¨^aG0bf0bM0¨1¨^A",""},
{"1M",0,"Manutention","*¨*¨0¨^bE0bc0bs0aH0aI0bM0bg0bp0bh0¨1",""},
{"1A",0,"SWITCH","*¨*¨0¨^iw0iT0iB0iB0iB0iE0iC0¨1¨^DOOR_IN\nATC\nSAS_OUT\nSTORAGE\nHANGAR\nALARM\nLIGHT",""},
{"1D",0,"ANALOG","*¨*¨0¨^aA0aC0aB0aE0aF0aG0aD0¨1",""},
{"1F",0,"COORDO","*¨*¨0¨^ax0ay0az0aI0bM0",""}
},

--manutention
{
{"1B",0,"Crane","*¨150¨0¨50¨2¨^$default:stone:6:BD:50¨100","Grue pour poser des STONE"},
{"1D",5000,"Digger","*¨250¨0¨50¨2¨^$default:stone:6:BD:50¨100","foreuse de STONE"},
{"1P",5000,"Pump","*¨150¨0¨50¨2¨^$group:water:8:P:50¨100","Pompe les liquides"},
{"2a",1500,"coal","*¨*¨*¨*¨*¨^$default:stone_with_coal:8:DB:60¨100","manutention du coal"},
{"2b",1500,"iron","*¨*¨*¨*¨*¨^$default:stone_with_iron:10:DB:75¨*","manutention du iron"},
{"2c",1500,"More range","*¨*¨*¨^>20¨*¨*¨*","augmente la distance de 20 blocs"},
{"2d",1500,"More zone","*¨*¨*¨*¨^>10¨*¨*","augmente la zone de travail +10"},
{"2e",1500,"Lava","*¨*¨*¨*¨*¨^$default:lava_source:12:P:75¨*","Pompage de lave"},
{"2f",1500,"Oil","*¨*¨*¨*¨*¨^$espace:oil_source:12:P:80¨*","Pompage de petrole"},
{"2g",1500,"Mud","*¨*¨*¨*¨*¨^$espace:mud_source:12:P:80¨*","Pompage de boue"},
{"2j",1500,"More speed","*¨*¨*¨*¨*¨*¨^<25","augmente la vitesse X1.5"},
{"2k",1500,"More speed2","*¨*¨*¨*¨*¨*¨^<50","augmente la vitesse X2"},
{"2h",1500,"Uranium","*¨*¨*¨*¨*¨^$technic:mineral_uranium:7:D:125¨*","Exctraction d'uranium"},
{"2i",1500,"mithril","*¨*¨*¨*¨*¨^$moreores:mineral_mithril:8:D:150¨*","Extraction de Mithril"}
},

--switch b
{
{"C","CONTROLER on/off"},
{"P","POWER change source"},
{"J","ENGINE JUMP"},
{"j","QUICK JUMP"},
{"k","QUICK JUMP DIRECTION"},
{"l","QUICK JUMP RANGE"},
{"F","WEAPONS FIRE"},
{"n","WEAPONS RANGE INC+1"},
{"S","RADAR SCAN"},
{"r","RADAR CIBLE"},
{"f","OXYGEN"},
{"E","MANUTENTION EXECUTE"},
{"c","MANUTENTION change command"},
{"s","MANUTENTION change source"},
{"g","MANUTENTION inc idx"},
{"h","MANUTENTION inc idy"},
{"p","MANUTENTION inc idz"},
{"G","GOUVERNAIL"},
{"W","CALL PATROL"},
{"N","Change Message"},
{"w","COMMAND SWITCH"},
{"H","CHEAT"}
},

--switch i
{
{"A","POWER ON/OFF"},
{"B","Keypad ON/OFF"},
{"C","Light ON/OFF"},
{"D","MANUTENTION ON/OFF"},
{"E","WARNING ON/OFF"},
{"T","ATC ON/OFF"},
{"w","COMMAND SWITCH"}
},

--switch a
{
{"A","ENGINE PUISSANCE"},
{"B","SHIELD PUISSANCE"},
{"C","WEAPONS PUISSANCE"},
{"D","WEAPONS RANGE"},
{"E","RADAR PUISSANCE"},
{"F","Gforce PUISSANCE"},
{"G","OXYGENE % AIR"},
{"H","MANUTENTION range"},
{"J","MANUTENTION zone"},
{"x","X pos"},
{"y","Y pos"},
{"z","Z pos"},
{"I","ZONE"}
}
}
