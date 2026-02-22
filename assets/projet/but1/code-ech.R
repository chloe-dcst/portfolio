setwd("C:/Users/chloe/OneDrive - Université de Poitiers/Bureau/BUT 1/S2/SAE/Stat inf")

# ouverture fichier CSV
table <- read.csv("C:/Users/chloe/OneDrive - Université de Poitiers/Bureau/BUT 1/S2/SAE/Stat inf/population_francaise_communes.csv",
                  sep=';',fileEncoding = "Latin1",header=TRUE)
table$Population.totale <- gsub(" ","",table$Population.totale)
table$Population.totale <- as.numeric(table$Population.totale)


# Partie 1 : échantillonnage aléatoire simple 
# question 1
donnees <- table[table$Nom.de.la.région == "Centre-Val de Loire", c("Code.département","Commune","Population.totale")]
donnees<- unique(donnees)
head(donnees)

# question 2
U <- donnees$Commune
head(U)
N = length(U)
N

# question 3
T<-sum(donnees$Population.totale)

# Tirage aléatoire simple d’un échantillon de taille n = 100
n=100
E=sample(U, n,replace=FALSE)
head(E)

# question 4 
donnees1= donnees[donnees$Commune %in% E, ]
head(donnees1)

# question 5
  #moyenne de l'échantillon
moy= mean(donnees1$Population.totale)
moy
 # idc de mu
idcmoy = t.test(donnees1$Population.totale)$conf.int
idcmoy

# question 6
# Nbre d’habitants total estimé
Test = N*moy
Test
# IDC de T 
idcT = idcmoy*N
idcT
#Marge d'erreur 
marge=(idcT[2]-idcT[1])/2
marge

# question 7
# initialisation du data frame final a expoté  
Tableau_simple <- data.frame(Population_totale = numeric(15),
                             population_estime = numeric(15),
                             idc_inf = numeric(15),
                             idc_sup = numeric(15),
                             marge_derreur = numeric(15))

# boucle pour répété les 3 dernières étape
for (i in 1:15) {
  E=sample(U,size=n, replace=FALSE)
  donnees1 <- donnees[donnees$Commune %in% E, ]
  
  # Ajout d'impressions pour le débogage
  print(paste("Groupe", i))
  print(donnees1)
  
  # Vérifier si le nombre d'observations est suffisante pour effectuer un test T
  if (nrow(donnees1) >= 2) {
    moy <- mean(donnees1$Population.totale)
    idcmoy <- t.test(donnees1$Population.totale)$conf.int
    Test <- N * moy
    idcT <- idcmoy * N
    marge <- (idcT[2] - idcT[1]) / 2
    
    # Stocker les résultats dans le tableau finale
    Tableau_simple[i, "Population_totale"] <- sum(donnees$Population.totale)
    Tableau_simple[i, "population_estime"] <- Test
    Tableau_simple[i, "idc_inf"] <- idcT[1]
    Tableau_simple[i, "idc_sup"] <- idcT[2]
    Tableau_simple[i, "marge_derreur"] <- marge
 } 
}

# export du fichier CSV
write.csv2(Tableau_simple, file = "Tableau_simple.csv", row.names = FALSE)

#Partie stratifié

# Question 1
# quartile
summary(donnees$Population.totale)

# Question 2
# strates :
datastrat=donnees
datastrat$Strate=cut(datastrat$Population.totale, breaks=c(0,275, 540, 1175, 140475), labels=c(1,2,3,4))
head(datastrat)

# Question 3 :
# effectif des strates
data = datastrat[order(datastrat$Strate), ]
Nh=table(data$Strate)

# Tirage d’un échantillon stratifié de taille n=100
n=100
nh=c(25,25,25,25)

# Sondage des strates sans remise
st = strata(datastrat, stratanames = c("Strate"), size = nh, method = "srswr")
data1=getdata(datastrat, st)
head(data)
data1 = data1[order(data1$Strate), ]
Nh=table(data$Strate)

# Poids des strates
gh=Nh/N

# Taux de sondage dans les strates
fh=nh/Nh

# Question 4
# Mise en place des 4 échantillons
ech1=data1[data1$Strate==1, ]
ech2=data1[data1$Strate==2, ]
ech3=data1[data1$Strate==3, ]
ech4=data1[data1$Strate==4, ]

# Moyennes des 4 échantillons
m1=mean(ech1$Population.totale)
m2=mean(ech2$Population.totale)
m3=mean(ech3$Population.totale)
m4=mean(ech4$Population.totale)

# Variances des 4 échantillons
var1=var(ech1$Population.totale)
var2=var(ech2$Population.totale)
var3=var(ech3$Population.totale)
var4=var(ech4$Population.totale)

# Question 5
# Moyenne générale (des 3 échantillons réunis)
Xbarst= (Nh[1]*m1 + Nh[2]*m2 + Nh[3]*m3 + Nh[4]*m4)/N

# Estimation de la variance de Xbarst
varXbarst= ((gh[1])^2)*(1-fh[1])*var1/(nh[1]) + ((gh[2])^2)*(1-fh[2])*var2/(nh[2]) +
  ((gh[3])^2)*(1-fh[3])*var3/(nh[3]) + ((gh[4])^2)*(1-fh[4])*var4/(nh[4])

# IDC pour mu à 95%
alpha=0.05
binf = Xbarst - qnorm(1-alpha/2)*sqrt(varXbarst)
bsup = Xbarst + qnorm(1-alpha/2)*sqrt(varXbarst)
idcmoy=c(binf, bsup)

# Question 6  
# Estimation du total T
Tstr= N*Xbarst
Tstr

# Estimation par IDC du total T
binf = idcmoy[1]*N
bsup= idcmoy[2]*N
idcT=c(binf, bsup)
idcT

# Marge d’erreur
marge=(idcT[2]-idcT[1])/2
marge

# Question 7
Tableau_strate <- data.frame(Population_totale = numeric(15),
                             population_estime = numeric(15),
                             idc_inf = numeric(15),
                             idc_sup = numeric(15),
                             marge_derreur = numeric(15))

for (i in 1:15) {
  st = strata(datastrat, stratanames = c("Strate"), size = nh, method = "srswr")
  data1=getdata(datastrat, st)
  
  # Ajout d'impressions pour le débogage
  print(paste("Groupe", i))
  print(data1)
  
  # Vérifier si le nombre d'observations est suffisant pour effectuer un test t
  if (nrow(data1) >= 2) {
    st = strata(datastrat, stratanames = c("Strate"), size = nh, method = "srswr")
    data1=getdata(datastrat, st)
    data1 = data1[order(data1$Strate), ]
    Nh=table(data$Strate)
    gh=Nh/N
    fh=nh/Nh
    ech1=data1[data1$Strate==1, ]
    ech2=data1[data1$Strate==2, ]
    ech3=data1[data1$Strate==3, ]
    ech4=data1[data1$Strate==4, ]
    m1=mean(ech1$Population.totale)
    m2=mean(ech2$Population.totale)
    m3=mean(ech3$Population.totale)
    m4=mean(ech4$Population.totale)
    var1=var(ech1$Population.totale)
    var2=var(ech2$Population.totale)
    var3=var(ech3$Population.totale)
    var4=var(ech4$Population.totale)
    Xbarst= (Nh[1]*m1 + Nh[2]*m2 + Nh[3]*m3 + Nh[4]*m4)/N
    varXbarst= ((gh[1])^2)*(1-fh[1])*var1/(nh[1]) + ((gh[2])^2)*(1-fh[2])*var2/(nh[2]) +
      ((gh[3])^2)*(1-fh[3])*var3/(nh[3]) + ((gh[4])^2)*(1-fh[4])*var4/(nh[4])
    binf = Xbarst - qnorm(1-alpha/2)*sqrt(varXbarst)
    bsup = Xbarst + qnorm(1-alpha/2)*sqrt(varXbarst)
    idcmoy=c(binf, bsup)
    Tstr= N*Xbarst
    binf = idcmoy[1]*N
    bsup= idcmoy[2]*N
    idcT=c(binf, bsup)
    marge=(idcT[2]-idcT[1])/2
    
    # Stocker les résultats dans le tableau
    Tableau_strate[i, "Population_totale"] <- sum(donnees$Population.totale)
    Tableau_strate[i, "population_estime"] <- Tstr
    Tableau_strate[i, "idc_inf"] <- idcT[1]
    Tableau_strate[i, "idc_sup"] <- idcT[2]
    Tableau_strate[i, "marge_derreur"] <- marge
  } 
}

# Export du fichier CSV
write.csv2(Tableau_strate, file = "Tableau_strate.csv", row.names = FALSE)



# PARTIE 2 :
# Ouverture de la table voitures
voiture <- read.csv("C:/Users/chloe/OneDrive - Université de Poitiers/Bureau/BUT 1/S2/SAE/Stat inf/voitures.csv",
                    sep=';',fileEncoding = "Latin1",header=TRUE)

head(voiture)

# nouvelle variable "Primes2"
Prime2 <- character(length(voiture$Prime)) 
for (i in 1:length(voiture$Prime)) {
  if (voiture$Prime[i] < 200) {
    Prime2[i] <- "faible"
  } else if (voiture$Prime[i] < 400) {
    Prime2[i] <- "moyenne"
  } else {
    Prime2[i] <- "élevée"
  }
}
voiture$Prime2 = Prime2
head(voiture)

# Construction des tableaux croisés
tableau_croise_Marque <- table(voiture$Prime2, voiture$Marque)
print(tableau_croise_Marque)
tableau_croise_PuissFisc <- table(voiture$Prime2, voiture$PuissFisc)
tableau_croise_categorie <- table(voiture$Prime2, voiture$Categorie)
tableau_croise_Anciennete <- table(voiture$Prime2, voiture$Anciennete)
tableau_croise_Formule <- table(voiture$Prime2, voiture$Formule)

# test du khi-deux
Marque=chisq.test(tableau_croise_Marque)
Marque
PuissFisc=chisq.test(tableau_croise_PuissFisc)
categorie=chisq.test(tableau_croise_categorie)
Anciennete=chisq.test(tableau_croise_Anciennete)
Formule=chisq.test(tableau_croise_Formule)

# Extraire les résultats 
khi2 <- c(Marque$statistic,PuissFisc$statistic,categorie$statistic,Anciennete$statistic,Formule$statistic)
pvaleur <- c(Marque$p.value,PuissFisc$p.value,categorie$p.value,Anciennete$p.value,Formule$p.value)

# mettre les résultats du test du Khideux et de la P_value dans un data frame
tab_khi2<-data.frame(variables_quali=c('Marque','PuissFisc','Categorie','Anciennete','Formule'),khi2,pvaleur)

# extraction de la table tab_khi2
write.csv2(tab_result, file='tab_result.csv', row.names=FALSE)

# V de Crammer
# pour le tableau croisé Marque Prime2
n<- sum(tableau_croise_Marque)
p<- nrow(tableau_croise_Marque)
q<- ncol(tableau_croise_Marque)
m<- min(p-1,q-1)
v<- sqrt(Marque$statistic/(n*m))
v
# Pour le tableau croisé Anciennete et Prime2
n2<- sum(tableau_croise_Anciennete)
p2<- nrow(tableau_croise_Anciennete)
q2<- ncol(tableau_croise_Anciennete)
m2<- min(p2-1,q2-1)
v2<- sqrt(Anciennete$statistic/(n*m))
v2
# Pour le tableau croisé Formule et Prime2
n3<- sum(tableau_croise_Formule)
p3<- nrow(tableau_croise_Formule)
q3<- ncol(tableau_croise_Formule)
m3<- min(p3-1,q3-1)
v3<- sqrt(Formule$statistic/(n*m))
v3

# récupération de tous les résultats du VCrammer
vcrammer<-c(v,v2,v3)

# création d'un nouveau data frame qui récupère les résultat du V de crammer
tab_vcrammer <- data.frame(variables_quali=c('Marque','Anciennete','Formule'),vcrammer)

#extraction du fichier tab_vcrammer
write.csv2(tab_vcrammer, file='tab_vcrammer.csv', row.names=FALSE)