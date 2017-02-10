(defpackage #:notify
  (:use #:cl
	#:stumpwm
	#:dbus
	#:bordeaux-threads)
  (:shadowing-import-from #:dbus :message)
  (:export #:*notification-received-hook*
	   #:notify-server-toggle))
