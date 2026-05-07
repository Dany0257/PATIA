(define (domain turing-machine)
  (:requirements :strips :typing)
  
  (:predicates
    ;; État de la machine
    (state ?z)
    (head ?c)                 ; La tête est sur la case ?c
    (content ?c ?sym)         ; La case ?c contient le symbole ?sym
    
    ;; Géométrie du ruban
    (right ?c1 ?c2)           ; La case ?c2 est juste à droite de ?c1
    
    ;; Les règles du programme chargées en mémoire
    (rule-right ?z-old ?sym-old ?z-new ?sym-new)
    (rule-left  ?z-old ?sym-old ?z-new ?sym-new)
    (rule-stay  ?z-old ?sym-old ?z-new ?sym-new)
  )

  (:action move-right
    :parameters (?z-old ?sym-old ?z-new ?sym-new ?c-old ?c-new)
    :precondition (and 
        (state ?z-old) (head ?c-old) (content ?c-old ?sym-old)
        (rule-right ?z-old ?sym-old ?z-new ?sym-new)
        (right ?c-old ?c-new) ;; Il faut une case à droite pour avancer
    )
    :effect (and 
        (not (state ?z-old)) (state ?z-new)
        (not (content ?c-old ?sym-old)) (content ?c-old ?sym-new)
        (not (head ?c-old)) (head ?c-new)
    )
  )

  (:action move-left
    :parameters (?z-old ?sym-old ?z-new ?sym-new ?c-old ?c-new)
    :precondition (and 
        (state ?z-old) (head ?c-old) (content ?c-old ?sym-old)
        (rule-left ?z-old ?sym-old ?z-new ?sym-new)
        (right ?c-new ?c-old) ;; La case ?c-new est à gauche de ?c-old
    )
    :effect (and 
        (not (state ?z-old)) (state ?z-new)
        (not (content ?c-old ?sym-old)) (content ?c-old ?sym-new)
        (not (head ?c-old)) (head ?c-new)
    )
  )

  (:action stay
    :parameters (?z-old ?sym-old ?z-new ?sym-new ?c-old)
    :precondition (and 
        (state ?z-old) (head ?c-old) (content ?c-old ?sym-old)
        (rule-stay ?z-old ?sym-old ?z-new ?sym-new)
    )
    :effect (and 
        (not (state ?z-old)) (state ?z-new)
        (not (content ?c-old ?sym-old)) (content ?c-old ?sym-new)
        ;; La tête ne bouge pas !
    )
  )
)
