from tkinter import *
from tkinter import filedialog, messagebox
from PIL import Image, ImageTk
import traitement
from AnalyseStatFinale import *
import webbrowser
import os

# Variable :
fichier1 = ""  # Chemin du premier fichier
fichier2 = ""  # Chemin du deuxième fichier
modif = False  # Stocker si le fichier "ajouter" a été modifié
modif1 = False  # Stocker si le premier fichier du "modifier" a été modifié
modif2 = False  # Sstocker si le deuxième fichier du "modifier" a été modifié
fichier_csv = 'accident.csv' # Nom du notre fichier csv
feuille='Accident' # Nom de la feuille excel (à récupérer sur le fichier excel)

# Lance le minimum nécessaire pour réaliser l'analyse stat
traitement.jointure()

# Fonction pour récupérer le nom du fichier de pars son chemin
def obtenir_nom_fichier(chemin_fichier):
    """
    Cette fonction prend un chemin de fichier en entrée et renvoie le nom du fichier.
    """
    return chemin_fichier.split('/')[-1].split('\\')[-1]

# Ouvre une boite de dialogue pour choisir un fichier et stock sont chemin
def parcourir_fichier():
    global fichier1  # Utilisation de la variable globale fichier1
    chemin_fichier = filedialog.askopenfilename()
    if chemin_fichier:
        fichier1 = chemin_fichier  # Stockage du chemin du fichier sélectionné dans la variable fichier1

# Fenetre pour le bouton ajout
def fenetre_ajout():
    def parcourir_fichier_ajout():
        global fichier1  # Utilisation de la variable globale fichier1
        chemin_fichier = filedialog.askopenfilename()
        if chemin_fichier:
            fichier1 = chemin_fichier  # Stockage du chemin du fichier sélectionné dans la variable fichier1
            label_chemin_ajout.config(text=fichier1)
            nom_fichier1 = obtenir_nom_fichier(fichier1)
        if modif == FALSE:
            traitement.convertisseur(nom_fichier1, fichier_csv, feuille)
            accListe, nomCol = traitement.ouverture(fichier_csv)
            traitement.modification(accListe, nomCol)  
        else:
            traitement.renommer_en_accident_traite(fichier1)

    def ouvrir_popup_ajouter():
        global modif
        if not fichier1:
            messagebox.showwarning("Attention", "Veuillez d'abord sélectionner un fichier.")
            return

        reponse = messagebox.askyesno("Confirmation", "Le fichier a-t-il été modifié ?")
        modif = reponse  # Stocker la réponse dans la variable modif
        if reponse:
            messagebox.showinfo("Info", "Vous avez indiqué que le fichier a été modifié.")
        else:
            messagebox.showinfo("Info", "Vous avez indiqué que le fichier n'a pas été modifié.")

    def ouvrir_popup_modifier():
        global modif1, modif2
        if not fichier1:
            messagebox.showwarning("Attention", "Veuillez d'abord sélectionner un fichier.")
            return

        reponse = messagebox.askyesno("Confirmation", "Le fichier a-t-il été modifié ?")
        modif1 = reponse  # Stocker la réponse pour le premier fichier dans la variable modif1
        if reponse:
            fenetre_selection_fichier_modifier()
        else:
            messagebox.showinfo("Info", "Vous avez indiqué que le fichier n'a pas été modifié.")

    def fenetre_selection_fichier_modifier():
        modif_fenetre = Toplevel(fenetre)
        modif_fenetre.title("Sélectionner un fichier à modifier")
        modif_fenetre.geometry("600x400")

        def parcourir_fichier_modifier():
            global fichier2, modif2
            chemin_fichier = filedialog.askopenfilename()
            if chemin_fichier:
                fichier2 = chemin_fichier  # Stockage du chemin du fichier sélectionné dans la variable fichier2
                label_chemin_modif.config(text=fichier2)
                reponse = messagebox.askyesno("Confirmation", "Le fichier modifié a-t-il été modifié ?")
                modif2 = reponse  # Stocker la réponse pour le deuxième fichier dans la variable modif2
                nom_fichier2 = obtenir_nom_fichier(fichier1)
                nom_fichier2 = obtenir_nom_fichier(fichier2)
                if reponse:
                    messagebox.showinfo("Info", "Vous avez indiqué que le fichier a été modifié.")
                else:
                    messagebox.showinfo("Info", "Vous avez indiqué que le fichier n'a pas été modifié.")
                traitement.concatener(fichier1, modif1, fichier2, modif2)

        cadre_modif = Frame(modif_fenetre)
        cadre_modif.pack(pady=10)

        # Création d'un cadre pour afficher le chemin du fichier sélectionné avec une largeur minimum
        cadre_chemin_modif = Frame(cadre_modif, bd=1, relief="sunken", width=300, height=30)
        cadre_chemin_modif.grid_propagate(False)  # Empêche le redimensionnement du cadre selon son contenu
        cadre_chemin_modif.grid(row=0, column=0, padx=(0, 10), pady=10)

        label_chemin_modif = Label(cadre_chemin_modif, text="", font=('Arial', '10', 'bold'), anchor='w', width=40)
        label_chemin_modif.pack(fill='x', padx=(5, 0))  # Remplit l'espace disponible horizontalement

        # Bouton pour parcourir les fichiers
        bouton_parcourir_modifier = Button(cadre_modif, text="Parcourir", command=parcourir_fichier_modifier)
        bouton_parcourir_modifier.grid(row=1, column=0, pady=10)

    visu = Toplevel(fenetre)
    visu.title("Ajouter/Modifier des données")
    visu.geometry("600x150")

    cadre = Frame(visu)
    cadre.pack(pady=10)

    # Création d'un cadre pour afficher le chemin du fichier sélectionné avec une largeur fixe de 300 pixels
    cadre_chemin_ajout = Frame(cadre, bd=1, relief="sunken", width=300, height=30)
    cadre_chemin_ajout.grid_propagate(False)  # Empêche le redimensionnement du cadre selon son contenu
    cadre_chemin_ajout.grid(row=0, column=0, padx=(0, 10), pady=10)

    label_chemin_ajout = Label(cadre_chemin_ajout, text="", font=('Arial', '10', 'bold'), anchor='w', width=40)
    label_chemin_ajout.pack(fill='x', padx=(5, 0))  # Remplit l'espace disponible horizontalement

    # Chargement et redimensionnage de l'image pour le "parcourir"
    img = Image.open("image.jpg")
    img = img.resize((20, 20))
    img = ImageTk.PhotoImage(img)
    
    # Création d'un Label avec l'image
    bouton_parcourir_ajout = Label(cadre, image=img)
    bouton_parcourir_ajout.image = img  # Garder une référence à l'image pour éviter la garbage collection
    bouton_parcourir_ajout.grid(row=0, column=1, pady=10)
    
    # Associer un événement de clic au Label
    bouton_parcourir_ajout.bind("<Button-1>", lambda e: parcourir_fichier_ajout())

    # Bouton pour utiliser un fichier comme base pour l'analyse et la visualisation
    bouton_ajouter = Button(cadre, text="Ajouter", command=ouvrir_popup_ajouter)
    bouton_ajouter.grid(row=1, column=0, pady=10)

    # Bouton pour "modifier", soit concatener deux fichier
    bouton_modifier = Button(cadre, text="Modifier", command=ouvrir_popup_modifier)
    bouton_modifier.grid(row=1, column=1, pady=10)

# Commande pour ouvrir le fichier Power BI (Dans le même répèrtoire)
def powerbi():
    os.startfile("acciStat.pbix")

# Commande pour ouvrir une page web (notre tuto youtube)
def tuto():
    webbrowser.open("https://youtu.be/XOiF5RKzbGM?si=OiNEz2w0UuXKBLWM")
    
# Première fenètre tk inter
fenetre = Tk()
fenetre.title("AcciStat")
fenetre.geometry("500x400")
# Ajouter un Canvas pour l'image de fond
canvas = Canvas(fenetre, width=500, height=400)
canvas.pack(fill="both", expand=True)

# Charger l'image de fond
img_fond = Image.open("fond.jpeg")  # Chemin de votre image de fond
img_fond = img_fond.resize((500, 400))  # Redimensionner l'image si nécessaire
img_fond = ImageTk.PhotoImage(img_fond)

# Ajouter l'image de fond au Canvas
canvas.create_image(0, 0, anchor="nw", image=img_fond)

# Première zone de texte
lblchoix = Label(fenetre, text='Choisissez ce que vous voulez faire :', font=('Arial', 10), bg=(lambda rgb: '#%02x%02x%02x' % rgb)((191, 191, 191)))
canvas.create_window(250, 150, window=lblchoix)

# Bouton pour voir l'analyse statistique
btn_visu = Button(fenetre, text="Analyse statistique", command=Application)
canvas.create_window(150, 200, window=btn_visu)

# Bouton pour la page ajouter ou modifier
btn_ajout = Button(fenetre, text="Ajouter/Modifier des données", command=fenetre_ajout)
canvas.create_window(350, 200, window=btn_ajout)

# Bouton pour ouvrir le fichier PowerBI
btn_powerbi = Button(fenetre, text="Data Visualisation", command=powerbi)
canvas.create_window(150, 250, window=btn_powerbi)

# Bouton pour ouvrir le tuto youtube
btn_youtube = Button(fenetre, text="Tutoriel d'utilisation", command=tuto)
canvas.create_window(350, 250, window=btn_youtube)

fenetre.mainloop()