;;;; Little Man Computer
;;;; Progetto di Linguaggi di Programmazione
;;;; Anno accademico 2018-2019
;;;; Appello di Gennaio 2019

;;; Replace
;;; Sostituisce tutte le occorrenze di un valore in una lista
(defun repl (list n elem)
  (if (= n 0)
      (append (list elem) (cdr list))
      (append (list (car list)) (repl (cdr list) (- n 1) elem))))

;;; List Parse Integer
;;; Converte tutti gli elementi numerici della lista in interi
(defun list-parse-integer (l)
  (cond ((equal l NIL) 
          NIL)
        (T 
          (cons (parse-integer (car l)) (list-parse-integer (cdr l))))))

;;; List of Zero
;;; Crea una lista di n zeri
(defun list-of-zero (n)
  (cond ((= n 0) NIL)
        (T (cons "0" (list-of-zero (- n 1))))))

;;; Addizione
;;; Instruction: 1xx 
(defun addizione (Acc Pointer Mem)
  (cons (mod (+ Acc (nth Pointer Mem)) 1000)
        (if (< (+ Acc (nth Pointer Mem)) 1000)
            'NOFLAG
            'FLAG)))

;;; Sottrazione
;;; Instruction: 2xx 
(defun sottrazione (Acc Pointer Mem)
  (cons (mod (- Acc (nth Pointer Mem)) 1000)
        (if (>= (- Acc (nth Pointer Mem)) 0)
            'NOFLAG
            'FLAG)))

;;; Store
;;; Instruction: 3xx 
(defun store (Acc Pointer Mem)
  (repl Mem Pointer Acc))

;;; Load
;;; Instruction: 5xx 
(defun lload (Pointer Mem)
  (nth Pointer Mem))

;;; Branch
;;; Instruction: 6xx 
(defun branch (Pc) (+ Pc 0))

;;; Branch If Zero
;;; Instruction: 7xx 
(defun branch-if-zero (Pc Acc Pointer Flag)
  (if (and (= Acc 0) (equal Flag 'NOFLAG))
      Pointer
      (mod (+ Pc 1) 100)))

;;; Branch If Zero
;;; Instruction: 8xx 
(defun branch-if-positive (Pc Pointer Flag)
  (if (equal Flag 'NOFLAG)
      Pointer
      (mod (+ Pc 1) 100)))

;;; Input
;;; Instruction: 901
(defun input (In)
  (cons (first In) (rest In)))

;;; Output
;;; Instruction: 902
(defun output (Acc Out)
  (append Out (list Acc)))

;;; One Instruction
;;; Passaggio da uno stato iniziale ad uno stato finale
;;; a seconda del valore dell'opcode (Istr)
(defun one-instruction (state)
  (let ((ACC (nth 2 state))
        (PC (nth 4 state))
        (MEM (nth 6 state))
        (IN (nth 8 state))
        (OUT (nth 10 state))
        (FLAG (nth 12 state)))
    (let ((ISTR (nth PC MEM)))
      (let ((POINTER (mod ISTR 100)))
        (cond ((and (>= ISTR 0) (< ISTR 100))
               (list 'halted-state ':acc ACC ':pc PC ':mem MEM
                     ':in IN ':out OUT ':flag FLAG))
              ((and (> ISTR 99) (< ISTR 200))
               (list 'state ':acc (car (addizione ACC POINTER MEM)) ':pc (mod (+ PC 1) 100)
                     ':mem MEM ':in IN ':out OUT ':flag (cdr (addizione ACC POINTER MEM))))
              ((and (> ISTR 199) (< ISTR 300))
               (list 'state ':acc (car (sottrazione ACC POINTER MEM)) ':pc (mod (+ PC 1) 100)
                     ':mem MEM ':in IN ':out OUT ':flag (cdr (sottrazione ACC POINTER MEM))))
              ((and (> ISTR 299) (< ISTR 400))
               (list 'state ':acc ACC ':pc (mod (+ PC 1) 100) ':mem (store ACC POINTER MEM)
                     ':in IN ':out OUT ':flag FLAG))
              ((and (> ISTR 499) (< ISTR 600))
               (list 'state ':acc (lload POINTER MEM) ':pc (mod (+ PC 1) 100) ':mem MEM
                     ':in IN ':out OUT ':flag FLAG))
              ((and (> ISTR 599) (< ISTR 700))
               (list 'state ':acc ACC ':pc (branch POINTER) ':mem MEM
                     ':in IN ':out OUT ':flag FLAG))
              ((and (> ISTR 699) (< ISTR 800))
               (list 'state ':acc ACC ':pc (branch-if-zero PC ACC POINTER FLAG) ':mem MEM
                     ':in IN ':out OUT ':flag FLAG))
              ((and (> ISTR 799) (< ISTR 900))
               (list 'state ':acc ACC ':pc (branch-if-positive PC POINTER FLAG) ':mem MEM
                     ':in IN ':out OUT ':flag FLAG))
              ((and (= ISTR 901) (not (= (list-length IN) 0)))
               (list 'state ':acc (car (input IN)) ':pc (mod (+ PC 1) 100) ':mem MEM
                     ':in (cdr (input IN)) ':out OUT ':flag FLAG))
              ((= ISTR 902)
               (list 'state ':acc ACC ':pc (mod (+ PC 1) 100) ':mem MEM
                     ':in IN ':out (output ACC OUT) ':flag FLAG)))))))

;;; Execution Loop
;;; Cicla dallo stato iniziale allo stato finale
;;; Restituisce la coda di output quando viene raggiunto uno stato di halt
(defun execution-loop (state)
  (cond ((> (list-length (nth 6 state)) 100) NIL) ; mem troppo grande (> 100)
        ((equal state NIL) NIL) ; istruzione errata
        ((and (< (nth 4 state) 100) (equal (nth 0 state) 'state))
         (execution-loop (one-instruction state)))
        ((equal (nth 0 state) 'halted-state) 
          (nth 10 state))))


;;; Definizione parametri top-level
;;; Si definisce una lista per i tags 
(defparameter tags (list))


;;; Remove Comment
;;; Rimuove i commenti da una stringa 
(defun remove-comment (row)
  (string-trim " " (subseq row 0 (search "//" row))))

;;; Split
;;; Splitta una stringa
;;; Restituisce una lista 
(defun split-core (str index)
  (cond ((= (length str) 0) (list str))
        ((>= index (length str)) (list str))
        ((equal (char str index) #\ )
         (append (list (subseq str 0 index)) (split-core (subseq str (+ index 1)) 0)))
        (T (split-core str (+ index 1)))))

(defun split (str)
  (split-core str 0))

;;; Remove Blank
;;; Elimina tutti gli elementi uguali alla stringa vuota da una lista
(defun remove-blank (lista)
  (cond ( (= (list-length lista) 0) NIL)
        ((equal (remove-comment (car lista)) "") (remove-blank (cdr lista)))
        (T  (cons (car lista) (remove-blank (cdr lista))))))

;;; Normalize
;;; Restituisce qualunque numero in 2 cifre
;;; aggiungendo uno 0 prima nel caso sia un numero compreso tra 0 e 10
(defun normalize (num)
  (cond ((= (length num ) 1) (concatenate 'string "0" num))
        (T num)))

;;; Get Value
;;; Restituisce il valore associato ad una etichetta
;;; o il valore stesso
(defun get-value-core (tag tags)
  (cond ( (equal tags NIL) NIL)
        ( (equal (string-upcase tag)
                 (string-upcase (first (first tags)))) (cdr (first tags)))
        ( T (get-value-core tag (cdr tags)))))

(defun get-value-of (tag)
  (get-value-core tag tags))

(defun value-of (word)
  (cond ((equal (get-value-of word) NIL) word)
        (T (get-value-of word))))

;;; Command to Istr
;;; Restituisce l'istruzione numerica associata al comando assembly
(defun command-to-instr (command pointer)
  (cond ((and (equal (string-upcase (car command)) "ADD") (not (equal (cdr command) NIL)))
         (concatenate 'string "1" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "SUB") (not (equal (cdr command) NIL)))
         (concatenate 'string "2" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "STA") (not (equal (cdr command) NIL)))
         (concatenate 'string "3" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "LDA") (not (equal (cdr command) NIL)))
         (concatenate 'string "5" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "BRA") (not (equal (cdr command) NIL)))
         (concatenate 'string "6" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "BRZ") (not (equal (cdr command) NIL)))
         (concatenate 'string "7" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "BRP") (not (equal (cdr command) NIL)))
         (concatenate 'string "8" (normalize (value-of (second command)))))
        ((and (equal (string-upcase (car command)) "INP") (equal (cdr command) NIL))
         "901")
        ((and (equal (string-upcase (car command)) "OUT") (equal (cdr command) NIL))
         "902")
        ((and (equal (string-upcase (car command)) "HLT") (equal (cdr command) NIL))
         "000")
        ((equal (string-upcase (car command)) "DAT")
         (cond ( (equal (cdr command) NIL) "000")
               (T (value-of (second command)))))
        ((not (equal (car command) ""))
         (car (cons (command-to-instr (cdr command) pointer)
                    (push (cons (string-upcase (car command)) (write-to-string pointer)) tags))))
        (T
          (command-to-instr (cdr command) pointer))))

;;; Read Lines
;;; Legge il file
;;; Restituisce una lista contenente le righe del file di testo letto
(defun read-all-lines-helper (stream)
  (let ((line (read-line stream NIL NIL))) ;; leggi la linea ritornando nil in caso di fine file
    (when line (cons line (read-all-lines-helper stream)))))

(defun read-all-lines (filename)
  (with-open-file (f filename :direction :input)
                  (read-all-lines-helper f)))

;;; Is In List
(defun is-in-list (elem list)
  (cond ((equal elem (car list)) T)
        ((equal list NIL) NIL)
        (T (is-in-list elem (cdr list)))))

;;; Is Istr
(defun is-istr (command)
  (is-in-list (string-upcase (car command)) 
              (list "ADD" "SUB" "STA" "LDA" "BRA" "BRZ" "BRP" "INP" "OUT" "HLT" "DAT")))

;;; Get Tags
;;; Restituisce la lista di etichette del file
(defun get-tags (commands pc)
  (cond ( (equal commands NIL) NIL )
        (T (cond ( (not (is-istr (remove-blank (split (remove-comment (car commands)))))) 
                    (append (list (cons (string-upcase (car (remove-blank (split (remove-comment (car commands)))))) pc)) (get-tags (cdr commands) (+ pc 1))) )
                 (T (get-tags (cdr commands) (+ pc 1)))))))

;;; Get Mem
;;; Riempie il fondo della Mem con gli 0 
(defun get-mem (mem)
  (nconc mem (list-of-zero (- 100 (list-length mem)))))

;;; Commands to Mem
;;; Aggiunge i vari comandi assembly alla memoria
(defun commands-to-mem (commands pointer)
  (cond ( (equal commands NIL) NIL)
        ( T (cons (command-to-instr (remove-blank (split (remove-comment (car commands)))) pointer)
                  (commands-to-mem (cdr commands) (+ pointer 1))))))

;;; LMC Load
;;; Legge il file .lmc e genera la memoria convertendola in interi
;;; dopo gli opportuni controlli 
(defun lmc-load (filename)
  (cdr (cons (get-mem (commands-to-mem (remove-blank (read-all-lines filename)) 0))
             (list-parse-integer (get-mem (commands-to-mem (remove-blank (read-all-lines filename)) 0))))))

;;; LMC Run
;;; Esegue il lmc_load del file .lmc,
;;; e passa la memoria ottenuta allo stato iniziale dell'execution-loop.
(defun lmc-run (filename input)
  (execution-loop (list 'state ':acc 0 ':pc 0 ':mem (lmc-load filename) ':in input ':out '() ':flag 'NOFLAG)))
