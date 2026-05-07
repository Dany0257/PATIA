(define (problem taquin-difficile)
  (:domain taquin)
  
  (:objects
    p1 p2 p3 p4
    p5 p6 p7 p8
    p9 p10 p11 p12
    p13 p14 p15 p16

    t1 t2 t3 t4
    t5 t6 t7 t8
    t9 t10 t11 t12
    t13 t14 t15
  )

  (:init
    ;; Ligne 1
    (adjacent p1 p2) (adjacent p2 p1) (adjacent p1 p5) (adjacent p5 p1)
    (adjacent p2 p3) (adjacent p3 p2) (adjacent p2 p6) (adjacent p6 p2)
    (adjacent p3 p4) (adjacent p4 p3) (adjacent p3 p7) (adjacent p7 p3)
    (adjacent p4 p8) (adjacent p8 p4)
    ;; Ligne 2
    (adjacent p5 p6) (adjacent p6 p5) (adjacent p5 p9) (adjacent p9 p5)
    (adjacent p6 p7) (adjacent p7 p6) (adjacent p6 p10) (adjacent p10 p6)
    (adjacent p7 p8) (adjacent p8 p7) (adjacent p7 p11) (adjacent p11 p7)
    (adjacent p8 p12) (adjacent p12 p8)
    ;; Ligne 3
    (adjacent p9 p10) (adjacent p10 p9) (adjacent p9 p13) (adjacent p13 p9)
    (adjacent p10 p11) (adjacent p11 p10) (adjacent p10 p14) (adjacent p14 p10)
    (adjacent p11 p12) (adjacent p12 p11) (adjacent p11 p15) (adjacent p15 p11)
    (adjacent p12 p16) (adjacent p16 p12)
    ;; Ligne 4
    (adjacent p13 p14) (adjacent p14 p13)
    (adjacent p14 p15) (adjacent p15 p14)
    (adjacent p15 p16) (adjacent p16 p15)

    ;; -- État initial (Mélangé et compliqué !) --
    ;; Visuellement la grille ressemble à ça :
    ;; 5  1   2  4
    ;; 9  6   3  8
    ;; 13 10  7  11
    ;; 14 15 [X] 12
    
    (at t5 p1)   (at t1 p2)   (at t2 p3)   (at t4 p4)
    (at t9 p5)   (at t6 p6)   (at t3 p7)   (at t8 p8)
    (at t13 p9)  (at t10 p10) (at t7 p11)  (at t11 p12)
    (at t14 p13) (at t15 p14) (empty p15)  (at t12 p16)
  )

  (:goal
    (and
      ;; -- État final visé (parfaitement en ordre, case 16 vide) --
      (at t1 p1)   (at t2 p2)   (at t3 p3)   (at t4 p4)
      (at t5 p5)   (at t6 p6)   (at t7 p7)   (at t8 p8)
      (at t9 p9)   (at t10 p10) (at t11 p11) (at t12 p12)
      (at t13 p13) (at t14 p14) (at t15 p15) (empty p16)
    )
  )
)
