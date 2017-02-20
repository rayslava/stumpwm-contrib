(defpackage #:notify-modeline
  (:use #:cl
	#:stumpwm
	#:bordeaux-threads
	#:queues)
  (:export notify-modeline-toggle))
