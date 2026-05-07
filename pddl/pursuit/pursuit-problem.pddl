(define (problem trap-intruder)
  (:domain pursuit-evasion)
  
  (:objects
    ;; 6 noeuds
    n1 n2 n3 n4 n5 n6
    ;; 2 policiers
    cop1 cop2
  )

  (:init
    (node n1) (node n2) (node n3) (node n4) (node n5) (node n6)
    
    ;; Les connexions du graphe (bidirectionnelles)
    (edge n1 n2) (edge n2 n1)
    (edge n2 n3) (edge n3 n2)
    (edge n3 n4) (edge n4 n3)
    (edge n4 n5) (edge n5 n4)
    (edge n5 n1) (edge n1 n5) ;; Les 5 premiers forment une boucle fermée
    (edge n5 n6) (edge n6 n5) ;; n6 est une impasse attachée à n5
    
    ;; Position de départ des policiers
    (at cop1 n1)
    (at cop2 n2)
    
    ;; Initialement, seuls les noeuds de départ sont nettoyés
    (cleared n1)
    (cleared n2)
  )

  (:goal
    (and
      ;; L'objectif est de nettoyer tout le graphe ! (L'intrus n'a plus nulle part où aller)
      (cleared n1)
      (cleared n2)
      (cleared n3)
      (cleared n4)
      (cleared n5)
      (cleared n6)
    )
  )
)
