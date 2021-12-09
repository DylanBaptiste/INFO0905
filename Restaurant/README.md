N correspond au nombre d'adresse à parcourir
Ns coresspond au nombre d'agent qui propose un solution

Les adresses (en gris) et le restaurant (en vert) sont placés aléatoirment

Les agents sont initialisé avec un parcours aléatoire
Les parcours commence forcement par le restaurant

N_Kill coresspond au nombre d'agent à tuer à chaque génération

Strategie de mutation:
Chaque agent effectue un nombre d'échange (voir plus bas) entre deux adresses

Strategie de remplacement:
Les N_Kill moins bon agent (chemin les plus longs) sont tués et remplacés par des proposition aléatoirement chsoisit dans les N_Kill - Ns meilleur solution

Evaulation d'un agent:
Somme des distances euclidiennes adresse apres adresse


Le graphique affiche le chemin le plus court pour chaque different type d'agent généré.
RangeSwapMin et RangeSwapMax determine le maximum d'echange à faire
Exemple :
Increment = 2
RangeSwapMin = 1
RangeSwapMax = 10
Permet de générer 5 type d'agents (chaque type d'agents comporte Ns agents). Chaque type est determiné par son nombre d'echange qu'il fera à chaque mutation. Dans cette exemple le type 1 fera un echnage de deux adresse lors de se mutation, le type 3 fera 3 echange etc...

N_kill est modifiable pendant la simulation

J'ai pu observer que le type 1 se bloque plus facilement dans des minima locaux tandis que ceux avec un grand nombre de swap converge moins vite car plus sujet au hasard mais son moins sujet aux minima locaux. Parfois le 1 tombe dans un minimum local où il faut au moins deux swap pour trouver une solution meilleur

Dans cet simulation N_Kill fait donc office de learning rate


Le tracé du parcours affcihé est celui le plus court à travers tout les types d'agents

Les boutons tempN Affciher Effacer permet d'afficher les tempN meilleur solutions (par types)


Je conseille de desactiver "view updates" pour faire les calcules plus rapidement