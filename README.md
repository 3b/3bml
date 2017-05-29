## simple [bullet-ml](http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index.html) -> sexp parser (no evaluator yet)

```lisp
(3bml:parse-bulletml "bulletml/sample/[1943]_rolling_fire.xml")

;; =>

(:BULLETML :VERTICAL (:ACTION :TOP (:FIRE NIL (:BULLET-REF :ROLL)))
 (:BULLET :ROLL
  (:ACTION NIL (:WAIT (+ 40 (* :RAND 20)))
   (:CHANGE-DIRECTION (:DIRECTION :RELATIVE -90) (:TERM 4))
   (:CHANGE-SPEED (:SPEED :ABSOLUTE 3) (:TERM 4)) (:WAIT 4)
   (:CHANGE-DIRECTION (:DIRECTION :SEQUENCE 15) (:TERM 9999))
   (:WAIT (+ 80 (* :RAND 40))) (:VANISH))))

```

Math is translated to sexp form, variables are currently keywords
(`:rand`, `:rank`, `:1`, `:2`, etc), but that will probably change at
some point.
