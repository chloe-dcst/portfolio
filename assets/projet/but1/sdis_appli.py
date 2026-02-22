from tkinter import *
from tkinter import ttk
import mysql.connector

conn = mysql.connector.connect(host="localhost", user="root", password="", database="sdis79")
cursor = conn.cursor()
table_select = ""
insert_window = None
entries = []
treeview = None  # Ajout d'une variable globale pour le widget Treeview

def afficher_table(nom_table):
    global treeview

    if nom_table and treeview:  # Vérifie si le treeview est initialisé
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="sdis79"
        )
        cursor = connection.cursor()

        # Effacer les anciens résultats et les en-têtes de colonnes
        for col in treeview.get_children():
            treeview.delete(col)
        treeview["columns"] = ()

        # Mettre à jour les nouveaux en-têtes de colonnes
        cursor.execute(f"SHOW COLUMNS FROM {nom_table}")
        colonnes = [col[0] for col in cursor.fetchall()]
        treeview["columns"] = colonnes
        for col in colonnes:
            treeview.heading(col, text=col)

        # Récupérer les données de la table sélectionnée
        query = f"SELECT * FROM {nom_table}"
        cursor.execute(query)
        resultats = cursor.fetchall()

        # Ajouter les nouveaux résultats
        for row in resultats:
            treeview.insert('', 'end', values=row)

        cursor.close()
        connection.close()

def insert_data():
    global table_select, insert_window

    insert_window = Toplevel(fenetre)
    insert_window.title("Insertion de données")

    # Calculer la taille de la fenêtre en fonction du nombre de champs à remplir
    height = 100 + len(table) * 30
    insert_window.geometry(f"400x{height}")

    label = Label(insert_window, text="Choisir la table pour insérer les données :")
    label.pack()

    table_select = StringVar(insert_window)
    table_select.set(table[0])
    lst_affiche = OptionMenu(insert_window, table_select, *table, command=lambda table_name=table_select: afficher_champs(table_select.get()))
    lst_affiche.pack()

def afficher_champs(nom_table):
    global insert_window, entries

    insert_window.destroy()

    insert_window = Toplevel(fenetre)
    insert_window.title("Insertion de données")

    # Calculer la taille de la fenêtre en fonction du nombre de champs à remplir
    height = 100 + len(table) * 30
    insert_window.geometry(f"400x{height}")

    label = Label(insert_window, text=f"Remplir les champs pour la table '{nom_table}' :")
    label.pack()

    cursor.execute(f"SHOW COLUMNS FROM {nom_table}")
    colonnes = [col[0] for col in cursor.fetchall()]

    entries = []
    for col in colonnes:
        frame = Frame(insert_window)
        frame.pack(pady=5)

        label = Label(frame, text=col)
        label.pack(side=LEFT)

        entry = Entry(frame)
        entry.pack(side=RIGHT)
        entries.append(entry)

    btn_insert = Button(insert_window, text="Insérer", command=lambda: inserer_donnees(nom_table))
    btn_insert.pack()

def inserer_donnees(nom_table):
    global entries

    valeurs = [entry.get() for entry in entries]

    query = f"INSERT INTO {nom_table} VALUES ({', '.join(['%s'] * len(valeurs))})"
    cursor.execute(query, valeurs)
    conn.commit()

    afficher_table(nom_table)

    # Créer une fenêtre pop-up pour afficher un message d'insertion réussie
    success_window = Toplevel(insert_window)
    success_window.title("Insertion réussie")
    success_window.geometry("200x100")
    label = Label(success_window, text="Insertion réussie !")
    label.pack()


def fenetre_visu():
    global table_select, treeview

    visu = Toplevel(fenetre)
    visu.title("Visualisation des tables")
    visu.geometry("600x400")

    label = Label(visu, text="Choisir la table à visualiser.")
    label.pack()

    table_select = StringVar(visu)
    table_select.set(table[0])
    lst_affiche = OptionMenu(visu, table_select, *table, command=lambda table_name=table_select: afficher_table(table_select.get()))
    lst_affiche.pack()

    # Ajout d'un tableau pour afficher les résultats
    treeview = ttk.Treeview(visu, show='headings')
    treeview.pack(fill='both', expand=True)

    # Ajout d'une barre de défilement pour le tableau
    scrollbar_y = Scrollbar(visu, orient=VERTICAL, command=treeview.yview)
    scrollbar_y.pack(side=RIGHT, fill=Y)
    treeview.config(yscrollcommand=scrollbar_y.set)

    scrollbar_x = Scrollbar(visu, orient=HORIZONTAL, command=treeview.xview)
    scrollbar_x.pack(side=BOTTOM, fill=X)
    treeview.config(xscrollcommand=scrollbar_x.set)

fenetre = Tk()
fenetre.title("Appli")
fenetre.geometry("500x400")

cadre = Frame(fenetre)
cadre.pack()

lblchoix = Label(cadre, text='Choississez ce que vous voulez faire :', font=('Arial', 10))
lblchoix.grid(row=0, column=1)

btn_visu = Button(cadre, text="Visualisation", command=fenetre_visu)
btn_visu.grid(row=2, column=0)

btn_insert = Button(cadre, text="Insertion", command=insert_data)
btn_insert.grid(row=2, column=1)

cursor.execute("SHOW TABLES")
table = [table[0] for table in cursor.fetchall()]

fenetre.mainloop()

cursor.close()
conn.close()
