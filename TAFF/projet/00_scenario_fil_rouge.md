# Scénario fil rouge ARESlabs

## Mission

L'équipe doit faire évoluer le SI d'une organisation multi-site qui ouvre deux
sites, expose certains services en DMZ et migre une application critique vers
le Cloud. Elle doit réduire le temps d'indisponibilité tout en conservant une
architecture exploitable par une petite équipe.

Chaque groupe reçoit un profil A, B, C ou D dans
[`../jeux_donnees/02_jeux_de_donnees.md`](../jeux_donnees/02_jeux_de_donnees.md).
Le profil fixe le contexte métier ; ARESlabs est la plateforme commune utilisée
pour prototyper et prouver les choix.

## État initial

Un hôte Ubuntu fournit KVM/Libvirt, Open vSwitch et un conteneur NetBox. Deux
hyperviseurs invités simulent deux sites :

- `vm1-Host` héberge la gestion et le routeur du site 1 ;
- `vm2-Host` héberge le routeur du site 2, une DMZ et les services `vm2` et
  `www` ;
- `ovs-br-mgnt` porte l'administration de la plateforme ;
- `ovs-br-lan` porte l'underlay ;
- un tunnel GRE relie les deux sites simulés ;
- OpenTofu et Ansible construisent et configurent le laboratoire.

Au démarrage du projet, cette architecture est volontairement incomplète :
GRE n'est pas chiffré, plusieurs composants sont uniques, le Cloud n'est pas
encore raccordé et les objectifs de service dépendent du profil.

## État cible attendu

À la fin du module 8, le dossier d'architecture doit montrer :

- des zones de confiance et une matrice de flux explicites ;
- un adressage sans chevauchement porté par une source de vérité ;
- une continuité locale des services essentiels en cas de perte WAN ;
- des accès intersites, distants et partenaires chiffrés et contrôlés ;
- une zone Cloud distincte contenant la cible de l'application critique ;
- des SLI/SLO, alertes et runbooks pour les dépendances critiques ;
- un chemin paquet documenté de la VM au réseau physique ;
- une évolution EVPN-VXLAN permettant de raisonner sur la perte d'un leaf ;
- un pipeline qui valide l'état désiré avant déploiement et sait revenir en
  arrière.

## Représentation du Cloud

Le Cloud est simulé par le préfixe `10.0.40.0/24`, une passerelle
`cloud-gw` et une charge `app-cloud`. Selon les moyens disponibles, cette zone
peut être réalisée par des namespaces, des VMs ou un VPC réel. Le mode de
réalisation peut changer ; les flux autorisés et les critères de service ne
changent pas.

L'application `www` constitue la version initiale en DMZ. Sa migration vers
`app-cloud` doit être préparée, observée et testée. Le groupe précise ce qui est
migré, la synchronisation des données, la méthode de bascule et le retour
arrière.

## Règles pédagogiques

- Une technologie n'est retenue que si elle répond à une exigence ou à un
  risque du profil.
- Toute décision comporte une alternative rejetée et une limite connue.
- Chaque jalon ajoute une preuve reproductible : commande, test, trace,
  métrique ou résultat de validation.
- Les contradictions présentes dans les PDF historiques doivent être
  détectées ; les valeurs arbitrées sont ensuite enregistrées dans la source de
  vérité canonique.
- Les pannes de la maquette prouvent un comportement logique. Elles ne prouvent
  une disponibilité physique que sur des domaines de panne réellement
  distincts.
