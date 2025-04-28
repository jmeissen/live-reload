# Live Reload

## Description

Live reloading for developing HTML webpages in Common Lisp.

Essentially, the code runs a clack Websocket server on port 12345 and reloads the page on *any* received value.

## Usage

### Prepare documents for live reload

In your page `<head>`, include the string return value of the function

```lisp
(live-reload:head)
```

Note that if you're developing remotely, then the server `host` and client `host` may diverge, as well as the protocol (`ssl`) if your server is behind a reverse proxy.

### Start server

```lisp
(live-reload:start)
```

### Reload client

Evaluate:
```lisp
(live-reload:reload)
```

### Stop server

```lisp
(live-reload:stop)
```

### Automatic reloading

#### Example 1

Automatic client reloading on page recompilation (on `C-c C-c`-ing).
```lisp
(progn (defun index (items)
         (spinneret:with-html-string (:doctype)
           (:html
            (:head
             (:title "Index")
             (:raw ,(live-reload:head))) ;; <- Add script to head
            (:body (:header (:h1 "Index"))
                   (:section
                    (:ol
                     (dolist (item items)
                       (:li (:h2 (car item))
                            (:a :href (cadr item) (cadr item))
                            (:p (caddr item))))))))))
       (live-reload:reload)) ;; <- Reload on recompilation
```

#### Example 2

Emacs after-save-hook.
```emacs-lisp
(add-hook 'after-save-hook
          (lambda () (when (derived-mode-p 'lisp-mode)
                       (sly-interactive-eval "(live-reload:reload)"))))
```

## Exported symbols

### Functions
1. `(head &key stream host port ssl)`: Get `<script>`-tag with Websocket code to include in HTML.
2. `(start (&key (host *host*) (websocket-port *websocket-port*)))`: Start Websocket server.
3. `(reload)`: Reload pages on connections through a broadcast to all connections.
4. `(stop)`: Stop Websocket server and location watcher.

### Variables
1. `*host*`: The host on which the Websocket server will listen for requests (default: `127.0.0.1`)
2. `*websocket-port*`: The port on which the Websocket server will listen for requests (default: `12345`)
3. `*websocket*`: `clack` instance if the Websocket is running (default: `nil`).
