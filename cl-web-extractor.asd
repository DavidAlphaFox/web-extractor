(defsystem cl-web-extractor
  :name "Web-Extractor"
  :description "Framework for extract data from web pages."
  :version "0.01"
  :author "Juan Monetta <jpmonettas@gmail.com>"
  :licence "MIT License"
  :depends-on (:drakma :cl-ppcre :cl-libxml2 :closure-html :cxml)
  :components ((:file "packages")
	       (:file "utils"
		      :depends-on ("packages"))
               (:file "web-extractor"
		      :depends-on ("packages" "utils"))))





