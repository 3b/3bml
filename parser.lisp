(in-package #:3bml)

(defun data-file-path (rel)
  (asdf:system-relative-pathname '3bml rel))

(defmethod dump ((doc dom:document))
  (dump (dom:document-element doc)))

(defun translate-name (n)
  (when (and n (not (zerop (length n))))
    (intern
     (coerce (loop for l = nil then (lower-case-p c)
                   for c across n
                   when (and l (upper-case-p c))
                     collect #\-
                   collect (char-upcase c))
             'string)
     :keyword)))

(defmethod dump ((el vector))
  (map 'list 'dump el))

#++
(defmethod dump ((el dom:element))
  (let ((name (translate-name (dom:local-name el)))
        (label (translate-name (dom:get-attribute el "label")))
        (type (translate-name (dom:get-attribute el "type"))))
    (case name
      (:bulletml ;; type,*
       (list* name
              (list :type (or type :none))
             (dump (dom:child-nodes el))))
      ((:action :bullet :fire :bullet-ref :action-ref :fire-ref) ;; label,*
       (list* name (when label (list :label label))
              (dump (dom:child-nodes el))))
      ((:change-direction :change-speed :accel :repeat) ;; x/*
       (list* name ()
              (dump (dom:child-nodes el))))
      ((:wait :term :times :param) ;; x,number
       (list name ()
             (3bml-infix-grammar::parse-bml
              (apply 'append (map 'list 'dom:data (dom:child-nodes el))))))
      ((:direction :speed :horizontal :vertical) ;; type,number
       (list name (list :type type)
             (3bml-infix-grammar::parse-bml
              (apply 'append (map 'list 'dom:data (dom:child-nodes el))))))
      ((:vanish) ;; no attr/contents
       (list name ()))
      (t (list name
               (map 'list 'dump (dom:child-nodes el)))))))

(defmethod dump ((el dom:element))
  (let ((name (translate-name (dom:local-name el)))
        (label (translate-name (dom:get-attribute el "label")))
        (type (translate-name (dom:get-attribute el "type"))))
    (case name
      (:bulletml ;; type,*
       (list* name (or type :none)
             (dump (dom:child-nodes el))))
      ((:action :bullet :fire :bullet-ref :action-ref :fire-ref) ;; label,*
       (list* name label
              (dump (dom:child-nodes el))))
      ((:change-direction :change-speed :accel :repeat) ;; x/*
       (list* name
              (dump (dom:child-nodes el))))
      ((:wait :term :times :param) ;; x,number
       (list name
             (3bml-infix-grammar::parse-bml
              (apply 'append (map 'list 'dom:data (dom:child-nodes el))))))
      ((:direction :speed :horizontal :vertical) ;; type,number
       (list name type
             (3bml-infix-grammar::parse-bml
              (apply 'append (map 'list 'dom:data (dom:child-nodes el))))))
      ((:vanish) ;; no attr/contents
       (list name))
      (t (list name
               (map 'list 'dump (dom:child-nodes el)))))))

(defmethod dump ((el dom:text))
  (list :text  (dom:data el)))

(defun parse-bulletml (f)
  (flet ((resolver (pubid sysid)
           (declare (ignore pubid sysid))
           #++(flexi-streams:make-in-memory-input-stream nil)
           (open (data-file-path "bulletml/relax/bulletml.dtd")
                 :element-type '(unsigned-byte 8))))
    (let* ((doc (cxml:parse-file
                 f
                 (cxml:make-namespace-normalizer
                  (cxml:make-whitespace-normalizer
                   #++(cxml-xmls:make-xmls-builder)
                   (cxml-dom:make-dom-builder)))
                 :entity-resolver #'resolver)))
      #++(assert (equal (caar x) "bulletml"))

      (dump doc))))

#++
(parse-bulletml
 (data-file-path "bulletml/sample/[1943]_rolling_fire.xml"))

#++
(loop for f in (directory
                (merge-pathnames "*.xml" (data-file-path "bulletml/sample/")))
      collect (parse-bulletml f))
