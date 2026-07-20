;; Package setup
(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu"    . 30)
        ("nongnu" . 20)
        ("melpa"  . 10))
      use-package-always-ensure t);; Custom File
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

;; Visuals
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 165)
(use-package ef-themes
  :ensure t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)
  (modus-themes-load-theme 'ef-bio))

;; Package
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))

(use-package org
  :ensure nil
  :config  
  (setq org-directory "~/Documents/org")
  (setq org-agenda-files (list org-directory)))

(use-package magit)

; Movement
(use-package meow
  :ensure t
  :config
  (meow-normal-define-key
   '("h" . meow-left)
   '("j" . meow-next)
   '("k" . meow-prev)
   '("l" . meow-right))	
  (meow-global-mode 1))
