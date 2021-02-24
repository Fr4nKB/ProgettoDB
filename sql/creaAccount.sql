DROP PROCEDURE IF EXISTS creaAccount;
DELIMITER $$
CREATE PROCEDURE creaAccount (IN _NomeUtente VARCHAR(50), IN _pswd VARCHAR(100), IN _DomandaDiSicurezza VARCHAR(255), IN _Risposta VARCHAR(255), IN _UtenteId INT)
BEGIN

    SET @var = 0;

    SELECT 1 INTO @var
    FROM Cliente
    WHERE NOT EXISTS (SELECT 1 FROM Cliente WHERE UtenteId = _UtenteId)
		AND UtenteId = _UtenteId
        AND DocID IS NOT NULL;

    IF @var = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore. È necessario fornire un documento per creare un account.';
    
    ELSE
        INSERT INTO Account (NomeUtente, Pwd, DomandaDiSicurezza, Risposta, DataIscrizione, UtenteId)
        VALUES (_NomeUtente, _pswd, _DomandaDiSicurezza, _Risposta, CURRENT_DATE(), _UtenteId);
    END IF;

END $$
DELIMITER ;
