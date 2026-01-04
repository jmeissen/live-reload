(in-package :cl-user)

(defpackage :live-reload
  (:use :cl)
  (:local-nicknames (:ws :websocket-driver))
  (:export
   :head
   :start
   :stop
   :reload
   :*host*
   :*websocket-port*
   :*websocket*))

(in-package :live-reload)

(defvar *connections* (make-hash-table))
(defvar *host* "127.0.0.1")
(defvar *websocket-port* 12345)
(defvar *websocket*)

(setf hunchentoot:*default-connection-timeout* 3600)

(defun script (host port &key ssl)
  "Output Websocket Javascript."
  (format nil "const ws = new WebSocket('~A://~A:~A/reload');
ws.onmessage = () => location.reload();
console.log('live-reload connected');" (if ssl "wss" "ws") host port))

(defun head (&key stream host port ssl)
  "Get JS wrapped in <script>-tag to include in HTML."
  (format stream "<script type='application/javascript'>~a</script>" (script (or host *host*) (or port *websocket-port*) :ssl ssl)))

(defun websocket-server (env)
  (let ((ws (ws:make-server env)))
    (ws:on :open ws
           (lambda ()
             (setf (gethash ws *connections*)
                   (format nil "user-~a" (random 10000)))))
    (ws:on :close ws
           (lambda (&key code reason)
             (declare (ignore code reason))
             (remhash ws *connections*)))
    (lambda (responder)
      (declare (ignore responder))
      (ws:start-connection ws))))

(defun start (&key (host *host*) (websocket-port *websocket-port*))
  (setf *websocket* (clack:clackup #'websocket-server :port websocket-port :address host)))

(defun broadcast (message)
  (loop for con being the hash-key of *connections*
        do (ws:send con message)))

(defun reload ()
  "Reload all pages that have an open websocket connection."
  (broadcast ""))

(defun stop ()
  (clack:stop *websocket*)
  (setf *websocket* nil))
