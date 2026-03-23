(define (domain pursuit-evasion)
  (:requirements :strips :adl)
  
  (:predicates
    (node ?n)
    (edge ?n1 ?n2)
    (at ?p ?n)         ; Le policier ?p est sur le noeud ?n
    (cleared ?n)       ; Le noeud ?n est nettoyé (l'intrus n'y est pas)
  )

  (:action move
    :parameters (?p ?from ?to)
    :precondition (and
        (node ?from) (node ?to)
        (at ?p ?from)
        (edge ?from ?to)
        
        ;; Règle anti-recontamination : Il ne doit PAS exister un voisin ?n2 de ?from
        ;; qui est encore contaminé (not cleared)
        ;; ET qui n'est pas notre destination (?to)
        ;; ET qui n'est pas surveillé par un autre policier (?p2).
        ;; Sinon, dès qu'on part, l'intrus va s'engouffrer dans ?from !
        (not (exists (?n2) 
               (and 
                 (edge ?from ?n2)
                 (not (cleared ?n2))
                 (not (= ?n2 ?to))
                 (not (exists (?p2) (at ?p2 ?n2)))
               )
             )
        )
    )
    :effect (and
        (not (at ?p ?from))
        (at ?p ?to)
        (cleared ?to)  ;; La destination devient nettoyée !
    )
  )
)
