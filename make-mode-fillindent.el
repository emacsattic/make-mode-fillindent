;;; make-mode-fillindent.el --- filling indented makefile comments

;; Copyright 2008 Kevin Ryde

;; Author: Kevin Ryde <user42@zip.com.au>
;; Version: 1
;; Keywords: files
;; URL: http://www.geocities.com/user42_kevin/make-mode-fillindent/index.html
;; EmacsWiki: MakefileMode

;; make-mode-fillindent.el is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; make-mode-fillindent.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.
;;
;; You can get a copy of the GNU General Public License online at
;; <http://www.gnu.org/licenses>.


;;; Commentary:

;; This is a spot of code for makefile-mode to let fill-paragraph (M-q) work
;; on indented comments like
;;
;;	foo:
;;		# this is
;;		# some comment
;;		echo hi
;;
;; In Emacs 22 and 21 makefile-mode uses a special makefile-fill-paragraph
;; for filling.  It handles "#" comments at the start of a line, but does
;; nothing if they're indented.  Doing nothing is particularly disconcerting
;; if you use filladapt.el, because filladapt-debug shows a correct
;; prefix+paragraph analysis yet M-q has no effect.
;;
;; Whether or not writing indented comments in a makefile is a good idea is
;; another question of course.  "make" runs them with the shell, which will
;; ignore them.  The happy side-effect is to get an echo from make, so you
;; see them as the rule runs (whereas unindented makefile comments are
;; consumed by make).
;;
;; Paragraph identification in Emacs 21 and XEmacs 21 makefile-mode isn't
;; really setup for indented comments, and no attempt is made here to do
;; anything about that.  The suggestion is to use filladapt which gets it
;; right (or is easier to configure if it doesn't).

;;; Install:

;; Put make-mode-fillindent.el somewhere in your load-path and in your .emacs
;;
;;     (eval-after-load "make-mode" '(require 'make-mode-fillindent))
;;
;; There's an autoload cookie below for this, if you're brave enough to use
;; `update-file-autoloads' and friends.

;;; History:
;;
;; Version 1 - the first version


;;; Code:

;;;###autoload (eval-after-load "make-mode" '(require 'make-mode-fillindent))

(require 'make-mode)

(if (with-temp-buffer
      (insert "\t# foo\n\t# bar\n")
      (goto-char (point-min))
      ;; if makefile-fill-paragraph claims to have acted, but leaves two
      ;; lines instead of one, then it's done the wrong thing and we should
      ;; apply our defadvice
      (and (makefile-fill-paragraph nil)
           (= 2 (count-lines (point-min) (point-max)))))

    (defadvice makefile-fill-paragraph (around make-mode-fillindent activate)
      "Let indented comments go to normal filling."
      (if (save-excursion
            (beginning-of-line)
            (looking-at "^[ \t]+#+\\s-*"))

          ;; Use ordinary filling.
          ;;
          ;; The usual way is to return nil to ask for ordinary filling, but
          ;; the following is what makefile-fill-paragraph does, so for
          ;; consistency we'll do the same.  Both ways seem fine with
          ;; filladapt.el, perhaps there's a difference with adaptive fill
          ;; or something.  (Emacs pre-23 has taken to returning nil, but
          ;; maybe it can rely on improved comment detection and whatnot.)
          ;;
          (let ((fill-prefix (buffer-substring-no-properties
                              (match-beginning 0) (match-end 0)))
                (fill-paragraph-function nil))
            (fill-paragraph nil)
            (setq ad-return-value t))

        ;; rest of makefile-fill-paragraph
        ad-do-it)))

(provide 'make-mode-fillindent)

;;; make-mode-fillindent.el ends here
