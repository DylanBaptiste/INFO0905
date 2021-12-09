Initial_Sudoku permet de modifier le sudoku à resoudre
M et N comme decrit dans le sujet

Les case en fond vert sont celles ficé par l'utilisateur
Les nombres en rouge sont ceux qui ne respecte pas les regles

Dans cette simulation il y a deux types d'agents avec des stategies de mutation differente

Strategie de mutation:
- Random : Choisit une case aléatoire non fixé par l'utilisateur et place un nombre aléatoirement dedans sans aucunes verification de conformité
- Swap: Choisit dans une colonne deux elements (si possible) non fixé par l'utilisateur et les echange. Puis fait la meme chose dans une ligne

Strategie de repeuplement:
Par type : le meilleur agent est gardé en vie et tout les autres sont tués. Puis on repeuple (aux meme nombre qu'avant) en copiant le meilleur puis en mutant

Strategie d'evaluation:
Dans cette simulation il existe deux manière de calculer le score:
- Score1: calcule le nombre d'element non dupliqué par ligne, colonne et block (valeur entre 0 et 1)
- Score2: calcule simplement le nombre d'elements placé qui respecte les regles du sudoku


Le score peut etre choisi avec le menu deroulant "use_score"

Il s'avere que le choit du score à un impacte tres important!
Score2 est une meniere naïve d'avluer les agents car on tombe rapidement dans des minima locaux, cepeendant il permet de rapidement avoir beaucoup d'element bien placé mais il est tres difficile voir paerfois impossible d'arriver à la solution

Score1 est plus interessant car il permet de plus representer la contrainte du sudoku dans le score des agents, cepedant il donnera toujours de moins resultat en terme de resolution du sudoku (plus de case rouge) à moins d'un tres long moment de calcul

Dans les deux cas un score à 1 coresspond à un sudoku resolut


Je conseille de desactiver "view updates" pour faire les calcules plus rapidement