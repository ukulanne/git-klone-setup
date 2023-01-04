#!/usr/bin/guile3.0 \
-e main -s
!#
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Anne Summers                ;;
;; ukulanne@gmail.com          ;;
;; May 4, 2017                 ;;
;; Clone new repo              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Time-stamp: <2023-01-03 20:02:52 panda> 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This program is free software: you can redistribute it and/or modify        ;;
;; it under the terms of the GNU Lesser General Public License as published by ;;
;; the Free Software Foundation, either version 3 of the License, or           ;;
;; (at your option) any later version.                                         ;;
;;                                                                             ;; 
;; This program is distributed in the hope that it will be useful,             ;;
;; but WITHOUT ANY WARRANTY; without even the implied warranty of              ;;
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               ;;
;; GNU Lesser General Public License for more details.                         ;;
;;                                                                             ;;
;; You should have received a copy of the GNU Lesser General Public License    ;;
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-modules (ice-9 getopt-long))

(define VERSION "0.75")
(define GIT " git@github.com:")
(define GIT-PATH  (string-append "/home/panda/src/git/"))
(define NPM #t)
(define ORG "ukulanne")
(define MODULE  "git-klone-setup")
(define BRANCH  "dev")
(define MODULE-PATH "")
(define GIT-COMMAND "")
(define TAG #f)
;;(define sed-to-ssh "sed -i 's/https:\\/\\/github.ibm.com\\/AIX-Tools-Team\\//git@github.ibm.com:AIX-Tools-Team\\//' .gitmodules")
;;(define sed-to-https "sed -i 's/git@github.ibm.com:AIX-Tools-Team/https:\\/\\/github.ibm.com\\/AIX-Tools-Team/' .gitmodules")
(define HELP "\
Usage: git-klone-setup.scm [options]
Clones a module from github and creates a backup of current version
  -m,  --module    Module to clone.
  -o,  --org       Organization to use (aixtools default)
  -b,  --branch    Branch to use.
  -t,  --tag       Tag to use for backup directory
  -v,  --version   Display version.
  -h,  --help      Display this help.
 Copyright (C) 2017-2023 Anne Summers <ukulanne@gmail.com>
 This is free software released under the GNU LPGL 3, 
 and you are welcome to redistribute it under certain conditions.
 Please see <https://www.gnu.org/licenses/ for more information.\n")
(define (main args)
  (let* ((option-spec '((module  (single-char #\m) (value #t))
                        (org     (single-char #\o) (value #t))
                        (branch  (single-char #\b) (value #t))
                        (tag     (single-char #\t) (value #t))
                        (version (single-char #\v) (value #f))
                        (help    (single-char #\h) (value #f))))
         (options (getopt-long args option-spec))
         (module-set     (option-ref options 'module #f))
         (org-set        (option-ref options 'org #f))
         (branch-set     (option-ref options 'branch #f))
         (tag-set        (option-ref options 'tag #f))
         (help-wanted    (option-ref options 'help #f))
         (version-wanted (option-ref options 'version #f)))
    (if (or version-wanted help-wanted)
        (begin
          (if version-wanted
              (display (string-append "git-klone-setup.scm  " VERSION "\nAnne Summers<ukulanne@gmail.com>\n")))
          (if help-wanted
              (display HELP)))
        
        (begin      
          (if module-set (set! MODULE module-set))
          (if org-set    (set! ORG org-set))
          (if branch-set (set! BRANCH branch-set))
          (if tag-set    (set! TAG  tag-set))
          (set! MODULE-PATH (string-append GIT-PATH MODULE))
          (set! GIT-COMMAND (string-append "git clone --branch=" BRANCH GIT ORG "/" MODULE ".git"))
          
          (if (file-exists? MODULE-PATH)
               (rename-file MODULE-PATH
                    (string-append MODULE-PATH "-" 
                        (if TAG (string-append TAG "-") "") 
                            (strftime "%Y%m%d-%H:%M:%S" (localtime (current-time))))))
          
          (system GIT-COMMAND)
        ;;  (if (file-exists? (string-append MODULE-PATH "/.gitmodules"))
          ;;    (system (string-append "cd " MODULE-PATH " && " sed-to-ssh)))
          (system (string-append "cd " MODULE-PATH " && git submodule update --init --recursive --remote"))
          ;;(if (file-exists? (string-append MODULE-PATH "/.gitmodules"))
            ;;  (system (string-append "cd " MODULE-PATH " && " sed-to-https)))
          
          (if (file-exists? (string-append MODULE-PATH "/package.json"))
              (system (string-append "cd " MODULE-PATH " && npm install")))
          
          (system (string-append "cd " MODULE-PATH))
        )
    )
  )
)
