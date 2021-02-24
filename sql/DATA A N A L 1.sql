-- DATA ANALYTICS 2
DROP PROCEDURE IF EXISTS DataAnalytics2;
DELIMITER $$
CREATE PROCEDURE DataAnalytics2 ()
BEGIN
	WITH
	CTE AS (SELECT M.ModelloId, Seq.SequenzaId, T*(L.Quantita + SUM(IFNULL(Numero,0))) AS TempoTotale, SUM(DISTINCT Op.Stipendio) AS TotRisorse, SUM(IFNULL(Numero,0)) AS TotUnitaPerse, 
				COUNT(DISTINCT Op.OperatoreId) AS NumOperaiImpiegati, COUNT(DISTINCT F.FacciaId) AS NumRotazioni, LP.DataProduzione, L.Quantita
			FROM Operazione Opz
				INNER JOIN Stazione S ON S.StazioneId = Opz.StazioneId
				INNER JOIN Operatore Op ON S.OperatoreId = Op.OperatoreId
				INNER JOIN OperazioneCampione OpC ON OpC.OpCampId = Opz.OpCampId
				INNER JOIN TempoStimato TS ON TS.OperatoreId = Op.OperatoreId AND TS.OpCampId = OpC.OpCampId
				INNER JOIN Insieme I ON I.OperazioneId = Opz.OperazioneId
				INNER JOIN Sequenza Seq ON Seq.SequenzaId = I.SequenzaId
				LEFT JOIN UnitaPersa UP ON UP.StazioneId = S.StazioneId
				INNER JOIN Faccia F ON F.FacciaId = Opz.FacciaId
				INNER JOIN Modello M ON M.ModelloId = F.ModelloId
				INNER JOIN LottoProduzione LP ON LP.SequenzaId = Seq.SequenzaId
				INNER JOIN Lotto L ON L.CodiceLotto = LP.CodiceLotto
			GROUP BY M.ModelloId, Seq.SequenzaId),
	CTE2 AS (SELECT ModelloId, SequenzaId, TempoTotale, TotRisorse/(Quantita+TotUnitaPerse) AS CostoMedioUnita, NumRotazioni/NumOperaiImpiegati AS RotazioniXOperaio, 
				LAG(TotUnitaPerse, 1) OVER(PARTITION BY ModelloId ORDER BY DataProduzione) > TotUnitaPerse AS AndamentoUnitaPerse, TotUnitaPerse
			FROM CTE)

	SELECT ModelloId, SequenzaId, AndamentoUnitaPerse, TotUnitaPerse
		FROM CTE2
	ORDER BY TempoTotale DESC, (TempoTotale*RotazioniXOperaio)*CostoMedioUnita ASC, AndamentoUnitaPerse DESC;
END $$
DELIMITER ;