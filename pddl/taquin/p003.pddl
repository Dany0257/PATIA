;; problem-taquin-3x3-ex3.pddl
(define (problem taquin-3x3)
  (:domain taquin-ff)
  (:objects
     blank tile1 tile2 tile3 tile4 tile5 tile6 tile7 tile8 - tile
     p11 p12 p13 p21 p22 p23 p31 p32 p33         - position
  )
  (:init
     ;; blank en haut-gauche
     (at blank p11) (at tile1 p12) (at tile2 p13)
     (at tile3 p21) (at tile4 p22) (at tile5 p23)
     (at tile6 p31) (at tile7 p32) (at tile8 p33)
     (empty p11)

     ;; mêmes faits d’adjacence que dans problem-taquin-3x3-tp1.pddl
  )
  (:goal (and
     (at tile1 p11) (at tile2 p12) (at tile3 p13)
     (at tile4 p21) (at tile5 p22) (at tile6 p23)
     (at tile7 p31) (at tile8 p32) (at blank p33)
  ))
)
