
/*
	CBR
*/
-- stored procedure che aggiunge un sintomo alla lista da controllare
DROP PROCEDURE IF EXISTS AggiungiSintomo;
DELIMITER $$
CREATE PROCEDURE AggiungiSintomo(IN _sintomoId INT)
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS Sintomo_tmp(
		SintomoId INT NOT NULL,
		PRIMARY KEY (SintomoId)
	) ENGINE = InnoDB DEFAULT CHARSET = latin1;
    
    INSERT INTO Sintomo_tmp
    VALUES (_sintomoId);
END $$
DELIMITER ;

-- stored procedure che restituisce i rimedi ordinati per score
DROP PROCEDURE IF EXISTS Retrieve;
DELIMITER $$
CREATE PROCEDURE Retrieve(IN _modelloId INT)
BEGIN
	DECLARE nVolteSintomiCurati BIGINT;
	SET @modelloid = _modelloId;
	CREATE TEMPORARY TABLE IF NOT EXISTS ScoreRimedi_tmp(
		id INT AUTO_INCREMENT,
		CodiceRimedio VARCHAR(50),
		Score DOUBLE,
        Funzionato BOOL DEFAULT FALSE,
		PRIMARY KEY (id)
	) ENGINE = InnoDB DEFAULT CHARSET = latin1;
    
	TRUNCATE  ScoreRimedi_tmp;
	
    SET nVolteSintomiCurati = ( SELECT COUNT(*)
		FROM Sintomo_tmp SP
			INNER JOIN Causa C ON SP.SintomoId = C.SintomoId
            INNER JOIN Caso CS ON C.CasoId = CS.CasoId
			INNER JOIN Cura CR ON CS.CasoId = CR.CasoId
		WHERE CS.ModelloId = @modelloId
    );

    INSERT INTO ScoreRimedi_tmp (CodiceRimedio, Score)
	SELECT T.cRimedio, T.Score as Score
	FROM (SELECT CR.CodiceRimedio as cRimedio, COUNT(SP.SintomoId) /  nVolteSintomiCurati * 100 AS Score
	FROM Sintomo_tmp SP
		RIGHT JOIN Causa C ON SP.SintomoId = C.SintomoId
		INNER JOIN Caso CS ON C.CasoId = CS.CasoId
		INNER JOIN Cura CR ON CS.CasoId = CR.CasoId
	WHERE CS.ModelloId = _modelloid
	GROUP BY CR.CodiceRimedio
	ORDER BY Score DESC) AS T;
    
    SELECT S.CodiceRimedio AS Cod, S.Score AS Score, R.Descrizione AS Descr
    FROM ScoreRimedi_tmp S
    INNER JOIN Rimedio R ON S.CodiceRimedio = R.CodiceRimedio;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Revise;
DELIMITER $$
CREATE PROCEDURE Revise(IN _codiceRimedio VARCHAR(50))
BEGIN
	DECLARE esisteGia BOOL;
    DECLARE retrieved BOOL;
    SET retrieved = EXISTS (
		SELECT 1
        FROM ScoreRimedi_tmp
        WHERE CodiceRimedio = _codiceRimedio
    );
    IF retrieved THEN
		UPDATE ScoreRimedi_tmp
        SET Funzionato = TRUE
        WHERE CodiceRimedio = _codiceRimedio;
	ELSE
		INSERT INTO ScoreRimedi_tmp (CodiceRimedio, Funzionato, Score)
        VALUES (_codiceRimedio, TRUE, 0);
	END IF;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS `Retain`;
DELIMITER $$
CREATE PROCEDURE `Retain`()
BEGIN
	DECLARE casoId INT;
    -- se i rimedi che hannop funzionato sono più del 50% generati dal revise allora il caso viene considerato importante e viene aggiunto
	IF (
		SELECT SUM(S.Score)
        FROM ScoreRimedi_tmp S
        WHERE S.Funzionato = 1
		) < 50 THEN
		-- inserisco un nuovo caso e prendo l'id del caso
        INSERT INTO Caso (ModelloId)
        VALUES (@modelloid);
		SET casoId = LAST_INSERT_ID();
        -- collego i sintomi
        INSERT INTO Causa(CasoId, SintomoId)
        SELECT casoId, S.SintomoId
        FROM Sintomo_tmp S;
        -- collego i rimedio
        INSERT INTO Cura (CasoId, CodiceRimedio)
        SELECT casoId, SR.CodiceRimedio
        FROM ScoreRimedi_tmp SR
        WHERE Funzionato = 1;
	END IF;
    TRUNCATE Sintomo_tmp;
    TRUNCATE ScoreRimedi_tmp;
END $$
DELIMITER ;

CALL AggiungiSintomo(1);
CALL AggiungiSintomo(2);
CALL AggiungiSintomo(13);
CALL Retrieve(1); 

CALL Revise("OSbjewhfja");
CALL Revise("SCOTCHoefw");
CALL Revise("PRESTkfewl");
select * from ScoreRimedi_tmp;

CALL `Retain`();

-- controllo se è stato inserito un altro caso con i sintomi e i rimedi discussi sopra visto che i rimedi non retrieved funzionanti sono più del 50%
SELECT *
FROM Caso C
	INNER JOIN Causa CS ON C.CasoId = CS.CasoId
    INNER JOIN Cura CR ON C.CasoId = CR.CasoId
WHERE C.CasoId = 5;

CALL AggiungiSintomo(1);
CALL AggiungiSintomo(2);
CALL AggiungiSintomo(13);
CALL Retrieve(1); 

CALL Revise("OSbjewhfja");
CALL Revise("SCOTCHoefw");
CALL Revise("PRESTkfewl");
select * from ScoreRimedi_tmp;

CALL `Retain`();

-- controllo che non venga inserito un altro caso visto che non ce n'è bisogno
SELECT *
FROM Caso C
	INNER JOIN Causa CS ON C.CasoId = CS.CasoId
    INNER JOIN Cura CR ON C.CasoId = CR.CasoId
WHERE C.CasoId = 6;
/*
	EfficienzaProcesso
*/

DROP PROCEDURE IF EXISTS EffecienzaProcesso;
DELIMITER $$
CREATE PROCEDURE EffecienzaProcesso ()
BEGIN
	WITH DatiLotti AS (
		SELECT F.ModelloId, SE.SequenzaId, LP.CodiceLotto, LP.DataEffettiva, L.Quantita, SUM(IFNULL(UP.Numero, 0)) AS TotUnitaPerseLotto
			, COUNT(DISTINCT OPT.OperatoreId) AS NumOperaiImpiegati, COUNT(DISTINCT O.FacciaId) AS NumRotazioni, SE.T, SUM(DISTINCT OPT.Stipendio) AS TotRisorseLotto
		FROM LottoProduzione LP
			INNER JOIN Lotto L ON L.CodiceLotto = LP.CodiceLotto
			INNER JOIN Sequenza SE ON LP.SequenzaId = SE.SequenzaId 
			INNER JOIN Insieme I ON I.SequenzaId = SE.SequenzaId
			INNER JOIN Operazione O ON I.OperazioneId = O.OperazioneId
			INNER JOIN Faccia F ON F.FacciaId = O.FacciaId
			INNER JOIN Stazione S ON O.StazioneId = S.StazioneId
			LEFT JOIN Operatore OPT ON S.OperatoreId = OPT.OperatoreId
			LEFT JOIN UnitaPersa UP ON UP.StazioneId = S.StazioneId AND L.CodiceLotto = UP.CodiceLotto
		WHERE LP.DataEffettiva IS NOT NULL
		GROUP BY F.ModelloId, SE.SequenzaId, LP.CodiceLotto 
	), DatiLottiConAndamento AS (
		SELECT CodiceLotto, ModelloId, SequenzaId, DataEffettiva,TotUnitaPerseLotto, NumOperaiImpiegati, NumRotazioni, TotRisorseLotto, Quantita, T
		, ROUND((LAG(TotUnitaPerseLotto, 1) OVER(PARTITION BY ModelloId, SequenzaId ORDER BY DataEffettiva) / TotUnitaPerseLotto * 100) - 100, 2) AS AndamentoUnitaPerse
		, ROW_NUMBER() OVER (PARTITION BY SequenzaId ORDER BY DataEffettiva DESC) as rNum
		FROM DatiLotti
		ORDER BY SequenzaId, DataEffettiva
	), SequenzaElaborate AS(
		SELECT ModelloId, SequenzaId, SUM(TotUnitaPerseLotto)/COUNT(CodiceLotto) AS MediaUnitaPerseSequenza, SUM(TotRisorseLotto) AS TotRisorseSequenza, NumOperaiImpiegati, NumRotazioni, SUM(Quantita)/COUNT(CodiceLotto) as QuantitaMedia, T
		FROM DatiLottiConAndamento
		GROUP BY ModelloId, SequenzaId
	), DatiAndamentoSequenze AS (
		SELECT AndamentoUnitaPerse, SequenzaId
		FROM DatiLottiConAndamento D
		WHERE D.rNum = 1
	)

	SELECT ModelloId, SequenzaId, TotRisorseSequenza/(QuantitaMedia+MediaUnitaPerseSequenza) AS CostoMedioUnita, T * (QuantitaMedia + MediaUnitaPerseSequenza) AS `TempoTotaleMedio [s]`, 
    MediaUnitaPerseSequenza, AndamentoUnitaPerse AS `AndamentoUnitaPerse [%]`
	FROM DatiAndamentoSequenze
	NATURAL JOIN SequenzaElaborate
	GROUP BY ModelloId, SequenzaId
	ORDER BY ModelloId, `TempoTotaleMedio [s]` DESC, (`TempoTotaleMedio [s]` * NumRotazioni/NumOperaiImpiegati ) * CostoMedioUnita ASC, AndamentoUnitaPerse DESC;
END $$
DELIMITER ;

CALL EffecienzaProcesso()