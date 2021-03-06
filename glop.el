;;; provides simple functions to open the current line or
;;; selection in gitlab

(require 's)
(require 'f)

(defun glop-shell-to-string (cmd)
  "Custom shell command execution. Returns stdout if command succeeds,
   otherwise returns nil"
  (interactive)
  (with-temp-buffer
    (let ((glob-buf-stdout (buffer-name)))
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
    (s-trim (glop-shell-to-string cmd))))


(defun glop-get-top-level-dir ()
  "Find top-level project directory"
  (let ((cmd (format "%s rev-parse --show-toplevel" (glop-get-git-exec))))
    (s-trim
     (glop-shell-to-string cmd))))

(defun glop-get-relevant-path ()
  "Return directory path if in dired mode. Return full file path if viewing
   a file. For all other cases, return the toplevel git directory"
  (cond
   ((eq major-mode "dired-mode") (dired-current-directory))
   ((null buffer-file-name) (glop-get-top-level-dir))
   (t (buffer-file-name))))

(defun glop-viewing-filep ()
  "Returns t if currently viewing a file, nil otherwise"
  (when (not (null buffer-file-name)) t))


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
  (let ((get-url-cmd (format "%s remote get-url origin" (glop-get-git-exec))))
    (glop-shell-to-string get-url-cmd)))
     

(defun glop-get-current-path-relative ()
  (file-relative-name (glop-get-relevant-path) (glop-get-top-level-dir)))


(defun glop-get-line-nums ()
  "Returns line number(s) if applicable. If region selected,
   returns range in url form"
  (cond ((not (glop-viewing-filep)) "")
        ((use-region-p)
         (format "#L%d-%d"
                 (line-number-at-pos (region-beginning))
                 (line-number-at-pos (region-end))))
         (t
          (format "#L%d" (line-number-at-pos (point))))))

(defun glop-make-url-current-file ()
  "Creates gitlab url for current file"
  (let* ((host gitlab-host)
         (branch (glop-get-branch))
         (group+name (glop-get-project-group+name))
         (path (glop-get-current-path-relative))
         (linenums (glop-get-line-nums)))
    (format "%s/%s" host (f-join group+name "blob" branch
                                 (format "%s%s" path linenums)))))


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
