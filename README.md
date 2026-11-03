# SAE 51 - Installation d'un ERP/CRM (Dolibarr)

**Étudiants :** Pay Nolan & Ouerdane Gwen  
**Date :** Octobre 2026

## Description du projet
Ce projet permet de déployer automatiquement Dolibarr et sa base de données (MariaDB) à l'aide de Docker. Il inclut aussi un script pour importer une liste de clients et fournisseurs directement depuis un fichier CSV.

## Prérequis
- Docker Desktop installé et démarré ;
- Docker Compose (inclus avec Docker Desktop) ;
- Git Bash ou WSL pour exécuter les scripts Bash sous Windows.

## 1. Installation
Pour lancer l'installation complète, exécutez le script suivant à la racine du projet :

```bash
./install.sh
```

Ce script va lancer les conteneurs via `docker-compose` et configurer Dolibarr pour qu'il soit prêt à l'emploi, en évitant de devoir remplir les étapes sur la page web.

Les données MariaDB sont conservées dans `mariadb/data/`. Les documents et la
configuration Dolibarr sont conservés dans des volumes Docker nommés. Un simple
redémarrage ne supprime donc pas les données :

```bash
docker compose restart
```

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
La persistance locale de `mariadb/data/` permet de redémarrer après un arrêt
simple, mais ce n'est pas une sauvegarde suffisante pour un PRA. La sauvegarde
portable créée par `backup.sh` contient :

- un dump SQL complet de la base MariaDB ;
- les documents déposés dans Dolibarr ;
- la configuration de Dolibarr ;
- un manifeste identifiant le format de l'archive.

Elle doit être copiée sur un support différent du serveur :

```bash
./backup.sh
# ou vers un autre dossier : ./backup.sh /chemin/vers/le/support
```

### Test d'une sauvegarde

Après avoir ajouté des données de test, créer une archive puis vérifier son
contenu :

```bash
./import.sh data/test.csv
./backup.sh ./backups
tar -tzf ./backups/dolibarr-AAAAMMJJ-HHMMSS.tar.gz
```

L'archive doit contenir `database.sql`, `documents/`, `conf/` et `manifest`.

### Reprise après incident

Pour repartir de zéro, arrêter les services et supprimer les volumes Docker :

```bash
docker compose down -v
```

Puis restaurer la sauvegarde avec la procédure d'installation :

```bash
./install.sh --restore ./backups/dolibarr-AAAAMMJJ-HHMMSS.tar.gz
```

La restauration recrée la base, réimporte les données SQL et remet en place les
documents et la configuration des volumes Docker. Il ne faut pas restaurer
automatiquement à chaque démarrage : un dossier `mariadb/data/` non vide
correspond normalement aux données actives et pourrait contenir des données
plus récentes que l'archive.

## 4. Arrêt et gestion des conteneurs

```bash
# Arrêter sans supprimer les données
docker compose stop

# Relancer les services existants
docker compose start

# Arrêter et supprimer les conteneurs, en conservant les volumes
docker compose down

# Arrêter et supprimer également les volumes (à réserver à un test PRA)
docker compose down -v
```

## 5. Journal de bord
Le détail de ce qui a été fait à chaque séance, ainsi que les problèmes rencontrés
et résolus, se trouve dans le fichier `Suivi_projet.md`.
