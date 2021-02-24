-- MW contenente le distanza
CREATE TABLE IF NOT EXISTS Distanze (
	InterventoId INT NOT NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    TecnicoId INT NOT NULL,
    Dist DOUBLE NOT NULL,
    DataIntervento DATE,
    FasciaOraria VARCHAR(50)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- MW contenente i tecnici scelti
CREATE TABLE IF NOT EXISTS Scelti (
    TecnicoId INT NOT NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    DataIntervento DATE
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
        SET Dist = p * R;
        RETURN Dist;
        
END $$
DELIMITER ;

-- carico le distanze tra i tecnici dagli interventi
-- TODO controllare la cosa del domicilio
DROP PROCEDURE IF EXISTS load_Distanze;
DELIMITER $$
CREATE PROCEDURE load_Distanze(IN _data date)
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
        INNER JOIN CentroAssistenza C
		INNER JOIN Intervento I
        INNER JOIN Richiesta R
        INNER JOIN Ordine O
        INNER JOIN Indirizzo Ind
	WHERE I.Data > CURRENT_DATE() AND T.CentroAssId IS NOT NULL; -- considero solo tecnici attualmente impiegati in un centro di Assistenza
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO inter, intlat, intlon, tecn, teclat, teclon, Idata, foraria;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        
        INSERT INTO Distanze
        VALUES (inter, intlat, intlon, tecn, CalcoloDistanza(intlat,intlon,teclat,teclon), Idata, foraria);
        
    END LOOP;
    CLOSE cursore;
    
END $$
DELIMITER ;

-- aggiorno le distanze dei tecnici che sono stati a fare un intervento
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
    FROM Scelti;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO tecn, teclat, teclon, Idata;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        
        UPDATE Distanze D
        SET D.Dist = CalcoloDistanza(D.lat, D.lon, teclat, teclon)
        WHERE TecnicoId = tecn AND DataIntervento = Idata;
        
        END LOOP;
	CLOSE cursore;
    
    TRUNCATE Scelti;
    
END $$
DELIMITER ;

-- assegna gli interventi ai tecnici più vicini e poi aggiorna le distanze
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
	
    -- prendo tutti gli interventi da assegnare di oggi di questa fascia oraria
    DECLARE cursore CURSOR FOR
    SELECT D.InterventoId, D.TecnicoId, D.Lat, D.Lon, D.DataIntervento
    FROM Distanze D
	WHERE D.FasciaOraria = _foraria
    ORDER BY D.InterventoId, D.Dist;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
	OPEN cursore;
    ciclo: LOOP
    
		FETCH cursore INTO inter, tecn, intlat, intlon, Ddata;
        
        IF finito = 1 THEN
			LEAVE ciclo;
        END IF;
        
        -- se questo è lo stesso intervento significa che gli ho già assegnato qualcuno
        IF inter <> lastInt THEN
			-- se il tecnico non è già stato assegnato in questa fascia oraria
			IF NOT EXISTS (SELECT 1 FROM Scelti WHERE TecnicoId = tecn) THEN
				SET lastInt = inter;
                -- inserisco i tecnici dentro quelli scelti, assegnandogli la posizione di dove affettuano l'intervento
                INSERT INTO Scelti VALUES (tecn, intlat, intlon, Ddata);
                -- assegno il tecnico all'intervento
                UPDATE Intevento
                SET TecnicoId = tecn
                WHERE InterventoId = inter;
			END IF;
		END IF;
        
    END LOOP;
    CLOSE cursore;
    
    CALL refresh_Distanze();
    
END $$
DELIMITER ;

-- procedura che assegna i tecnici agli interventi che avvengono nei prossimi 7 giorni
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

DROP EVENT IF EXISTS aggiornaDistanze;
CREATE EVENT aggiornaDistanze
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO CALL AssegnaTecnici();