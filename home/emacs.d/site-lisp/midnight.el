;; ----------------------------------------------------- [ midnight-mode ]
(require 'midnight)

;; Never clean up these files. I will probably always have my .emacs file open.
(add-to-list 'clean-buffer-list-kill-never-buffer-names "emacs")

;; Clean up these buffers more often
(add-to-list 'clean-buffer-list-kill-buffer-names "*Annotate ")