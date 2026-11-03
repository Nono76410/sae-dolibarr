# SAE 51 - Installation d'un ERP/CRM (Dolibarr)

**Étudiants :** Pay Nolan & Ouerdane Gwen  
**Date :** Octobre 2026

## Description du projet
Ce projet permet de déployer automatiquement Dolibarr et sa base de données (MariaDB) à l'aide de Docker. Il inclut aussi un script pour importer une liste de clients et fournisseurs directement depuis un fichier CSV.

## 1. Installation
Pour lancer l'installation complète, exécutez le script suivant à la racine du projet :

```bash
./install.sh
```

Ce script va lancer les conteneurs via `docker-compose` et configurer Dolibarr pour qu'il soit prêt à l'emploi, en évitant de devoir remplir les étapes sur la page web.

**Accès à Dolibarr (sur http://localhost:8080) :**
- Identifiant : `dolibarr`
- Mot de passe : `azerty1234`

## 2. Importation des données et Base de données
Pour importer la liste des clients et fournisseurs depuis l'ancien système :

```bash
./import.sh data/test.csv
```

**Analyse des tables (Comment ça marche ?) :**
Au lieu de passer par le menu d'importation de Dolibarr, notre script interagit directement avec MariaDB. 
Dans Dolibarr, les entreprises sont enregistrées dans la table `llx_societe`. Notre script lit le CSV et vient remplir les colonnes obligatoires :
- `nom` : le nom de l'entreprise
- `client` : 1 (oui) ou 0 (non)
- `fournisseur` : 1 (oui) ou 0 (non)
- `datec` : la date d'ajout

## 3. Sauvegarde et PRA (Plan de Reprise d'Activité)
Toutes les données de la base MariaDB sont sauvegardées à l'extérieur du conteneur Docker, dans le dossier local `./jmariadb/data/`. 

Si le serveur plante ou si les conteneurs sont supprimés, il suffit de conserver ce dossier et de relancer `./install.sh`. Le système redémarrera avec toutes les données exactes du moment de la coupure.

## 4. Journal de bord
Le détail de ce qui a été fait à chaque séance, ainsi que les problèmes rencontrés et résolus, se trouvent dans le fichier `suivi_projet.md`.
