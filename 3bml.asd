(defsystem 3bml
  :description "simple BulletML parser"
  :depends-on (alexandria cxml-rng esrap)
  :serial t
  :license "MIT"
  :author "Bart Botta <00003b at gmail.com>"
  :components ((:file "package")
               (:file "infix-grammar")
               (:file "parser")))
