;;; defuns.el --- Define some custom functions
;;
;; Part of the Emacs Starter Kit

(require 'thingatpt)
(require 'imenu)

;; Buffer-related
(defun ido-imenu ()
  "Update the imenu index and then use ido to select a symbol to navigate to.
Symbols matching the text at point are put first in the completion list."
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))
                              
                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))
                              
                              ((stringp symbol)
                               (setq name symbol)
                               (setq position (get-text-property 1 'org-imenu-marker symbol))))
                             
                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    ;; If there are matching symbols at point, put them at the beginning of `symbol-names'.
    (let ((symbol-at-point (thing-at-point 'symbol)))
      (when symbol-at-point
        (let* ((regexp (concat (regexp-quote symbol-at-point) "$"))
               (matching-symbols (delq nil (mapcar (lambda (symbol)
                                                     (if (string-match regexp symbol) symbol))
                                                   symbol-names))))
          (when matching-symbols
            (sort matching-symbols (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (symbol) (setq symbol-names (cons symbol (delete symbol symbol-names))))
                  matching-symbols)))))
    (let* ((selected-symbol (ido-completing-read "Symbol? " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (goto-char position))))

(defun turn-on-paredit ()
  (paredit-mode t))  
 
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))
  
(defun goto-longest-line ()
  "Finds the longest line and puts the point there."
  (interactive)
  (let ((width 0)
        (pos 0))
    (goto-char (point-min))
    (while (= (forward-line 1) 0)
      (end-of-line)
      (let ((curwid (current-column)))
        (unless (<= curwid width)
          (setq width curwid)
          (setq pos (point)))))
    (goto-char pos)))
	
(defun goto-matching-paren ()
  "If point is sitting on a parenthetic character, jump to its match."
  (interactive)
  (cond ((looking-at "\\s\(") (forward-list 1))
        ((progn
           (backward-char 1)
           (looking-at "\\s\)")) (forward-char 1) (backward-list 1))))
		   
(defun beginning-or-indentation (&optional n)
    "Move cursor to beginning of this line or to its indentation.
  If at indentation position of this line, move to beginning of line.
  If at beginning of line, move to beginning of previous line.
  Else, move to indentation position of this line.
  With arg N, move backward to the beginning of the Nth previous line.
  Interactively, N is the prefix arg."
    (interactive "P")
    (cond ((or (bolp) n)
           (forward-line (- (prefix-numeric-value n))))
          ((save-excursion (skip-chars-backward " \t") (bolp)) ; At indentation.
           (forward-line 0))
          (t (back-to-indentation))))

(defun recentf-ido-find-file ()
  "Find a recent file using ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

;; Other

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun recompile-init ()
  "Byte-compile all your dotfiles again."
  (interactive)
  (byte-recompile-directory emacs-dir 0)
  ;; TODO: remove elpa-to-submit once everything's submitted.
  (byte-recompile-directory (concat emacs-dir "elpa-to-submit/") 0))

(defun regen-autoloads (&optional force-regen)
  "Regenerate the autoload definitions file if necessary and load it."
  (interactive "P")
  (let ((autoload-dir (concat emacs-dir "/elpa-to-submit"))
        (generated-autoload-file autoload-file))
    (when (or force-regen
              (not (file-exists-p autoload-file))
              (some (lambda (f) (file-newer-than-file-p f autoload-file))
                    (directory-files autoload-dir t "\\.el$")))
      (message "Updating autoloads...")
      (let (emacs-lisp-mode-hook)
        (update-directory-autoloads autoload-dir))))
  (load autoload-file))

(defun sudo-edit (&optional arg)
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun lorem ()
  "Insert a lorem ipsum."
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do "
          "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim"
          "ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
          "aliquip ex ea commodo consequat. Duis aute irure dolor in "
          "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "
          "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
          "culpa qui officia deserunt mollit anim id est laborum."))

;; -------------------------------------------------- [ select-vc-status ]
(defun select-vc-status ()
  "Calls for a directory and calls `svn-status' or `git-status' depending on what
type of version control found in that directory"
  (interactive)
  (let* ((local-default-dir (ftf-project-directory))
         (targetDir
          (read-directory-name "Status of directory: "
                               local-default-dir
                               local-default-dir
                               nil)))
    (cond ((file-exists-p (concat targetDir "/.git"))
           (git-status targetDir))
          ((file-exists-p (concat targetDir "/.svn"))
           (svn-status targetDir))
          ((file-exists-p (concat targetDir "/CVS"))
           (cvs-status targetDir)))))

;; -----------------------------------------------------------------------
;; Helper Functions (used in mode startup)
;; -----------------------------------------------------------------------
;; --------------------------------------------- [ start-programing-mode ]
(defun start-programing-mode()
  (interactive)

  ;; Setup flyspell to make me not look like an idiot to my coworkers
  ;; and Haeleth and whoever else reads my code.
  ;(flyspell-prog-mode)

  ;; All trailing whitespace needs to be highlighted so it can die.
  (setq show-trailing-whitespace t)

  ;; Highlight matching parentheses when the point is on them.
  ;; show-paren-mode: subtle blinking of matching paren (defaults are ugly)
  ;; http://www.emacswiki.org/cgi-bin/wiki/ShowParenMode
  (when (fboundp 'show-paren-mode)
	(show-paren-mode t)
	(setq show-paren-delay 0.0)  
	(setq show-paren-style 'mixed))  
	
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|BUG\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t)))
		  
  (whitespace-mode t)
  
  (add-hook 'before-save-hook
    'delete-trailing-whitespace nil t)
  
  (setq comment-auto-fill-only-comments t)
  (auto-fill-mode t)
)
  
;; ------------------------------------------- [ my-start-scripting-mode ]
(defun my-start-scripting-mode (file-extension hash-bang)
  ;; All scripting languages are programming languages
  (start-programing-mode)

  (local-set-key "\C-css" 'insert-script-seperator-line)
  (local-set-key "\C-csh" 'insert-script-section-header)
  (local-set-key "\C-csb" 'insert-script-big-header)

  ;; Build a startup template for this mode.
  (my-start-autoinsert)
  (tempo-define-template (concat file-extension "startup")
                         (list (concat hash-bang "\n\n")))
  (push (cons (concat "\\." file-extension "$")
              (intern (concat "tempo-template-" file-extension "startup")))
        auto-insert-alist)

  ;; Make the script executable on save
  (add-hook 'after-save-hook
            'executable-make-buffer-file-executable-if-script-p
            nil t))
			
;; ----------------------------------------------- [ my-start-autoinsert ]
(defun my-start-autoinsert ()
  "Helper function called from anything that puts in a template
from an empty file."
  (interactive)
  (require 'autoinsert)
  (add-hook 'find-file-hooks 'auto-insert)
  (setq auto-insert-alist '())
  (setq auto-insert-query nil)
  (require 'tempo))
  
;; ------------------------------------------------- [ intelligent-close ]
(defun intelligent-close ()
  "quit a frame the same way no matter what kind of frame you are on.

This method, when bound to C-x C-c, allows you to close an emacs frame the
same way, whether it's the sole window you have open, or whether it's
a \"child\" frame of a \"parent\" frame.  If you're like me, and use emacs in
a windowing environment, you probably have lots of frames open at any given
time.  Well, it's a pain to remember to do Ctrl-x 5 0 to dispose of a child
frame, and to remember to do C-x C-x to close the main frame (and if you're
not careful, doing so will take all the child frames away with it).  This
is my solution to that: an intelligent close-frame operation that works in
all cases (even in an emacs -nw session).

Stolen from http://www.dotemacs.de/dotfiles/BenjaminRutt.emacs.html"
  (interactive)
  (if (eq (car (visible-frame-list)) (selected-frame))
      ;;for parent/master frame...
      (if (> (length (visible-frame-list)) 1)
          ;;close a parent with children present
          (delete-frame (selected-frame))
        ;;close a parent with no children present
        (save-buffers-kill-emacs))
    ;;close a child frame
    (delete-frame (selected-frame))))

(global-set-key "\C-x\C-c" 'intelligent-close) ;forward reference

;; ------------------------------------------------------------- [ tempo ]
(defun tempo-space ()
  (interactive "*")
  (or (tempo-expand-if-complete)
      (insert " ")))
	  
(defun switch-or-start (function buffer)
  "If the buffer is current, bury it, otherwise invoke the function."
  (if (equal (buffer-name (current-buffer)) buffer)
      (bury-buffer)
    (if (get-buffer buffer)
        (switch-to-buffer buffer)
      (funcall function))))

(defun insert-date ()
  "Insert a time-stamp according to locale's date and time format."
  (interactive)
  (insert (format-time-string "%c" (current-time))))

(autoload 'paredit-mode "paredit"
    "Minor mode for pseudo-structurally editing Lisp code." t)
      
(defun esk-paredit-nonlisp ()
  "Turn on paredit mode for non-lisps."
  (set (make-local-variable 'paredit-space-delimiter-chars)
       (list ?\"))
  (paredit-mode 1))

(defun esk-space-for-delimiter? (endp delimiter)
  (not (member major-mode '(ruby-mode espresso-mode js-mode js2-mode))))

(eval-after-load 'paredit
  '(add-to-list 'paredit-space-for-delimiter-predicates
                'esk-space-for-delimiter?))

(defun toggle-fullscreen ()
  (interactive)
  ;; TODO: this only works for X. patches welcome for other OSes.
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))

(defun message-startup-time ()
  "Display a message of how long Emacs took to start up, in milliseconds."
  (message "Emacs loaded in %dms"
           (/ (-
               (+
                (third after-init-time)
                (* 1000000
                   (second after-init-time)))
               (+
                (third before-init-time)
                (* 1000000
                   (second before-init-time))))
              1000)))

(provide 'defuns)
;;; defuns.el ends here