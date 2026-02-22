setwd("C:/Users/chloe/Desktop/Université/BUT 1/SAE/stat desc 2")

# import fichier train et test 
train <- read.csv2("train.csv")
test<- read.csv2("test.csv")

deciles <- quantile(train$Valeur.fonciere, probs = seq(0.1,0.9, by = 0.1))
print(deciles)
df <- train[train$Valeur.fonciere >= deciles[1] & train$Valeur.fonciere <= deciles[9], ]

# catégorie en fonction du nombre de pièces et du type de logement
appart_moins4pièces <- df[df$Nombre.pieces.principales <= 4 & df$Type.local == "Appartement", ]
appart_plus4pièces <- df[df$Nombre.pieces.principales >=5 & df$Type.local == "Appartement", ]
maison <- df[df$Type.local == "Maison", ]


# catégorie en fonciton de la commune 
a <- c("PARIS 01","PARIS 02","PARIS 03","PARIS 04","PARIS 05","PARIS 06","PARIS 07","PARIS 08","PARIS 16")
appart_moins4pièces_pluschère <- appart_moins4pièces[appart_moins4pièces$Commune %in% a, ]

b <- c("PARIS 09","PARIS 10","PARIS 11","PARIS 12","PARIS 13","PARIS 14","PARIS 15","PARIS 17","PARIS 18","PARIS 19","PARIS 20")
appart_moins4pièces_moinschère <- appart_moins4pièces[appart_moins4pièces$Commune %in% b, ]

c<- c("PARIS 01","PARIS 04","PARIS 06","PARIS 07","PARIS 08","PARIS 16")
appart_plus4pièces_pluschère <- appart_plus4pièces[appart_plus4pièces$Commune %in% c, ]

d <- c("PARIS 02","PARIS 30","PARIS 05","PARIS 09","PARIS 10","PARIS 11","PARIS 12","PARIS 13","PARIS 14","PARIS 15","PARIS 17","PARIS 18","PARIS 19","PARIS 20")
appart_plus4pièces_moinschère <- appart_plus4pièces[appart_plus4pièces$Commune %in% d, ]

# Modèle linéaire des appart de moins de 4 pièces les moins chères
x1 <-appart_moins4pièces_moinschère$Surface.reelle.bati
y1 <-appart_moins4pièces_moinschère$Valeur.fonciere
covx1y1 <- cov(x1,y1 )
varx1 <- var(x1)
a1 <- covx1y1/varx1
b1 <-mean(y1)-a1*mean(x1)
yi1 <-a1*x1+b1
appart_moins4pièces_moinschère$prediction <- yi1
diff <- (yi1-appart_moins4pièces_moinschère$Valeur.fonciere)
SR2 <-sum(diff^2)

# Modèle linéaire pour les apparts de moins 4 pièces les plus chères 
x2 <-appart_moins4pièces_pluschère$Surface.reelle.bati
y2 <-appart_moins4pièces_pluschère$Valeur.fonciere
covx2y2 <- cov(x2,y2 )
varx2 <- var(x2)
a2 <- covx2y2/varx2
b2 <-mean(y2)-a2*mean(x2)
yi2 <-a2*x2+b2
appart_moins4pièces_pluschère$prediction <- yi2
dif <- (yi2-appart_moins4pièces_pluschère$Valeur.fonciere)
SR2 <-sum(diff^2)

# Modèle linéaire pour les apparts de plus de 4 pièces les moins chères
x3 <- appart_plus4pièces_moinschère$Surface.reelle.bati
y3<- appart_plus4pièces_moinschère$Valeur.fonciere
covx3y3 <- mean(x3*y3)-mean(x3)*mean(y3)
a3 <- covx3y3 / var(x3)
b3 <- mean(y3)- mean(x3)
yi3 <- a3*x3+b3
appart_plus4pièces_moinschère$prediction <- yi3
diff4 <- yi3 - y3
sr2 <- sum(dif^2)
           
# Modèle linéaire pour les apparts de plus de 4 pièces les plus chères 
x4 <- appart_plus4pièces_pluschère$Surface.reelle.bati
y4 <- appart_plus4pièces_pluschère$Valeur.fonciere
covx4y4 <- mean(x4*y4)-mean(x4)*mean(y4)
a4 <- covx4y4 / var(x4)
b4 <- mean(y4)- a4*mean(x4)
yi4 <- a4*x4+b4
appart_plus4pièces_pluschère$prediction <- yi4
dif <- yi4 - y4
sr2 <- sum(dif^2)

# Modèle  pour les maisons 
x5 <- maison$Surface.reelle.bati
y5 <- maison$Valeur.fonciere
covx5y5 <- mean(x5*y5)-mean(x5)*mean(y5)
a5 <- covx5y5 / var(x5)
b5 <- mean(y5)- a5*mean(x5)
yi5 <- a5*x5+b5
maison$prediction <- yi5
dif <- yi5 - y5
sr2 <- sum(dif^2)

# Catégoriser le test

# appart plus de 4 pièces
t_appart_plus4pièces <- test[test$Nombre.pieces.principales >=5 & test$Type.local == "Appartement", ]

# appart plus de 4 pièces les moins chères
t_appart_plus4pièces_moinschère <- t_appart_plus4pièces[t_appart_plus4pièces$Commune %in% d, ]

# appart plus de 4 pièces les plus chères
t_appart_plus4pièces_pluschère <- t_appart_plus4pièces[t_appart_plus4pièces$Commune %in% c, ]

# appart moins de 4 pièces 
t_appart_moins4pièces <- test[test$Nombre.pieces.principales <5 & test$Type.local == "Appartement", ]

#appart moins de 4 pièces les moins chères / Il n'y a pas de logement dans cette catégorie
t_appart_moins4pièces_moinschère <- t_appart_moins4pièces[t_appart_moins4pièces$Commune %in% b, ]

# appart moins de 4 pièces les plus chères
t_appart_moins4pièces_pluschère <- t_appart_moins4pièces[t_appart_moins4pièces$Commune %in% a, ]

# maison 
t_maison <- test[test$Type.local == "Maison", ]

# application du modèle

# appart plus de 4 pièces les plus chères
x4 <- t_appart_plus4pièces_pluschère$Surface.reelle.bati
for (valeur in t_appart_plus4pièces_pluschère$id ){
  yi4 <- a4*x4+b4
  t_appart_plus4pièces_pluschère$Valeur.fonciere<- c(yi4)}

# appart plus de 4 pièces les moins chères
x3 <- t_appart_plus4pièces_moinschère$Surface.reelle.bati
for (valeur in t_appart_plus4pièces_moinschère$id ){
  yi3 <- a3*x3+b3
  t_appart_plus4pièces_moinschère$Valeur.fonciere<- c(yi3)}

# appart moins de 4 pièces les plus chères
x2 <-t_appart_moins4pièces_pluschère$Surface.reelle.bati
for (valeur in t_appart_moins4pièces_pluschère$id ){
  yi2 <- a2*x2+b2
  t_appart_moins4pièces_pluschère$Valeur.fonciere<- c(yi2)}

# appart moins de 4 pièces les moins chères
x1 <-t_appart_moins4pièces_moinschère$Surface.reelle.bati
for (valeur in t_appart_moins4pièces_moinschère$id ){
  yi1 <- a1*x1+b1
  t_appart_moins4pièces_moinschère$Valeur.fonciere<- c(yi1)}

# maison 
x5 <-t_maison$Surface.reelle.bati
for (valeur in t_maison$id ){
  yi5 <- a5*x5+b5
  t_maison$Valeur.fonciere<- c(yi5)}


# Création du data frame avec les predictions
prediction <- data.frame(id = c(t_maison$id,t_appart_moins4pièces_moinschère$id,t_appart_moins4pièces_pluschère$id,t_appart_plus4pièces_moinschère$id,t_appart_plus4pièces_pluschère$id),
                         Valeur.fonciere = c(t_maison$Valeur.fonciere,t_appart_moins4pièces_moinschère$Valeur.fonciere,t_appart_moins4pièces_pluschère$Valeur.fonciere,t_appart_plus4pièces_moinschère$Valeur.fonciere,t_appart_plus4pièces_pluschère$Valeur.fonciere))


# export du fichier CSV
write.csv2(prediction, file = "prediction.csv", row.names = FALSE)
