# ARES -- Exercices IA-safe a distribuer

Ce dossier contient les supports distribuables aux etudiants pour le projet fil rouge ARES.

Objectif : produire une architecture defendable a partir de donnees imposees en seance. Une reponse generique, meme correcte, ne suffit pas.

Le socle commun du projet est ARESlabs, documente dans
[`../projet/README.md`](../projet/README.md). Les profils de ce dossier
personnalisent ce socle pour chaque groupe.

## Contenu

- `00_sujet_etudiants.md` : consignes generales du projet.
- `01_gabarit_rendu.md` : structure obligatoire de chaque livrable.
- `02_jeux_de_donnees.md` : donnees variables a attribuer aux groupes.
- `03_incidents_tirage.md` : incidents a tirer au sort.
- `04_grille_verification.md` : checklist d'auto-evaluation avant rendu.
- `module_1_exercice.md` a `module_8_exercice.md` : exercices par module.

## Utilisation recommandee

1. Donner `00_sujet_etudiants.md` et `01_gabarit_rendu.md` a tous les groupes.
2. Presenter le scenario et la topologie canoniques dans `../projet/`.
3. Attribuer a chaque groupe un profil dans `02_jeux_de_donnees.md`.
4. Distribuer l'exercice du module concerne.
5. En fin de seance, tirer un incident dans `03_incidents_tirage.md`.
6. Evaluer avec la grille du module projet et la checklist `04_grille_verification.md`.

## Regle IA-safe

Les etudiants peuvent utiliser une IA comme assistant de reformulation ou de verification. En revanche, ils doivent exploiter les donnees specifiques donnees en seance : plan IP incomplet, logs, sorties de commandes, contraintes et incident impose. Sans preuves reliees a ces donnees, la reponse est consideree incomplete.
