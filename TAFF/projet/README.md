# ARESlabs -- Projet fil rouge ARES

ARESlabs est le socle technique commun des huit modules. Chaque groupe part de
la même maquette, reçoit un profil métier différent, puis fait évoluer
l'architecture en justifiant et en validant ses décisions.

Le projet articule trois niveaux :

1. le **profil de groupe** fournit les exigences, le budget, les risques et les
   contraintes propres à l'entreprise ;
2. **ARESlabs** fournit la topologie de référence et les composants à
   configurer ;
3. les **TP** fournissent des maquettes Linux légères pour expérimenter chaque
   mécanisme avant son intégration dans l'architecture cible.

## Parcours recommandé

1. Lire [`00_scenario_fil_rouge.md`](00_scenario_fil_rouge.md).
2. Utiliser la topologie et les adresses de
   [`01_topologie_canonique.md`](01_topologie_canonique.md).
3. Suivre les jalons de
   [`02_progression_modules.md`](02_progression_modules.md).
4. Définir les preuves avec
   [`03_plan_validation.md`](03_plan_validation.md).
5. Faire évoluer [`source_of_truth_cible.yaml`](source_of_truth_cible.yaml),
   puis la valider avec les outils du module 8.

Les exercices et profils sont dans [`../jeux_donnees/`](../jeux_donnees/)
et les manipulations dans [`../tps/`](../tps/).

## Statut des fichiers historiques

Les PDF (`labs.pdf`, `etapes.pdf`, `etap1.pdf`, les schémas et les challenges)
sont conservés comme documents d'origine. Ils restent utiles pour comprendre
la première intention du laboratoire, mais ils ne constituent plus la source
de vérité pour les adresses ou l'état cible.

En cas de divergence, l'ordre d'autorité est :

1. `source_of_truth_cible.yaml` pour les objets réseau ;
2. `01_topologie_canonique.md` pour l'intention d'architecture ;
3. le profil attribué pour les contraintes métier ;
4. les PDF historiques comme éléments de contexte.

## Limite structurante

La maquette imbrique `vm1-Host` et `vm2-Host` sur un seul serveur Ubuntu. Elle
permet de valider segmentation, routage, sécurité, observabilité et
automatisation, mais elle ne prouve pas une haute disponibilité physique. Une
architecture de production doit séparer les hôtes, alimentations, liens WAN et
domaines de panne.
