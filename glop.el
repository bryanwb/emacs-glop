;;; provides simple functions to open the current line or
;;; selection in gitlab

(defun glop-shell-to-string (cmd)
  "Custom shell command execution. Returns stdout if command succeeds,
   otherwise returns nil"
  (interactive)
  (with-temp-buffer
    (let* ((glob-buf-stdout (buffer-name)))
      (if (eq 0 (call-process-shell-command cmd nil glob-buf-stdout))
          (buffer-string)
        nil))))
  

(defun glop-get-git-exec ()
  "This duplicates functionality inside magit"
  (executable-find "git"))

(defun glop-get-branch ()
  "Finds the current branch"
  (let
      ((cmd (format "%s rev-parse --abbrev-ref HEAD" (glop-get-git-exec))))
    (string-trim (glop-shell-to-string cmd))))


(defun glop-get-project-group+name ()
  "Gets the project's gitlab group and name"
  (let ((origin (glop-get-origin)))
    (if (null origin)
        nil
      (car (split-string
             (cadr (split-string origin ":" t "\n"))
             ".git" t)))))

(defun glop-get-origin ()
  "Get the full git url for the origin remote"
  (interactive)
  (let ((get-url-cmd (format "%s remote get-url origin" (glop-get-git-exec)))
    (glop-shell-to-string get-url-cmd))))
     

(defun glop-get-current-file-relative ()
  (string-trim 
   (glop-shell-to-string
    (format "%s ls-files %s" (glop-get-git-exec) (buffer-file-name)))))


(defun iglop-get-line-nums ()
  (interactive)
  (message (glop-get-line-nums)))

(defun glop-get-line-nums ()
  "Returns line number(s) if applicable. If region selected,
   returns range in url form"
  (if (use-region-p)
      (format "#L%d-%d"
              (line-number-at-pos (region-beginning))
              (line-number-at-pos (region-end)))
    (format "#L%d" (line-number-at-pos (point)))))
      

(defun glop-make-url-current-file ()
  "Creates gitlab url for current file"
  (let* ((host gitlab-host)
         (branch (glop-get-branch))
         (group+name (glop-get-project-group+name))
         (fname (glop-get-current-file-relative))
         (linenums (glop-get-line-nums)))
         (format "%s/%s/blob/%s/%s%s" host group+name branch fname linenums)))


(defun glop-glap ()
  "Copy to clipboard gitlab url for current selection"
  (interactive)
  (let ((url (glop-make-url-current-file)))
    (kill-new url)
    url))


(defun glop-glop ()
  "Open browser to view current file in gitlab"
  (interactive)
  (browse-url (glop-glap)))


(provide 'glop)
