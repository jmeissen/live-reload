(asdf:defsystem :live-reload
  :description "Live reload for Common Lisp web development"
  :version "0.1.0"
  :author "Jeffrey Meissen <jeffrey@meissen.email>"
  :license "Public domain"
  :depends-on (:clack :websocket-driver)
  :components ((:file "live-reload")))
