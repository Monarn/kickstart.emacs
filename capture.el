(require 'json)
(require 'org-id)

(defvar my/org-capture-title "")
(defvar my/org-capture-deadline "")

(defun my/org-title ()
  my/org-capture-title)

(defun my/org-deadline ()
  (org-read-date nil nil my/org-capture-deadline))

(setq org-capture-templates
      '(("t" "Todo" entry
         (file+headline "~/org/todo.org" "Todo")
         "* TODO %(my/org-title)
DEADLINE: <%(my/org-deadline)>
:PROPERTIES:
:ID: %(org-id-new)
:END:
CREATED: %U"
         :immediate-finish t)))

(defun my/org-capture-todo (title deadline)
  (let ((my/org-capture-title title)
        (my/org-capture-deadline deadline))
    (org-capture nil "t")))

(defun my/org-get-todo-list ()
  (with-current-buffer (find-file-noselect "~/org/todo.org")
    (org-map-entries
     (lambda ()
       (list
        :name (org-get-heading t t t t)
        :deadline (org-get-deadline-time nil)
        :id (org-id-get)))
     "TODO=\"TODO\""
     'file)))

(defun my/filter-todo-list-by-deadline (task-list)
  (seq-filter
   (lambda (task)
     (let ((deadline (plist-get task :deadline)))
       (time-less-p (current-time) deadline)))
   task-list))

(defun my/sort-todo-list-by-deadline (task-list)
  (seq-sort-by
   (lambda (task)
     (or (plist-get task :deadline) most-positive-fixnum))
   #'time-less-p
   task-list))

(defun my/get-filtered-list ()
  (my/sort-todo-list-by-deadline (my/filter-todo-list-by-deadline (my/org-get-todo-list))))

(defun my/task-plist-for-json (task)
  (let ((deadline (plist-get task :deadline)))
    (list :name (plist-get task :name)
          :deadline (if deadline
                        (format-time-string "%A %d %B %Y" deadline)
                      :null)
          :id (plist-get task :id))))

(defun my/get-todo-list ()
  (json-encode
   (apply #'vector (mapcar #'my/task-plist-for-json (my/get-filtered-list)))))

(defun my/set-todo-done (id)
  (let ((res (org-id-find-id-in-file id "~/org/todo.org")))
    (with-current-buffer (find-file-noselect "~/org/todo.org")
    (goto-char (cdr res))
    (org-todo "DONE")
    (save-buffer))))
