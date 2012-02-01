(setq visible-bell t
      font-lock-maximum-decoration t
      color-theme-is-global t
      truncate-partial-width-windows nil)

;(set-face-background 'region "#464740")

;; Global highlight current line
(global-hl-line-mode t)

;; Customize background color of lighlighted line
;(set-face-background 'hl-line "#222222")

;; Subtler highlight in magit
;(set-face-background 'magit-item-highlight "#121212")
;(set-face-foreground 'magit-diff-none "#666666")
;(set-face-foreground 'magit-diff-add "#00cc33")

;; Highlight in yasnippet
(set-face-background 'yas/field-highlight-face "#333399")

;; org-mode colors
(setq org-todo-keyword-faces
      '(
        ("INPR" . (:foreground "yellow" :weight bold))
        ("DONE" . (:foreground "green" :weight bold))
        ("IMPEDED" . (:foreground "red" :weight bold))
        ))

;; Highlight matching parentheses when the point is on them.
;; show-paren-mode: subtle blinking of matching paren (defaults are ugly)
;; http://www.emacswiki.org/cgi-bin/wiki/ShowParenMode
(show-paren-mode t)
(setq show-paren-delay 0.0)
(setq show-paren-style 'mixed)

;; Highwhen when searching and replacing
(setq search-highlight t
      query-replace-highlight t)

;; No menu bars
(menu-bar-mode -1)

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (turn-off-tool-bar)
  (tooltip-mode -1)
  (mouse-wheel-mode t)
  (blink-cursor-mode -1))

(add-hook 'before-make-frame-hook 'turn-off-tool-bar)

;; Ditch them scrollbars
(scroll-bar-mode -1)

;; Make zooming affect frame instead of buffers
(require 'zoom-frm)

(provide 'appearance)
