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
			AND NOT EXISTS ( -- la sostituzione di parti sostituite (in richieste avvenute prima di questa) da meno di 12 mesi è gratis
				SELECT 1
				FROM Sostituita S1
					INNER JOIN Parte P1 ON S1.CodiceParte = P1.CodiceParte
                    INNER JOIN Richiesta R1 ON R1.Ticket = S1.Ticket
				WHERE R1.Seriale = _seriale 
					AND P1.CodiceParte = P.CodiceParte 
					AND S1.Data + INTERVAL 12 MONTH  >= DataRichiesta
					AND R1.Data < DataRichiesta)
    );
    -- sommo il costo dello stipendio dei tecnici
    SET costo = costo + (
		SELECT IFNULL(SUM(I.Durata * T.StipendioOrario),0)
		FROM Intervento I
			INNER JOIN Tecnico T ON T.Tecnicoid = I.Tecnicoid
		WHERE I.Ticket = _richiestaId
	);
    -- percentuale di sconto in base ai guasti coperti dalla garanzia
    SET ScontoGaranzia = (
		WITH GuastiCoperti AS(  -- tutti i guasti coperti dalla garanzia in questa unita
			SELECT GA.CodiceGuasto 
			FROM Unita U 
				INNER JOIN Applicato A ON A.Seriale = U.Seriale 
				INNER JOIN Garanzia G ON G.CodiceGaranzia = A.CodiceGaranzia
                AND (A.Data + INTERVAL G.Durata MONTH) >= DataRichiesta
				INNER JOIN Coperto C ON C.CodiceGaranzia  = G.CodiceGaranzia 
				INNER JOIN Guasto GA ON GA.CodiceGuasto = C.CodiceGuasto
            WHERE U.Seriale = _seriale
        ), GuastiRichiesta AS ( -- guasti su cui è richiesta assistenza 
			SELECT GA.CodiceGuasto
            FROM Guasto GA
				INNER JOIN Rotto R ON GA.CodiceGuasto = R.CodiceGuasto
            WHERE R.Ticket = _richiestaId
        )
        SELECT IFNULL(COUNT(G.CodiceGuasto) / C, 0) -- calcolo percentuale
        FROM (SELECT COUNT(*) AS C
			FROM GuastiCoperti GA
			NATURAL JOIN GuastiRichiesta GR) AS T, GuastiRichiesta G
    );
    RETURN CEIL(costo - (costo * ScontoGaranzia)); -- ritorno il costo meno lo sconto dovuto alla garanzia
END $$
DELIMITER ;







