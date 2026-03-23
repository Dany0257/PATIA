(define (problem sat-example)
  (:domain sat-solver)
  
  (:objects
    x1 x2 x3 x4
    c1 c2 c3
  )

  (:init
    (variable x1) (variable x2) (variable x3) (variable x4)
    (clause c1) (clause c2) (clause c3)
    
    ;; Clause 1 : (x1 ∨ x3 ∨ ¬x4)
    (pos-in x1 c1)
    (pos-in x3 c1)
    (neg-in x4 c1)
    
    ;; Clause 2 : (x4)
    (pos-in x4 c2)
    
    ;; Clause 3 : (x2 ∨ ¬x3)
    (pos-in x2 c3)
    (neg-in x3 c3)
  )

  (:goal
    (and
      ;; L'objectif est simple : Toutes les clauses doivent être "satisfaites" (Vraies)
      (satisfied c1)
      (satisfied c2)
      (satisfied c3)
    )
  )
)
