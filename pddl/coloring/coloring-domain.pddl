(define (domain graph-coloring)
  (:requirements :strips :adl)
  
  (:predicates
    (node ?n)          ; ?n est un sommet/noeud
    (color ?c)         ; ?c est une couleur
    (edge ?n1 ?n2)     ; Il y a un bord entre ?n1 et ?n2
    (colored ?n ?c)    ; Le sommet ?n est colorié avec la couleur ?c
    (uncolored ?n)     ; Le sommet ?n n'a pas encore de couleur
  )

  (:action paint
    :parameters (?n ?c)
    :precondition (and
        (node ?n)
        (color ?c)
        (uncolored ?n)
        ;; La magie est ici : Il NE FAUT PAS qu'il existe un voisin (?n2) 
        ;; qui partage une arête avec ?n ET qui a déjà cette couleur ?c.
        (not (exists (?n2) (and (edge ?n ?n2) (colored ?n2 ?c))))
    )
    :effect (and
        (not (uncolored ?n))
        (colored ?n ?c)
    )
  )
)
