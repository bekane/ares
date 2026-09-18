# Topologie et adressage canoniques

## Topologie logique

voir images/topo.png

Le GRE des premières étapes sert à observer l'overlay. À partir du module 4, le
chemin intersite cible est chiffré avec WireGuard/IPsec ou une solution
équivalente. Au module 7, une variante VXLAN/EVPN est ajoutée ; elle ne remplace
le WAN chiffré que si ce choix est explicitement justifié.

L'underlay reste un réseau IP routé et ne reçoit pas de VNI. Les VNI de la
source de vérité correspondent uniquement aux segments transportés par
l'overlay VXLAN.

## Plan d'adressage arbitré

| Zone | Préfixe | Affectations de référence |
| --- | --- | --- |
| Management | `10.0.10.0/24` | hôte `.1`, `vm1-Host` `.11`, `vm2-Host` `.21`, `vm-mgnt` `.31`, NetBox `.60` |
| Underlay/data | `10.0.20.0/24` | passerelle `.1`, `vm1-router` `.2`, `vm1-Host` `.11`, `vm2-Host` `.21`, `vm2-router` `.22` |
| Liaison GRE de lab | `100.64.0.0/30` | site 1 `.1`, site 2 `.2` |
| Overlay applicatif | `172.16.30.0/24` | `vm1-router` `.1`, `vm2-router` `.254` |
| DMZ | `192.0.2.0/27` | `vm2-router` `.1`, `vm2` `.10`, `www` `.11` |
| Cloud simulé | `10.0.40.0/24` | `cloud-gw` `.1`, `app-cloud` `.10` |

Les préfixes de documentation `192.0.2.0/24` et la plage partagée
`100.64.0.0/10` ne doivent pas être repris tels quels en production. Ils sont
réservés ici à la maquette.

## Arbitrages par rapport aux PDF

Les choix suivants rendent les documents et l'automatisation non ambigus :

- `vm-mgnt` utilise `10.0.10.31`, valeur visible dans le schéma ; l'ancienne
  valeur `.50` est abandonnée ;
- le site 1 porte `100.64.0.1` et le site 2 `100.64.0.2` pour la liaison GRE ;
- `10.0.20.11/21` dans l'ancien tableau signifiait deux adresses, `.11` et
  `.21`, toutes deux en `/24` ;
- `vm2` et `www` sont placés dans la DMZ, conformément à leur fonction ;
- `10.0.40.0/24`, auparavant réservé, devient la zone Cloud simulée.

## Adresses du profil et adresses du laboratoire

Le plan ci-dessus décrit l'infrastructure commune. Les préfixes propres au
profil A, B, C ou D décrivent les réseaux métier. Ils sont représentés dans des
VRF, VLAN ou namespaces séparés et ne remplacent pas automatiquement les
adresses de gestion du laboratoire.

Si un TP emploie un plan simplifié différent, le livrable fournit une table de
correspondance entre l'objet du TP et l'objet ARESlabs. Par exemple,
`ns_admin` représente la zone d'administration et `ns_prod` une zone de
production, indépendamment de leur adresse locale dans le script.

## Domaines de panne

Dans la maquette, tous les composants partagent un seul domaine de panne
physique. Dans la cible de production, `site 1`, `site 2` et `Cloud` sont trois
domaines distincts. Les doubles liens ne sont considérés indépendants que s'ils
n'utilisent ni le même opérateur, ni le même équipement, ni le même chemin
physique.
