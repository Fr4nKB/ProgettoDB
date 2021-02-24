USE edevice;

SET @timer = CURRENT_TIME();
/*
INDICE OPERAZIONI
	Operazioni richieste:
		CalcolaRicevuta
        AnalisiSpazioMagazzino
        InterventoSos
		InserisciModello	
		CreaAccount	
		Ordina	
		AssegnaOperatore	
		GeneraSequenza	
		InserimentoLotto	
		AssegnaTecnici	
		TecniciDisponibili	
		AnalisiVendite	
        GestioneResi	
	Aggiornamento ridondanze:
		AggiornaQuantitaLotto	
		AggiornaSostituita	
		InserisciPrezzoProduzione	
    Funzioni per simulare inserimenti dell'utente:
		GeneraSeriale	
		InserisciInterventi

INDICE TRIGGERS
		ControllaVariante
		AggiornaStatoOrdini
		ControllaIndirizzo
		ControllaDocumento
		ControllaRotazione
		ControllaMotivazioneReso
		ControllaStatoOrdine
*/

/*
	CalcolaRicevuta
*/
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS CalcoloRicevuta;
DELIMITER $$
CREATE FUNCTION CalcoloRicevuta (_richiestaId VARCHAR(50))
RETURNS DOUBLE NOT DETERMINISTIC
BEGIN
    DECLARE finito INT DEFAULT 0;
    DECLARE ScontoGaranzia DOUBLE;
    DECLARE costo DOUBLE;
    DECLARE _seriale INT;
    DECLARE dataRichiesta DATE;
    -- prendo il seriale dell'unita su cui è stata fatta la richiesta
    SET _seriale = (
		SELECT U.Seriale
        FROM Richiesta R
			INNER JOIN Unita U ON R.Seriale = U.Seriale
        WHERE R.Ticket = _richiestaId
    );
    -- prendo la data in cui è stata effettuata questa richiesta
    SET DataRichiesta = (SELECT R.Data FROM Richiesta R WHERE R.Ticket = _richiestaId);
    -- se ho fatto una sostituzione meno di sei mesi fa in una richiesta precedente l'assistenza fisica è gratis
    IF EXISTS ( 
		SELECT 1 
		FROM Sostituita S
			INNER JOIN Richiesta R ON R.Ticket = S.Ticket
        WHERE R.Seriale = _seriale 
		AND S.Data + INTERVAL 6 MONTH  >= DataRichiesta
        AND R.Data < DataRichiesta
	) THEN
        RETURN 0;
	END IF;
    -- prendo il costo degli ordini di parti sostituite da meno di 12 mesi
    SET costo = (
		SELECT IFNULL(SUM(P.PrezzoProduzione),0)
        FROM OrdineSostituzione OS
			INNER JOIN Compreso C ON C.CodiceOrdineSos = OS.CodiceOrdineSos
            INNER JOIN Intervento I ON I.InterventoId = OS.InterventoId
			INNER JOIN Parte P ON C.CodiceParte = P.CodiceParte
		WHERE I.Ticket = _richiestaId 
			AND NOT EXISTS ( 
				SELECT 1
				FROM Sostituita S1
					INNER JOIN Parte P1 ON S1.CodiceParte = P1.CodiceParte
                    INNER JOIN Richiesta R1 ON R1.Ticket = S1.Ticket
				WHERE R1.Seriale = _seriale 
					AND P1.CodiceParte = P.CodiceParte 
					AND S1.Data + INTERVAL 12 MONTH  >= DataRichiesta AND R1.Data < DataRichiesta -- la sostituzione di parti sostituite (in richieste avvenute prima di questa) da meno di 12 mesi è gratis
				)
    );
    -- sommo il costo dello stipendio dei tecnici moltiplicato per le ore in cui hanno lavorato
    SET costo = costo + (
		SELECT IFNULL(SUM(I.Durata * T.StipendioOrario),0)
		FROM Intervento I
			INNER JOIN Tecnico T ON T.Tecnicoid = I.Tecnicoid
		WHERE I.Ticket = _richiestaId
	);
    -- percentuale di sconto in base ai guasti coperti dalla garanzia
    SET ScontoGaranzia = (
		SELECT IFNULL(COUNT( DISTINCT GA.CodiceGuasto) , 0) -- numero guasti su cui ho fatto una richiesta che hanno garanzia
		FROM Unita U 
			INNER JOIN Applicato A ON A.Seriale = U.Seriale 
			INNER JOIN Garanzia G ON G.CodiceGaranzia = A.CodiceGaranzia
				AND (A.Data + INTERVAL G.Durata MONTH) >= DataRichiesta
			INNER JOIN Coperto C ON C.CodiceGaranzia  = G.CodiceGaranzia 
			INNER JOIN Guasto GA ON GA.CodiceGuasto = C.CodiceGuasto
			INNER JOIN Rotto R ON GA.CodiceGuasto = R.CodiceGuasto
		WHERE U.Seriale = _seriale AND R.Ticket = _richiestaId
    ) / (	
		SELECT COUNT( DISTINCT GA.CodiceGuasto )	-- numero guasti su cui ho fatto una richiesta
        FROM Guasto GA
			INNER JOIN Rotto R ON GA.CodiceGuasto = R.CodiceGuasto
		WHERE R.Ticket = _richiestaId
    );
    RETURN ROUND(costo - (costo * ScontoGaranzia),2); -- ritorno il costo meno lo sconto dovuto alla garanzia
END $$
DELIMITER ;


/*
	AnalisiSpazioMagazzino
*/

DROP PROCEDURE IF EXISTS analisiSpazioMagazzino;
CREATE PROCEDURE analisiSpazioMagazzino()

	SELECT CodiceMagazzino, AreaId, SpazioTotale,(SpazioTotale - Lotti - Resi) as SpazioDisponibile, 100 * (Lotti + Resi) / SpazioTotale  AS `SpazioOccupato [%]`
    FROM (SELECT M.CodiceMagazzino, A.AreaId, (M.Altezza * A.Larghezza * A.Lunghezza) AS SpazioTotale, COUNT(L.CodiceLotto) AS Lotti, COUNT(CodiceReso) AS Resi
		FROM Magazzino M
			INNER JOIN Area A ON M.CodiceMagazzino = A.CodiceMagazzino
			LEFT OUTER JOIN Lotto L ON L.AreaId = A.AreaId
			LEFT OUTER JOIN Reso R ON R.AreaId = A.AreaId
		WHERE 	(R.AreaId IS NOT NULL AND (R.DataFine IS NULL OR R.DataFine > CURRENT_DATE()))
		OR		(L.AreaId IS NOT NULL AND (L.DataFine IS NULL OR L.DataFine > CURRENT_DATE()))
	GROUP BY M.CodiceMagazzino, A.AreaId) AS T;

/*
	InterventoSostituzione
*/
CREATE TABLE IF NOT EXISTS InterventiSosDaCreare_MW(
	I INT AUTO_INCREMENT,
    TicketRichiesta VARCHAR(50),
    PRIMARY KEY (I)
);

-- una volta a settimana creo gli interventi di sostituzione
DROP EVENT IF EXISTS CreaInterventiSosEvent;
CREATE EVENT CreaInterventiSosEvent
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO CALL CreaInterventiSos();

-- ogni volta in cui arriva un ordineSos aggiungo un intervento a quelli da eseguire
DROP TRIGGER IF EXISTS sostituzionePartiOrdinateUpdate;
DELIMITER $$
CREATE TRIGGER sostituzionePartiOrdinateUpdate
AFTER UPDATE ON OrdineSostituzione
FOR EACH ROW
BEGIN
    DECLARE toAdd INT DEFAULT 14; 			-- giorni in cui vedere se ci sono tecnici disponibili
	DECLARE ticketRichiesta VARCHAR(50);
    DECLARE i INT DEFAULT 0;				-- iteratore del ciclo
    DECLARE max INT DEFAULT 7;				-- numero massimo di volte in cui provo a vedere se ci sono tecnici disponibili nei toAdd giorni seguenti
    IF NEW.DataEffettivaConsegna IS NOT NULL AND OLD.DataEffettivaConsegna IS NULL THEN
        INSERT INTO InterventiSosDaCreare_MW (TicketRichiesta)
			SELECT I.Ticket
			FROM Intervento I
			WHERE I.InterventoId = NEW.InterventoId
            LIMIT 1;
    END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS CreaInterventiSos;
DELIMITER $$
CREATE PROCEDURE CreaInterventiSos()
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE _ticket VARCHAR(50) DEFAULT 0;
	DECLARE _data DATE;
    DECLARE _fascia VARCHAR(15);
    DECLARE cursore CURSOR FOR
    SELECT D.TicketRichiesta
    FROM InterventiSosDaCreare_MW D;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    -- aggiorno le date in cui i tecnici saranno disponibili in modo da creare gli interventi in quelle date
    CALL aggiornaTecniciDisponibili(CURRENT_DATE + INTERVAL 1 DAY,CURRENT_DATE + INTERVAL 7 DAY);
    OPEN cursore;
    ciclo: LOOP

        FETCH cursore INTO _ticket;
        IF finito = 1 THEN
            LEAVE ciclo;
        END IF;
        -- prendo la prima data e fascia oraria disponibile
		SELECT C.DataTecniciDisponibili_MW, C.FasciaOraria INTO _data, _fascia
        FROM TecniciDisponibili_MW C
        WHERE TecniciDisponibili <> 0
        ORDER BY C.DataTecniciDisponibili_MW
        LIMIT 1;
		
        -- decremento il numero di tecnici disponibili in quella data e fascia oraria
		UPDATE TecniciDisponibili_MW C
        SET C.TecniciDisponibili = C.TecniciDisponibili - 1 
        WHERE C.FasciaOraria = _fascia AND C.DataTecniciDisponibili_MW = _data;
        
        INSERT INTO Intervento (`Data`, FasciaOraria, Durata, TecnicoId, Ticket)
        VALUES (_data, _fascia, 3, NULL, _ticket);
        
    END LOOP;
    CLOSE cursore;
    TRUNCATE InterventiSosDaCreare_MW;
END $$
DELIMITER ;

/* 
    AssegnaOperatore
*/

DROP PROCEDURE IF EXISTS AssegnaOperatore;
DELIMITER $$
CREATE PROCEDURE AssegnaOperatore(IN _stazioneId INT)
BEGIN
	DECLARE daAssegnare INT DEFAULT 0;
    -- prendo l'operatore che svolge più velocemente le operazione eseguite in una stazione
    SET daAssegnare  = (
		with tempi as(
			SELECT TS.OperatoreId as Operatore, SUM(TS.Tempo) as SommaTempi
			FROM Operazione O
				INNER JOIN OperazioneCampione OC ON O.OpCampId = OC.OpCampId
				INNER JOIN TempoStimato TS ON TS.OpCampId = OC.OpCampId
			WHERE O.StazioneId = _stazioneId
			GROUP BY TS.OperatoreId
        )
        SELECT Operatore
        FROM tempi t
        WHERE t.SommaTempi <= ALL (
			SELECT t1.SommaTempi
            FROM tempi t1
        ) 
        LIMIT 1
    );
    -- lo assegno nella stazione richiesta
    UPDATE Stazione
    SET OperatoreId = daAssegnare
	WHERE StazioneId = _stazioneId;
END $$
DELIMITER ;

/* 
    CreaAccount
*/
DROP PROCEDURE IF EXISTS creaAccount;
DELIMITER $$
CREATE PROCEDURE creaAccount (IN _nomeUtente VARCHAR(50), IN _pswd VARCHAR(100), IN _domandaDiSicurezza VARCHAR(255), IN _risposta VARCHAR(255), IN _clienteId INT)
BEGIN
    DECLARE var BOOL;
    -- controllo il documento di identita'
	SET var = (
		SELECT D.Scadenza < CURRENT_DATE()
        FROM Cliente C
        INNER JOIN Documento D ON C.DocId = D.DocId
        WHERE C.ClienteId = _clienteId
        LIMIT 1
    );
    IF var IS NULL OR var THEN
		IF var THEN		-- se var e' true significa che il documento di identita' e' scaduto
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Errore. È necessario fornire un documento valido per creare un account.';
        ELSE	-- se var è NULL significa che il documento di identita' non esiste
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Errore. È necessario fornire un documento per creare un account.';
        END IF;
    ELSE	-- se tutto e' andato bene inserisco l'account
        INSERT INTO Account (NomeUtente, Pwd, DomandaDiSicurezza, Risposta, DataIscrizione, ClienteId)
        VALUES (_NomeUtente, _pswd, _DomandaDiSicurezza, _Risposta, CURRENT_DATE(), _clienteId);
    END IF;

END $$
DELIMITER ;

/* 
    Ordina
*/

DROP PROCEDURE IF EXISTS aggiungiProdotto;
DELIMITER $$
CREATE PROCEDURE aggiungiProdotto(IN _prodottoId INT, IN _quantita INT, IN _ricondizionato BOOL)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS Carrello_tmp(
		ind INT AUTO_INCREMENT,
		ProdottoId INT NOT NULL,
		Quantita INT NOT NULL,
		Ricondizionato BOOL,
		PRIMARY KEY (ind)
	) ENGINE = InnoDB DEFAULT CHARSET = latin1;
	-- inserisco il prodotto nel carrello
	INSERT INTO Carrello_tmp (ProdottoId, Quantita, Ricondizionato)
    VALUES (_prodottoId, _quantita, _ricondizionato);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS EseguiOrdine;
DELIMITER $$
CREATE PROCEDURE EseguiOrdine(IN _codiceOrdine VARCHAR(50), IN _data DATE, IN _ora Time, IN _accountId INT, IN _giorniMaxReso INT, IN _indirizzoId INT)
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE prodottoId INT;
    DECLARE quantita INT;
    DECLARE ricondizionato BOOL;
    DECLARE curdisponibili BOOL;
    DECLARE _processazione BOOL DEFAULT TRUE;
    -- prendo i prodotti nel carrello (nel caso in cui ci siano due prodotti uguali li raggruppo)
    DECLARE cursore CURSOR FOR(
		SELECT O.ProdottoId, SUM(O.Quantita), O.Ricondizionato
        FROM Carrello_tmp O
        GROUP BY O.ProdottoId, O.Ricondizionato
	); 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    -- inserisco l'ordine
    INSERT INTO Ordine (CodiceOrdine, `Data`, Ora, Stato, AccountId, GiorniMaxReso, IndirizzoId)
	VALUES (_codiceOrdine, _data, _ora, 'Pendente', _accountId, _giorniMaxReso, _indirizzoId);
    OPEN cursore;
    ciclo: LOOP
		FETCH cursore INTO prodottoId, quantita, ricondizionato;
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        -- ordino il prodotto controllando se tutti le unita' hanno finito la produzione
        CALL OrdinaProdotto(_codiceOrdine, prodottoId, quantita, ricondizionato, curdisponibili);
        -- se anche solo uno dei prodotti non è disponibile allora l'ordine non è in processazione
        IF NOT curdisponibili THEN
			SET _processazione = FALSE;
		END IF;
    END LOOP;
    CLOSE cursore;
	TRUNCATE Carrello_tmp;
    -- se ogni unita' ordinata era disponibile allora posso mettere l'ordine in processazione
    IF _processazione THEN
			UPDATE Ordine O
            SET Stato = 'Processazione'
			WHERE O.CodiceOrdine = _codiceOrdine;
        END IF;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS OrdinaProdotto;
DELIMITER $$
CREATE PROCEDURE OrdinaProdotto(IN _codiceOrdine VARCHAR(50), IN _prodottoId INT, IN _quantita INT, IN _ricondizionato BOOL, OUT _tuttedisponibili BOOL)
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE curSeriale INT;
    DECLARE prezzoVendita DOUBLE;
    DECLARE effQuantita INT;
    DECLARE scontoRic DOUBLE;
    DECLARE disp DATE;
    /*	
		mi ricavo le unita' relative al prodotto richiesto ordinandole in base alla data produzione, disp indica se l'unita e' disponibile,
		grazie a una window function controllo il numero totale di unita disponibili in modo da non sforare
    */
    DECLARE cursore CURSOR FOR(
		SELECT U.Seriale, IFNULL(U.ScontoRicondizionati, 0), COUNT(U.Seriale) OVER() as Quantita, IF(_ricondizionato, LR.Data, LP.DataEffettiva) as disp
        FROM Unita U
        INNER JOIN Lotto L ON L.CodiceLotto = U.CodiceLotto 
        LEFT OUTER JOIN LottoProduzione LP ON L.CodiceLotto = LP.CodiceLotto AND NOT _ricondizionato -- scelgo se prendere lotti ricondizionati in base a quello che chiede l'utente
        LEFT OUTER JOIN LottoRicondizionati LR ON L.CodiceLotto = LR.CodiceLotto AND _ricondizionato
        WHERE L.ProdottoId = _prodottoId AND U.CodiceOrdine IS NULL
        ORDER BY IF(_ricondizionato, LR.Data, IFNULL(LP.DataEffettiva, LP.DataPreventivata))
	);

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    SET _tuttedisponibili = TRUE;
    -- prezzo una volta venduta un' unita
    SET prezzoVendita = (SELECT PrezzoProduzione * CoefficienteSovraprezzo FROM Prodotto P WHERE P.ProdottoId = _prodottoId);
    OPEN cursore;
    ciclo: LOOP
		FETCH cursore INTO curSeriale, scontoRic, effQuantita, disp;
        IF finito = 1 OR NOT i < _quantita THEN
			LEAVE ciclo;
        END IF;
        -- controllo il numero di unita richieste
		IF _quantita > effQuantita THEN
			SET @tmp = CONCAT("non sono disponibili abbastanza unita per ordinare ", _quantita, "di ", _prodottoId);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = @tmp;
		END IF;
        -- disp è null nel caso in cui datafineproduzione sia null
        IF disp IS NULL THEN
			SET _tuttedisponibili = FALSE;
		END IF;
        -- aggiorno le unita, tolgo al prezzo di vendita lo scontoRicondizionati (di default è zero)
        UPDATE Unita U
        SET U.CodiceOrdine = _codiceOrdine,
			U.PrezzoVendita = prezzoVendita + (prezzoVendita * scontoRic)
        WHERE U.Seriale = curSeriale;
        SET i = i + 1;
    END LOOP;
    CLOSE cursore;
	IF i < _quantita THEN
		SET @tmp = CONCAT("non sono disponibili ", _quantita," unita con questo prodotto id: ", _prodottoId);
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = @tmp;
	END IF;
END $$
DELIMITER ;


/*
    InserisciModello
*/

DROP PROCEDURE IF EXISTS aggiungiPrecTecn;
DELIMITER $$
CREATE PROCEDURE aggiungiPrecTecn(IN _parteA VARCHAR(50), IN _parteB VARCHAR(50), IN _giunzioneId INT)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS PrecTecn_tmp(
		Id INT AUTO_INCREMENT NOT NULL,
		ParteA VARCHAR(50) NOT NULL,
		ParteB VARCHAR(50) NOT NULL,
		GiunzioneId INT,
		PRIMARY KEY (Id)
	) ENGINE = InnoDB DEFAULT CHARSET = latin1;
    
	INSERT INTO PrecTecn_tmp (ParteA, ParteB, GiunzioneId)
    VALUES (_parteA, _parteB, _giunzioneId);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InserisciModello;
DELIMITER $$
CREATE PROCEDURE InserisciModello(IN _marca VARCHAR(50), IN _nome VARCHAR(50), IN _codiceTest VARCHAR(50))
BEGIN
    DECLARE modelloId INT;
    -- creo il modello
    INSERT INTO Modello (Marca, Nome, CodiceTest)
    VALUES (_marca, _nome, _codiceTest);
    
    -- prendo l'id dell'ultimo modello inserito
    SET modelloId =  (SELECT LAST_INSERT_ID());
    
    -- inserisco le relative precedenze tecnologiche
    INSERT INTO PrecedenzaTecnologica (ParteA,ParteB, GiunzioneId, ModelloId)
    SELECT O.ParteA, O.ParteB, O.GiunzioneId, modelloId
    FROM PrecTecn_tmp O;
	TRUNCATE PrecTecn_tmp;
END $$
DELIMITER ;

/*
    InserimentoLotto
*/

DROP PROCEDURE IF EXISTS InserimentoLotto;
DELIMITER $$
CREATE PROCEDURE InserimentoLotto(IN _prod BOOL, IN _prodottoId INT, IN _codiceLotto VARCHAR(50), IN _sedeId INT, IN _quantita INT, IN _dataProduzione DATE, IN _dataPreventivata DATE, IN _dataEffettiva DATE, IN _nomeSeq VARCHAR(50), IN _data DATE)
BEGIN
    DECLARE i INT DEFAULT 0;
    INSERT INTO Lotto(CodiceLotto,ProdottoId, SedeId, Quantita)
    VALUES (_codiceLotto, _prodottoId, _sedeId, _quantita);
    IF _prod THEN
        INSERT INTO LottoProduzione(CodiceLotto, DataProduzione, DataPreventivata, DataEffettiva, SequenzaId)
        VALUES (_codiceLotto, _dataProduzione,_dataPreventivata, _dataEffettiva,(SELECT SequenzaId FROM Sequenza WHERE Nome = _nomeSeq LIMIT 1));
    ELSE
        INSERT INTO LottoRicondizionati(CodiceLotto, Data)
        VALUES (_codiceLotto, _data);
    END IF;
    ciclo: LOOP
        IF NOT i <= _quantita THEN
            LEAVE ciclo;
        END IF;
        INSERT INTO Unita (CodiceLotto)
        VALUES (_codiceLotto);
        SET i = i + 1;
    END LOOP;
END $$
DELIMITER ;

/* 
    GeneraSequenza
*/

CREATE TABLE IF NOT EXISTS  DaInserire_MW(
	Ordine INT AUTO_INCREMENT,
	PrecTecn INT,
    Operazione INT,
    parteA VARCHAR(50),
    parteB VARCHAR(50),
    PRIMARY KEY (Ordine)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP PROCEDURE IF EXISTS GeneraSequenza;
DELIMITER $$
CREATE PROCEDURE GeneraSequenza(IN _modelloId INT, IN _nome VARCHAR(50), IN _T INT)
BEGIN
    DECLARE _sequenzaId INT;
    TRUNCATE TABLE DaInserire_MW;
    -- inserisco la sequenza con il nome richiesto
    INSERT INTO Sequenza (Nome, T)
    VALUES (_nome, _T);
    -- prendo il suo id
    SET _sequenzaId = LAST_INSERT_ID();
    -- continuo ad inserire operazioni finche' ho inserito tutte le parti
    ciclo:LOOP
        IF NOT caricaDaInserire_MW(_modelloId) THEN
            LEAVE ciclo;
        END IF;
    END LOOP;
    -- controllo il numero di parti da inserire
    SET @nPartiDaInserire = (
        SELECT COUNT(DISTINCT P.CodiceParte)
        FROM DaInserire_MW D
        INNER JOIN Parte P ON D.ParteA = P.CodiceParte OR D.ParteB = P.CodiceParte
    );
    -- controllo qual'era il numero effettivo di parti da inserire
    SET @totParti = (
        SELECT COUNT(DISTINCT P.CodiceParte) 
        FROM PrecedenzaTecnologica PT
        INNER JOIN Parte P ON PT.ParteA = P.CodiceParte OR PT.ParteB = P.CodiceParte
        WHERE PT.ModelloId = _modelloId
    );
    -- se non combaciano significa che le operazioni implementate non bastano per soddisfare le precedenze tecnologiche
    IF  @nPartiDaInserire <>  @totParti THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "problemi con il numero di operazioni implementate";
    END IF;
	-- inserisco dentro insieme le operazioni ordinate in base alla PrecTec
    INSERT INTO Insieme (Ordine, SequenzaId,OperazioneId)
    SELECT D.Ordine, _sequenzaId, D.Operazione
    FROM DaInserire_MW D;
END $$
DELIMITER ;


SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS caricaDaInserire_MW;
DELIMITER $$
CREATE FUNCTION caricaDaInserire_MW (_modelloId INT)
RETURNS BOOL NOT DETERMINISTIC
BEGIN
	DECLARE inserito BOOL DEFAULT false; -- se non modifico inserito significa che ho finito di inserire
    DECLARE finito INT DEFAULT 0;
    
    DECLARE precTecn INT;
    DECLARE operazione INT;
    DECLARE parteA VARCHAR(50);
    DECLARE parteB VARCHAR(50);
    DECLARE FacciaId INT;
    -- prendo le precedenze tecnologiche ordinandole randomicamente
    DECLARE cursore CURSOR FOR (
		SELECT PT.PrecTecId, O.OperazioneId, PT.ParteA, PT.ParteB
        FROM PrecedenzaTecnologica PT
        INNER JOIN Operazione O ON PT.PrecTecId = O.PrecTecId
        WHERE PT.ModelloId = _modelloId
		ORDER BY RAND()
	);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET Finito = 1;
    OPEN cursore;
	ciclo: LOOP
		FETCH cursore INTO precTecn, operazione, parteA, parteB;
		IF finito = 1
			THEN LEAVE ciclo;
		END IF;
		IF EXISTS ( -- se la precedenza tecnologica è gia in quelli da inserire
				SELECT 1 
				FROM DaInserire_MW D2 
				WHERE D2.ParteB = parteB
            ) OR NOT EXISTS ( -- o non ci sono precedenze tecnologiche che permettono di aggiungerla
				SELECT 1 
				FROM PrecedenzaTecnologica PT 
                WHERE PT.PrecTecId IN (SELECT D1.PrecTecn FROM DaInserire_MW D1)
				AND PT.ParteB = parteA
			) AND EXISTS ( -- e non è una prima (se non ci sono precedenze tecnologiche precedenti ma questa è la prima va comunque aggiunta)
				SELECT 1
				FROM PrecedenzaTecnologica PT1
				WHERE parteA = PT1.ParteB AND PT1.ModelloId = _modelloId
            )THEN
			ITERATE ciclo; -- controllo la prossima
		END IF;
        -- altrimenti ((se è un nodo a inizio del grafo oppure se c'è già un nodo precedente) e non esiste già la inserisco)
        INSERT INTO DaInserire_MW (PrecTecn, Operazione, parteA, parteB)
        VALUES (precTecn, operazione, parteA, parteB);
        SET inserito = TRUE;
	END LOOP;
	CLOSE cursore;
	RETURN inserito;
END $$
DELIMITER ;

-- test
/*
SELECT I.SequenzaId, I.Ordine, A.Nome, B.Nome
FROM Insieme I
INNER JOIN Operazione O ON I.OperazioneId = O.OperazioneId
INNER JOIN PrecedenzaTecnologica PC ON O.PrecTecId = PC.PrecTecId
INNER JOIN Parte A ON PC.ParteA = A.CodiceParte
INNER JOIN Parte B ON PC.ParteB = B.CodiceParte
WHERE I.SequenzaId = 1
ORDER BY I.Ordine;
*/

/*
    AssegnaTecnici
*/

DROP PROCEDURE IF EXISTS AssegnaTecnici;
DELIMITER $$
CREATE PROCEDURE AssegnaTecnici ()
BEGIN
	CALL load_Distanze();
	CALL updateInterventi('Mattina');
    CALL updateInterventi('Pomeriggio');
    CALL updateInterventi('Sera');
END $$
DELIMITER ;

-- evento che richiama la procedura
DROP EVENT IF EXISTS aggiornaDistanze_MW;
CREATE EVENT aggiornaDistanze_MW
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO CALL AssegnaTecnici();

-- contiene le distanze tecnico-intervento
CREATE TABLE IF NOT EXISTS Distanze_MW (
	InterventoId INT NOT NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    TecnicoId INT NOT NULL,
    Dist DOUBLE NOT NULL,
    DataIntervento DATE,
    FasciaOraria VARCHAR(50)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- contiene i tecnici scelti per un certo intervento
CREATE TABLE IF NOT EXISTS TecniciScelti_MW (
    TecnicoId INT NOT NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    DataIntervento DATE
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- funzione per calcolare la distanza tra due coordinate
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS CalcoloDistanza;
DELIMITER $$
CREATE FUNCTION CalcoloDistanza (latA DOUBLE, lonA DOUBLE, latB DOUBLE, lonB DOUBLE)
RETURNS DOUBLE NOT DETERMINISTIC
BEGIN
        DECLARE Raggio DOUBLE DEFAULT 6371;
        DECLARE PiGreco DOUBLE DEFAULT 3.1415927;
        DECLARE lat_a DOUBLE;
        DECLARE lat_b DOUBLE;
        DECLARE lon_a DOUBLE;
        DECLARE lon_b DOUBLE;
        DECLARE Phi DOUBLE;
        DECLARE p DOUBLE;
        DECLARE dist DOUBLE;
        SET lat_a = pigreco * latA / 180;
        SET lat_b = pigreco * latB / 180;
        SET lon_a = pigreco * lonA / 180;
        SET lon_b = pigreco * lonB / 180;
        SET Phi = ABS(lon_a - lon_b);
        SET p = acos(sin(lat_b) * sin(lat_a) + cos(lat_b) * cos(lat_a) * cos(Phi));
        SET Dist = p * Raggio;
        RETURN Dist;
        
END $$
DELIMITER ;

-- stored procedure che calcola la distanza iniziale tecnico-intervento
DROP PROCEDURE IF EXISTS load_Distanze;
DELIMITER $$
CREATE PROCEDURE load_Distanze()
BEGIN

	DECLARE finito INT DEFAULT 0;
    DECLARE inter INT DEFAULT 0;
    DECLARE intlat DOUBLE DEFAULT 0;
    DECLARE intlon DOUBLE DEFAULT 0;
    DECLARE tecn INT DEFAULT 0;
    DECLARE teclat INT DEFAULT 0;
    DECLARE teclon INT DEFAULT 0;
    DECLARE Idata DATE;
    DECLARE foraria VARCHAR(50);
    DECLARE cursore CURSOR FOR
		SELECT I.InterventoId, Ind.lat, Ind.lon, T.TecnicoId, C.lat, C.lon, I.Data, I.FasciaOraria
		FROM Tecnico T	
			INNER JOIN CentroAssistenza C ON T.CentroAssId = C.CentroAssId,
			Intervento I
			INNER JOIN Richiesta R ON R.Ticket = I.Ticket
			INNER JOIN Unita U ON R.Seriale = U.Seriale
			INNER JOIN Ordine O ON O.CodiceOrdine = U.CodiceOrdine
			INNER JOIN Indirizzo Ind ON Ind.IndirizzoId = O.IndirizzoId
		 WHERE I.`Data` > CURRENT_DATE() AND T.CentroAssId IS NOT NULL; -- considero solo tecnici attualmente impiegati in un centro di Assistenza
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO inter, intlat, intlon, tecn, teclat, teclon, Idata, foraria;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        /*
        per ogni tecnico inserisco dentro Distanze_MW:
			lat e lon del prossimo intervento (ipotetico)
			la relativa distanza
            poi data e fascia oraria
        */
        INSERT INTO Distanze_MW
        VALUES (inter, intlat, intlon, tecn, CalcoloDistanza(intlat,intlon,teclat,teclon), Idata, foraria);
        
    END LOOP;
    CLOSE cursore;
    
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS updateInterventi;
DELIMITER $$
CREATE PROCEDURE updateInterventi (IN _foraria VARCHAR(15))
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE inter INT DEFAULT 0;
    DECLARE intlat DOUBLE DEFAULT 0;
    DECLARE intlon DOUBLE DEFAULT 0;
	DECLARE tecn INT DEFAULT 0;
    DECLARE Ddata DATE;
	DECLARE lastInt INT DEFAULT -1;
	
    -- prendo tutti gli interventi da assegnare di questa fascia oraria
    DECLARE cursore CURSOR FOR
    SELECT D.InterventoId, D.TecnicoId, D.Lat, D.Lon, D.DataIntervento
    FROM Distanze_MW D
	WHERE D.FasciaOraria = _foraria
    ORDER BY D.InterventoId, D.Dist;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
	OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO inter, tecn, intlat, intlon, Ddata;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        
        -- se questo è lo stesso intervento di lastInt significa che gli ho già assegnato qualcuno (cambio lastInt ogni volta in cui assegno qualcuno)
        -- non posso fare il group by perchè altrimenti un tecnico potrebbe essere il migliore per due interventi e non avrei modo di controllare se l'ho già inserito
        IF inter <> lastInt THEN
			-- controllo che il tecnico non sia già stato assegnato in questa fascia oraria e data
			IF NOT EXISTS (SELECT 1 FROM TecniciScelti_MW WHERE TecnicoId = tecn AND DataIntervento = Ddata) THEN
				-- inserisco quindi l'ultimo intervento è quello corrente
				SET lastInt = inter;
                -- inserisco i tecnici dentro quelli TecniciScelti_MW, assegnandogli la posizione di dove affettuano l'intervento
                INSERT INTO TecniciScelti_MW VALUES (tecn, intlat, intlon, Ddata);
                -- assegno il tecnico all'intervento
                UPDATE Intervento
                SET TecnicoId = tecn
                WHERE InterventoId = inter;
			END IF;
		END IF;
        
    END LOOP;
    CLOSE cursore;
    -- refresho le distanze
    CALL refresh_Distanze();
    
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS refresh_Distanze;
DELIMITER $$
CREATE PROCEDURE refresh_Distanze()
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE tecn INT DEFAULT 0;
    DECLARE teclat INT DEFAULT 0;
    DECLARE teclon INT DEFAULT 0;
    DECLARE Idata DATE;
    DECLARE cursore CURSOR FOR
    SELECT TecnicoId, lat, lon, Idata
    FROM TecniciScelti_MW;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO tecn, teclat, teclon, Idata;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        -- l'ultimo luogo in cui sono stati i tecnici è l'intervento, non più il centro assistenza quindi aggiorno le posizioni
        UPDATE Distanze_MW D
        SET D.Dist = CalcoloDistanza(D.lat, D.lon, teclat, teclon)
        WHERE TecnicoId = tecn AND DataIntervento = Idata;
        
        END LOOP;
	CLOSE cursore;
    
    TRUNCATE TecniciScelti_MW;
    
END $$
DELIMITER ;

/*
    TecniciDisponibili
*/
-- MW contenente il numero di tecnici liberi per giorno e fascia oraria
CREATE TABLE IF NOT EXISTS TecniciDisponibili_MW (
	DataTecniciDisponibili_MW DATE,
    FasciaOraria VARCHAR(50),
    TecniciDisponibili INT DEFAULT 0
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- procedure che piena il calendario tra le due date che passate in ingresso (mettendo a 0 il numero di tecnici disponibili)
DROP PROCEDURE IF EXISTS pienaTecniciDisponibili_MW;
DELIMITER $$
    CREATE PROCEDURE pienaTecniciDisponibili_MW(IN dataInizio DATE,IN dataFine DATE)
    BEGIN
    DECLARE cur DATE;
    SET cur = dataInizio;
    WHILE cur <= dataFine DO
        INSERT INTO TecniciDisponibili_MW VALUES
			(cur, 'Mattina', 0),
			(cur, 'Pomeriggio', 0),
            (cur, 'Sera', 0);
        SET cur = cur + INTERVAL 1 DAY;
    END WHILE;
END $$
DELIMITER ;

-- aggiorna i momenti disponibili tra le date passate 
DROP PROCEDURE IF EXISTS aggiornaTecniciDisponibili;
DELIMITER $$
CREATE PROCEDURE aggiornaTecniciDisponibili(IN dataInizio DATE, IN dataFine DATE)
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE totTecnici INT DEFAULT 0;
    DECLARE tecniciImpiegati INT DEFAULT 0;
    DECLARE dataCorrente DATE;
    DECLARE fasciaCorrente VARCHAR(16);
    
    DECLARE cursore CURSOR FOR
    SELECT COUNT(*), I.data, I.FasciaOraria
    FROM Intervento I
    WHERE I.TecnicoId IS NOT NULL AND  I.data BETWEEN dataInizio AND dataFine 
    GROUP BY I.data, I.FasciaOraria;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    -- prendo il totale dei tecnici attualmente in servizio
    SET totTecnici = (SELECT COUNT(TecnicoId) FROM Tecnico t WHERE t.CentroAssId IS NOT NULL); -- conto tutti i tecnici attualmente impiegati
    
    TRUNCATE TecniciDisponibili_MW;
    CALL pienaTecniciDisponibili_MW(dataInizio, dataFine);
    -- di default metto il massimo
    UPDATE TecniciDisponibili_MW
    SET TecniciDisponibili = totTecnici;
    
    OPEN cursore;
    ciclo: LOOP
		FETCH cursore INTO tecniciImpiegati, dataCorrente, fasciaCorrente;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        -- ogni volta in cui dei tecnici eseguono interventi diminuisco il numero di TecniciDisponibili in quella data e fascia oraria
        UPDATE TecniciDisponibili_MW c
        SET TecniciDisponibili = totTecnici - tecniciImpiegati
        WHERE c.DataTecniciDisponibili_MW = dataCorrente AND c.FasciaOraria = fasciaCorrente;
    END LOOP;
    CLOSE cursore;
END $$
DELIMITER ;

/*
	AnalisiVendite
*/
-- Settimanalmente, alcune funzionalità di back-end confezionano dei report che analizzano le vendite e gli ordini pendenti. Tali report segnalano alla direzione quantità indicative di prodotti da produrre

CREATE TABLE IF NOT EXISTS analisivendite_mw (
	ProdottoId INT NOT NULL,
    Venduti INT NOT NULL,
    Rimanenti INT NOT NULL,
    FineScorteGG DOUBLE NOT NULL,			-- indica quanti giorni mancano a finire le scorte se si mantiene una media settimanale di vendite costante a quella attuale
    PRIMARY KEY(ProdottoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

CREATE TABLE IF NOT EXISTS analisivendite_lt (
	ID INT AUTO_INCREMENT NOT NULL,
	ProdottoId INT NOT NULL,
    PRIMARY KEY(ID)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TRIGGER IF EXISTS update_analisivendite;
DELIMITER $$
CREATE TRIGGER update_analisivendite
AFTER UPDATE ON Unita
FOR EACH ROW
BEGIN

	IF NEW.CodiceOrdine IS NOT NULL THEN
		INSERT INTO analisivendite_lt (ProdottoId)
		SELECT L.ProdottoId
		FROM Lotto L
			NATURAL JOIN Unita U
		WHERE U.Seriale = NEW.Seriale;
	END IF;
        
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS analisiVendite;
DELIMITER $$
CREATE PROCEDURE analisiVendite()
BEGIN

	DECLARE finito INT DEFAULT 0;
    DECLARE prod INT DEFAULT 0;
    DECLARE ven INT DEFAULT 0;
    DECLARE rim INT DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    SELECT LT.ProdottoId, COUNT(LT.ProdottoId) AS Tot, SUM(L.Quantita)
    FROM analisivendite_lt LT
		NATURAL JOIN Lotto L
    GROUP BY LT.ProdottoId;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO prod, ven, rim;
    
		IF finito = 1 THEN
			LEAVE ciclo;
		END IF;
    
		SET @var = rim / ven * 7;
    
		REPLACE INTO analisivendite_mw
		VALUES (prod, ven, rim, @var);

	END LOOP;
    CLOSE cursore;
END $$
DELIMITER ;

DROP EVENT IF EXISTS update_analisiVendite;
CREATE EVENT update_analisiVendite
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY -- faccio partire a mezzanotte
DO CALL analisiVendite();

/*
	GestionResi: ldgfmbedpe
*/
-- Associare ad ogni prodotto numero di unità rese e motivazioni
DROP PROCEDURE IF EXISTS gestioneResi;
DELIMITER $$
CREATE PROCEDURE gestioneResi()
BEGIN
	SELECT L.ProdottoId as Prodotto, COUNT(U.Seriale) AS NumeroUnitaRese, MR.Nome as Motivazione
    FROM MotivazioneReso MR
    INNER JOIN Reso R ON R.CodiceMotivazione = MR.CodiceMotivazione
    INNER JOIN Unita U ON R.Seriale = U.Seriale
    INNER JOIN Lotto L ON U.CodiceLotto = L.CodiceLotto
    GROUP BY L.ProdottoId, MR.CodiceMotivazione;
END $$
DELIMITER ;

/*
	AggiornaQuantitaLotto
*/

DROP TRIGGER IF EXISTS updateQuantita;
DELIMITER $$
CREATE TRIGGER updateQuantita
AFTER UPDATE ON Unita
FOR EACH ROW
BEGIN
	IF NEW.CodiceOrdine IS NOT NULL AND OLD.CodiceOrdine IS NULL THEN
		SELECT L.CodiceLotto INTO @var
		FROM Lotto L
		INNER JOIN Unita U ON L.CodiceLotto = U.CodiceLotto
		WHERE U.Seriale = NEW.Seriale;
		
		UPDATE Lotto
		SET Quantita = Quantita - 1
		WHERE CodiceLotto = @var;
	END IF;
END $$
DELIMITER ;

/*
	AggiornaSostitute
*/

DROP TRIGGER IF EXISTS aggiornaSostituite;
DELIMITER $$
CREATE TRIGGER aggiornaSostituite
AFTER INSERT ON Compreso
FOR EACH ROW
BEGIN
	INSERT INTO Sostituita (Ticket, CodiceParte, `Data`)
    SELECT I.Ticket, NEW.CodiceParte, OS.DataPrevistaConsegna
	FROM OrdineSostituzione OS
        INNER JOIN Intervento I ON I.InterventoId = OS.InterventoId
	WHERE  OS.CodiceOrdineSos = NEW.CodiceOrdineSos
	LIMIT 1;
END $$
DELIMITER ;

/*
	InserisciPrezzoProduzione
*/
DROP TRIGGER IF EXISTS InserisciPrezzoProduzione;
DELIMITER $$
CREATE TRIGGER InserisciPrezzoProduzione
AFTER INSERT ON Costituito
FOR EACH ROW
BEGIN
	DECLARE modelloId INT;
    DECLARE prezzoModello DOUBLE;
	DECLARE prezzoVariante DOUBLE;
    DECLARE curPrezzo DOUBLE;
    SET modelloId = (
		SELECT V.ModelloId
        FROM Variante V
        WHERE V.VarianteId = NEW.VarianteId
        LIMIT 1
    );
    SET curPrezzo = (SELECT P.PrezzoProduzione FROM Prodotto P WHERE P.ProdottoId = NEW.ProdottoId);
    -- se è il primo inserimento mi calcolo il prezzo del modello da cui deriva il prodotto
    IF curPrezzo  = 0 THEN
		SET curPrezzo = (
			SELECT IFNULL(SUM(TMP.PrezzoProduzione),0)
			FROM (
				SELECT DISTINCT P.CodiceParte, P.PrezzoProduzione 
				FROM PrecedenzaTecnologica PC
				INNER JOIN Parte P ON P.CodiceParte = PC.ParteA OR P.CodiceParte = PC.ParteB
				WHERE PC.ModelloId = modelloId) AS TMP
		);
    END IF;
    SET prezzoVariante = (
		SELECT V.Prezzo
        FROM Variante V
        WHERE V.VarianteId = NEW.VarianteId
    );
    UPDATE Prodotto P
    SET P.PrezzoProduzione = curPrezzo + prezzoVariante
    WHERE P.ProdottoId = NEW.ProdottoId;
END $$
DELIMITER ;

/*
    GeneraSeriale
*/

DROP FUNCTION IF EXISTS GeneraSeriale;
DELIMITER $$
CREATE FUNCTION GeneraSeriale (_prodottoId INT)
RETURNS VARCHAR(50) NOT DETERMINISTIC
    BEGIN
		RETURN (
			SELECT U.Seriale
            FROM Unita U
				INNER JOIN Lotto L ON U.CodiceLotto = L.CodiceLotto
                LEFT OUTER JOIN Reso R ON U.Seriale = R.Seriale
            WHERE U.CodiceOrdine IS NOT NULL AND L.ProdottoId = _prodottoId AND R.Seriale IS NULL
            ORDER BY RAND()
            LIMIT 1
        );
    END $$
DELIMITER ;


/*
    InserisciInterventi
*/

DROP PROCEDURE IF EXISTS inserisciInterventi;
DELIMITER $$
CREATE PROCEDURE inserisciInterventi()
BEGIN

    DECLARE finito INT DEFAULT 0;
    DECLARE _ticket VARCHAR(50) DEFAULT 0;
    DECLARE _data DATE;
    DECLARE _fascia VARCHAR(50) DEFAULT '';

    DECLARE cursore CURSOR FOR
    SELECT R.Ticket
    FROM Richiesta R
        INNER JOIN Preventivo P ON P.Ticket = R.Ticket
    WHERE P.Accettato = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cursore;
    ciclo: LOOP

        FETCH cursore INTO _ticket;

        IF finito = 1 THEN
            LEAVE ciclo;
        END IF;

        SELECT DataTecniciDisponibili_MW, FasciaOraria INTO _data, _fascia
        FROM TecniciDisponibili_MW
        WHERE TecniciDisponibili <> 0
        ORDER BY RAND()
        LIMIT 1;

        INSERT INTO Intervento (Data, FasciaOraria, Durata, TecnicoId, Ticket)
        VALUES (_data, _fascia, 3, NULL, _ticket);

    END LOOP;
    CLOSE cursore;

END $$
DELIMITER ;

/*
	ControllaVariante
*/
DROP TRIGGER IF EXISTS controlloVariante;
DELIMITER $$
CREATE TRIGGER controlloVariante
BEFORE INSERT ON Costituito
FOR EACH ROW
BEGIN
	DECLARE var BOOL;
    DECLARE modId INT;
    SET modId = (SELECT M.ModelloId FROM Variante V INNER JOIN Modello M ON V.ModelloId = M.ModelloId WHERE V.VarianteId = NEW.VarianteId LIMIT 1);
    -- se non hai ancora messo una variante non puoi sapere a che modello è collegato un prodotto
    IF modId IS NOT NULL THEN
		SET var = EXISTS(
			SELECT 1
			FROM Variante V
			WHERE V.ModelloId <> modId AND V.VarianteId IN (
				SELECT C1.VarianteId
                FROM Costituito C1
                WHERE C1.ProdottoId = NEW.ProdottoId
            )
		);
		IF var = 1 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La specifica inserita è destinata ad un altro modello. Riprovare.';
		END IF;
	END IF;
END $$
DELIMITER ;

/*
	AggiornaStatoOrdini
*/

DROP TRIGGER IF EXISTS aggiornaStatoOrdini;
DELIMITER $$
CREATE TRIGGER aggiornaStatoOrdini
AFTER UPDATE ON LottoProduzione
FOR EACH ROW
BEGIN
	DECLARE finito INT DEFAULT 0;
    DECLARE CO VARCHAR(50);
    DECLARE CL VARCHAR(50);
    -- prendo tutti gli ordini in cui sono state ordinate unita di questo lotto e non sono state ordinate altre unita i cui lotti devono ancora finire la produzione
    DECLARE cursore CURSOR FOR
		SELECT O.CodiceOrdine, U.CodiceLotto
		FROM Ordine O
		INNER JOIN Unita U ON U.CodiceOrdine = O.CodiceOrdine
		WHERE U.CodiceLotto = NEW.CodiceLotto AND NOT EXISTS (
			SELECT 1
            FROM Unita U1
            INNER JOIN LottoProduzione LP ON U1.CodiceLotto = LP.CodiceLotto
            WHERE U1.CodiceOrdine = O.CodiceOrdine AND LP.DataEffettiva IS NULL
        );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
	IF OLD.DataEffettiva IS NULL AND NEW.DataEffettiva IS NOT NULL THEN
		OPEN cursore;
		ciclo: LOOP
			FETCH cursore INTO CO, CL;
			IF finito = 1 THEN
				LEAVE ciclo;
			END IF;
			-- aggiorno lo stato in processazione
			UPDATE Ordine
			SET Stato = 'Processazione'
			WHERE CodiceOrdine = CO;
			
		END LOOP;
		CLOSE cursore;
	END IF;
END $$
DELIMITER ;

/*
	ControllaIndirizzo
*/
DROP TRIGGER IF EXISTS controlloIndirizzo;
DELIMITER $$
CREATE TRIGGER controlloIndirizzo
BEFORE INSERT ON Ordine
FOR EACH ROW
BEGIN
	DECLARE var INT;
    -- se non hai questo indirizzo tra i disponibili lo aggiungo
    SET var = NOT EXISTS (
		SELECT 1 
		FROM Disponibile D
		WHERE D.AccountId = NEW.AccountId
			AND D.IndirizzoId = NEW.IndirizzoId
	);
    IF var = 1 THEN
        INSERT INTO Disponibile
        VALUES (NEW.AccountId, NEW.IndirizzoId);
    END IF;

END $$
DELIMITER ;

/*
	ControllaDocumento
*/                      
                        
-- Quando un cliente esegue un ordine controllo che il suo documento esista e che nel caso non sia scaduto
DROP TRIGGER IF EXISTS controllaDocumento;
DELIMITER $$
CREATE TRIGGER controllaDocumento
BEFORE INSERT ON Ordine
FOR EACH ROW
BEGIN
	DECLARE var BOOL;
	SET var = (
		SELECT D.Scadenza < CURRENT_DATE()
        FROM `Account` A
        INNER JOIN Cliente C ON A.ClienteId = C.ClienteId
        INNER JOIN Documento D ON C.DocId = D.DocId
        WHERE A.AccountId = NEW.AccountId
        LIMIT 1
    );
    IF var IS NULL OR var THEN
		IF var THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Errore. È necessario fornire un documento valido per creare un account.';
        ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Errore. È necessario fornire un documento per creare un account.';
        END IF;
    END IF;
END $$
DELIMITER ;

/*
	ControllaRotazione
*/                      
                        
-- Controllo che nella stazione non ci siano altre operazioni sullo stesso modello soggetto che riguardano una faccia diversa di esso
DROP TRIGGER IF EXISTS controlloRotazione;
DELIMITER $$
CREATE TRIGGER controlloRotazione
BEFORE INSERT ON Operazione
FOR EACH ROW
BEGIN

    DECLARE var BOOL;
    -- se non hai ancora messo una variante non puoi sapere a che modello è collegato un prodotto
	SET var = EXISTS(
		SELECT 1
		FROM Operazione O
		WHERE O.OperazioneId <> NEW.OperazioneId AND O.StazioneId = NEW.StazioneId AND O.FacciaId <> NEW.FacciaId
	);
	IF var = 1 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Non puoi eseguire operazioni su facce diverse all'interno di una stazione";
	END IF;
END $$
DELIMITER ;

/*
	ControllaMotivazioneReso
*/                            
-- Controllo che sia presente la motivazione del reso se esso è stato effettuato dopo i giorni max reso indicati dall'ordine
DROP TRIGGER IF EXISTS controlloMotivReso;
DELIMITER $$
CREATE TRIGGER controlloMotivReso
BEFORE INSERT ON Reso
FOR EACH ROW
BEGIN
    IF NEW.CodiceMotivazione IS NULL AND (
			SELECT IFNULL(( O.`Data` + INTERVAL O.GiorniMaxReso DAY ) < CURRENT_DATE(), 1)
            FROM Unita U
				INNER JOIN Ordine O ON U.CodiceOrdine = O.CodiceOrdine
            WHERE U.Seriale = NEW.Seriale
        ) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Impossibile effettuare il reso incodizionato, superato il numero massimo di giorni dipsonibili';
    END IF;
END $$
DELIMITER ;
/*
	ControllaStatoOrdine
*/
-- Ogni volta che si aggiorna un ordine viene controllata la consistenza degli stati dell'ordine
DROP TRIGGER IF EXISTS ControllaStatoOrdine;
DELIMITER $$
CREATE TRIGGER ControllaStatoOrdine
BEFORE UPDATE ON Ordine
FOR EACH ROW
BEGIN
	IF	(
		OLD.Stato = 'Pendente' AND NEW.Stato <> 'Processazione')
        OR (OLD.Stato = 'Processazione' AND NEW.Stato <> 'Preparazione')
        OR (OLD.Stato = 'Preparazione' AND NEW.Stato <> 'Spedito')
        OR (OLD.Stato = 'Spedito' AND NEW.Stato <> 'Evaso')
        OR (OLD.Stato = 'Evaso'
	) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossibile inserire, gli stati di un ordine devono seguire questo ordine: Pendente/Processazione, Preparazione, Spedito, Evaso';
	END IF;
END $$
DELIMITER ;

SELECT TIMEDIFF(CURRENT_TIME(), @timer ) as 'Success, stopwatch:';