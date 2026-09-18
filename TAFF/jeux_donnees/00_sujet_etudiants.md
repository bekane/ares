# Projet fil rouge ARES -- Sujet et consignes

Vous êtes l'équipe d'architecture réseau d'une entreprise multi-sites. Votre objectif est de construire progressivement une architecture réseau défendable.

## Socle technique commun

Tous les groupes utilisent ARESlabs, décrit dans
[`../projet/README.md`](../projet/README.md), comme plateforme de référence.
`vm1-Host` et `vm2-Host` simulent deux sites, une DMZ héberge les services
initiaux et une zone Cloud simulée reçoit l'application critique.

Le profil attribué ne remplace pas ARESlabs : il indique les exigences métier
auxquelles la plateforme doit être adaptée. Les adresses d'infrastructure
communes sont définies dans
[`../projet/01_topologie_canonique.md`](../projet/01_topologie_canonique.md).
Les préfixes du profil représentent les réseaux métier à intégrer dans des
zones, VLAN, VRF ou namespaces dédiés.

Le projet avance module par module :

- M1 : cadrage, exigences, contraintes, flux.
- M2 : segmentation, dataplane Linux, policy enforcement.
- M3 : services critiques DHCP/DNS/IPAM.
- M4 : accès sécurisé VPN/ZTNA/SASE.
- M5 : observabilité, SLO, alertes, runbooks.
- M6 : réseau virtualisé et Cloud.
- M7 : fabric datacenter EVPN-VXLAN.
- M8 : automatisation, validation et NetDevOps.

La progression, les gates et les preuves minimales sont définies dans
[`../projet/02_progression_modules.md`](../projet/02_progression_modules.md).

## Ce qui est attendu

Chaque livrable doit contenir :

1. une décision d'architecture ;
2. les alternatives rejetées ;
3. une justification par exigences, contraintes et flux ;
4. des preuves issues des données fournies ;
5. un scénario de panne ou de dégradation ;
6. une validation.

## Règle importante

Une réponse générique ne suffit pas. Vous devez utiliser les données distribuées en séance : plan IP, logs, sorties de commandes, contraintes budgétaires, exigences de disponibilité ou incident tiré au sort.


