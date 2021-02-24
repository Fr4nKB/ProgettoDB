USE edevice;
SET @timer = CURRENT_TIME();

INSERT INTO Rimedio (CodiceRimedio, Descrizione)
VALUES	("jjrdi68ku0", "Accendi il dispositivo"),
		("qq1cmyxnju", "Collega il caricatore"),
		("sydp5phk2p", "Accendi il dispositivo più forte"),
		("7v944vhmvw", "Riavvia il dispositivo"),
		("famew7p1qy", "Fai il backup"),
		("83jsavgbj3", "CTRL + ALT + CANC"),
		("yxsfc5r7j2", "Apri il task manager e chiudi i programmi che non utilizzi"),
		("qk2wpsm039", "Installa un Antivirus"),
		("ar4dsemp4h", "Alza il volume"),
		("pfd39rrhc3", "Esegui il test delle casse"),
		("osqzhwawds", "Collega il caricatore"),
		("ihil3h4ox8", "Chiama il 911");
        
INSERT INTO Guasto (CodiceGuasto, Nome, Descrizione)
VALUES	("8ypvc1wejp", "schermo nero", ""),
		("a74m19zwjt", "os esploso", ""),
		("j82lftun4x", "cassa non funzionate", ""),
		("m4lcpopbym", "non si carica più", ""),
		("08h2fcfrhg", "mi sta cercando di uccidere", "");
       
INSERT INTO AssistenzaVirtuale (CodiceRimedio, Domanda, SI, `NO`, CodiceGuasto)
VALUES	-- assistenza schermo nero
		("qq1cmyxnju", "Sei Sicuro?", NULL, NULL, NULL),
        ("qq1cmyxnju", "La batteria e' carica?", 1, NULL, NULL),
		("sydp5phk2p", "Sei sicuro di aver premuto il tasto giusto?", 2, NULL, NULL),
        ("jjrdi68ku0", "Hai provato ad accendere il dispositivo?", 2, 3, "8ypvc1wejp"),
		-- assistenza os esploso pensata per telefoni
		("famew7p1qy", "Hai provato a ripristinare il telefono?", NULL, NULL, NULL),
		("7v944vhmvw", "Hai provato a riavviare il telefono?", 5, 5, "a74m19zwjt"),
		-- assistenza os esploso pensata per i computer
		("qk2wpsm039", "Hai controllato che non ci siano virus?", NULL, NULL, NULL),
        ("yxsfc5r7j2", "Hai provato a chiudere tutti i programmi?", 7, 7, NULL),
        ("83jsavgbj3", "Riesci a muovere il mouse?", 8, NULL, "a74m19zwjt"),
        -- casse rotte
        ("pfd39rrhc3", "Hai eseguito test delle casse?", NULL, NULL, NULL),
        ("ar4dsemp4h", "Hai alzato il volume?", 10, NULL, "j82lftun4x"),
        --  non si carica più
        ("osqzhwawds", "Il caricatore e' attaccato?", NULL, NULL, "m4lcpopbym"),
        -- mi sta cercando di uccidere
        ("ihil3h4ox8", "Hai assunto stupefacenti?", NULL, NULL, "08h2fcfrhg");

INSERT INTO Prodotto (NumeroResiRicondizionamento, CoefficienteSovraprezzo, PrezzoProduzione)
VALUES	(50, 0.4, 0),
		(60, 0.3, 0),
		(70, 0.6, 0),
		(80, 0.14, 0),
		(30, 0.7, 0),
		(40, 0.9, 0),
		(100, 0.14, 0),
		(60, 0.4, 0);

INSERT INTO Giunzione (Nome, Tipo)
VALUES	("ycuek", "vite"),
		("loon7", "vite"),
		("oc8fr", "vite"),
		("cki2k", "vite"),
		("gzs25", "saldatura"),
		("313ce", "saldatura"),
		("np98j", "bullone"),
		("9v31i", "bullone"),
		("dw1aq", "bullone"),
		("b3g47", "colla"),
		("8za1u", "incastro"),
		("0u3kr", "vite"),
		("uwljs", "vite");

INSERT INTO Caratteristica (Nome, Descrizione)
VALUES	("Lunghezza", "3mm"),
		("Lunghezza", "4mm"),
		("Lunghezza", "5mm"),
		("Lunghezza", "6mm"),
		("Colore", "nero"),
		("Colore", "grigio"),
		("Tipo", "stagno"),
		("Tipo", "tig"),
		("Dimensione", "1"),
		("Dimensione", "2"),
		("Dimensione", "3"),
		("Densità", "1, 19 g/cm3"),
		("Tipo", "Taglio"),
		("Tipo", "Stella");

INSERT INTO Caratterizzato (GiunzioneId, CaratteristicaId)
VALUES	(1, 1),
		(1, 5),
		(1, 13),
		(2, 2),
		(2, 6),
		(2, 14),
		(3, 3),
		(3, 13),
		(4, 4),
		(4, 14),
		(5, 7),
		(6, 8),
		(7, 9),
		(8, 10),
		(9, 11),
		(10, 12);

INSERT INTO Utensile (Nome, Descrizione)
VALUES	("cacciavite", NULL),
		("saldatore", NULL),
		("avvitatore", NULL),
		("guanti", NULL),
		("pressa", NULL),
		("calibratoreColori", NULL),
		("microfono", NULL),
		("mascherina", NULL);

INSERT INTO OperazioneCampione (Nome, Descrizione)
VALUES	("avvitare", NULL),
		("saldare", NULL),
		("unire", NULL),
		("montare", NULL),
		("pressare", NULL),
		("incollare", NULL),
		("calibrare", NULL);

INSERT INTO Usato (OpCampId, UtensileId)
VALUES	(1, 1),
		(2, 2),
		(2, 8),
		(3, 4),
		(4, 8),
		(5, 5),
		(6, 4),
		(6, 5),
		(7, 6),
		(7, 7);

INSERT INTO Parte (CodiceParte, PrezzoProduzione, CoefficienteSvalutazione, Nome)
VALUES	("0e07trrrtg", 5.6, 0.2, "A"),
		("au0fhxphnj", 6.5, 0.1, "B"),
		("qkqrr83kkp", 1.5, 0.12, "C"),
		("acsrrawgc5", 1.4, 0.15, "D"),
		("y0j61jsa36", 7.2, 0.14, "E"),
		("q9xnjmkb1w", 2.5, 0.23, "F"),
		("agyf1q9u41", 1.3, 0.34, "G"),
		("28pkovijm3", 1.6, 0.35, "H"),
		("feo65cvtal", 4.2, 0.75, "I"),
		("kupr67zchl", 9.7, 0.35, "J"),
		("spl8vmx51h", 0.3, 0.57, "K"),
		("iowur4sbn0", 4.3, 0.45, "L"),
		("fjgy4cb7ap", 3.8, 0.75, "M"),
		("skdldoj16r", 3.7, 0.45, "N"),
		("krkyc6gzf5", 1.3, 0.75, "O"),
		("d42xrf96qy", 1.6, 0.2, "P"),
		("yd05ffqah5", 4.5, 0.1, "Q"),
		("7xvaogwkpa", 6.5, 0.12, "R"),
		("m6smfdr2az", 5.4, 0.15, "S"),
		("ubnu2h8l3x", 0.2, 0.14, "T"),
		("swaarpcvl4", 6.5, 0.23, "U"),
		("ndrjqkiii0", 8.3, 0.34, "V"),
		("k98gga3tl1", 0.6, 0.35, "W");
        
INSERT INTO Test (CodiceTest, Nome, CodiceParte, SottoTestDi)
VALUES  ("uwvev9wfj1", "bnlja", "0e07trrrtg", NULL),    -- root1
        ("3bbwd2kye3", "qbd0s", "qkqrr83kkp", "uwvev9wfj1"),
        ("g0ix23qlt3", "20mms", "acsrrawgc5", "uwvev9wfj1"),
        ("16nd0mjl3v", "urvrd", "k98gga3tl1", "g0ix23qlt3"),
        ("32kidxi8z6", "l1s5l", "au0fhxphnj", "uwvev9wfj1"),
        ("87436r8faw", "9gvdw", "swaarpcvl4", NULL),    -- root2
        ("29lwcuyaaf", "7ypch", "yd05ffqah5", "87436r8faw"),
        ("k65q00zei6", "r9xiy", "agyf1q9u41", "87436r8faw"),
        ("w2rr4vf9ot", "d2kch", "y0j61jsa36", "k65q00zei6"),
        ("936rup7b5m", "c5c2u", "q9xnjmkb1w", "k65q00zei6"),
        ("wkcxfhr513", "nl97m", "feo65cvtal", NULL),    -- root3
        ("ipbb7zcfxi", "1zxe2", "0e07trrrtg", "wkcxfhr513"),
        ("2dh58c09sb", "24w6p", "ubnu2h8l3x", "wkcxfhr513"),
        ("sqe9ew3a66", "t5ed4", "7xvaogwkpa", "wkcxfhr513"),
        ("pu4r6b1v04", "irt0e", "ubnu2h8l3x", "sqe9ew3a66"),
        ("6pki1jvyae", "9cl9n", "m6smfdr2az", "sqe9ew3a66"),
        ("6fzkt56k1k", "wrvrx", "iowur4sbn0", NULL),    -- root4
        ("fjb1aeu6nt", "464n7", "fjgy4cb7ap", "6fzkt56k1k"),
        ("0owvvmv4n8", "6kj58", "ndrjqkiii0", "6fzkt56k1k"),
        ("nqtf9yav9j", "x0sf3", "skdldoj16r", "6fzkt56k1k"),
        ("mg2dnojtus", "tqx3e", "k98gga3tl1", "6fzkt56k1k");


CALL aggiungiPrecTecn("0e07trrrtg", "au0fhxphnj", 1); 	-- A --> B
CALL aggiungiPrecTecn("0e07trrrtg", "qkqrr83kkp", 12);	-- A --> C
CALL aggiungiPrecTecn("au0fhxphnj", "qkqrr83kkp", 5);	-- B --> C
CALL aggiungiPrecTecn("au0fhxphnj", "acsrrawgc5", 7);	-- B --> D
CALL aggiungiPrecTecn("acsrrawgc5", "k98gga3tl1", 5);	-- D --> W
CALL InserisciModello("apple", "X", "uwvev9wfj1");		-- Modello

CALL aggiungiPrecTecn("swaarpcvl4", "agyf1q9u41", 6);	-- U --> G
CALL aggiungiPrecTecn("swaarpcvl4", "yd05ffqah5", 3);	-- U --> Q
CALL aggiungiPrecTecn("agyf1q9u41", "y0j61jsa36", 11);	-- G --> E
CALL aggiungiPrecTecn("y0j61jsa36", "q9xnjmkb1w", 9);	-- E --> F
CALL InserisciModello("apple", "XI", "87436r8faw");		-- Modello

CALL aggiungiPrecTecn("feo65cvtal", "0e07trrrtg", 1);	-- I --> A
CALL aggiungiPrecTecn("0e07trrrtg", "7xvaogwkpa", 12);	-- A --> R
CALL aggiungiPrecTecn("0e07trrrtg", "ubnu2h8l3x", 1);	-- A --> T
CALL aggiungiPrecTecn("ubnu2h8l3x", "7xvaogwkpa", 10);	-- T --> R
CALL aggiungiPrecTecn("7xvaogwkpa", "m6smfdr2az", 1);	-- R --> S
CALL InserisciModello("samsung", "S10", "wkcxfhr513");	-- Modello

CALL aggiungiPrecTecn("iowur4sbn0", "fjgy4cb7ap", 3);	-- L --> M
CALL aggiungiPrecTecn("iowur4sbn0", "ndrjqkiii0", 4);	-- L --> V
CALL aggiungiPrecTecn("iowur4sbn0", "skdldoj16r", 4);	-- L --> N
CALL aggiungiPrecTecn("k98gga3tl1", "iowur4sbn0", 8);	-- W --> L
CALL InserisciModello("microsoft", "surface", "6fzkt56k1k");

INSERT INTO Relativa (ModelloId, AssVirtId)
VALUES 	(1,4),
		(1,6),
		(1,11),
        (1,12),
        (2,4),
        (2,6),
        (2,12),
        (3,4),
        (3,6),
        (3,11),
        (4,4),
        (4,9),
        (4,13);
        
INSERT INTO Variante (Nome, Descrizione, Prezzo, ModelloId)
VALUES	("RAM", "4GB", 30.5, 1),
		("RAM", "6GB", 40.5, 1),
		("RAM", "8GB", 60.5, 1),
		("Colore", "rosso",30.2, 1),
		("Colore", "nero", 0, 1),
		("RAM", "8GB", 61.2, 2),
		("RAM", "12GB", 75.2, 2),
		("Colore", "nero",21.2, 2),
		("Colore", "bianco",11.43, 2),
		("RAM", "8GB", 61.2, 3),
		("Colore", "nero", 2.1, 3),
		("Colore", "bianco", 32, 3),
		("RAM", "8GB", 31.2, 4),
		("RAM", "16GB", 85.2, 4),
		("SSD", "512GB", 0, 4),
		("SSD", "1TB", 70.5, 4),
		("Dimensione", "14", 0, 4),
		("Dimensione", "15", 5, 4),
		("Dimensione", "17", 10, 4),
		("Colore", "grigio",3.3, 4),
		("Colore", "bianco", 21, 4);
        
INSERT INTO Costituito (ProdottoId, VarianteId)
VALUES	(1, 1),
		(1, 4),
		(2, 1),
		(2, 5),
		(3, 2),
		(3, 4),
		(4, 3),
		(4, 5),
		(5, 6),
		(5, 8),
		(6, 7),
		(6, 9),
		(7, 10),
		(7, 11),
		(8, 14),
		(8, 15),
		(8, 17),
		(8, 20);

INSERT INTO Faccia (Descrizione, ModelloId)
VALUES	("Sopra", 1),
		("Sotto", 1),
		("Sopra", 2),
		("Sotto", 2),
		("Sopra", 3),
		("Sotto", 3),
		("Schermo", 4),
		("Tastiera", 4),
		("Interno", 4);

INSERT INTO Materiale (Nome, ValoreAlKg)
VALUES	("alluminio", 32.2),
		("ferro", 7.2),
		("oro", 100.2),
		("argento", 50.2),
		("carbonio", 17.1),
		("plastica", 1.5);

INSERT INTO Costruito (CodiceParte, MaterialeId, Quantitativo)
VALUES	("0e07trrrtg", 1, 0.12),
		("0e07trrrtg", 3, 0.24),
		("0e07trrrtg", 4, 0.11),
		("au0fhxphnj", 6, 0.15),
		("au0fhxphnj", 2, 0.32),
		("qkqrr83kkp", 5, 0.17),
		("qkqrr83kkp", 4, 1.22),
		("qkqrr83kkp", 1, 1.45),
		("acsrrawgc5", 2, 0.42),
		("acsrrawgc5", 3, 0.21),
		("y0j61jsa36", 5, 0.14),
		("q9xnjmkb1w", 4, 1.22),
		("q9xnjmkb1w", 6, 0.52),
		("q9xnjmkb1w", 2, 0.25),
		("agyf1q9u41", 1, 0.53),
		("agyf1q9u41", 3, 1.36),
		("agyf1q9u41", 4, 0.66),
		("28pkovijm3", 6, 0.02),
		("28pkovijm3", 2, 1.98),
		("feo65cvtal", 5, 0.52),
		("feo65cvtal", 4, 1.13),
		("feo65cvtal", 1, 0.13),
		("kupr67zchl", 2, 0.07),
		("kupr67zchl", 3, 0.17),
		("spl8vmx51h", 5, 0.08),
		("spl8vmx51h", 4, 0.11),
		("iowur4sbn0", 6, 0.01),
		("fjgy4cb7ap", 2, 0.09),
		("fjgy4cb7ap", 5, 0.28),
		("skdldoj16r", 4, 0.78),
		("krkyc6gzf5", 1, 0.18),
		("krkyc6gzf5", 2, 0.29),
		("krkyc6gzf5", 3, 0.14),
		("d42xrf96qy", 5, 0.19),
		("d42xrf96qy", 4, 0.01),
		("yd05ffqah5", 6, 0.11),
		("7xvaogwkpa", 2, 0.19),
		("m6smfdr2az", 4, 0.10),
		("ubnu2h8l3x", 6, 0.20),
		("ubnu2h8l3x", 2, 0.11),
		("ubnu2h8l3x", 5, 0.10),
		("swaarpcvl4", 4, 0.32),
		("ndrjqkiii0", 1, 0.11),
		("ndrjqkiii0", 2, 0.10),
		("k98gga3tl1", 5, 0.22),
		("k98gga3tl1", 4, 0.10);

INSERT INTO Operatore (CodFiscale, Nome, Cognome, Stipendio, DataNascita)
VALUES	("DNDZVY85M24A427L", "Han", "Solo", 1600, '1987-10-09'),
		("GHNYSJ97T48C387E", "Giacomo", "Sansone", 3100, '1987-10-27'),
		("MSTFTR83S61M043U", "Natalie", "Portman", 1200, '1997-10-11'),
		("QKMFJT89P09A256A", "Pamela", "Beesly", 3400, '1957-07-24'),
		("MHPNSP92E71C727P", "Ted", "Mosby", 2200, '1947-02-11'),
		("JFSPCC92M70F569Y", "Barney", "Stinson", 1600, '1987-10-09'),
		("DGDDVZ92T49D253K", "Lorenzo Von", "MatthernHorn", 4600, '1991-11-15');

INSERT INTO TempoStimato (OperatoreId, OpCampId, Tempo)
VALUES	(1, 1, 340),
		(1, 2, 210),
		(1, 3, 233),
		(1, 4, 344),
		(1, 5, 234),
		(1, 6, 234),
		(1, 7, 664),
		(2, 1, 456),
		(2, 2, 245),
		(2, 3, 10),
		(2, 4, 356),
		(2, 5, 900),
		(2, 6, 325),
		(2, 7, 653),
		(3, 1, 214),
		(3, 2, 242),
		(3, 3, 212),
		(3, 4, 532),
		(3, 5, 20),
		(3, 6, 871),
		(3, 7, 141),
		(4, 1, 444),
		(4, 2, 144),
		(4, 3, 32),
		(4, 4, 255),
		(4, 5, 554),
		(4, 6, 225),
		(4, 7, 55),
		(5, 1, 254),
		(5, 2, 252),
		(5, 3, 222),
		(5, 4, 255),
		(5, 5, 453),
		(5, 6, 255),
		(5, 7, 251),
		(6, 1, 224),
		(6, 2, 595),
		(6, 3, 263),
		(6, 4, 253),
		(6, 5, 363),
		(6, 6, 27),
		(6, 7, 352),
		(7, 1, 111),
		(7, 2, 245),
		(7, 3, 255),
		(7, 4, 402),
		(7, 5, 214),
		(7, 6, 121),
		(7, 7, 145);

INSERT INTO Stazione (OperatoreId)
VALUES 	(NULL),
		(NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL),
        (NULL);

INSERT INTO Operazione (StazioneId, OpCampId, PrecTecId, FacciaId)
VALUES 	-- apple X
		(1, 1,1,1),
		(2, 2,2,2),
        (1, 3,3,1),
        (2, 4,4,2),
        (1, 5,5,1),
        -- apple XI
        (3, 6,8,3),
        (3, 7,9,3),
        (4, 5,10,4),
        (5, 1,11,3),
        -- samsung s20
        (6, 2,15,5),
        (6, 3,16,5),
        (7, 4,17,6),
        (6, 5,18,5),
        (7, 6,19,6),
        -- surface
        (8, 3,22,7),
        (9, 4,23,8),
        (10, 3,24,8),
        (11, 1,25,9);

-- assegno gli operatori alle stazioni
CALL AssegnaOperatore(1);
CALL AssegnaOperatore(2);
CALL AssegnaOperatore(3);
CALL AssegnaOperatore(4);
CALL AssegnaOperatore(5);
CALL AssegnaOperatore(6);
CALL AssegnaOperatore(7);
CALL AssegnaOperatore(8);
CALL AssegnaOperatore(9);
CALL AssegnaOperatore(10);
CALL AssegnaOperatore(11);
CALL AssegnaOperatore(12);

-- genero le sequenze
CALL GeneraSequenza(1, "rf921", 2034);
CALL GeneraSequenza(1, "24875", 2024);
CALL GeneraSequenza(2, "2dy82", 5104);
CALL GeneraSequenza(3, "iuy43", 2056);
CALL GeneraSequenza(4, "g7t87", 3406);
CALL GeneraSequenza(1, "agwer", 7113);
CALL GeneraSequenza(2, "d3124", 5636);
CALL GeneraSequenza(2, "fhrgf", 7534);
CALL GeneraSequenza(3, "fgsrs", 5123);
CALL GeneraSequenza(4, "asdfw", 7324);
CALL GeneraSequenza(4, "dgf42", 6213);

INSERT INTO Magazzino (CodiceMagazzino, Predispozione, Lat, Lon, Altezza)
VALUES	("0yux6wari5", "elettronica", 30.81, 30.1, 4),
		("gu7i6n87kz", "elettronica", 31.01, 29.876, 5);

INSERT INTO `Area` (Larghezza, Lunghezza, Tipo, CodiceMagazzino)
VALUES	(7, 8, "Resi", "0yux6wari5"),
		(10, 12, "Ricondizionati", "0yux6wari5"),
		(11, 30, "Resi", "0yux6wari5"),
		(6, 5, "Produzione", "gu7i6n87kz"),
		(13, 6, "Ricondizionati", "gu7i6n87kz"),
		(19, 11, "Resi", "gu7i6n87kz");

INSERT INTO Sede (Nome, CAP, Provincia, Citta, Via, NumeroCivico)
VALUES	("of1pz", "52010", "AR", "Arezzo", "Cavour", "1"),
		("e77oa", "52010", "AR", "Arezzo", "Robespierre", "3");
        
-- inserimento lotto produzione
CALL InserimentoLotto(1, 1,"erjlhb3847", 1, 15,'2015-10-11','2015-11-03','2015-11-07', "rf921", NULL);
CALL InserimentoLotto(1, 1,"kbfgruy348", 1, 15,'2018-11-01','2018-12-07', NULL, "rf921", NULL);
CALL InserimentoLotto(1, 1,"regg3t34t3", 1, 15,'2017-09-05','2017-11-05', '2017-12-08', "rf921", NULL);
CALL InserimentoLotto(1, 2,"erkgnrekre", 1, 40,'2019-04-05','2019-04-05', '2017-11-06', "rf921", NULL);
CALL InserimentoLotto(1, 3,"3246ou7t3t", 1, 30,'2018-09-11','2018-11-23', NULL, "2dy82", NULL);
CALL InserimentoLotto(1, 4,"3497try344", 2, 10,'2016-10-11','2016-06-02','2016-07-24', "rf921", NULL);
CALL InserimentoLotto(1, 5,"4387t8trf4", 1, 50,'2018-10-11','2018-08-13','2018-09-17', "iuy43", NULL);
CALL InserimentoLotto(1, 6,"eouth4837h", 2, 10,'2018-10-11','2018-08-11', NULL, "g7t87", NULL);
CALL InserimentoLotto(1, 7,"45yutnegew", 2, 10,'2018-10-11','2019-01-12','2019-04-10', "iuy43", NULL);
CALL InserimentoLotto(1, 1,"erk312ekre", 1, 45,'2019-05-10','2019-06-15', '2019-06-10', "agwer", NULL);
CALL InserimentoLotto(5, 2,"erk1fhr1re", 1, 57,'2019-04-05','2019-07-05', '2019-12-12', "d3124", NULL);
CALL InserimentoLotto(5, 2,"63r411ekre", 1, 49,'2019-11-12','2019-12-18', '2019-12-17', "fhrgf", NULL);
CALL InserimentoLotto(7, 2,"ejthe6kr84", 1, 69,'2019-12-17','2019-04-05', '2019-11-06', "fgsrs", NULL);
CALL InserimentoLotto(8, 2,"sgg6546kre", 1, 420,'2019-03-15','2019-11-05', '2019-11-14', "asdfw", NULL);
CALL InserimentoLotto(8, 2,"gsda32541e", 1, 367,'2019-01-25','2019-04-05', '2019-11-06', "dgf42", NULL);
-- inserimento lotto ricondizionati
CALL InserimentoLotto(0, 1, "h4i324ih32", 1, 26, NULL, NULL, NULL, NULL, '2019-04-10');
CALL InserimentoLotto(0, 2, "erkgbi3434", 2, 26, NULL, NULL, NULL, NULL, '2014-06-01');
CALL InserimentoLotto(0, 7, "34tiu3h4ip", 1, 26, NULL, NULL, NULL, NULL, '2019-05-21');
CALL InserimentoLotto(0, 4, "o234ru9823", 2, 26, NULL, NULL, NULL, NULL, '2019-07-17');
CALL InserimentoLotto(0, 6, "34ot9328r4", 1, 26, NULL, NULL, NULL, NULL, '2019-08-11');

UPDATE Lotto 
SET AreaId = 4,
	X = 1,
    Y = 1,
    Z = 1,
	DataInizio = CURRENT_DATE() - INTERVAL 10 DAY,
    DataFine = CURRENT_DATE() - INTERVAL 5 DAY
WHERE CodiceLotto = "erjlhb3847";
UPDATE Lotto
SET AreaId = 4,
	X = 1,
    Y = 2,
    Z = 1,
    DataInizio = CURRENT_DATE() - INTERVAL 5 DAY,
    DataFine = NULL
WHERE CodiceLotto = "3246ou7t3t";
UPDATE Lotto
SET AreaId = 4,
	X = 1,
    Y = 2,
    Z = 1,
	DataInizio = CURRENT_DATE() - INTERVAL 5 DAY,
    DataFine = NULL
WHERE CodiceLotto = "eouth4837h";

UPDATE Lotto
SET AreaId = 2,
	X = 1,
    Y = 1,
    Z = 1,
	DataInizio = CURRENT_DATE() - INTERVAL 5 DAY,
    DataFine = NULL
WHERE CodiceLotto = "h4i324ih32";
UPDATE Lotto
SET AreaId = 5,
	X = 1,
    Y = 1,
    Z = 1,
	DataInizio = CURRENT_DATE() - INTERVAL 5 DAY,
    DataFine = NULL
WHERE CodiceLotto = "o234ru9823";

INSERT INTO UnitaPersa (CodiceLotto, StazioneId, Numero)
VALUES	("erjlhb3847",1,18),
		("erjlhb3847",2,67),
        ("3497try344",3,14),
        ("3246ou7t3t",4,187),
        ("3497try344",5,49),
        ("ejthe6kr84",7,42),
        ("erkgnrekre",2,29),
        ("regg3t34t3",1,49),
        ("gsda32541e",8,32),
        ("45yutnegew",6,31),
        ("eouth4837h",4,23),
        ("4387t8trf4",6,96);        
        
INSERT INTO Documento (Tipologia, Numero, Scadenza, Ente)
VALUES	("CartaIdentita", "AT21564", '2023-10-12', "stato"),
		("CartaIdentita", "AF23864", '2023-10-12', "stato"),
		("CartaIdentita", "AT39487", '2023-10-12', "stato"),
		("CartaIdentita", "AU43982", '2023-10-12', "stato"),
		("Passaporto", "23985232", '2023-10-12', "stato"),
		("Passaporto", "34877223", '2023-10-12', "stato"),
        ("Passaporto", "83299485", '2023-10-12', "stato");

INSERT INTO Cliente (CodFiscale, Nome, Cognome, DataNascita, Telefono, DocId)
VALUES	("AB2143J28Y", "Iacopo", "Canetta", '2000-03-11',"3527122877", 1),
		("AB2143J28Y", "Ragnar", "Lothbrok", '2000-03-11',"3527122877", 2),
        ("AB2143J28Y", "Walter", "White", '2000-03-11',"3527122877", 3),
        ("AB2143J28Y", "Peter", "Griffin", '2000-03-11',"3527122877", 4),
        ("AB2143J28Y", "Glenn", "Quagmire", '2000-03-11',"3527122877", 5),
        ("AB2143J28Y", "Spongebob", "SquarePants", '2000-03-11',"3527122877", 6),
		("AB2143J28Y", "Jim", "Helpert", '2000-03-11',"3527122877", 7);


INSERT INTO Indirizzo (CAP, Provincia, Citta, Via, NumeroCivico, Lat, Lon)
VALUES	(00100, "RO", "Roma", "Via Roma", 1, 41.761130, 12.706870),
		(00101, "PI", "Pisa", "Via Cavour", 32, 43.716844, 10.403739),
		(00102, "BO", "Bologna", "Via dal vento", 45, 41.06130, 12.980030),
		(00103, "NA", "Napoli", "Via vai", 69, 40.856935, 14.261079),
		(00104, "PI", "Orciano", "Via blaze it", 420, 43.494585, 10.509641),
		(00105, "MI", "Milano", "Via dei dragoni", 1337, 45.463615, 9.191627),
		(52011, "AR", "Bibbiena", "Via G. Borghi", 52, 43.694181, 11.817514),
		(86039, "CB", "Termoli", "Via montacastello", 1, 42.004181, 14.996591);

CALL creaAccount("A-Hey", "4n3f343209rj", "Ma secondo voi la passo analisi?", "No", 1);
CALL creaAccount("FiglioDiOdino", "54òtu4398", "Lo vuoi un chinotto", "dipende", 2);
CALL creaAccount("Heisemberg", "342587tr432", "Who is the one who knock?", "Me", 3);
CALL creaAccount("Madonna", "ewfnt4378", "La vuoi un po' di metedrina?", "Certo", 4);

INSERT INTO Disponibile (AccountId, IndirizzoId)
VALUES	(1, 1),
		(2, 2),
		(2, 3),
		(3, 4),
		(3, 6),
		(4, 5);

-- ordino i prodotti
CALL aggiungiProdotto(1,9,0);
CALL aggiungiProdotto(3,3,0);
CALL EseguiOrdine("uy2g34ru2g", CURRENT_DATE(), CURRENT_TIME(), 1, 365, 1);

CALL aggiungiProdotto(4,3,0);
CALL aggiungiProdotto(5,7,0);
CALL EseguiOrdine("34t7613848", CURRENT_DATE(), CURRENT_TIME(), 2, 365, 2);

CALL aggiungiProdotto(1,6,0);
CALL aggiungiProdotto(6,7,0);
CALL EseguiOrdine("t43hg76476", CURRENT_DATE(), CURRENT_TIME(), 3, 365, 1);

CALL aggiungiProdotto(2,3,0);
CALL aggiungiProdotto(4,6,0);
CALL aggiungiProdotto(7,4,0);
CALL EseguiOrdine("34o87t8342", CURRENT_DATE(), CURRENT_TIME(), 4, 365, 5);

INSERT INTO Esaminato (CodiceTest, Seriale, Passato, `Data`)
VALUES 	("uwvev9wfj1", GeneraSeriale(1), 1, '2020-11-03'),
		("87436r8faw", GeneraSeriale(5), 0, '2020-11-03'),
        ("wkcxfhr513", GeneraSeriale(7), 1, '2020-11-03'),
        ("uwvev9wfj1", GeneraSeriale(2), 1, '2020-11-03'),
        ("uwvev9wfj1", GeneraSeriale(4), 1, '2020-11-03');

INSERT INTO Hub (Nome, Lat, Lon)
VALUES	("mwr0t", 12.3, 15.36),
		("3n2id", 13.1, 124.33),
		("uc7z3", 14.3, 13.32),
		("jjiaj", 15.1, 32.3),
		("fxoy3", 112.5, 22.3),
		("49e82", 132.4, 42.3),
		("1ddir", 162.1, 52.3);

INSERT INTO Spedizione (CodiceSpedizione, DataPrevista, Stato, DataEffettiva, CodiceOrdine)
VALUES 	("wfn3wejfgi",'2021-10-15','Consegnata', '2021-10-19', "uy2g34ru2g"),
		("8734y87332",'2021-11-12','In transito', NULL, "34t7613848"),
        ("43298yr423",'2021-09-11','Consegnata', '2021-10-12', "t43hg76476"),
        ("32409i4u3h",'2021-07-12','Spedita', NULL, "34o87t8342");
        
INSERT INTO Presente (CodiceSpedizione, HubId, `Data`)
VALUES	("wfn3wejfgi", 1, '2021-10-15'),
		("wfn3wejfgi", 4, '2021-10-17'),
        ("8734y87332", 2, '2021-11-13'),
        ("8734y87332", 3, '2021-11-15'),
        ("8734y87332", 6, '2021-11-17'),
        ("43298yr423", 1, '2021-09-15'),
        ("43298yr423", 2, '2021-10-01'),
        ("43298yr423", 3, '2021-10-04');

INSERT INTO Recensione (Voto, Commento, Seriale)
VALUES 	(1,"bello belo", GeneraSeriale(1)),
		(2,"bello belo, ma un po' rotto", GeneraSeriale(3)),
        (3,"funziona ma non si accende", GeneraSeriale(3)),
        (2,"si accende ma non funziona", GeneraSeriale(3)),
        (1,"fake non salite sul telefono non funziona come bilancia", GeneraSeriale(3)),
        (9,"compro le cose per sentirmi meglio xoxo", GeneraSeriale(7));

INSERT INTO MotivazioneReso (CodiceMotivazione, Nome, Descrizione)
VALUES	("aewc7zwed0", "Guasto Batteria", NULL),
		("tc7zd0fxhf", "non so", NULL),
		("liawq6y6e6", "e' esploso", NULL),
		("zi4hz4j5rn", "malfunzionante", NULL),
		("q0yhjhms8j", "meh", NULL),
		("00gtrv8sr6", "e' troppo piccolo", NULL);

-- sono solo sul primo ordine il che non so se e' un male??
INSERT INTO Reso (CodiceReso, DataInizio, DataFine, X, Y, Z, Seriale, CodiceMotivazione, AreaId)
VALUES	("bh9n3kjyaj", '2020-10-02', NULL, 1, 1, 1, GeneraSeriale(1), "aewc7zwed0", 3),
		("1kg4ymu4ni", '2020-11-19', NULL, 1, 1, 2, GeneraSeriale(2), "liawq6y6e6", 1),
		("sf956zbj1e", '2020-12-02', NULL, 1, 1, 1, GeneraSeriale(7), "zi4hz4j5rn", 1),
		("61nvlialp9", NULL, NULL, NULL, NULL, NULL, GeneraSeriale(1), "zi4hz4j5rn", NULL);

INSERT INTO Garanzia (CodiceGaranzia, Durata, Costo)
VALUES	("8xsxsy3n5e", 12, 0),
		("beeim7idrc", 12, 300),
		("i097n08urp", 3, 40),
		("linol6xlmg", 4, 70);

INSERT INTO Applicabile (ModelloId, CodiceGaranzia)
VALUES	(1, "8xsxsy3n5e"),
		(2, "8xsxsy3n5e"),
		(3, "8xsxsy3n5e"),
		(4, "8xsxsy3n5e"),
		(1, "beeim7idrc"),
		(3, "beeim7idrc"),
		(4, "beeim7idrc"),
		(2, "i097n08urp");
        
INSERT INTO Coperto (CodiceGaranzia, CodiceGuasto)
VALUES	("8xsxsy3n5e", "8ypvc1wejp"),
		("8xsxsy3n5e", "a74m19zwjt"),
		("8xsxsy3n5e", "j82lftun4x"),
		("8xsxsy3n5e", "m4lcpopbym"),
		("8xsxsy3n5e", "08h2fcfrhg"),
		("beeim7idrc", "8ypvc1wejp"),
		("beeim7idrc", "a74m19zwjt"),
		("beeim7idrc", "j82lftun4x"),
		("beeim7idrc", "m4lcpopbym"),
		("beeim7idrc", "08h2fcfrhg"),
		("i097n08urp", "8ypvc1wejp"),
		("i097n08urp", "a74m19zwjt"),
		("i097n08urp", "j82lftun4x"),
		("linol6xlmg", "8ypvc1wejp"),
		("linol6xlmg", "a74m19zwjt"),
		("linol6xlmg", "08h2fcfrhg");

INSERT INTO Errore (CodiceErrore, CodiceGuasto, ModelloId)
VALUES	("mzbuli696p", "8ypvc1wejp", 1),
		("40an9k7wp7", "m4lcpopbym", 1),
		("ggw2p42k01", "08h2fcfrhg", 1),
		("bqmnw2thun", "a74m19zwjt", 2),
		("s0eagclcbf", "j82lftun4x", 2),
		("omb8615iey", "08h2fcfrhg", 2),
		("jt1vhmh6pc", "8ypvc1wejp", 3),
		("id9m7tg5y4", "m4lcpopbym", 3),
		("ji9eqv5vs1", "08h2fcfrhg", 3),
		("1oa0aeszwb", "8ypvc1wejp", 4),
		("lmyoz5c9l2", "m4lcpopbym", 4);
        
INSERT INTO Corrisposto (CodiceErrore, CodiceRimedio)
VALUES	("mzbuli696p", "jjrdi68ku0"),
		("40an9k7wp7", "qq1cmyxnju"),
		("ggw2p42k01", "sydp5phk2p"),
		("bqmnw2thun", "7v944vhmvw"),
		("s0eagclcbf", "famew7p1qy"),
		("omb8615iey", "83jsavgbj3"),
		("jt1vhmh6pc", "yxsfc5r7j2"),
		("id9m7tg5y4", "qk2wpsm039"),
		("ji9eqv5vs1", "ar4dsemp4h"),
		("1oa0aeszwb", "pfd39rrhc3"),
		("lmyoz5c9l2", "osqzhwawds");

INSERT INTO Richiesta (Ticket, Domicilio, `Data`, Seriale)
VALUES 	("34rgfqjhge", 0, '2020-10-09', GeneraSeriale(1)),
		("3452uth35u", 0, '2019-11-19', GeneraSeriale(1)),
        ("ergqge34io", 0, '2018-10-14', GeneraSeriale(2)),
        ("ergeqgqegq", 0, '2019-10-15', GeneraSeriale(2)),
        ("11ouiht483", 0, '2020-09-18', GeneraSeriale(3)),
        ("4otuy4g3t4", 0, '2020-03-11', GeneraSeriale(3)),
        ("oeirjgt984", 0, '2020-02-02', GeneraSeriale(7)),
        ("reoig8i3ut", 0, '2020-11-17', GeneraSeriale(7));
        
INSERT INTO Rotto (CodiceGuasto, Ticket)
VALUES 	("8ypvc1wejp", "34rgfqjhge"),
		("j82lftun4x", "34rgfqjhge"),
        ("m4lcpopbym", "34rgfqjhge"),
        ("m4lcpopbym", "3452uth35u"),
        ("8ypvc1wejp", "3452uth35u"),
        ("08h2fcfrhg", "11ouiht483"),
        ("m4lcpopbym", "11ouiht483"),
        ("a74m19zwjt", "11ouiht483"),
        ("m4lcpopbym", "4otuy4g3t4"),
        ("m4lcpopbym", "oeirjgt984"),
        ("m4lcpopbym", "reoig8i3ut");
		
INSERT INTO Preventivo (Prezzo, Accettato, Ticket)
VALUES 	(300, 1, "34rgfqjhge"),
		(500, 0, "3452uth35u"),
        (700, 1, "ergqge34io"),
        (800, 1, "oeirjgt984"),
        (900, 1, "reoig8i3ut"),
        (900, 1, "11ouiht483");

INSERT INTO CentroAssistenza (Nome, lat, lon)
VALUES	("aqhwo", 45.465843, 9.154728),
		("ir0kq", 41.882386, 12.509899),
		("1ycv2", 40.890191, 14.261545);

INSERT INTO Tecnico (CodFiscale, Nome, Cognome, StipendioOrario, CentroAssId)
VALUES	("GZZVZR98T53I997A", "Kenneth", "Caselli", 8.4, 1),
		("PFVVHR81H06E163M", "Jennifer", "Aniston", 7.5, 1),
        ("CDSSKD27P17D925L", "Jenna", "Fisher", 9.9, 1),
        ("NHQFMP80P70B352P", "Nathan", "Drake", 10.2, 2),
        ("RLRJFG39H44F268G", "Cole", "MacGrath", 8.5, 2),
        ("QBNSRG94R26C115V", "Sergio", "Mattarella", 7.9, 2),
        ("THFXBN89S16I433X", "Lisa", "Su", 10.2, 2),
        ("VJHKPR66T19L999D", "Jen-Hsun", "Huang", 6.5, 3),
        ("QCLNVC70M50D218C", "Linus", "Sebastian", 9.9, 3),
        ("RXZGML64D25Z602T", "Nicola", "Palmieri", 1.9, 3);

-- inserisco gli interventi che hanno un preventivo, in uno scenario reale questo sarebbe il compito dell'utente
CALL aggiornaTecniciDisponibili(CURRENT_DATE + INTERVAL 1 DAY,CURRENT_DATE + INTERVAL 7 DAY);
CALL inserisciInterventi(); -- random di solito sceglierebbe l'utente

-- assegno i tecnici agli interventi, in uno scenario reale questo viene eseguito da un event ogni settimana
CALL AssegnaTecnici();

delete from ordinesostituzione;
INSERT INTO OrdineSostituzione(CodiceOrdineSos, DataOrdine, DataPrevistaConsegna, DataEffettivaConsegna, InterventoId)
VALUES ("342iur23iu", CURRENT_DATE(),CURRENT_DATE() + INTERVAL 10 DAY , NULL, 1); 

UPDATE OrdineSostituzione O
SET O.DataEffettivaConsegna = CURRENT_DATE() + INTERVAL 10 DAY
WHERE O.CodiceOrdineSos = "342iur23iu";
CALL CreaInterventiSos(); -- questa in uno scenario reale viene chiamata da un evento ogni settimana

INSERT INTO Compreso (CodiceOrdineSos, CodiceParte)
VALUES 	("342iur23iu", "0e07trrrtg"), -- A
		("342iur23iu", "au0fhxphnj"), -- B
        ("342iur23iu", "qkqrr83kkp"); -- C

-- inserire ricevuta
INSERT INTO Ricevuta (CodiceRicevuta, ModalitaPagamento, Ticket)
VALUES 	("23ugr328ab",'Contanti',"34rgfqjhge"),
		("324tgvu42u",'POS',"4otuy4g3t4");
        
-- i valori di sostituita vengono aggiunti dal trigger che mantiene la ridondanza

-- popolamento entità CBR

INSERT INTO Rimedio (CodiceRimedio, Descrizione)
VALUES	("efuRAMinst", "installa piu' ram"),
		("dsCHARGERa", "cambia il carica batterie"),
        ("BATTjeiwfe", "cambia batteria"),
        ("OSbjewhfja", "aggiorna l'os"),
        ("AVIRUShjwe", "installa un antivirus"),
        ("SCOTCHoefw", "metti lo scotch nella webcam"),
        ("PRESTkfewl", "attiva modalità prestazioni");

-- Inserimenti Necessari a testare la Data Analytics
INSERT INTO Sintomo(Nome, Descrizione)
VALUES 	("A", "il dispositivo va lento"),
		("B", "chrome si incarta"),
        ("C", "le app in background non rimangono aperte"),
        ("D", "il dispositivo si blocca"),
        ("E", "surriscaldamento"),
        ("F", "si scarica anche se lo carico"),
        ("G", "la batteria non è mai completamente carica"),
        ("H", "si scarica velocemente"),
        ("I", "un'app non è più supportata"),
        ("J", "problemi di virus"),
        ("K", "il dispositivo si blocca"),
        ("L", "ho perso tutti i dati"),
        ("M", "la webcam mi riprende");

INSERT INTO Caso (ModelloId)
VALUES 	(1),
		(1),
        (1),
        (1);

INSERT INTO Causa (CasoId, SintomoId)
VALUES	(1,7),
        (1,1),
        (1,2),
        (2,7),
        (2,8),
        (2,9),
        (3,13),
        (3,10),
        (4, 3);
        
INSERT INTO Cura (CodiceRimedio, CasoId)
VALUES	("efuRAMinst",1),
		("OSbjewhfja", 1),
        ("BATTjeiwfe", 2),
        ("AVIRUShjwe", 3),
        ("efuRAMinst", 4);

SELECT TIMEDIFF(CURRENT_TIME(),@timer ) as 'Success, stopwatch:';