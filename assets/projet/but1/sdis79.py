import csv
import mysql.connector

# Destination pour la base de donnée
db= mysql.connector.connect(host="localhost",user="root",password="",database="sdis79")

valeur =[]
requete=""

# Fonction pour récupérer les fichiers csv en liste de tuple
def recherche(fichier,encod):
    try :
        with open(fichier,encoding=encod)as c :
            lire =csv.reader(c, delimiter = ';')
            for ligne in lire:
                valeur.append(tuple(ligne))
            valeur.pop(0)
    except FileNotFoundError:
        print("fichier ",fichier," introuvable")
    return valeur

# Fonction pour créer la requête d'insertion sql à 2 colonnes
def req2(fichier):
    nom=fichier[:-4]
    requete=f"insert into {nom} values (%s,%s)"
    return requete

# Fonction pour l'insertion des données dans les tables
def insertion(valeur,requete):
    for each in valeur:
        try:   
            db.cursor().execute(requete,each)
            db.commit()
        except:
            print("doublon ignoré") # Message d'erreur global

# Insertion de différente table avec le même nombre de colonne (2) dans la base de données
dossier=['caserne.csv','grade.csv','typeengin.csv','situation.csv','fonction.csv']
codage=['windows-1252','latin-1']
for chacun in dossier:
    valeur=[]
    if chacun=='caserne.csv':
        recherche(chacun,codage[0])
    elif chacun =='situation.csv':
        recherche(chacun,codage[1])
        v2 = []
        for ligne in valeur :
            v2.append(tuple(ligne[:2]))
        valeur=v2
    else:
        valeur=recherche(chacun,codage[1])
    insertion(valeur,req2(chacun))
    
# Insertion de la table necessiter
paires=[]
valeur=[]
valeur=recherche('situation.csv',codage[1])
for ligne in valeur:
    col=ligne[0]
    for valeur in ligne [2:]:
        if valeur:
            paires.append((valeur,col))
insertion(paires,req2('necessiter.xxx'))

# Insertion de la table mobiliser
# Inverse les colonnes codeFonction et TypeEngin, pour la cohérence avec la base de donnée
valeur=[]
newval=[]
valeur=recherche('mobiliser_moyens_humains.csv',codage[1])
for tup in valeur:
    v1,v2,v3=tup
    newv1=v2
    newv2=v1
    newval.append((v2,v1,v3))
insertion(newval,"""insert into mobiliser values (%s,%s,%s)""")

# Insertion de la table engin
# Changer nom de caserne en code caserne pour la table engin, pour la cohérence avec la base de donnée
valeur=[]
recherche('engin.csv',codage[1])
c2 = db.cursor()
try :
    for each in valeur:   
        c2.execute("""select CodeCaserne from caserne where LibelleCaserne = %s""",(each[2],))
        while True:
            result=c2.fetchone()
            if not result:
                break
            for y in result:
                col=(each[0],each[1],result[0])
                c2.execute("INSERT INTO engin VALUES (%s, %s, %s)",col)
                db.commit()
except:
    print("doublon ignoré")  

# Insertion de la table employeur
# Création d'un num_employeur
valeur = []
recherche('volontaire.csv', codage[0])
newval = []
newval2 =[]
for tup in valeur:
    v1,v2,v3,v4,v5,v6,v7,v8,v9,v10 = tup
    newval.append((v5,v6,v8,v7,v10,v9))
    for element in newval:
        if element not in newval2:
            newval2.append(element)
for i, t in enumerate(newval2, start=1):
    newval2[i - 1] = (i,) + t  # Ajoutez le NumEmployeur avant chaque tuple
requete = """insert into employeur values (%s,%s,%s,%s,%s,%s,%s)"""
insertion(newval2,requete)

# Insertion de la table pompier 
# Récupération des num_employeur et insertion en fonction de si ils sont employé ou non
newval=[]
pompier=[]
pompier = recherche('pompier.csv', codage[1])
numE=""
volontaire=[]
volontaire=recherche('volontaire.csv',codage[0])
c3=db.cursor()
numero=[]
try:
    for tup in pompier :
        v1,v2,v3,v4,v5,v6,v7,v8,v9,v10=tup
        c2.execute("""select codeGrade from grade where Libellegrade = %s""",(tup[9],))
        result=c2.fetchone()
        if result :
            codegrade=result[0]
            for i in volontaire :
                if i[0]==v1:
                    mail=i[9]
                    reqe=f"select numEmployeur from employeur where Mail = '{mail}'"
                    c3.execute(reqe)
                    numE_result=c3.fetchall()
                    if numE_result:
                        numE = numE_result[0][0]
                    else :
                        numE=None
                    if v8=="NULL":
                        col1=((v1,v3,v2,v4,v5,v6,None,None,v7,numE,codegrade))
                        c2.execute("""insert into pompier values (%s, %s, %s, STR_TO_DATE(%s, '%d/%m/%Y'), %s, %s, %s, %s, %s, %s, %s)""",col1)
                        db.commit()
                    else :
                        col2=((v1,v3,v2,v4,v5,v6,v8,v9,v7,numE,codegrade))
                        c2.execute("""insert into pompier values (%s, %s, %s, STR_TO_DATE(%s, '%d/%m/%Y'), %s, %s, STR_TO_DATE(%s, '%d/%m/%Y'), %s, %s, %s, %s)""",col2)
                        db.commit()
                    break
except :
    print("doublon ignoré")

# Insertion date_affect
valeur=[]
recherche('affectation.csv',codage[0])
try :
    for each in valeur :
        val=each[3]
        c2.execute("INSERT INTO date_affec VALUES (STR_TO_DATE(%s, '%d/%m/%Y'))",(val,))
        db.commit()
except:
     print("doublon ignoré") 

# Insertion de la table affecter
# Changer nom de caserne en code caserne pour la table affecter, pour la cohérence avec la base de donnée
valeur=[]
recherche('affectation.csv',codage[0])
c2 = db.cursor()
try :
    for each in valeur:   
        c2.execute("""select CodeCaserne from caserne where LibelleCaserne = %s""",(each[4],))
        while True:
            result=c2.fetchone()
            if not result:
                break
            for y in result:
                col=(each[0],result[0],each[3])
                c2.execute("INSERT INTO affecter VALUES (%s, %s,STR_TO_DATE(%s, '%d/%m/%Y'))",col)
                db.commit()
except:
    print("doublon ignoré") 

# Insertion de la table habilité
# Récupération des différentes habilitation pour un même pompier en plusieurs tuples
valeur=[]
newval=[]
recherche('habilitation.csv',codage[0])
for tup in valeur:
    matricule = tup[0]
    fonctions = [(tup[i], tup[i+1]) for i in range(3, len(tup), 2) if tup[i] and tup[i+1]]
    newval.extend([(matricule, code, date) for code, date in fonctions])
requete="insert into habiliter values (%s,%s,STR_TO_DATE(%s, '%d/%m/%Y'))"
insertion(newval,requete)

db.close()