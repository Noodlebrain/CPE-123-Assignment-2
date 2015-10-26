;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname project-2) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp")) #f)))
(require rsound)
(require 2htdp/universe)
(require 2htdp/image)

(define FR 44100)

(define (s frames)
  (* frames FR))

(define LEAD-FRAMES (round (s 0.05)))
(define PLAY-CHUNK (round (s 0.1)))
(define (both a b) b)

(define ps (make-pstream))

;Constants for the canvas size
(define LENGTH 1000)
(define HEIGHT 500)

;Constant for the number of regions
(define numRegions 4)

;Constants for each song
(define sound1 (rs-scale .1 (rs-read/clip "Episode.wav" (s 10) (s 70))))
(define sound2 (rs-read/clip "Sandstorm.wav" (s 30) (s 90)))
(define sound3 (rs-scale .1 (rs-read/clip "Showers.wav" (s 10) (s 70))))
(define sound4 (rs-scale .1 (rs-read/clip "Fantasy.wav" (s 10) (s 70))))

;Defining the structures we will need for the loop engine
;Ex: (make-playhead (Song1 #t frame))
(define-struct playhead (sound On? currentframe))

;Creating the loop engine which is 4 playheads and the when the next song ends
(define-struct engine (PH1 PH2 PH3 PH4 endtime))

;Checks if the next song chunks need to be queued
(define (time-to-play? cur next)
  (<= (- next cur) LEAD-FRAMES))

;Given the current frame, playhead, and end of current chunk of sound, maybe plays the next chunk of sound
(define (maybe-play-chunk cur ph end)
 (cond [(playhead-On? ph)
       (local [(define beg (cond
                                    [(> (+ (playhead-currentframe ph) PLAY-CHUNK) (rs-frames (playhead-sound ph))) 0]
                                    [else (playhead-currentframe ph)]))
                   (define next-beg (+ beg PLAY-CHUNK))]
           (both (pstream-queue ps
                                  (clip (playhead-sound ph) beg next-beg)
                                  end)
                   (make-playhead (playhead-sound ph) #t next-beg)))]
       [else ph]))
       


;Makes the next world state by potentially playing sounds
(define (play-chunks cur w)
(local [(define end (engine-endtime w))]
  (cond
       [(time-to-play? cur end)
                (make-engine 
                (maybe-play-chunk cur (engine-PH1 w) end)
                (maybe-play-chunk cur (engine-PH2 w) end)
                (maybe-play-chunk cur (engine-PH3 w) end)
                (maybe-play-chunk cur (engine-PH4 w) end)
                (+ end PLAY-CHUNK))]
       [else w])))

(define (tickhandler w)
  (play-chunks (pstream-current-frame ps) w))


;Helper for mouseHandler
;Takes in a sound, and a mouseX - ASSUMES MOUSEX IS ON THE CANVAS
;Gives new frame based on proportion (mouseX/CanvasLENGTH) * numFramesInSong, (Round)
(define (newPH sound mouseX)
	(round (* (/ mouseX LENGTH) (rs-frames sound)))
)

;LATER->Play/Pause regions
;Takes the world, mouse x position, mouse y position, the mouse event
(define regionLength LENGTH);Length of each region
(define regionHeight (/ HEIGHT numRegions))
(define (mouseHandler world mouseX mouseY event)
(cond	;Check that it’s on release ;MAYBE NEED TO: CHECK IF MOUSE IS ON CANVAS
[(string=? event "button-up")
(cond   ;Check where clicked
[(and (>= mouseY 0) ( < mouseY regionHeight)) ;If clicked in track region 1;
(make-engine (make-playhead sound1 #t (newPH sound1 mouseX)) 
                       (engine-PH2 world)
                       (engine-PH3 world)  
                       (engine-PH4 world)
                       (engine-endtime world))] ;Set playhead based on position
[(and (>= mouseY regionHeight) (< mouseY (* 2 regionHeight)))
(make-engine (engine-PH1 world) 
                       (make-playhead sound2 #t (newPH sound1 mouseX))
                       (engine-PH3 world)
                       (engine-PH4 world)
                       (engine-endtime world))];Set playhead based on position
[(and (>= mouseY (* 2 regionHeight)) (< mouseY (* 3 regionHeight)))
(make-engine (engine-PH1 world) 
                       (engine-PH2 world)
                       (make-playhead sound3 #t (newPH sound1 mouseX))
                       (engine-PH4 world)
                       (engine-endtime world))];Set playhead based on position
		[(and (>= mouseY (* 3 regionHeight)) (<= mouseY (* 4 regionHeight)))
(make-engine (engine-PH1 world) 
                       (engine-PH2 world)
                       (engine-PH3 world)
                       (make-playhead sound4 #t (newPH sound1 mouseX))
                       (engine-endtime world))];Set playhead based on position
)	
]
[else world] ;If it’s not on release, just don’t change the playheads
)
)


; Draws the world: each slider moves based on current place in song
(define (drawWorld w)
	(place-images
    		(list (rectangle 20 100 "solid" "black")
(rectangle 20 100 "solid" "black")
(rectangle 20 100 "solid" "black")
(rectangle 20 100 "solid" "black")
(line LENGTH 0 "grey")
(line LENGTH 0 "grey")
(line LENGTH 0 "grey")
(line LENGTH 0 "grey"))
    		(list (make-posn (* LENGTH (/ (playhead-currentframe (engine-PH1 w))
                        		(rs-frames (playhead-sound (engine-PH1 w))))) 70)
          			(make-posn (* LENGTH (/ (playhead-currentframe (engine-PH2 w))
                        		(rs-frames (playhead-sound (engine-PH2 w))))) 190)
          			(make-posn (* LENGTH (/ (playhead-currentframe (engine-PH3 w))
                        		(rs-frames (playhead-sound (engine-PH3 w))))) 310)
          			(make-posn (* LENGTH (/ (playhead-currentframe (engine-PH4 w))
                        		(rs-frames (playhead-sound (engine-PH4 w))))) 430)
          			(make-posn 500 70)
          			(make-posn 500 190)
          			(make-posn 500 310)
          			(make-posn 500 430))             	 
    		(empty-scene LENGTH HEIGHT)))

(big-bang (make-engine (make-playhead sound1 #t 0)
                       (make-playhead sound2 #t 0)
                       (make-playhead sound3 #t 0)
                       (make-playhead sound4 #t 0)
                       0)
          [on-tick tickhandler]
          [on-mouse mouseHandler]
          [to-draw drawWorld])