(define (domain hamiltonian)
  (:requirements :strips :adl)
  
  (:predicates
    (node ?n)              ; Le lieu est un noeud
    (edge ?n1 ?n2)         ; Il y a un pont/chemin entre ?n1 et ?n2
    (at ?n)                ; Le voyageur est sur le noeud ?n
    (visited ?n)           ; Le noeud ?n a été visité
    (starting_node ?n)     ; C'est notre ville de départ
    (cycle_completed)      ; On a gagné 
  )

  (:action move
    :parameters (?from ?to)
    :precondition (and 
        (node ?from) (node ?to)
        (at ?from)
        (edge ?from ?to)
        ;; On ne peut avancer QUE vers un noeud qu'on n'a jamais visité
        (not (visited ?to))  
    )
    :effect (and 
        (not (at ?from))
        (at ?to)
        (visited ?to)
    )
  )

  (:action complete_cycle
    :parameters (?from ?start)
    :precondition (and
        (node ?from) (node ?start)
        (at ?from)
        (starting_node ?start)   ;; La destination doit absolument être le point de départ
        (edge ?from ?start)
        ;; VÉRIFICATION CRITIQUE : 
        ;; Il ne doit PAS y avoir un seul noeud dans tout le graphe qui ne soit pas "visited"
        (not (exists (?n) (and (node ?n) (not (visited ?n)))))
    )
    :effect (and
        (not (at ?from))
        (at ?start)
        (cycle_completed)
    )
  )
)
