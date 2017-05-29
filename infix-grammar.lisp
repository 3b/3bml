(in-package #:3bml-infix-grammar)

(defrule whitespace (or #\space #\tab #\return #\linefeed)
  (:constant ""))

(defrule digit (or #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))
(defrule hex-digit (or digit
                       #\a #\A #\b #\B #\c #\C #\d #\D #\e #\E #\f #\F))
(defrule number (and (? (or #\- #\+))
                     (or (and (+ digit) (? (and #\. (* digit))))
                         (and #\. (+ digit))))
  (:lambda (a)
    (parse-number:parse-real-number (text a))))
(require 'parse-number)
(defrule alphanumeric (alphanumericp character))
(defrule variable (and #\$ (+ alphanumeric))
  (:destructure ($ name)
    (declare (ignore $))
    (intern (string-upcase (text name)) :keyword)))

(defrule op3 (or #\/ #\* #\%)
  (:lambda (a)
    (or (find-symbol a :cl)
        (if (string= a "%")
            'mod
            (intern (string-upcase a) :keyword)))))
(defrule op4 (or #\+ #\-)
  (:lambda (a) (or (find-symbol a :cl) (intern (string-upcase a) :keyword))))

(defrule value (or number variable))

(defrule expression (or (and expression op3 expression)
                        (and expression op4 expression)
                        (and #\( expression #\))
                        value)
  (:lambda (e)
    (cond
      ((and (consp e)
            (equal (car e) "("))
       (setf e (second e)))
      ((consp e)
       (list* (second e) (first e) (cddr e)))
      (t e))))

(defun parse-bml (s)
  (parse 'expression
         (remove-if (lambda (a) (member a '(#\space #\tab #\return #\linefeed)))
                    s)))

#++
(loop for e in '("35"
                 "$1"
                 "-30"
                 "3+$rank*6"
                 "360/16"
                 "(1+2)"
                 "1+2*3"
                 "(1+2)*3"
                 "0.7 + 0.9*$rand"
                 "180-$rank*20"
                 "$rand*90+135"
                 "$1+$rand*20-10"
                 "1.2+$rank"
                 "10+$rand*10"
                 "9-$rand*0.1"
                 "(2+$1)*0.3")
      collect (print (parse-bml e)))

