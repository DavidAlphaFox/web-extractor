(in-package :web-extractor)


;;;; SOME THIRD PARTY LIBS TESTS    

;; (pprint
;;  (parse-html 
;;   (http-request "http://www.google.com")))

;; (define-sanitize-mode links
;;     :elements (:a) 
;;     :attributes ((:a :href)))

;; (setq *atp-ranking-links* (parse-html (clean *atp-ranking* links)))



;; THE REAL THING

(defun regexp-finder (regexp)
  (lambda (html-str)
    (register-groups-bind (first) (regexp html-str) first)))

(defun xpath-finder (xpath-expr) nil)

(defun regexp-splitter (regexp) nil)

(defun xpath-splitter (xpath-expr)
  (lambda (html-str)
    (with-parse-document (doc html-str)
      (iter (for node in-xpath-result xpath-expr on doc)
	    (let ((node-str (remove-nl-tab-spc (serialize node :to-string))))
	      (when (> (length node-str) 0) (collect node-str)))))))

(defmacro def-web-extractor (name attributes) 
  `(defparameter ,name 
     (list
      ,@(loop for attr in attributes collect 
	     (cond ((member :collection attr)
		    `(list (quote ,(car attr)) 
			   :collection ,(get-key :collection attr)
			   :splitter ,(get-key :splitter attr)))
		   (t 
		    `(list (quote ,(car attr)) :finder ,(get-key :finder attr))))))))

(defun clean-for-xpath (html)
  (let ((xhtml (html2xhtml html)))
    (regex-replace-all "<[Hh][Tt][Mm][Ll].*?>" xhtml "<html>")))
  
(defun extract (&key str url struct-map)
  (let ((data (if str 
		  str
		  (clean-for-xpath (get-string-from-url url)))))
  (loop for attr in struct-map collect
       (list
	(car attr)
	(cond 
	  ((member :follow attr)                            
	   (extract 
	    :url (funcall (get-key :finder attr) data)
	    :struct-map (get-key :follow attr)))
	  ((member :collection attr)                        
	   (cons :COLLECTION
		 (let* ((splitted-list (funcall (get-key :splitter attr) data))
			(struct-map-type (get-key :collection attr)))
		   (if struct-map-type
		       (loop for spl in splitted-list collect
			    (extract
			     :str spl
			     :struct-map struct-map-type))
		       splitted-list))))
	  (t 
	   (funcall (get-key :finder attr) data)))))))



;; (expose players-web-ex)

;; You should GET the data via HTTP using REST like services :
;;
;; http://localhost/player
;; http://localhost/player/1
;; http://localhost/player/1/age
;; http://localhost/player/1/matches/
;; http://localhost/player/1/matches/1
;; http://localhost/player/1/matches/1/date
;; http://localhost/player/1/matches/1/details/against
