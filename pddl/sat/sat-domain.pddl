(define (domain sat-solver)
  (:requirements :strips :adl)
  
  (:predicates
    (variable ?v)      ; ?v est une variable logique (x1, x2...)
    (clause ?c)        ; ?c est une clause de la formule (parenthèse)
    
    (pos-in ?v ?c)     ; La variable ?v est positive dans la clause ?c (ex: x1)
    (neg-in ?v ?c)     ; La variable ?v est négative dans la clause ?c (ex: ¬x4)
    
    (assigned ?v)      ; On a pris une décision (vrai ou faux) pour la variable ?v
    (satisfied ?c)     ; La clause ?c est satisfaite !
  )

  (:action assign-true
    :parameters (?v)
    :precondition (and (variable ?v) (not (assigned ?v)))
    :effect (and
        (assigned ?v)
        ;; Formule magique : Pour chaque clause, SI on est positif dedans, ALORS on la satisfait !
        (forall (?c) 
            (when (pos-in ?v ?c) 
                  (satisfied ?c)
            )
        )
    )
  )

  (:action assign-false
    :parameters (?v)
    :precondition (and (variable ?v) (not (assigned ?v)))
    :effect (and
        (assigned ?v)
        ;; Formule magique inverse : Pour chaque clause, SI on est négatif (¬x) dedans, on la satisfait !
        (forall (?c) 
            (when (neg-in ?v ?c) 
                  (satisfied ?c)
            )
        )
    )
  )
)
