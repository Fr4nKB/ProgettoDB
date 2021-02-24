SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

BEGIN;
CREATE DATABASE IF NOT EXISTS `eDevice`;
COMMIT;

USE `eDevice`;

DROP TABLE IF EXISTS Rimedio;
CREATE TABLE Rimedio (
	CodiceRimedio VARCHAR(50) NOT NULL,
    Descrizione VARCHAR(255) NOT NULL,
    PRIMARY KEY (CodiceRimedio)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS AssistenzaVirtuale;
CREATE TABLE AssistenzaVirtuale (
	AssVirtId INT AUTO_INCREMENT NOT NULL,
    CodiceRimedio VARCHAR(50) NOT NULL,
    Domanda VARCHAR (100) NOT NULL,
    SI INT,
	`NO` INT,
    CodiceGuasto VARCHAR(50), 
    PRIMARY KEY (AssVirtId),
    FOREIGN KEY (CodiceRimedio) REFERENCES Rimedio(CodiceRimedio),
    FOREIGN KEY (SI) REFERENCES AssistenzaVirtuale(AssVirtId),
    FOREIGN KEY (`NO`) REFERENCES AssistenzaVirtuale(AssVirtId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Relativa;
CREATE TABLE Relativa (
	RelativaId INT AUTO_INCREMENT NOT NULL,
    AssVirtId INT NOT NULL,
    ModelloId INT NOT NULL,
    PRIMARY KEY (RelativaId),
    FOREIGN KEY (AssVirtId) REFERENCES AssistenzaVirtuale(AssVirtId),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Modello;
CREATE TABLE Modello (
	ModelloId INT AUTO_INCREMENT NOT NULL,
    Marca VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL UNIQUE,
    CodiceTest VARCHAR(50) NOT NULL,
    PRIMARY KEY (ModelloId),
	FOREIGN KEY (CodiceTest) REFERENCES Test(CodiceTest)  
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Faccia;
CREATE TABLE Faccia (
	FacciaId INT AUTO_INCREMENT NOT NULL,
    Descrizione VARCHAR(255),
    ModelloId INT NOT NULL,
    PRIMARY KEY (FacciaId),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId)  
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Variante;
CREATE TABLE Variante (
	VarianteId	INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Descrizione VARCHAR(255),
    Prezzo DOUBLE NOT NULL,
    ModelloId INT NOT NULL,
    PRIMARY KEY(VarianteId),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- Template tabella Prodotto
DROP TABLE IF EXISTS Prodotto;
CREATE TABLE Prodotto (
	ProdottoId INT AUTO_INCREMENT NOT NULL,
    NumeroResiRicondizionamento INT DEFAULT 0,
    CoefficienteSovraprezzo DOUBLE CHECK (CoefficienteSovraprezzo >= 0),
    PrezzoProduzione DOUBLE,
    PRIMARY KEY (ProdottoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Costituito;
CREATE TABLE Costituito (
	ProdottoId INT NOT NULL,
    VarianteId	INT NOT NULL,
    PRIMARY KEY (ProdottoId, VarianteId),
    FOREIGN KEY (ProdottoId) REFERENCES Prodotto(ProdottoId),
	FOREIGN KEY (VarianteId) REFERENCES Variante(VarianteId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Giunzione;
CREATE TABLE Giunzione (
	GiunzioneId INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Tipo VARCHAR(100),
    PRIMARY KEY (GiunzioneId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Caratteristica;
CREATE TABLE Caratteristica (
	CaratteristicaId INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Descrizione VARCHAR(255),
    PRIMARY KEY (CaratteristicaId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Caratterizzato;
CREATE TABLE Caratterizzato (
	GiunzioneId INT NOT NULL,
	CaratteristicaId INT NOT NULL,
    FOREIGN KEY (GiunzioneId) REFERENCES Giunzione(GiunzioneId),
	FOREIGN KEY (CaratteristicaId) REFERENCES Caratteristica(CaratteristicaId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;


DROP TABLE IF EXISTS Utensile;
CREATE TABLE Utensile (
	UtensileId INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50),
    Descrizione VARCHAR(255),
    PRIMARY KEY (UtensileId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS OperazioneCampione;
CREATE TABLE OperazioneCampione (
	OpCampId INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50),
    Descrizione VARCHAR(255),
    PRIMARY KEY (OpCampId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Usato;
CREATE TABLE Usato (
	OpCampId INT NOT NULL,
	UtensileId INT NOT NULL,
    PRIMARY KEY (OpCampId, UtensileId),
    FOREIGN KEY (OpCampId) REFERENCES OperazioneCampione(OpCampId),
	FOREIGN KEY (UtensileId) REFERENCES Utensile(UtensileId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Parte;
CREATE TABLE Parte (
	CodiceParte VARCHAR(50) NOT NULL,
	PrezzoProduzione DOUBLE NOT NULL,
    CoefficienteSvalutazione DOUBLE NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceParte)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Materiale;
CREATE TABLE Materiale (
	MaterialeId INT AUTO_INCREMENT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
    ValoreAlKg DOUBLE NOT NULL,
    PRIMARY KEY (MaterialeId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Costruito;
CREATE TABLE Costruito (
	CodiceParte VARCHAR(50) NOT NULL,
	MaterialeId INT NOT NULL,
    Quantitativo DOUBLE NOT NULL,
    PRIMARY KEY (CodiceParte, MaterialeId),
    FOREIGN KEY (CodiceParte) REFERENCES Parte(CodiceParte),
	FOREIGN KEY (MaterialeId) REFERENCES Materiale(MaterialeId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS PrecedenzaTecnologica;
CREATE TABLE PrecedenzaTecnologica (
	PrecTecId INT AUTO_INCREMENT NOT NULL,
	ModelloId INT NOT NULL,
    ParteA VARCHAR(50) NOT NULL,
    ParteB VARCHAR(50) NOT NULL,
    GiunzioneId INT NOT NULL,
    PRIMARY KEY (PrecTecId),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId),
	FOREIGN KEY (ParteA) REFERENCES Parte(CodiceParte),
	FOREIGN KEY (ParteB) REFERENCES Parte(CodiceParte),
	FOREIGN KEY (GiunzioneId) REFERENCES Giunzione(GiunzioneId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;


DROP TABLE IF EXISTS Operatore;
CREATE TABLE Operatore (
	OperatoreId INT AUTO_INCREMENT NOT NULL,
	CodFiscale VARCHAR(16) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    Stipendio INT NOT NULL,
    DataNascita DATE NOT NULL,
    PRIMARY KEY(OperatoreId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS TempoStimato;
CREATE TABLE TempoStimato (
	OperatoreId INT NOT NULL,
	OpCampId INT NOT NULL,
    Tempo INT NOT NULL CHECK (Tempo > 0),
    FOREIGN KEY (OperatoreId) REFERENCES Operatore(OperatoreId),
	FOREIGN KEY (OpCampId) REFERENCES OperazioneCampione(OpCampId) 
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Stazione;
CREATE TABLE Stazione (
	StazioneId INT AUTO_INCREMENT NOT NULL,
	OperatoreId INT,
    PRIMARY KEY (StazioneId),
    FOREIGN KEY (OperatoreId) REFERENCES Operatore(OperatoreId) 
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Sequenza;
CREATE TABLE Sequenza (
	SequenzaId INT AUTO_INCREMENT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
    T INT NOT NULL CHECK (T > 0),
    PRIMARY KEY (SequenzaId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Operazione;
CREATE TABLE Operazione (
	OperazioneId INT AUTO_INCREMENT NOT NULL,
	StazioneId INT,
    OpCampId INT NOT NULL,
    PrecTecId INT NOT NULL,
    FacciaId INT NOT NULL,
    PRIMARY KEY (OperazioneId),
    FOREIGN KEY (StazioneId) REFERENCES Stazione(StazioneId),
	FOREIGN KEY (OpCampId) REFERENCES OperazioneCampione(OpCampId),
	FOREIGN KEY (PrecTecId) REFERENCES PrecedenzaTecnologica(PrecTecId),
	FOREIGN KEY (FacciaId) REFERENCES Faccia(FacciaId) 
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Insieme;
CREATE TABLE Insieme (
	SequenzaId INT NOT NULL,
	OperazioneId INT NOT NULL,
	Ordine INT NOT NULL,
    PRIMARY KEY (SequenzaId, OperazioneId),
    FOREIGN KEY (SequenzaId) REFERENCES Sequenza(SequenzaId),
    FOREIGN KEY (OperazioneId) REFERENCES Operazione(OperazioneId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Magazzino;
CREATE TABLE Magazzino (
	CodiceMagazzino VARCHAR(50) NOT NULL,
	Predispozione VARCHAR(50) NOT NULL,
    Lat DOUBLE NOT NULL,
    Lon DOUBLE NOT NULL,
    Altezza INT NOT NULL,
    PRIMARY KEY (CodiceMagazzino)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS `Area`;
CREATE TABLE `Area` (
	AreaId INT AUTO_INCREMENT NOT NULL,
	Larghezza INT NOT NULL,
    Lunghezza INT NOT NULL,
    Tipo VARCHAR(20) NOT NULL CHECK (Tipo IN ('Ricondizionati', 'Produzione', 'Resi')),
    CodiceMagazzino VARCHAR(50) NOT NULL,
    PRIMARY KEY (AreaId),
	FOREIGN KEY (CodiceMagazzino) REFERENCES Magazzino(CodiceMagazzino)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Sede;
CREATE TABLE Sede (
	SedeId INT AUTO_INCREMENT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
    CAP VARCHAR(20) NOT NULL,
    Provincia VARCHAR(2) NOT NULL,
    Citta VARCHAR(50) NOT NULL,
    Via VARCHAR(100) NOT NULL,
    NumeroCivico VARCHAR(10) NOT NULL,
    PRIMARY KEY (SedeId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Lotto;
CREATE TABLE Lotto (
	CodiceLotto VARCHAR(50) NOT NULL,
	Quantita INT NOT NULL,
	DataInizio DATE,
    DataFine DATE,
    X INT,
    Y INT,
    Z INT,
    SedeId INT NOT NULL,
    AreaId INT,
    ProdottoId INT NOT NULL,
	PRIMARY KEY (CodiceLotto),
    FOREIGN KEY (SedeId) REFERENCES Sede(SedeId),
    FOREIGN KEY (AreaId) REFERENCES `Area`(AreaId),
    FOREIGN KEY (ProdottoId) REFERENCES Prodotto(ProdottoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS LottoProduzione;
CREATE TABLE LottoProduzione (
	CodiceLotto VARCHAR(50) NOT NULL,
	DataProduzione DATE NOT NULL,
    DataPreventivata DATE NOT NULL,
    DataEffettiva DATE,
    SequenzaId INT NOT NULL,
    PRIMARY KEY (CodiceLotto),
    FOREIGN KEY (CodiceLotto) REFERENCES Lotto(CodiceLotto),
    FOREIGN KEY (SequenzaId) REFERENCES Sequenza(SequenzaId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS UnitaPersa;
CREATE TABLE UnitaPersa (
	CodiceLotto VARCHAR(50) NOT NULL,
    StazioneId INT NOT NULL,
    Numero INT NOT NULL,
    PRIMARY KEY (CodiceLotto, StazioneId),
    FOREIGN KEY (CodiceLotto) REFERENCES LottoProduzione(CodiceLotto),
    FOREIGN KEY (StazioneId) REFERENCES Stazione(StazioneId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS LottoRicondizionati;
CREATE TABLE LottoRicondizionati (
	CodiceLotto VARCHAR(50) NOT NULL,
    `Data` DATE NOT NULL,
    PRIMARY KEY (CodiceLotto),
    FOREIGN KEY (CodiceLotto) REFERENCES Lotto(CodiceLotto)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Unita;
CREATE TABLE Unita (
	Seriale INT AUTO_INCREMENT NOT NULL,
	CodiceLotto VARCHAR(50) NOT NULL,
    CodiceOrdine VARCHAR(50),
    PrezzoVendita DOUBLE,
    ScontoRicondizionati DOUBLE DEFAULT 0,
    PRIMARY KEY (Seriale),
    FOREIGN KEY (CodiceLotto) REFERENCES Lotto(CodiceLotto),
	FOREIGN KEY (CodiceOrdine) REFERENCES Ordine(CodiceOrdine)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Documento;
CREATE TABLE Documento (
	DocId INT AUTO_INCREMENT NOT NULL,
    Tipologia VARCHAR(50) NOT NULL CHECK(Tipologia IN ('Patente', 'CartaIdentita', 'PassaPorto')),
    Numero VARCHAR(50) NOT NULL,
    Scadenza DATE NOT NULL,
    Ente VARCHAR(50) NOT NULL,
    PRIMARY KEY (DocId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Cliente;
CREATE TABLE Cliente (
	ClienteId INT AUTO_INCREMENT NOT NULL,
    CodFiscale VARCHAR(16) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    DataNascita DATE NOT NULL,
    Telefono VARCHAR(30) NOT NULL,
    DocId INT UNIQUE,
    PRIMARY KEY (ClienteId),
    FOREIGN KEY (DocId) REFERENCES Documento(DocId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Indirizzo;
CREATE TABLE Indirizzo (
	IndirizzoId INT AUTO_INCREMENT NOT NULL,
    CAP INT NOT NULL,
    Provincia VARCHAR(2) NOT NULL,
    Citta VARCHAR(50) NOT NULL,
    Via VARCHAR(50) NOT NULL,
    NumeroCivico VARCHAR(10) NOT NULL,
    Lat DOUBLE NOT NULL,
    Lon DOUBLE NOT NULL,
    PRIMARY KEY (IndirizzoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Ordine;
CREATE TABLE Ordine (
	CodiceOrdine VARCHAR(50) NOT NULL,
    `Data` DATE NOT NULL,
    Ora TIME NOT NULL,
    Stato VARCHAR(50) NOT NULL CHECK(Stato IN ('Pendente','Processazione', 'Preparazione', 'Spedito', 'Evaso')),
    GiorniMaxReso INT NOT NULL,
    AccountId INT NOT NULL,
    IndirizzoId INT NOT NULL,
    PRIMARY KEY (CodiceOrdine),
    FOREIGN KEY (IndirizzoId) REFERENCES Indirizzo(IndirizzoId),
    FOREIGN KEY (AccountId) REFERENCES `Account`(AccountId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS `Account`;
CREATE TABLE `Account` (
	AccountId INT AUTO_INCREMENT NOT NULL,
    NomeUtente VARCHAR(50) NOT NULL,
    Pwd VARCHAR(100) NOT NULL,
    DomandaDiSicurezza VARCHAR(255) NOT NULL,
    Risposta VARCHAR(255) NOT NULL,
    DataIscrizione DATE NOT NULL,
    ClienteId INT NOT NULL,
    PRIMARY KEY (AccountId),
    FOREIGN KEY (ClienteId) REFERENCES Cliente(ClienteId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Disponibile;
CREATE TABLE Disponibile (
	AccountId INT NOT NULL,
    IndirizzoId INT NOT NULL,
    PRIMARY KEY (AccountId, IndirizzoId),
    FOREIGN KEY (AccountId) REFERENCES `Account`(AccountId),
    FOREIGN KEY (IndirizzoId) REFERENCES Indirizzo(IndirizzoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Hub;
CREATE TABLE Hub (
	HubId INT AUTO_INCREMENT NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Lat DOUBLE NOT NULL,
    Lon DOUBLE NOT NULL,
    PRIMARY KEY (HubId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Spedizione;
CREATE TABLE Spedizione (
	CodiceSpedizione VARCHAR(50) NOT NULL,
    DataPrevista DATE NOT NULL,
    Stato VARCHAR(50) NOT NULL CHECK(Stato IN('Spedita', 'In transito', 'In consegna', 'Consegnata')),
    DataEffettiva DATE,
    CodiceOrdine VARCHAR(50) NOT NULL,
    HubId INT,
    PRIMARY KEY (CodiceSpedizione),
    FOREIGN KEY (CodiceOrdine) REFERENCES Ordine(CodiceOrdine),
    FOREIGN KEY (HubId) REFERENCES Hub(HubId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Recensione;
CREATE TABLE Recensione (
	RecensioneId INT AUTO_INCREMENT NOT NULL,
    Voto INT NOT NULL CHECK(Voto BETWEEN 1 AND 10),
    Commento VARCHAR(255) NOT NULL,
    Seriale INT NOT NULL,
    PRIMARY KEY (RecensioneId),
    FOREIGN KEY (Seriale) REFERENCES Unita(Seriale)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS MotivazioneReso;
CREATE TABLE MotivazioneReso (
	CodiceMotivazione VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Descrizione VARCHAR(255),
    PRIMARY KEY (CodiceMotivazione)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Reso;
CREATE TABLE Reso (
	CodiceReso VARCHAR(50) NOT NULL,
    DataInizio DATE,
    DataFine DATE,
    X INT,
    Y INT,
    Z INT,
    Seriale INT NOT NULL,
    CodiceMotivazione VARCHAR(50),
    AreaId INT,
    PRIMARY KEY (CodiceReso),
    FOREIGN KEY (Seriale) REFERENCES Unita(Seriale),
    FOREIGN KEY (CodiceMotivazione) REFERENCES MotivazioneReso(CodiceMotivazione),
    FOREIGN KEY (AreaId) REFERENCES `Area`(AreaId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Garanzia;
CREATE TABLE Garanzia (
	CodiceGaranzia VARCHAR(50) NOT NULL,
    Durata INT NOT NULL,
    Costo DOUBLE NOT NULL,
    PRIMARY KEY (CodiceGaranzia)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Applicato;
CREATE TABLE Applicato (
	Seriale INT NOT NULL,
	CodiceGaranzia VARCHAR(50) NOT NULL,
    `Data` DATE NOT NULL,
    PRIMARY KEY (Seriale, CodiceGaranzia),
    FOREIGN KEY (Seriale) REFERENCES Unita(Seriale),
    FOREIGN KEY (CodiceGaranzia) REFERENCES Garanzia(CodiceGaranzia)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Applicabile;
CREATE TABLE Applicabile (
	ModelloId INT NOT NULL,
	CodiceGaranzia VARCHAR(50) NOT NULL,
    PRIMARY KEY (ModelloId, CodiceGaranzia),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId),
    FOREIGN KEY (CodiceGaranzia) REFERENCES Garanzia(CodiceGaranzia)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Guasto;
CREATE TABLE Guasto (
	CodiceGuasto VARCHAR(50) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
    Descrizione VARCHAR(255) NULL,
    PRIMARY KEY (CodiceGuasto)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Errore;
CREATE TABLE Errore (
	CodiceErrore VARCHAR(50) NOT NULL,
	CodiceGuasto VARCHAR(50) NOT NULL,
    ModelloId INT NOT NULL,
    PRIMARY KEY (CodiceErrore),
    FOREIGN KEY (CodiceGuasto) REFERENCES Guasto(CodiceGuasto),
    FOREIGN KEY (ModelloId) REFERENCES Modello(ModelloId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Corrisposto;
CREATE TABLE Corrisposto (
	CodiceErrore VARCHAR(50) NOT NULL,
	CodiceRimedio VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceErrore, CodiceRimedio),
    FOREIGN KEY (CodiceErrore) REFERENCES Errore(CodiceErrore),
    FOREIGN KEY (CodiceRimedio) REFERENCES Rimedio(CodiceRimedio)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Coperto;
CREATE TABLE Coperto (
	CodiceGaranzia VARCHAR(50) NOT NULL,
	CodiceGuasto VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceGaranzia, CodiceGuasto),
    FOREIGN KEY (CodiceGaranzia) REFERENCES Garanzia(CodiceGaranzia),
    FOREIGN KEY (CodiceGuasto) REFERENCES Guasto(CodiceGuasto)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Richiesta;
CREATE TABLE Richiesta (
	Ticket VARCHAR(50) NOT NULL,
	Domicilio BOOLEAN NOT NULL,
    `Data` DATE NOT NULL,
    Seriale INT NOT NULL,
    PRIMARY KEY (Ticket),
    FOREIGN KEY (Seriale) REFERENCES Unita(Seriale)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Rotto;
CREATE TABLE Rotto (
	CodiceGuasto VARCHAR(50) NOT NULL,
	Ticket VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceGuasto, Ticket),
    FOREIGN KEY (CodiceGuasto) REFERENCES Guasto(CodiceGuasto),
	FOREIGN KEY (Ticket) REFERENCES Richiesta(Ticket)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Preventivo;
CREATE TABLE Preventivo (
	PreventivoId INT AUTO_INCREMENT NOT NULL,
	Prezzo DOUBLE NOT NULL,
    Accettato BOOLEAN NOT NULL,
    Ticket VARCHAR(50) NOT NULL,
    PRIMARY KEY (PreventivoId),
    FOREIGN KEY (Ticket) REFERENCES Richiesta(Ticket)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS CentroAssistenza;
CREATE TABLE CentroAssistenza (
	CentroAssId INT AUTO_INCREMENT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
    Lat DOUBLE NOT NULL,
    Lon DOUBLE NOT NULL,
    PRIMARY KEY (CentroAssId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Tecnico;
CREATE TABLE Tecnico (
	TecnicoId INT AUTO_INCREMENT NOT NULL,
	CodFiscale VARCHAR(16) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    StipendioOrario DOUBLE NOT NULL,
    CentroAssId INT,
    PRIMARY KEY (TecnicoId),
    FOREIGN KEY (CentroAssId) REFERENCES CentroAssistenza(CentroAssId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Intervento;
CREATE TABLE Intervento (
	InterventoId INT AUTO_INCREMENT NOT NULL,
	`Data` DATE NOT NULL,
    FasciaOraria VARCHAR(16) NOT NULL CHECK (FasciaOraria IN ('Mattina', 'Pomeriggio', 'Sera')),
    Durata DOUBLE NOT NULL,
    TecnicoId INT,
    Ticket VARCHAR(50) NOT NULL,
    PRIMARY KEY (InterventoId),
    FOREIGN KEY (TecnicoId) REFERENCES Tecnico(TecnicoId),
    FOREIGN KEY (Ticket) REFERENCES Richiesta(Ticket)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS OrdineSostituzione;
CREATE TABLE OrdineSostituzione (
	CodiceOrdineSos VARCHAR(50) NOT NULL,
	DataOrdine DATE NOT NULL,
    DataPrevistaConsegna DATE NOT NULL,
    DataEffettivaConsegna DATE,
    InterventoId INT NOT NULL,
    PRIMARY KEY (CodiceOrdineSos),
    FOREIGN KEY (InterventoId) REFERENCES Intervento(InterventoId)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Compreso;
CREATE TABLE Compreso (
	CodiceOrdineSos VARCHAR(50) NOT NULL,
	CodiceParte VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceOrdineSos, CodiceParte),
    FOREIGN KEY (CodiceOrdineSos) REFERENCES OrdineSostituzione(CodiceOrdineSos),
    FOREIGN KEY (CodiceParte) REFERENCES Parte(CodiceParte)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Ricevuta;
CREATE TABLE Ricevuta (
	CodiceRicevuta VARCHAR(50) NOT NULL,
	ModalitaPagamento VARCHAR(50) NOT NULL CHECK(ModalitaPagamento IN ('Contanti', 'Carta di credito', 'Carta di debito', 'POS')),
	Ticket VARCHAR(50) NOT NULL,
    PRIMARY KEY (CodiceRicevuta),
    FOREIGN KEY (Ticket) REFERENCES Richiesta(Ticket)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Sostituita;
CREATE TABLE Sostituita (
	Ticket VARCHAR(50) NOT NULL,
    CodiceParte VARCHAR(50) NOT NULL,
    `Data` DATE NOT NULL,
    PRIMARY KEY (Ticket, CodiceParte),
    FOREIGN KEY (Ticket) REFERENCES Richiesta(Ticket),
    FOREIGN KEY (CodiceParte) REFERENCES Parte(CodiceParte)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Test;
CREATE TABLE Test (
	CodiceTest VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    CodiceParte VARCHAR(50) NOT NULL,
    SottoTestDi VARCHAR(50),
    PRIMARY KEY (CodiceTest),
    FOREIGN KEY (CodiceParte) REFERENCES Parte(CodiceParte),
    FOREIGN KEY (SottoTestDi) REFERENCES Test(CodiceTest)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS Esaminato;
CREATE TABLE Esaminato (
	CodiceTest VARCHAR(50)  NOT NULL,
    Seriale INT NOT NULL,
    Passato BOOLEAN NOT NULL,
    `Data` DATE NOT NULL,
    PRIMARY KEY (CodiceTest, Seriale),
    FOREIGN KEY (CodiceTest) REFERENCES Test(CodiceTest),
    FOREIGN KEY (Seriale) REFERENCES Unita(Seriale)
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

SET FOREIGN_KEY_CHECKS = 1;
SELECT 'Success!' AS '';