;; bindings.el file
;; Rishi Dhupar
;; Time-stamp: <09-01-2011 16:53:24 (rkd4127)>

;; Global key bindings

(defmacro djcb-program-shortcut (name key &optional use-existing)
  "* macro to create a key binding KEY to start some terminal program PRG; 
    if USE-EXISTING is true, try to switch to an existing buffer"
  `(global-set-key ,key 
     '(lambda() (interactive) 
        (djcb-term-start-or-switch ,name ,use-existing))))

(global-set-key (kbd "<delete>")    'delete-char)  ; delete == delete    
(global-set-key (kbd "M-g")         'goto-line)    ; M-g  'goto-line

;; kill whole line with C-; (because ; is close to k)
(global-set-key (kbd "C-;") 'kill-whole-line)

;; Completion that uses many different methods to find options.
(global-set-key (kbd "M-/") 'hippie-expand)

;; C-pgup goes to the start, C-pgdw goes to the end
(global-set-key(kbd "<C-prior>")(lambda()(interactive)(goto-char(point-min))))
(global-set-key(kbd "<C-next>") (lambda()(interactive)(goto-char(point-max))))

;; Use regex searches by default.
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(global-set-key (kbd "C-z") 'undo)   ;; use it like CUA, not like 'suspend'
(global-set-key (kbd "s-b") 'pop-global-mark) ; jump *back* to prev location

; replace-string and replace-regexp need a key binding
(global-set-key (kbd "C-c s") 'replace-string)
(global-set-key (kbd "C-c r") 'replace-regexp)

;; Window switching. (C-x o goes to the next window)
(windmove-default-keybindings) ;; Shift+direction
(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two

;; Start eshell or switch to it if it's active.
(global-set-key (kbd "C-x m") 'eshell)

;; Start a new eshell even if one is active.
(global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))


;; programming/writing stuff; f5-f8
(global-set-key (kbd "<f7>") 'compile)                     ;; compile
(global-set-key (kbd "S-<f7>") 'delete-other-windows)      ;; close ...


(global-set-key (kbd "<f8>") 'comment-or-uncomment-region) ;; (un)comment
;; for writing
(global-set-key (kbd "C-<f5>") 'djcb-count-words)          ;; count words
(when (djcb-require-maybe 'magit)                          ;; marius...
  (global-set-key (kbd "C-<f6>") 'magit-status))           ;; ...git mode

(global-set-key (kbd "C-c q") 'join-line)

;; some toggles; Shift + function key
(global-set-key (kbd "<S-f6>") 'highlight-changes-visible-mode) ;; changes
(global-set-key (kbd "<S-f7>") 'whitepace-mode)            ;; show blanks
(autoload 'linum "linum" "mode for line numbers" t) 
(global-set-key (kbd "<S-f9>")   'djcb-fullscreen-toggle)  ;; fullscreen
(global-set-key (kbd "<S-<f10>")  'package-list-packages)  ;; elpa

(provide 'bindings)
