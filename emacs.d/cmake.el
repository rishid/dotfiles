;;; cmake.el --- Some helpful CMake code
;;

;; Add cmake listfile names to the mode list.
(require 'cmake-mode)

(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode))
     
(provide 'cmake)
;; cmake.el ends here