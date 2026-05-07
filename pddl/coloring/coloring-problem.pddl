(define (problem color-australia)
  (:domain graph-coloring)
  
  (:objects
    ;; Les territoires de l'Australie
    wa nt sa q nsw v t
    ;; Les 3 couleurs
    rouge vert bleu
  )

  (:init
    ;; Définition de ce qui est un "noeud" et une "couleur"
    (node wa) (node nt) (node sa) (node q) (node nsw) (node v) (node t)
    (color rouge) (color vert) (color bleu)
    
    ;; Initialement, personne n'est colorié
    (uncolored wa) (uncolored nt) (uncolored sa) 
    (uncolored q) (uncolored nsw) (uncolored v) (uncolored t)

    ;; Définition des frontières (arêtes du graphe)
    ;; L'Australie Occidentale (WA)
    (edge wa nt) (edge nt wa)
    (edge wa sa) (edge sa wa)
    ;; Le Territoire du Nord (NT)
    (edge nt sa) (edge sa nt)
    (edge nt q)  (edge q nt)
    ;; L'Australie Méridionale (SA) touche presque tout le monde
    (edge sa q)  (edge q sa)
    (edge sa nsw)(edge nsw sa)
    (edge sa v)  (edge v sa)
    ;; Le Queensland (Q)
    (edge q nsw) (edge nsw q)
    ;; La Nouvelle-Galles du Sud (NSW)
    (edge nsw v) (edge v nsw)
    ;; La Tasmanie (T) est une île ! Elle ne touche personne.
  )

  (:goal
    (and
      ;; Le but est de tout colorier (plus aucun noeud 'uncolored')
      (not (uncolored wa))
      (not (uncolored nt))
      (not (uncolored sa))
      (not (uncolored q))
      (not (uncolored nsw))
      (not (uncolored v))
      (not (uncolored t))
    )
  )
)
