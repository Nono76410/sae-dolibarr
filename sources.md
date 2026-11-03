# Sources et Ressources utilisées

Ce fichier liste les différentes sources documentaires et outils qui nous ont aidés à réaliser ce projet.

## Documentation officielle
* **Wiki Dolibarr (Modèle de données) :** 
  Pour comprendre la structure de la base de données et notamment les champs obligatoires de la table `llx_societe`.
  https://wiki.dolibarr.org/

* **Dépôt GitHub de Dolibarr :** 
  Pour analyser les scripts d'installation par défaut et adapter notre `docker-entrypoint.sh`.
  https://github.com/Dolibarr/dolibarr/

* **Documentation Docker & MariaDB :** 
  Pour la création des Dockerfiles, la gestion des volumes (PRA) et la configuration du `docker-compose.yml`.
  https://hub.docker.com/_/mariadb

## Ressources du cours
* **Dépôt du professeur (S. Kramm) :**
  Pour l'inspiration sur la conteneurisation de la base de données.
  https://github.com/skramm/but3_rt/tree/main/docker_BDD

## Outils d'assistance
* **Intelligence Artificielle (Gemini) :**
  Utilisée en tant qu'assistant de codage pour la syntaxe Bash, le formatage des requêtes SQL dans le script d'import, et l'optimisation des `Dockerfile`.