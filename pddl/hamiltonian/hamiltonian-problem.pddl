(define (problem konigsberg-hamilton)
  (:domain hamiltonian)
  
  (:objects
    a b c d
  )

  (:init
    ;; Déclaration des noeuds
    (node a) (node b) (node c) (node d)
    
    ;; Les connexions physiques (graphe simplifié de Königsberg)
    (edge a b) (edge b a)
    (edge a c) (edge c a)
    (edge a d) (edge d a)
    
    (edge b d) (edge d b)
    (edge c d) (edge d c)

    ;; État de départ : Le voyageur commence sur l'île (A)
    (at a)
    (starting_node a)
    (visited a)  ;; Le noeud de spawn est considéré comme visité
  )

  (:goal
    ;; L'objectif unique : clôturer le cycle Hamiltonien !
    (cycle_completed)
  )
)
