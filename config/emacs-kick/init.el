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
(set-frame-parameter nil 'undecorated t)

(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 165)

(use-package ef-themes
  :ensure t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t))

(use-package catppuccin-theme
  :ensure t
  :config
  (setq catppuccin-flavor 'mocha) ;; latte, frappe, macchiato, mocha
  (load-theme 'catppuccin :no-confirm)
  (catppuccin-reload))

;; General Config
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq backup-directory-alist
      `(("." . "~/.emacs.d/backups")))

;; Packages
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
  :bind (("C-c c" . org-capture)
	 ("C-c a" . org-agenda))
  :config  
  (setq org-directory "~/Documents/org")
  (setq org-default-notes-file
        (expand-file-name "inbox.org" org-directory))

  (setq org-capture-templates
        '(("t" "Todo" entry
           (file org-default-notes-file)
           "* TODO %?\n%U\n")))
  (require 'org-tempo)
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-files (list org-directory))
  (setq org-babel-python-command "/opt/homebrew/bin/python3")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t))))

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local fill-column 80)
            (turn-on-auto-fill)))

;; (use-package org-roam
;;   :ensure t
;;   :custom
;;   (org-roam-directory (file-truename "~/Documents/org/roam/"))
;;   (org-roam-dailies-directory "daily/")
;;   (org-roam-dailies-capture-templates
;;     '(("d" "daily" entry
;;       "* Work Goals\n1. %?\n2. \n3. \n\n* Ideal Stop Time:\n\n* Actual Stop Time\n\n* Side Quest(s)\n\n* Reflection:\n"
;;       :target
;;       (file+head "%<%Y-%m-%d>.org"
;;                  "#+title: %<%Y-%m-%d>\n\n"))))
;;   :bind
;;   (("C-c n t" . org-roam-dailies-goto-today)
;;    ("C-c n d" . org-roam-dailies-capture-today))
;;   :config
;;   (org-roam-db-autosync-mode))

(use-package denote
  :ensure t
  :bind
  ( :map global-map
    ("C-c n n" . denote)
    ("C-c n d" . denote-dired)
    ("C-c n g" . denote-grep)
    ("C-c n l" . denote-link-or-create)
    ("C-c n L" . denote-add-links)
    ("C-c n b" . denote-backlinks)
    ("C-c n q c" . denote-query-contents-link) ; create link that triggers a grep
    ("C-c n q f" . denote-query-filenames-link) ; create link that triggers a dired
    ("C-c n r" . denote-rename-file)
    ("C-c n R" . denote-rename-file-using-front-matter))
  :config
    (setq denote-directory (expand-file-name "~/Documents/org/notes/")))

(use-package magit)

(use-package gptel
  :ensure t
  :hook
  (gptel-mode . visual-line-mode)
  :config
  (setq gptel-default-mode 'org-mode)
  (setq gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key #'gptel-api-key-from-auth-source
          :models '(openai/gpt-5.5
                    anthropic/claude-sonnet-5)))

  (setq gptel-model 'openai/gpt-5.5))

(use-package elfeed
  :ensure t
  :config
  (setq elfeed-feeds
	'("https://lemire.me/blog/feed/"
	  "https://feeds.feedburner.com/TheHackerNews"
	  "https://geohot.github.io/blog/feed.xml"
	  "https://joshblais.com/index.xml"
	  "https://xenodium.com/rss.xml"
	  "https://xn--gckvb8fzb.com/index.xml"
	  "https://protesilaos.com/master.xml"
	  "https://projecteuler.net/rss2_euler.xml"
	  "https://www.youtube.com/feeds/videos.xml?channel_id=UC1tV5SjRyejRGeHAaMGYSsQ"
	  "https://www.youtube.com/feeds/videos.xml?channel_id=UCcaTUtGzOiS4cqrgtcsHYWg"
	  "https://www.youtube.com/feeds/videos.xml?channel_id=UC1HNvqTpK24NjOh6VsHxdfw"
	  "https://www.youtube.com/feeds/videos.xml?channel_id=UC0uTPqBCFIpZxlz_Lv1tk_g"
	  "https://www.youtube.com/feeds/videos.xml?channel_id=UC4NNPgQ9sOkBjw6GlkgCylg"))
  (setq elfeed-search-filter "@2-weeks"))

(use-package ytr
  :hook
  (ytr-mode . (lambda ()
		(display-line-numbers-mode -1)))
  :vc (:url "https://github.com/xenodium/ytr" :rev :newest)
  :commands (ytr))

(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package ghostel
  :ensure t)

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

;; mu4e
;; Account-specific identities, folders, SMTP hosts, and auth-source setup live
;; in private.el.gpg so this public config can stay reusable.
(defconst my/emacs-config-directory
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name user-init-file)))
  "Directory containing this Emacs configuration.")

(use-package mu4e
  :ensure nil
  :defer t
  :commands (mu4e mu4e-compose-new mu4e-context-switch)
  :init
  ;; Use mu4e when Emacs asks which mail composer/sender UI to use.
  (setq mail-user-agent 'mu4e-user-agent)
  :config
  ;; Local mail storage and refresh behavior.
  ;;
  ;; The Maildir subfolders below ~/.mail are configured per account in
  ;; private.el.gpg, because their names are account-specific.
  (let ((mbsync (executable-find "mbsync")))
    (setq mu4e-maildir "~/.mail"
          mu4e-update-interval 300
          mu4e-change-filenames-when-moving t)

    ;; `mu4e-get-mail-command` is what `U` in mu4e runs to fetch new mail.
    ;; The actual accounts/channels are defined in ~/.config/isync/mbsyncrc.
    (when mbsync
      (setq mu4e-get-mail-command
            (mapconcat #'identity
                       (list mbsync
                             "-c" (expand-file-name "~/.config/isync/mbsyncrc")
                             "-a")
                       " "))))

  ;; Private mail setup:
  (load
   (expand-file-name
    "private.el.gpg" my/emacs-config-directory)
   nil
   'nomessage))
