Regulierement des dechets (en rouge) apparaissent dans la simulation, chaque case de dechet contient entre 1 et 9 dechets
Une fourmis se deplace aléatoirement sauf si elle croise dans son champ de vision un dechet ou une zonne de phéromone et lorsqu'elle rammene un dechet.
Son champ de vison est divisé via la variable "adiv" (modulable)
Une fois qu'une fourmis recupere un dechet elle s'affiche en vert et depose du pheromone affiché en bleu qui s'evapore et se diffuse au fil du temps. (le degradé de bleu est fonction de la case qui contient le plus de phéromone)


Utilisation:

N donne le nombre de fourmis lancer au debut de la simulation

PerceptionVision donne le rayon de case que la fourmis voit dans son champ de vison (dans le sujet: 2)
AngleVison Correpond au degre de vison de la fourmis (dans le sujet: 360)


Evaporation correspond au taux de phéromone qui s'evapore à chaque tick sur chaque case

Diffusion correspond au taux de diffusion par case dans ses voisines du montant de feromone qu'elle contient

ShoPatchesWithPH affiche en bleu les case avec un montyant de phéromone > 0

Step lance la simulation

Ajouter et Supprimer module le nombre de fourmis (modifiable avec l'input à coté de ces boutons)

alpha affiche plus ou moins en rouge la vision de la fourmis
DirectionAlpha affiche plus ou moins en vert la direction que prend la fourmis, soit car elle a detecté des dechets soit car elle a decidé de suivre du phéromone

