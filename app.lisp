
(require :html-entities)
(require :wu-sugar)

(defun xpath (expression xml)
  (let* ((target-path (rest (wu-sugar:split expression #\/)))
	 (target-depth (1- (length target-path)))
	 (depth -1)
	 (parent-match-depth -1)
	 prev-char-was-lt
	 el-name-start-index
	 el-name
	 close-tag
	 el-inner-start-index
	 results
	 in-xml-header)
    (loop for c across xml 
       for i from 0 do
	 (cond
	   ((char= c #\/)
	    (when prev-char-was-lt
	      (setf close-tag t
		    el-name-start-index (1+ i))))
	   ((char= c #\<)
	    (setf prev-char-was-lt t
		  close-tag nil
		  el-name-start-index (1+ i)))
	   ((char= c #\?)
	    (when prev-char-was-lt
	      (setf in-xml-header t)))
	   ((char= c #\>)
	    (if in-xml-header
		(setf in-xml-header nil)
		(progn
		  (setf el-name (subseq xml el-name-start-index i))
		  (if close-tag
		      (progn ; closing tag
			(when (= depth target-depth parent-match-depth)
			  (push (subseq xml el-inner-start-index 
					(- i (length el-name) 2)) 
				results))
			(when (= depth parent-match-depth) 
			  (decf parent-match-depth))
			(decf depth))
		      (progn ; opening tag
			(incf depth)
			(when (and (= (1- depth) parent-match-depth)
				   (let ((target-nth (nth depth target-path)))
				     (or (zerop (length target-nth)) 
					 (string= el-name target-nth))))
			  (incf parent-match-depth))
			(when (and (= depth target-depth parent-match-depth)
				   (string= el-name (nth depth target-path)))
			  (setf el-inner-start-index (1+ i))))))))
	   (t 
	    (setf prev-char-was-lt nil))))
    (if (= 1 (length results))
        (first results)
        (nreverse results))))

(defun http-get (host &key (query "/") (port 80))
  "Returns the response from an HTTP GET request to HOST for QUERY."
  (let ((http-stream nil)
        (pos 0)
        (buf (make-array 16384 :element-type 'character :adjustable t)))
    (unwind-protect
         (progn
           (setf http-stream (rt:make-socket-stream (rt:socket-connect host port)))
           (write-sequence (format nil "GET ~A HTTP/1.0~%Host: ~A~%~%" query host)
                           http-stream)
           (loop
              (when (> (+ pos 4096) (length buf))
                (setf buf (adjust-array buf (* (length buf) 2))))
              (let ((new-pos (read-sequence buf http-stream :start pos :end (+ pos 4096))))
                (if (= new-pos pos)
                    (return (subseq buf 0 new-pos))
                    (setf pos new-pos)))))
      (when http-stream (close http-stream)))))


(defvar *items*)

(defstruct rss title description link)

(defun parse-rss (rss)
  (mapcar (lambda (item-xml)
            (make-rss :title (html-entities:decode-entities (xpath "/title" item-xml))
                      :description (html-entities:decode-entities (xpath "/description" item-xml))
                      :link (html-entities:decode-entities (xpath "/link" item-xml))))
          (xpath "///item" rss)))

(declaim (call-in load-rss))
(defun load-rss ()
  (setf *items* (parse-rss (http-get "planet.lisp.org" :query "/rss20.xml"))))

(declaim (call-in get-item-count))
(defun get-item-count ()
  (length *items*))

(rt:enable-objc-reader)

(declaim (call-in config-cell))
(defun config-cell (cell index)
  @(cell textLabel :setText (rss-title (elt *items* index))))

(defvar *item-index*)

(declaim (call-in set-item-index))
(defun set-item-index (index)
  (setf *item-index* index))

(declaim (call-in load-content))
(defun load-content (self)
  @(self webView :loadHTMLString (rss-description (elt *items* *item-index*))
         :baseURL @('NSURL :URLWithString (rss-link (elt *items* *item-index*)))))
