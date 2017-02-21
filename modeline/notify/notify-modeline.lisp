;;;; notify-modeline.lisp

(in-package #:notify-modeline)

;;;;
;;;; Status line for notification server which shows the messages
;;;;

(defvar *message-list-queue* (make-queue :simple-queue)
  "List of received messages")

(defvar *notify-modeline-is-on* nil
  "Does the notify-modeline show messages?")

(defvar *running-lock* (make-lock)
  "The multithreading lock for variable")

(defvar *message-received* (make-condition-variable
			    :name "notify-modeline.*message-received*")
  "Method of communication between handler and *show-thread*")

(defvar *show-thread* nil
  "Thread to move notifcations from *message-list* to the line")

(defvar *update-timeout* 5
  "Timeout of notification in seconds")

(defvar *current-message* ""
  "Message that is currently shown in modeline")

(defun notification-handler (app icon summary body)
  "Set the *last-message* text to the text from incoming notification"
  (declare (ignore app icon))
  (let ((msg (format nil "~A ~A" summary body)))
    (qpush *message-list-queue* msg))
  (with-lock-held (*running-lock*)
    (condition-notify *message-received*)))

(defun listening-thread ()
  "Endless loop waiting for new messages and directing them to *current-message*"
  (do ((running T)) ((eq running nil))
    (let ((msg (qpop *message-list-queue*)))
      (if (not (null msg))
	  (setf *current-message* msg)
	  (with-lock-held (*running-lock*)
	    (condition-wait *message-received* *running-lock*))))
    (with-lock-held (*running-lock*)
      (setf running *notify-modeline-is-on*))))

(defun notify-modeline-on ()
  "Start showing the messages"
  (setf notify:*notification-received-hook* #'notification-handler)
  (with-lock-held (*running-lock*)
    (setf *notify-modeline-is-on* T))
  (setf *show-thread*
	(make-thread #'listening-thread
		     :name "notify-modeline.*listening-thread*")))

(defun notify-modeline-off ()
  "Stop showing the messages"
  (setf notify:*notification-received-hook* #'notify::show-notification)
  (with-lock-held (*running-lock*)
    (setf *notify-modeline-is-on* nil))
  (condition-notify *message-received*)
  (join-thread *show-thread*))

(stumpwm:defcommand notify-modeline-toggle () ()
  "Toggles notify modeline."
  (if *notify-modeline-is-on*
      (notify-modeline-off)
      (notify-modeline-on)))
