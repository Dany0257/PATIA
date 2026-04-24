(define (domain Sokoban)
  (:requirements :strips :typing :negative-preconditions)
  (:types player box place)
  
  (:predicates
    (playerIsAt ?p - place)
    (boxIsAt ?p - place)
    (isEmpty ?p - place)
    (isRight ?p1 - place ?p2 - place)
    (isLeft ?p1 - place ?p2 - place)
    (isUp ?p1 - place ?p2 - place)
    (isDown ?p1 - place ?p2 - place)
    (deadlock ?p - place)
  )
  
  ;; Actions de déplacement du joueur
  (:action move-right
    :parameters (?from - place ?to - place)
    :precondition (and 
                    (playerIsAt ?from)
                    (isRight ?from ?to)
                    (isEmpty ?to))
    :effect (and
              (playerIsAt ?to)
              (not (playerIsAt ?from))
              (isEmpty ?from)
              (not (isEmpty ?to))))
  
  (:action move-left
    :parameters (?from - place ?to - place)
    :precondition (and 
                    (playerIsAt ?from)
                    (isLeft ?from ?to)
                    (isEmpty ?to))
    :effect (and
              (playerIsAt ?to)
              (not (playerIsAt ?from))
              (isEmpty ?from)
              (not (isEmpty ?to))))
  
  (:action move-up
    :parameters (?from - place ?to - place)
    :precondition (and 
                    (playerIsAt ?from)
                    (isUp ?from ?to)
                    (isEmpty ?to))
    :effect (and
              (playerIsAt ?to)
              (not (playerIsAt ?from))
              (isEmpty ?from)
              (not (isEmpty ?to))))
  
  (:action move-down
    :parameters (?from - place ?to - place)
    :precondition (and 
                    (playerIsAt ?from)
                    (isDown ?from ?to)
                    (isEmpty ?to))
    :effect (and
              (playerIsAt ?to)
              (not (playerIsAt ?from))
              (isEmpty ?from)
              (not (isEmpty ?to))))
  
  ;; Actions de poussée de caisses (chaque action interdit de pousser vers une case en deadlock)
  (:action push-right
    :parameters (?pFrom - place ?bFrom - place ?bTo - place)
    :precondition (and
                    (playerIsAt ?pFrom)
                    (boxIsAt ?bFrom)
                    (isRight ?pFrom ?bFrom)
                    (isRight ?bFrom ?bTo)
                    (isEmpty ?bTo)
                    (not (deadlock ?bTo)))
    :effect (and
              (playerIsAt ?bFrom)
              (not (playerIsAt ?pFrom))
              (boxIsAt ?bTo)
              (not (boxIsAt ?bFrom))
              (isEmpty ?pFrom)
              (not (isEmpty ?bTo))))
  
  (:action push-left
    :parameters (?pFrom - place ?bFrom - place ?bTo - place)
    :precondition (and
                    (playerIsAt ?pFrom)
                    (boxIsAt ?bFrom)
                    (isLeft ?pFrom ?bFrom)
                    (isLeft ?bFrom ?bTo)
                    (isEmpty ?bTo)
                    (not (deadlock ?bTo)))
    :effect (and
              (playerIsAt ?bFrom)
              (not (playerIsAt ?pFrom))
              (boxIsAt ?bTo)
              (not (boxIsAt ?bFrom))
              (isEmpty ?pFrom)
              (not (isEmpty ?bTo))))
  
  (:action push-up
    :parameters (?pFrom - place ?bFrom - place ?bTo - place)
    :precondition (and
                    (playerIsAt ?pFrom)
                    (boxIsAt ?bFrom)
                    (isUp ?pFrom ?bFrom)
                    (isUp ?bFrom ?bTo)
                    (isEmpty ?bTo)
                    (not (deadlock ?bTo)))
    :effect (and
              (playerIsAt ?bFrom)
              (not (playerIsAt ?pFrom))
              (boxIsAt ?bTo)
              (not (boxIsAt ?bFrom))
              (isEmpty ?pFrom)
              (not (isEmpty ?bTo))))
  
  (:action push-down
    :parameters (?pFrom - place ?bFrom - place ?bTo - place)
    :precondition (and
                    (playerIsAt ?pFrom)
                    (boxIsAt ?bFrom)
                    (isDown ?pFrom ?bFrom)
                    (isDown ?bFrom ?bTo)
                    (isEmpty ?bTo)
                    (not (deadlock ?bTo)))
    :effect (and
              (playerIsAt ?bFrom)
              (not (playerIsAt ?pFrom))
              (boxIsAt ?bTo)
              (not (boxIsAt ?bFrom))
              (isEmpty ?pFrom)
              (not (isEmpty ?bTo))))
)
