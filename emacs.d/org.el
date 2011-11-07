;;; org.el --- Some helpful Org mode mode
;;

(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-log-done t)   ;; When marking item done add a timestamp

;; Remaps the S+Up/Down/Left/Right keys which clash with windmove
(setq org-replace-disputed-keys t)

;; Add all org files in org dir to agenda
(setq org-agenda-files '("~/.emacs.d/org/"))

;; Show only the last star
(setq org-hide-leading-stars t)

;; Two stars per level gives better alignment
(setq org-odd-levels-only t)

;; URL abbreviations
(setq org-link-abbrev-alist
    '(("ticket" . "http://svn:8000/squirt/ticket/%s")))

;; Only show top level items in agenda todo list
(setq org-agenda-todo-list-sublevels nil)

;; Add tags for squirt and emacs and define custom agenda views
;; http://orgmode.org/org.html#Custom-agenda-views
;; http://orgmode.org/org.html#Tags

;; Don't allow parent entries to be DONE when children are not
(setq org-enforce-todo-dependencies t)

;; Dim agenda tasks which are blocked by dependencies
(setq org-agenda-dim-blocked-tasks t)

;; Load the habits module
(defun im-org-mode-hook ()
    (add-to-list 'org-modules 'habits)
)
(add-hook 'org-mode-hook 'im-org-mode-hook)

(provide 'org)
;; org.el ends here

