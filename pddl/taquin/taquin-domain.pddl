(define (domain taquin)
  (:requirements :strips)

  (:predicates
    (at ?tile ?pos)
    (empty ?pos)
    (adjacent ?pos1 ?pos2)
  )

  (:action slide
    :parameters (?tile ?from ?to)
    :precondition (and
       (at ?tile ?from)      ; La tuile est sur la position de départ
       (empty ?to)           ; La position d'arrivée est vide
       (adjacent ?from ?to)  ; Les deux positions se touchent
    )
    :effect (and
       (not (at ?tile ?from)) ; La tuile quitte la position de départ
       (not (empty ?to))      ; La position d'arrivée n'est plus vide
       (at ?tile ?to)         ; La tuile est sur sa nouvelle position
       (empty ?from)          ; L'ancienne position devient vide
    )
  )
)
