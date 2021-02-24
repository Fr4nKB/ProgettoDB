/*Settimanalmente, alcune funzionalità di back-end confezionano dei report che analizzano le vendite e gli ordini pendenti. 
Tali report segnalano alla direzione quantità indicative di prodotti da produrre*/

CREATE TABLE IF NOT EXISTS analisiVenditeMW (
	ProdottoId INT NOT NULL,
    Venduti INT NOT NULL,
    Rimanenti INT NOT NULL,
    FineScorteGG DOUBLE NOT NULL,			-- indica quanti giorni mancano a finire le scorte se si mantiene una media settimanale di vendite costante a quella attuale
    PRIMARY KEY(ProdottoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

CREATE TABLE IF NOT EXISTS analisiVenditeLT (
	ID INT AUTO_INCREMENT NOT NULL,
	ProdottoId INT NOT NULL,
    PRIMARY KEY(ID)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TRIGGER IF EXISTS update_analisiVenditeLT;
DELIMITER $$
CREATE TRIGGER update_analisiVenditeLT
AFTER UPDATE ON Unita
FOR EACH ROW
BEGIN

	IF NEW.CodiceOrdine IS NOT NULL THEN
		INSERT INTO analisiVenditeLT (ProdottoId)
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
    FROM analisiVenditeLT LT
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
    
		REPLACE INTO analisiVenditeMW
		VALUES (prod, ven, rim, @var);

	END LOOP;
    CLOSE cursore;
    
    -- TRUNCATE analisiVenditeLT;
    
END $$
DELIMITER ;

DROP EVENT IF EXISTS update_analisiVendite;
CREATE EVENT update_analisiVendite
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 DAY -- faccio partire a mezzanotte
DO
	CALL analisiVendite();