DROP PROCEDURE IF EXISTS inserisciRimedio;
DELIMITER $$
CREATE PROCEDURE inserisciRimedio ()
BEGIN

	DECLARE i INT DEFAULT 75;
    ciclo: LOOP
    IF i = 0 THEN
		LEAVE ciclo;
	END IF;
    
    SET @CodiceRimedio = SUBSTRING(MD5(RAND()) FROM 1 FOR 10);
    SET @Descrizione = SUBSTRING(MD5(RAND()) FROM 1 FOR 32);
    
    INSERT INTO Rimedio
    VALUES (@CodiceRimedio, @Descrizione);
    
    SET i = i - 1;
    
    END LOOP;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS inserisciAssVirt2;
DELIMITER $$
CREATE PROCEDURE inserisciAssVirt2 ()
BEGIN

    DECLARE finito INT DEFAULT 0;
    DECLARE av1 INT DEFAULT 0;
    DECLARE av2 INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    WITH 
    T1 AS (SELECT AssVirtId AS AVId
		FROM AssistenzaVirtuale),
    T2 AS (SELECT AssVirtId AS AVId
		FROM AssistenzaVirtuale)
    SELECT T1.AVId, T2.AVId
    FROM T1, T2
    ORDER BY RAND()
    ;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    SET i = (SELECT COUNT(*) FROM AssistenzaVirtuale);
    
    OPEN cursore;
    ciclo: LOOP
    
    FETCH cursore INTO av1, av2;
    
    IF finito = 1 OR i = 0 THEN
		LEAVE ciclo;
	END IF;
    
    UPDATE AssistenzaVirtuale
    SET SI = IF(i = av1, NULL, av1), NO = IF(av2 = av1, NULL, av2)
	WHERE AssVirtId = i;
    
    SET i = i - 1; 
    
    END LOOP;
    CLOSE cursore;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS inserisciAssVirt;
DELIMITER $$
CREATE PROCEDURE inserisciAssVirt ()
BEGIN

    DECLARE finito INT DEFAULT 0;
    DECLARE cr VARCHAR(50) DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    SELECT CodiceRimedio
    FROM Rimedio;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
    FETCH cursore INTO cr;
    
    IF finito = 1 THEN
		LEAVE ciclo;
	END IF;
    
    INSERT INTO AssistenzaVirtuale (CodiceRimedio)
    VALUES (cr);
    
    END LOOP;
    CLOSE cursore;
    
    CALL inserisciAssVirt2();

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS inserisciModello;
DELIMITER $$
CREATE PROCEDURE inserisciModello ()
BEGIN
	
    DECLARE finito INT DEFAULT 0;
	DECLARE i INT DEFAULT 15;
    DECLARE av INT DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    SELECT AssVirtId
    FROM AssistenzaVirtuale
    ORDER BY RAND()
    LIMIT 15;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cursore;
    ciclo: LOOP
    
    FETCH cursore INTO av;
    
    IF finito = 1 OR i = 0 THEN
		LEAVE ciclo;
	END IF;
    
    SET @marca = SUBSTRING(MD5(RAND()) FROM 1 FOR 10);
    SET @nome = SUBSTRING(MD5(RAND()) FROM 1 FOR 15);
    
    INSERT INTO Modello (Marca, Nome, AssVirtId)
    VALUES (@marca, @nome, av);
    
    SET i = i - 1;
    
    END LOOP;
    CLOSE cursore;

END $$
DELIMITER ;

/*
CALL inserisciRimedio();
CALL inserisciAssVirt();
CALL inserisciModello();
-- non spostare l'ordine altrimenti non funziona
