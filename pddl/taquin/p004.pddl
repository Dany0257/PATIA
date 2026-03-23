;; problem-taquin-3x3-ex4.pddl
(define (problem taquin-3x3)
  (:domain taquin-ff)
  (:objects
     blank tile1 tile2 tile3 tile4 tile5 tile6 tile7 tile8 - tile
     p11 p12 p13 p21 p22 p23 p31 p32 p33         - position
  )
  (:init
     ;; configuration : blank en bas-droite, tuiles légèrement décalées
     (at tile8 p11) (at tile1 p12) (at tile2 p13)
     (at tile3 p21) (at tile4 p22) (at tile5 p23)
     (at tile6 p31) (at tile7 p32) (at blank p33)
     (empty p33)

     ;; --- adjacences horizontales ---
     (adjacent p11 p12) (adjacent p12 p11)
     (adjacent p12 p13) (adjacent p13 p12)
     (adjacent p21 p22) (adjacent p22 p21)
     (adjacent p22 p23) (adjacent p23 p22)
     (adjacent p31 p32) (adjacent p32 p31)
     (adjacent p32 p33) (adjacent p33 p32)

     ;; --- adjacences verticales ---
     (adjacent p11 p21) (adjacent p21 p11)
     (adjacent p12 p22) (adjacent p22 p12)
     (adjacent p13 p23) (adjacent p23 p13)
     (adjacent p21 p31) (adjacent p31 p21)
     (adjacent p22 p32) (adjacent p32 p22)
     (adjacent p23 p33) (adjacent p33 p23)
  )
  (:goal (and
     (at tile1 p11) (at tile2 p12) (at tile3 p13)
     (at tile4 p21) (at tile5 p22) (at tile6 p23)
     (at tile7 p31) (at tile8 p32) (at blank p33)
  ))
)
