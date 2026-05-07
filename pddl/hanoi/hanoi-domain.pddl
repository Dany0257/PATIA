(define (domain hanoi)
  (:requirements :strips)
  
  (:predicates 
    (clear ?x)
    (on ?x ?y)
    (smaller ?x ?y)
  )

  (:action move
    :parameters (?disc ?from ?to)
    :precondition (and 
        (smaller ?disc ?to)   ; Le disque doit être plus petit que sa destination
        (on ?disc ?from)      ; Le disque est actuellement sur '?from'
        (clear ?disc)         ; Rien ne doit être posé sur le disque qu'on bouge
        (clear ?to)           ; La destination doit être libre (rien posé dessus)
    )
    :effect (and 
        (not (on ?disc ?from)) ; Le disque n'est plus sur son ancien emplacement
        (not (clear ?to))      ; La destination n'est plus libre
        (on ?disc ?to)         ; Le disque est maintenant sur la destination
        (clear ?from)          ; L'ancien emplacement est maintenant libre
    )
  )
)
