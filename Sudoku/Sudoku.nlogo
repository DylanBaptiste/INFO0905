extensions [matrix] ;; dieu merci
globals [min_score sudoku mean_random_score mean_swap_score mean_father_score] ;; variables globales
breed [ signs sign ] ;; utilisé pour l'affichage
signs-own [score su] ;; petit hack pour simplifier les calculs plus tard

;; les agents qui vont resoudre le sudoku
;; une race de solveur par strtegie de mutation
breed [ solveurs solveur ]
breed [ swap_solveurs swap_solveur ]
breed [ father_solveurs father_solveur ]
solveurs-own [su score]
swap_solveurs-own [su score]
father_solveurs-own [su score]

to setup
  ca ;; clear-all
  reset-ticks
  set min_score (1 / (9 * 3))

  plot-pen-up
  plotxy ticks min_score
  plot-pen-down
  plotxy ticks 1


  ;;set N 10 ;; Nombre d'agents
  ;;set M 1 ;; Afficher le resultat du meilleur agent tout les M ticks

  ;set sudoku matrix:from-row-list [ ;; inital sudoku à résoudre
    ;[0  0  3  0  2  0  6  0  0]
    ;[9  0  0  3  0  5  0  0  1]
    ;[0  0  1  8  0  6  4  0  0]
    ;[0  0  8  1  0  2  9  0  0]
    ;[7  0  0  0  0  0  0  0  8]
    ;[0  0  6  7  0  8  2  0  0]
    ;[0  0  2  6  0  9  5  0  0]
    ;[8  0  0  2  0  3  0  0  9]
   ; [0  0  5  0  1  0  3  0  0]
  ;]

  set sudoku matrix:from-row-list read-from-string Initial_Sudoku
  let filled_su matrix:copy first_fill matrix:copy sudoku

  if (is_legal sudoku != true)[
    output-print "Le sudoku à résoudre est illégal !\nChanger ça dans l'entrée 'Initial_Sudoku'"
    display-sudoku sudoku
    reset-ticks
    stop
  ]

  output-print "Le Sudoku: "
  output-print matrix:pretty-print-text sudoku

  set mean_random_score min_score
  set mean_swap_score min_score
  set mean_father_score min_score


  create-solveurs N [
    set su matrix:copy sudoku
    set score 0
    set size 0
  ]


  create-swap_solveurs N [
    set su matrix:copy filled_su
    set score 0
    set size 0
  ]

  create-father_solveurs N [
    set su matrix:copy sudoku
    set score 0
    set size 0
  ]

  ;; map chaque element pour l'afficher
  display-sudoku sudoku
  ;;print-sudoku sudoku
  reset-ticks
end

to step


  tick
  let displayresult? (ticks mod M) = 0
  ifelse (use_score = "score1")[
    ask turtles [set score score1 su]
  ][
    ask turtles [set score score2 su]
  ]


  ;; mutation
  ;if(use_random)[ask solveurs [set su random-mutation su]]
  if(use_random)[ask max-one-of solveurs [score] [ask other solveurs [set su random-mutation su]]]
  ;if(use_swap2)[ask swap_solveurs [set su swap_in_r-mutation su]]
  if(use_swap2)[ask max-one-of swap_solveurs [score] [ask other swap_solveurs [set su swap_in_r-mutation su]]]

  if(use_random)[set mean_random_score max [score] of solveurs]
  if(use_swap2)[set mean_swap_score max [score] of swap_solveurs]
  ;if(use_swap_rc)[set mean_father_score max [score] of father_solveurs]


  ;set-plot-y-range 0.5 1

  ;; afficher le meilleur de chaque mutation
  if(displayresult?)[

    ;plot-pen-up
    ;plotxy ticks min_score
    ;plot-pen-down
    ;plotxy ticks 1

    ;; tuer tout le monde sauf le meilleur
    kill

    clear-output
    output-print (list word "Génération: " (ticks / M))
    if(use_random)[
      ask solveurs [
        output-print (list "RANDOM" who score)
        output-print matrix:pretty-print-text su
      ]
    ]

    if(use_swap2)[ask swap_solveurs [
      output-print (list "SWAP" who score)
      output-print matrix:pretty-print-text su
    ]]

    ;if(use_swap_rc)[ask father_solveurs [
    ;  output-print (list "Father" who score)
    ;  output-print matrix:pretty-print-text su
    ;]]

    ;; le meilleur des meilleurs
    display-sudoku [su] of max-one-of turtles [score]

    ;; repopulation
    repopulation


  ]


end




to kill

  if(use_random)[ask max-one-of solveurs [score] [ask other solveurs [die]]]
  if(use_swap2)[ask max-one-of swap_solveurs [score] [ask other swap_solveurs [die]]]

  ;if(use_swap_rc)[ask other min-n-of (N - 2) father_solveurs [score] [die]]


end

to repopulation

  if(use_random)[
    create-solveurs (N - 1) [
      set su matrix:copy [su] of max-one-of solveurs [score]
      set size 0
    ]
  ]

  if(use_swap2)[
  create-swap_solveurs (N - 1) [
    set su matrix:copy [su] of max-one-of swap_solveurs [score]
    set size 0
  ]]

  ;if(use_swap_rc)[
 ;   let f_sus [su] of swap_solveurs
 ;   let s1 item 0 f_sus
 ;   let s2 item 1 f_sus
 ;   create-father_solveurs (N - 2) [
 ;     set su father-mutation s1 s2
 ;     set size 0
 ;   ]
  ;]

end

to-report random-mutation[s]
  ;; si un nombre peut etre placé à un endroit chosii au hasard non fixé par l'utilisateur, on le place
  ;; meme si on en ecrase un nombre deja bien placé
  let x random 9
  let y random 9
  let v ((random 8) + 1) ;; 1 à 9
  while [is_fixed x y] [
    set x random 9
    set y random 9
  ]
  ;if((is_fixed x y = false) and (is_legal_placement s x y v))[ matrix:set s x y v ]
  if(is_fixed x y = false)[ matrix:set s x y v ]
  report s
end

to-report swap-mutation[s]
  ;; si un nombre peut etre placé à un endroit chosii au hasard non fixé par l'utilisateur, on le place
  ;; meme si on en ecrase un nombre deja bien placé
  let max_loop 1000
  let ml 0
  let v1 -1
  let v2 -1
  let x1 random 9
  let y1 random 9
  let x2 random 9
  let y2 random 9

  while[(ml < max_loop)][
    set ml (ml + 1)
    set x1 random 9
    set y1 random 9
    set x2 random 9
    set y2 random 9
    set v1 matrix:get s x1 y1
    set v2 matrix:get s x2 y2
    if(v1 != v2 and (not is_fixed x1 y1) and (not is_fixed x2 y2))[
      ;print (list (list x1 y1 v1) (list x2 y2 v2) )
      matrix:set s x1 y1 v2
      matrix:set s x2 y2 v1
      report s
    ]
  ]
  report s
end
to-report swap_in_r-mutation[s]
  ;; on echange dans la meme row deux element non placé par l'utilisateur
  ;; puis la meme chose en colone

  let max_loop 1000
  let ml 0
  let v1 -1
  let v2 -1
  let x1 random 9
  let x2 random 9
  let y random 9

  while[(ml < max_loop)][
    set ml (ml + 1)
    set x1 random 9
    set x2 random 9
    set y random 9
    set v1 matrix:get s x1 y
    set v2 matrix:get s x2 y
    if(v1 != v2 and (not is_fixed x1 y) and (not is_fixed x2 y))[
      ;print (list (list x1 y1 v1) (list x2 y2 v2) )
      matrix:set s x1 y v2
      matrix:set s x2 y v1
      report s
    ]
  ]
  set ml 0
  while[(ml < max_loop)][
    set ml (ml + 1)
    set x1 random 9
    set x2 random 9
    set y random 9
    set v1 matrix:get s y x1
    set v2 matrix:get s y x2
    if(v1 != v2 and (not is_fixed y x1) and (not is_fixed y x2))[
      ;print (list (list x1 y1 v1) (list x2 y2 v2) )
      matrix:set s y x1 v2
      matrix:set s y x2 v1
      report s
    ]
  ]

  report s
end

to-report fill-mutation[s]
  ;; on cherche un emplacement vide et on place un nombre aléatoir

  foreach range 9 [x -> foreach range 9 [y ->
    if(matrix:get s x y = 0)[
      matrix:set s x y ((random 8) + 1)
      report s
    ]
  ]]

  ;; si tout est rempli on cherche un emplacement illégal et on change aléatoirement la valeur
  let x random 9
  let y random 9
  let v ((random 8) + 1) ;; 1 à 9
  while [(is_fixed x y = true) and (not is_legal_placement s x y matrix:get s x y)] [
    set x random 9
    set y random 9
  ]
  matrix:set s x y v
  report s
end


to-report father-mutation[s1 s2]
  let rid (random 9)
  let row matrix:get-row s1  rid
  matrix:set-row s2 rid row

  let cid (random 9)
  let col matrix:get-row s1  cid
  matrix:set-row s2 cid col

  report matrix:copy s2
end

to-report score1[s]
  ;; on compte pour chaque row, chaque col, chaque block le nombre d'elements unique
  if(su = 0)[report -1]
  let final_score 0.0
  let  c_score 0
  let  r_score 0
  let  b_score 0
  let elements (list)

  foreach range 9 [idx ->
    foreach (matrix:get-row s idx)[ element -> set elements insert-item 0 elements element ]
    set elements remove-duplicates elements
    set elements remove 0 elements
    set r_score  (r_score + (length elements))

    foreach (matrix:get-column s idx)[ element -> set elements insert-item 0 elements element ]
    set elements remove-duplicates elements
    set elements remove 0 elements
    set c_score  (c_score + (length elements))
  ]

  foreach [0 3 6][ x -> foreach [0 3 6][ y ->
    set elements flatten-list matrix:to-row-list matrix:submatrix s x y (x + 3) (y + 3)
    set elements remove-duplicates elements
    set elements remove 0 elements
    set b_score  (b_score + (length elements))
  ]]

  set final_score ((r_score / 81) * (c_score / 81) * (b_score / 81))
  report final_score
  ;max score: 81*3
  ;min score 9 * 3, ... +
  ;report ((b_score + c_score + r_score )/ (81 * 3))
end

to-report score2[s]
  ;; on compte simplement le nombre d'élement bien placé
  if(su = 0)[report 0]
  let final_score 0
  foreach range 9 [x -> foreach range 9 [y ->
    if((matrix:get s x y != 0) and (is_fixed x y or is_legal_placement s x y matrix:get s x y ) )[
      set final_score final_score + 1
    ]
  ]]
  report (final_score / 81)
end






;; utils functions

to-report first_fill[s]
  let s_count [0 0 0 0 0 0 0 0 0 0]
  foreach range 9 [x -> foreach range 9 [y ->
    let v matrix:get s x y
    let nv item v s_count + 1
    set s_count replace-item v s_count nv
  ]]
  foreach range 9 [x ->
    foreach range 9 [y ->
      if(not is_fixed x y and matrix:get s x y = 0)[
        foreach (range 1 10) [z ->
          ;if item 0 s_count = 0 [report s]
          if(item z s_count < 9 and matrix:get s x y = 0)[
            set s_count replace-item z s_count ((item z s_count) + 1)
            set s_count replace-item 0 s_count ((item 0 s_count) - 1)
            matrix:set s x y z
          ]
        ]
      ]
    ]
  ]
  print s
  report s
end

to-report is_legal [s]

  foreach range 9 [ li -> ;; lignes
    if(is_legal_list matrix:get-row s li != true)[report (list false "row" li)]
  ]

  foreach range 9 [ ci -> ;; colones
    if(is_legal_list matrix:get-column s ci != true)[report (list false "column" ci)]
  ]

  foreach [0 3 6][ x ->
    foreach [0 3 6][ y ->
      if(is_legal_list flatten-list matrix:to-row-list matrix:submatrix s x y (x + 3) (y + 3) != true)[
        ;;print (list false "block" x y (x + 3) (y + 3))
        report false
      ]
    ]
  ]
  report true
end

to-report is_legal_block [s x y] ;; verifie si un block 3*3 est legal ou non x y la coordonée haute gauche du block (inclusif)
  if(is_legal_list flatten-list matrix:to-row-list matrix:submatrix s x y (x + 3) (y + 3) != true)[
      ;;print (list false "block" x y (x + 3) (y + 3))
      report false
    ]
  report true
end

to-report is_legal_list[l] ;; prend une colone ou une ligne et verifie qu'il n'y a pas d'elements dupliqué dedans
  foreach range 9 [ x1 ->
    foreach range 9 [ x2 ->
      if (x1 != x2) and (item x1 l != 0 and item x2 l != 0) and (item x1 l = item x2 l) [ ;; les elements qu'on regarde ne sont pas les memes ET un des item n'est pas 0 ET x1 == x2 -> illégal
        ;;print (list x1 x2 false)
        report false
      ]
    ]
  ]
  report true
end

to-report is_duplicate_in_list[l v];; compte le nombre de fois que v se trouve dans l, si > 1 => illégal
  let count_v 0
  foreach range 9 [ x1 ->
    if (item x1 l = v) [
      set count_v count_v + 1
    ]
    if(count_v > 1) [
      ;;print (list l v count_v)
      report true
    ]
  ]
  ;;print (list l v count_v)
  report false
end

to-report is_legal_placement [s x y value] ;; verifie si le placement d'un nombre est legal ou pas

  if(is_fixed x y = true)[ report false ]
  ;;let initial_value matrix:get s x y ;; on save la valeur initial
  ;;matrix:set s x y value
  let xb floor (x / 3) * 3
  let yb floor (y / 3) * 3

  let l_dup is_duplicate_in_list (matrix:get-row s x) value
  let c_dup is_duplicate_in_list (matrix:get-column s y) value
  let b_dup is_duplicate_in_list (flatten-list matrix:to-row-list matrix:submatrix s xb yb (xb + 3) (yb + 3)) value


  if(l_dup or c_dup or b_dup)[
    ;print(list value x y "ce placement est illégal" l_dup c_dup b_dup)
    ;;matrix:set s x y initial_value
    report false
  ]

  ;;matrix:set s x y initial_value
  report true
end

;;to-report is_legal_placement [s x y value] ;; verifie si le placement d'un nombre est legal ou pas
;;
;;  let initial_value matrix:get s x y ;; on save la valeur initial
;;  matrix:set s x y 0
;;
;;  let l_legal_before is_legal_list matrix:get-row s x
;;  let c_legal_before is_legal_list matrix:get-column s y
;;  let b_legal_before is_legal_block s (floor (x / 3)) (floor (y / 3)) ;; !! on floor x et y / 3 pour connaitre la coord du block auquel appartient le coord (x, y)
;;
;;  if(not (l_legal_before and c_legal_before and b_legal_before))[
;;    ;;print(list "Probleme en" x y "la ligne, colone ou block est illégale et l'agent tente de mettre une valeur")
;;    matrix:set s x y initial_value
;;    report false
;;  ]
;;
;;  matrix:set s x y value ;; on place la valeur
;;
;;  let l_legal_after is_legal_list matrix:get-row s x
;;  let c_legal_after is_legal_list matrix:get-column s y
;;  let b_legal_after is_legal_block s (floor (x / 3)) (floor (y / 3))
;;
;;  if(not (l_legal_after and c_legal_after and b_legal_after))[
;;    ;;print(list value x y "ce placement est illégal")
;;    matrix:set s x y initial_value
;;    report false
;;  ]
;;
;;  matrix:set s x y initial_value
;;  report true
;;end

to-report is_fixed [x y]
  report matrix:get sudoku x y != 0
end



to-report is_legal_placement_fixed [s x y value] ;; verifie si le placement d'un nombre est legal ou pas

  ;;let initial_value matrix:get s x y ;; on save la valeur initial
  ;;matrix:set s x y value
  let xb floor (x / 3) * 3
  let yb floor (y / 3) * 3

  let l_dup is_duplicate_in_list (matrix:get-row s x) value
  let c_dup is_duplicate_in_list (matrix:get-column s y) value
  let b_dup is_duplicate_in_list (flatten-list matrix:to-row-list matrix:submatrix s xb yb (xb + 3) (yb + 3)) value


  if(l_dup or c_dup or b_dup)[
    ;print(list value x y "ce placement est illégal" l_dup c_dup b_dup)
    ;;matrix:set s x y initial_value
    report false
  ]

  ;;matrix:set s x y initial_value
  report true
end

to set-vue [s x y] ;; affichage
  let value matrix:get s x y ;; (penser à setup la vue en 8 x 8, location origine : corner top-left)
  ifelse value > 0 [
    create-signs 1 [
      set score -1
      setxy (y + 0.1) (- x - 0.25) ;; placement avec offset inversé car la vue l'est
      set size 0 ; hide the turtle, but not the label
      set label value
      ;; pour les couleurs: http://ccl.northwestern.edu/netlogo/docs/programming.html#colors
      set label-color white
      ifelse(is_fixed x y)[
        set pcolor [25 63 25]
        set label-color [0 255 0]
        if (not is_legal_placement_fixed s x y matrix:get s x y )[
          ;set pcolor [127 63 63]
          set label-color [255 0 0]
        ]
      ][

        set pcolor [63 63 63]
        set label-color [0 255 0]

        if (not is_legal_placement s x y matrix:get s x y )[
          set pcolor [127 63 63]
          set label-color [255 0 0]
        ]
      ]


    ]
  ][
    create-signs 1 [
      set score -1
      setxy (y + 0.1) (- x - 0.25) ;; placement avec offset inversé car la vue l'est
      set size 0 ; hide the turtle, but not the label
      set label ""
      ;; pour les couleurs: http://ccl.northwestern.edu/netlogo/docs/programming.html#colors
      set label-color black
      set pcolor black
    ]
  ]
end

to display-sudoku [s]
  ask signs [ die ]
  foreach range 9 [x -> foreach range 9 [y -> set-vue s x y]]
end
to print-sudoku [s]
  print matrix:pretty-print-text s
end


to-report flatten-list [ xs ]
  let ys reduce sentence xs
  report ifelse-value (reduce or map is-list? ys) [ flatten-list ys ] [ ys ]
end
@#$#@#$#@
GRAPHICS-WINDOW
306
10
799
504
-1
-1
53.9
1
20
1
1
1
0
0
0
1
0
8
-8
0
1
1
1
ticks
30.0

BUTTON
0
10
169
89
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
2
195
295
335
GO
step
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

OUTPUT
798
10
1106
502
11

PLOT
0
505
802
791
mean score
Génération
Max  Score
0.0
0.0
0.0
1.0
true
true
"set mean_random_score min_score" ""
PENS
"M" 1.0 0 -4539718 true "" ""
"Random" 1.0 0 -13791810 true "" "if (ticks + 1) mod M = 0 [plot mean_random_score]"
"Swap" 1.0 0 -2674135 true "" "if (ticks + 1) mod M = 0 [plot mean_swap_score]"

BUTTON
6
349
298
487
STEP
repeat M [step]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
0
89
80
149
M
5.0
1
0
Number

INPUTBOX
80
90
169
150
N
20.0
1
0
Number

INPUTBOX
169
10
306
193
Initial_Sudoku
[[3 0 0 0 1 9 0 0 0]\n [0 9 6 0 2 8 4 3 1]\n [1 5 2 0 4 7 6 8 0]\n [0 6 7 0 0 0 0 0 0]\n [8 0 5 0 0 0 3 0 6]\n [0 0 0 0 0 0 0 7 0]\n [0 0 0 2 3 0 9 6 0]\n [5 0 0 0 6 0 0 0 0]\n [0 2 0 8 0 0 1 0 7]]
1
1
String

MONITOR
800
501
970
562
Meilleur score
[score] of max-one-of turtles [score]
17
1
15

SWITCH
799
563
970
596
use_random
use_random
0
1
-1000

SWITCH
799
596
970
629
use_swap2
use_swap2
0
1
-1000

CHOOSER
0
148
169
193
use_score
use_score
"score1" "score2"
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
