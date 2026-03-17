;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Mail identity
(defun tim/mail-address-from-msmtp-config ()
  "Read the default sender address from the local msmtp config."
  (let ((msmtp-config (expand-file-name "~/.config/msmtp/config")))
    (when (file-readable-p msmtp-config)
      (with-temp-buffer
        (insert-file-contents msmtp-config)
        (goto-char (point-min))
        (when (re-search-forward "^from[[:space:]]+\\(.+\\)$" nil t)
          (string-trim (match-string 1)))))))

(setq user-mail-address (or (tim/mail-address-from-msmtp-config) user-mail-address))

;; Appearance
(setq doom-font (font-spec :family "JetBrainsMonoNL NF" :size 12))

(setq doom-theme 'doom-gruvbox)
(add-to-list 'default-frame-alist '(alpha . 90))

(setq display-line-numbers-type `relative)

;; Org
(setq org-directory "~/Documents/org/")
(setq org-roam-directory (file-truename "~/Documents/org/roam"))
(after! org-roam
  (org-roam-db-autosync-mode))

;; Org Babel
(setq org-babel-python-command "python3")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python  . t)
   (shell   . t)
   (C       . t)
   (verilog . t)
   (asm     . t)
   (lua     . t)))

;; Org editing
(after! org
  (setq-default fill-column 80)
  (add-hook 'org-mode-hook #'auto-fill-mode)
  (setq truncate-lines nil))

;; Org links
(org-link-set-parameters
 "proj"
 :follow (lambda (path)
           (find-file (expand-file-name path "~/projects/")))
 :export (lambda (path desc format)
           (format "file:%s" (expand-file-name path "~/projects/"))))

;; macOS frame styling
(when (featurep 'ns)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (add-to-list 'default-frame-alist '(undecorated . t)))
(add-to-list 'default-frame-alist '(internal-border-width . 10))
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; PDF
(use-package pdf-view
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :config
  (setq pdf-view-midnight-colors '("#ABB2BF" . "#282C35")))

;; mu4e load path
(when (featurep 'ns)
  (setq mu4e-mu-binary "/opt/homebrew/bin/mu"
        mu4e-maildir "~/.mail")
  (dolist (dir '("/opt/homebrew/share/emacs/site-lisp/mu/mu4e"
                 "/opt/homebrew/opt/mu/share/emacs/site-lisp/mu4e"
                 "/usr/local/share/emacs/site-lisp/mu/mu4e"
                 "/usr/local/opt/mu/share/emacs/site-lisp/mu4e"))
    (when (file-directory-p dir)
      (add-to-list 'load-path dir))))

;; mu4e
(after! mu4e
  (let ((mail-address (tim/mail-address-from-msmtp-config)))
    (setq mu4e-maildir "~/.mail"
          mu4e-user-mail-address-list (when mail-address (list mail-address))
        mu4e-get-mail-command
        "/etc/profiles/per-user/tim/bin/mbsync -c ~/.config/isync/mbsyncrc gmail"
        mu4e-update-interval 300
        sendmail-program
        (or (executable-find "msmtp")
            "/etc/profiles/per-user/tim/bin/msmtp")
        message-send-mail-function #'message-send-mail-with-sendmail
        message-sendmail-envelope-from 'header
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments
        (list "--read-envelope-from"
              "--read-recipients"
              (concat "--file=" (expand-file-name "~/.config/msmtp/config")))
        mu4e-drafts-folder "/gmail/[Gmail]/Drafts"
        mu4e-sent-folder "/gmail/[Gmail]/Sent Mail"
        mu4e-trash-folder "/gmail/[Gmail]/Trash"
        mu4e-refile-folder "/gmail/[Gmail]/All Mail")))
