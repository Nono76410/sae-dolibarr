## Séance n° 1
* 05/10 16H-17H30
* Recherche sur dolibar + installation de la VM.
* Création du github. 
* Mise en place du début d’un schéma et discussion sur la solution à envisager.
* Aucune pour le moment
* Manque de temps car on à commencé tard suite au explication.

## Séance n° 2
* 06/10 8H30-10H
* Création de la vm avec dolibarr
* on a commencer a faire les 2 docker
* à faire mise en place des 2 docker files
* à faire Configuration dolibarr

## Séance n° 2.5 
* 07/10 19H30-23H20
* Compréhension de l'architecture
* Mise en place du docker avec ces scripts. 
* ajout de la persistence de la base dans le dossier data. 
* Prochaine étape : Faire en sortes que les mdps ne soit pas en clair et réaliser les test. 

## Séance n° 3
* 08/10 13H00-16H00
* modification et finalisation de la configuration
* centralisation des mdp dans docker-compose
* Création du script install.sh et import.sh
* à faire test de fin et finalisation + optimisation pour la db

## Séance 4 
* 02/11 13H00-16H00
* Rédaction de la documentation technique (`README.md`). 
* Analyse des tables SQL générées par Dolibarr (ex: `llx_societe`). 
* Ajout des sources et objectifs en en-tête des scripts. 
* Documentation du PRA (Plan de Reprise d'Activité). 

## Séance 5
* 03/11 16H00-17H30
* Vérification du besoin de sauvegarde dans le cadre d'un PRA.
* Ajout du script `backup.sh`, qui génère une archive portable contenant la
  base MariaDB, les documents Dolibarr et sa configuration.
* Ajout du script `restore.sh` et de l'option
  `./install.sh --restore <sauvegarde.tar.gz>` pour repartir de zéro après un
  incident.
* Correction de l'initialisation du conteneur web afin de ne pas écraser une
  configuration restaurée.
* Complément du `README.md` avec les procédures de sauvegarde, de test et de
  restauration.
* Décision de ne pas restaurer automatiquement au démarrage : un dossier
  `mariadb/data/` non vide contient normalement les données actives et une
  restauration automatique pourrait les écraser.
* Création des slides pour la soutenance orale. 
* Préparation des explications sur nos choix techniques et problèmes résolus. 
* Rangement final du GitHub (déplacement du CSV dans le dossier `data/`). 
