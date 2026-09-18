# Jeux de données variables

Attribuer un profil différent à chaque groupe. Les groupes ne doivent pas tous recevoir les mêmes contraintes.

## Profil A -- Siège industriel

Sites :

- Siège Rennes : 900 utilisateurs, datacenter principal.
- Usine Nantes : 350 utilisateurs, supervision industrielle.
- Agence Brest : 80 utilisateurs.
- Agence Paris : 140 utilisateurs.
- Cloud public : application ERP secondaire.

Contraintes :

- RTO application production : 2 h.
- RPO données critiques : 30 min.
- Budget WAN limité pour les agences.
- Administration réseau uniquement depuis bastions.

Plan IP partiel :

| Zone | Préfixe | Remarque |
| --- | --- | --- |
| Users Rennes | 10.10.10.0/23 | DHCP requis |
| Admin Rennes | 10.10.250.0/24 | accès restreint |
| Prod DC | 10.20.0.0/22 | services critiques |
| Nantes OT | 10.30.10.0/24 | isolation forte |
| Paris Users | 10.10.10.0/24 | conflit volontaire avec Rennes |

## Profil B -- Entreprise SaaS

Sites :

- Siège Lyon : 250 utilisateurs.
- Datacenter privé : 120 serveurs.
- Cloud public : production principale.
- Support distant : 80 télétravailleurs.
- Partenaire externe : accès API uniquement.

Contraintes :

- SLO API client : 99,9 % mensuel.
- Accès partenaire limité à une application.
- Journalisation obligatoire des accès admin.
- Croissance prévue : x2 utilisateurs en 18 mois.

Plan IP partiel :

| Zone | Préfixe | Remarque |
| --- | --- | --- |
| Users Lyon | 10.40.10.0/24 | DHCP requis |
| Admin | 10.40.250.0/24 | MFA + bastion |
| DMZ API | 10.50.20.0/24 | exposé partenaire |
| Cloud Prod | 10.60.0.0/20 | connectivité hybride |
| VPN Remote | 10.40.10.128/25 | chevauchement volontaire |

## Profil C -- Université multi-campus

Sites :

- Campus principal : 3000 étudiants, 500 personnels.
- Campus santé : 600 utilisateurs.
- Campus recherche : 400 utilisateurs.
- Résidence : 1200 utilisateurs.
- Cloud : outils collaboratifs.

Contraintes :

- Segmentation étudiants/personnels/recherche.
- Wi-Fi invité fortement isolé.
- DNS interne critique pour applications métier.
- Coût par site à justifier.

Plan IP partiel :

| Zone | Préfixe | Remarque |
| --- | --- | --- |
| Étudiants | 10.70.0.0/20 | forte volumétrie |
| Personnels | 10.70.16.0/22 | accès SI interne |
| Recherche | 10.70.20.0/23 | données sensibles |
| Invités | 10.70.22.0/24 | Internet seul |
| Résidence | 10.70.0.0/21 | conflit volontaire |

## Profil D -- Groupe retail

Sites :

- Siège Lille : 300 utilisateurs.
- 40 magasins : 10 à 25 utilisateurs chacun.
- Datacenter externalisé.
- Cloud SaaS caisse/inventaire.
- Équipe IT en télétravail partiel.

Contraintes :

- Magasins peu administrés localement.
- Perte WAN magasin tolérable 4 h sauf caisse.
- Budget équipement magasin faible.
- Besoin de diagnostic centralisé.

Plan IP partiel :

| Zone | Préfixe | Remarque |
| --- | --- | --- |
| Siège Users | 10.80.10.0/24 | DHCP |
| Siège Admin | 10.80.250.0/24 | IT |
| Magasin type | 10.81.X.0/24 | X = numéro magasin |
| Caisse | 10.81.X.128/26 | prioritaire |
| Invités | 10.81.X.160/27 | chevauchement volontaire avec caisse |

## Logs et sorties communes à distribuer ponctuellement

### DNS

```text
2026-09-08T10:14:22 dns-rec-1 query[A] erp.interne.example from 10.10.10.44 SERVFAIL
2026-09-08T10:14:23 dns-rec-2 query[A] erp.interne.example from 10.10.10.44 NOERROR 10.20.0.15
2026-09-08T10:15:01 dns-auth-1 zone transfer to 10.10.250.12 denied: bad TSIG
```

### Linux dataplane

```text
$ ip rule
0:      from all lookup local
100:    from 10.10.250.0/24 lookup admin
200:    from 10.10.10.0/23 lookup users
32766:  from all lookup main

$ ip route get 10.20.0.15 from 10.10.10.44
10.20.0.15 from 10.10.10.44 via 10.10.254.1 dev vlan10 table users
```

### VPN

```text
peer: site-paris
  endpoint: 198.51.100.24:51820
  allowed ips: 10.10.10.0/24, 10.20.0.0/22
  latest handshake: 2 minutes ago
  transfer: 84.2 MiB received, 12.7 MiB sent
```

### Observabilité

```text
ALERT WanPacketLossHigh
site="nantes" link="wan1" loss="8.2%" duration="12m"

ALERT DnsServfailRatioHigh
resolver="dns-rec-1" ratio="18%" duration="7m"
```

### EVPN

```text
VNI 10110 tenant prod state up
VTEP 10.255.0.11 reachable
VTEP 10.255.0.12 unreachable
MAC 52:54:00:aa:10:15 IP 10.10.110.15 missing from EVPN table
```
