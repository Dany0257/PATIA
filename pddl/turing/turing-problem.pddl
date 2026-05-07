(define (problem add-one)
  (:domain turing-machine)
  
  (:objects
    ;; 6 cases pour le ruban
    c1 c2 c3 c4 c5 c6
    
    ;; L'alphabet
    zero one blank
    
    ;; Les états
    z0 z1 zh
  )

  (:init
    ;; Structure du ruban
    (right c1 c2) (right c2 c3) (right c3 c4) (right c4 c5) (right c5 c6)
    
    ;; Contenu initial du ruban : [blank, 1, 0, 1, 1, blank]
    (content c1 blank)
    (content c2 one)
    (content c3 zero)
    (content c4 one)
    (content c5 one)
    (content c6 blank)
    
    ;; Position initiale de la machine
    (state z0)
    (head c2) ;; Elle commence sur le premier chiffre du nombre
    
    ;; === LE PROGRAMME DE LA MACHINE DE TURING ===
    ;; Ligne z0 de la table (Avancer à droite jusqu'à la fin du mot)
    (rule-right z0 zero z0 zero)
    (rule-right z0 one  z0 one)
    (rule-left  z0 blank z1 blank)
    
    ;; Ligne z1 de la table (L'addition de la retenue, de droite à gauche)
    (rule-stay z1 zero zh one)   ;; Si 0, on écrit 1 et on s'arrête (zh)
    (rule-stay z1 blank zh one)  ;; Si vide, on écrit 1 et on s'arrête (zh)
    (rule-left z1 one z1 zero)   ;; Si 1, on écrit 0 et on continue à gauche (retenue)
  )

  (:goal
    ;; L'objectif : La machine doit se mettre en état d'arrêt "zh" (Halt)
    (state zh)
  )
)
