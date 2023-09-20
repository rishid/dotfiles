
;; ---------------------------------------------------------- [ ido-mode ]
;; ido makes completing buffers and finding files easier
;; http://www.emacswiki.org/cgi-bin/wiki/InteractivelyDoThings
;; ido-mode is like magic pixie dust!

(require 'ido)
(ido-mode 'both)
(setq 
	ido-default-file-method 'selected-window
	ido-default-buffer-method 'selected-window
	ido-save-directory-list-file (concat emacs-tmp-dir "/ido.last")
	ido-ignore-buffers ;; ignore these guys
	'("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
	ido-work-directory-list '("~/" "~/Desktop" "~/Documents")
	ido-everywhere t                                              ; use for many file dialogs
	ido-case-fold  t                                              ; be case-insensitive
	ido-enable-last-directory-history t                           ; remember last used dirs
	ido-max-work-directory-list 30                                ; should be enough
	ido-max-work-file-list      50                                ; remember many
	ido-use-filename-at-point nil                                 ; don't use filename at point (annoying)
	ido-use-url-at-point nil                                      ;  don't use url at point (annoying)ido-enable-prefix nil
	ido-enable-flex-matching t                                    ; be flexible
	ido-create-new-buffer 'always
	ido-use-filename-at-point 'guess
	ido-confirm-unique-completion t                              ; wait for RET, even with unique completion
	ido-max-prospects 10)                                        ; don't spam my minibuffer

(provide 'init-ido)