(define (problem hanoi-4)
  (:domain hanoi)
  
  (:objects 
      peg1 peg2 peg3 
      d1 d2 d3 d4
  )

  (:init 
      ;; --- Définition des tailles (qui est plus petit que qui) ---
      ;; d1 est le plus petit disque
      (smaller d1 d2) (smaller d1 d3) (smaller d1 d4)
      (smaller d1 peg1) (smaller d1 peg2) (smaller d1 peg3)
      
      ;; d2
      (smaller d2 d3) (smaller d2 d4)
      (smaller d2 peg1) (smaller d2 peg2) (smaller d2 peg3)
      
      ;; d3
      (smaller d3 d4)
      (smaller d3 peg1) (smaller d3 peg2) (smaller d3 peg3)
      
      ;; d4 (le plus grand disque)
      (smaller d4 peg1) (smaller d4 peg2) (smaller d4 peg3)

      ;; --- État initial (disques empilés sur peg1) ---
      (clear peg2)
      (clear peg3)
      (clear d1)
      
      (on d4 peg1)
      (on d3 d4)
      (on d2 d3)
      (on d1 d2)
  )

  (:goal 
      (and 
          ;; --- L'objectif : empiler tout sur peg3 ---
          (on d4 peg3)
          (on d3 d4)
          (on d2 d3)
          (on d1 d2)
      )
  )
)
