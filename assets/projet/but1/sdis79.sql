CREATE TABLE TypeEngin(
   CodeTypeEngin VARCHAR(50),
   LibelleTypeEngin VARCHAR(50) NOT NULL,
   PRIMARY KEY(CodeTypeEngin),
   UNIQUE(LibelleTypeEngin)
)ENGINE = InnoDB;

CREATE TABLE Situation(
   RefSituation VARCHAR(50),
   LibelleSituation VARCHAR(50) NOT NULL,
   PRIMARY KEY(RefSituation),
   UNIQUE(LibelleSituation)
)ENGINE=InnoDB;

CREATE TABLE Grade(
   CodeGrade VARCHAR(50),
   LibelleGrade VARCHAR(50) NOT NULL,
   PRIMARY KEY(CodeGrade),
   UNIQUE(LibelleGrade)
)ENGINE = InnoDB;

CREATE TABLE Fonction(
   CodeFonction VARCHAR(50),
   LibelleFonction VARCHAR(50) NOT NULL,
   PRIMARY KEY(CodeFonction),
   UNIQUE(LibelleFonction)
)ENGINE = InnoDB;

CREATE TABLE Caserne(
   codeCaserne VARCHAR(50),
   LibelleCaserne VARCHAR(50) NOT NULL,
   PRIMARY KEY(codeCaserne),
   UNIQUE(LibelleCaserne)
)ENGINE = InnoDB;

CREATE TABLE Employeur(
   NumEmployeur VARCHAR(50),
   Employeur VARCHAR(50),
   Rue VARCHAR(50),
   Ville VARCHAR(50),
   CP VARCHAR(50),
   Mail VARCHAR(50),
   Tel VARCHAR(50),
   PRIMARY KEY(NumEmployeur)
)ENGINE = InnoDB;

CREATE TABLE Engin(
   CodeTypeEngin VARCHAR(50),
   NumOrdre VARCHAR(50),
   codeCaserne VARCHAR(50) NOT NULL,
   PRIMARY KEY(CodeTypeEngin, NumOrdre),
   FOREIGN KEY(CodeTypeEngin) REFERENCES TypeEngin(CodeTypeEngin),
   FOREIGN KEY(codeCaserne) REFERENCES Caserne(codeCaserne)
)ENGINE = InnoDB;

CREATE TABLE Date_affec(
   Date_affectation DATE,
   PRIMARY KEY(Date_affectation)
)ENGINE = InnoDB;

CREATE TABLE POMPIER(
   Matricule VARCHAR(10),
   Prenom VARCHAR(50) NOT NULL,
   Nom VARCHAR(50) NOT NULL,
   Date_Naiss DATE NOT NULL,
   Sexe VARCHAR(50) NOT NULL,
   Telephone VARCHAR(50) NOT NULL,
   DateEmbauche DATE,
   DernierIndice VARCHAR(50),
   NumBIP VARCHAR(50) NOT NULL,
   NumEmployeur VARCHAR(50),
   CodeGrade VARCHAR(50) NOT NULL,
   PRIMARY KEY(Matricule),
   UNIQUE(Telephone),
   FOREIGN KEY(NumEmployeur) REFERENCES Employeur(NumEmployeur),
   FOREIGN KEY(CodeGrade) REFERENCES Grade(CodeGrade)
)ENGINE = InnoDB;

CREATE TABLE Affecter(
   Matricule VARCHAR(10),
   codeCaserne VARCHAR(50),
   Date_affectation DATE,
   PRIMARY KEY(Matricule, codeCaserne, Date_affectation),
   FOREIGN KEY(Matricule) REFERENCES POMPIER(Matricule),
   FOREIGN KEY(codeCaserne) REFERENCES Caserne(codeCaserne),
   FOREIGN KEY(Date_affectation) REFERENCES Date_affec(Date_affectation)
)ENGINE = InnoDB;

CREATE TABLE Mobiliser(
   CodeTypeEngin VARCHAR(50),
   CodeFonction VARCHAR(50),
   NbPompier INT,
   PRIMARY KEY(CodeTypeEngin, CodeFonction),
   FOREIGN KEY(CodeTypeEngin) REFERENCES TypeEngin(CodeTypeEngin),
   FOREIGN KEY(CodeFonction) REFERENCES Fonction(CodeFonction)
)ENGINE = InnoDB;

CREATE TABLE Habiliter(
   Matricule VARCHAR(10),
   CodeFonction VARCHAR(50),
   DateObt VARCHAR(50) NOT NULL,
   PRIMARY KEY(Matricule, CodeFonction),
   FOREIGN KEY(Matricule) REFERENCES POMPIER(Matricule),
   FOREIGN KEY(CodeFonction) REFERENCES Fonction(CodeFonction)
)ENGINE = InnoDB;

CREATE TABLE Necessiter(
   CodeTypeEngin VARCHAR(50),
   RefSituation VARCHAR(50),
   PRIMARY KEY(CodeTypeEngin, RefSituation),
   FOREIGN KEY(CodeTypeEngin) REFERENCES TypeEngin(CodeTypeEngin),
   FOREIGN KEY(RefSituation) REFERENCES Situation(RefSituation)
)ENGINE = InnoDB;
