(defun flow-type/call-process-on-buffer-to-string (command)
  (with-output-to-string
    (call-process-region (point-min) (point-max) shell-file-name nil standard-output nil shell-command-switch command)))

(defun flow-type/type-description (info)
  (let ((type (alist-get 'type info)))
    (if (string-equal type "(unknown)")
        (let ((reasons (alist-get 'reasons info)))
          (if (> (length reasons) 0) (alist-get 'desc (aref reasons 0))))
      type)))

(defun flow-type/type-at-cursor ()
  (let ((output (flow-type/call-process-on-buffer-to-string
                 (format "%s type-at-pos --retry-if-init=false --json %d %d"
                         (executable-find "flow")
                         (line-number-at-pos) (+ (current-column) 1)))))
    (unless (string-match "\w*flow is still initializing" output)
      (flow-type/type-description (json-read-from-string output)))))

(defun flow-type/enable-eldoc ()
  (set (make-local-variable 'eldoc-documentation-function) 'flow-type/type-at-cursor))
