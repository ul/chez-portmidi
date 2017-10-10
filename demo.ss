(load "portmidi-ffi.ss")
(Pm_Initialize)
(Pm_CountDevices)
(define *stream (make-ftype-pointer PortMidiStream (foreign-alloc (ftype-sizeof PortMidiStream))))

(define time-proc
  (let ([code (foreign-callable
               (lambda (x)
                 ;; (let ([now (current-time)])
                 ;;   (+ (* 1000 (time-second now))
                 ;;      (* 1000000 (time-nanosecond now))))
                 123
                 )
               (void*)
               integer-32)])
    (lock-object code)
    (make-ftype-pointer PmTimeProc (foreign-callable-entry-point code))))

(Pm_OpenInput *stream 0 0 256 time-proc 0)

(define stream (ftype-ref PortMidiStream () *stream))

(define buffer (make-ftype-pointer
                PmEventBuffer
                (foreign-alloc (* PmEventBuffer-size (ftype-sizeof PmEvent)))))
;; (sleep (make-time 'time-duration 0 2))
;; turn knobs... and then
;; (define msg-count (Pm_Read stream buffer PmEventBuffer-size))
;; (printf "0/~s@~s:~s\r\n"
;;         msg-count
;;         (ftype-ref PmEventBuffer (0 timestamp) buffer)
;;         (ftype-ref PmEventBuffer (0 message) buffer)
;;         )
;; (Pm_Close stream)
;; (Pm_Terminate)
