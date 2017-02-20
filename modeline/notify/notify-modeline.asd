;;;; notify-modeline.asd

(asdf:defsystem #:notify-modeline
  :description "Support for receiving notifications into StumpWM modeline"
  :author "Slava Barinov <rayslava@gmail.com>"
  :license "GPLv3"
  :depends-on (#:stumpwm
               #:notify
	       #:bordeaux-threads
	       #:queues.simple-cqueue)
  :serial t
  :components ((:file "package")
               (:file "notify-modeline" :depends-on ("package"))))
