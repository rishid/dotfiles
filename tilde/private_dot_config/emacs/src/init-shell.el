;; ------------------------------------------------------------- [ shell ]
(eval-after-load "shell"
  '(progn
     (ansi-color-for-comint-mode-on)))

;; ---------------------------------------------- [ Shell script startup ]
(defun my-shellscript-startup ()
  "Setup shell script mode."
  (interactive)
  (my-start-scripting-mode "sh" "#!/bin/bash"))

(add-hook 'sh-mode-hook 'my-shellscript-startup)

(provide 'shell)