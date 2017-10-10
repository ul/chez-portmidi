(library (portmidi (1))
  (export message-status message-channel message-data1 message-data2
          *midi-note-on* *midi-note-off* *midi-cc*
          init terminate count-devices open-input close poll read)
  (import (except (chezscheme) read))
  (include "portmidi-ffi.ss")

  (define *midi-note-on* #x90)
  (define *midi-note-off* #x80)
  (define *midi-channel-aftertouch* #xD0)
  (define *midi-poly-aftertouch* #xA0)
  (define *midi-program-change* #xC0)
  (define *midi-control-change* #xB0)
  (define *midi-cc* #xB0)
  (define *midi-pitch-bend* #xE0)

  (define *midi-sysex* #xF0)
  (define *midi-time-code* #xF1)
  (define *midi-song-position* #xF2)
  (define *midi-song-select* #xF3)
  (define *midi-tune* #xF6)
  (define *midi-sysex-end* #xF7)
  (define *midi-timiing-clock* #xF8)
  (define *midi-start* #xFA)
  (define *midi-continue* #xFB)
  (define *midi-stop* #xFC)
  (define *midi-active-sensing* #xFE)
  (define *midi-reset* #xFF)

  (define (message-status message)
    (bitwise-and message #xFF))

  (define (message-channel message)
    (bitwise-and message #x0F))

  (define (message-type message)
    (bitwise-and message #xF0))

  (define (message-data1 message)
    (bitwise-and (bitwise-arithmetic-shift-right message 8) #xFF))

  (define (message-data2 message)
    (bitwise-and (bitwise-arithmetic-shift-right message 16) #xFF))

  (define (note-on? message)
    (= (message-type message) *midi-note-on*))

  (define (note-off? message)
    (= (message-type message) *midi-note-off*))

  (define (note-cc? message)
    (= (message-type message) *midi-cc*))

  (define-record-type stream
    (fields pointer buffer))

  (define init Pm_Initialize)

  (define terminate Pm_Terminate)

  (define count-devices Pm_CountDevices)

  (define (open-input id)
    (let ([*stream (make-ftype-pointer
                    PortMidiStream
                    (foreign-alloc (ftype-sizeof PortMidiStream)))]
          [buffer (make-ftype-pointer
                   PmEventBuffer
                   (foreign-alloc (* PmEventBuffer-size (ftype-sizeof PmEvent))))])
      ;; TODO process errors
      (Pm_OpenInput *stream 0 0 PmEventBuffer-size 0 0)
      (make-stream
       (ftype-ref PortMidiStream () *stream)
       buffer)))

  (define (close stream)
    (Pm_Close (stream-pointer stream)))

  (define (poll stream)
    (Pm_Poll (stream-pointer stream)))

  (define (read stream callback)
    (let* ([buffer (stream-buffer stream)]
           [message-count (Pm_Read (stream-pointer stream)
                                   buffer
                                   PmEventBuffer-size)])
      (do ([i 0 (+ i 1)])
          ((= i message-count) 0)
        (let ([message (ftype-ref PmEventBuffer (i message) buffer)])
          (callback (message-type message)
                    (message-data1 message)
                    (message-data2 message)
                    (message-channel message))))))
  )
