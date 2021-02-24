-- per ogni magazzino e ogni area di esso viene restituito lo spazio disponibile e spazio totale
DROP PROCEDURE IF EXISTS analisiSpazio;
CREATE PROCEDURE analisiSpazio()

	SELECT CodiceMagazzino, AreaId, SpazioTotale, 100 * (SpazioTotale - Lotti - Resi) / SpazioTotale AS SpazioDisponibile
    FROM (SELECT M.CodiceMagazzino, A.AreaId, (M.Altezza * A.Larghezza * A.Lunghezza) AS SpazioTotale, COUNT(L.CodiceLotto) AS Lotti, COUNT(CodiceReso) AS Resi
		FROM Magazzino M
			INNER JOIN Area A
			INNER JOIN Lotto L
			INNER JOIN Reso R
		WHERE L.X IS NOT NULL
			AND L.Y IS NOT NULL
			AND L.Z IS NOT NULL
			AND R.X IS NOT NULL
			AND R.Y IS NOT NULL
			AND R.Z IS NOT NULL
	GROUP BY M.CodiceMagazzino, A.AreaId) AS T;