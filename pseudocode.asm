; Define data structures (assuming simple book record)
book_record struct
    title db 50 ; 50 byte character array for title
    author db 50 ; 50 byte character array for author
    count dw 0 ; 2-byte word to store number of copies
end struct

.data
books_data db 10 * book_record ; Allocate memory for 10 book records

; Function to get user input for a string (limited to 50 characters)
get_string proc
    ; Use registers for temporary storage
    mov     ecx, 50 ; String length limit
    mov     edx, offset buffer ; Pointer to store input
loop_get:
    mov     eax, 0 ; Prepare for system call (read)
    mov     ebx, 1 ; Standard input (stdin)
    mov     ecx, edx ; Pointer to buffer
    mov     edx, 1 ; Read 1 byte at a time
    int     80h ; Make system call
    cmp     al, 10 ; Check for newline character
    je      done_get
    mov     byte ptr [edx], al ; Store character in buffer
    inc     edx ; Move pointer to next byte
    loop    loop_get
done_get:
    mov     byte ptr [edx], 0 ; Add null terminator to string
    ret
get_string endp

; Function to add a new book
add_book proc
    mov     esi, offset books_data ; Point to book data array
    ; Find an empty slot (check count of each record)
loop_find:
    cmp     word ptr [esi + 2], 0 ; Check count
    jne     book_found ; Skip if not empty
    add     esi, 10 ; Move to next book record
    cmp     esi, offset books_data + 100 ; Check for array end
    jl      loop_find ; Loop if not at the end
    mov     eax, -1 ; Indicate no empty slot found
    jmp     exit_add_book
book_found:
    ; Get book title
    mov     eax, 4 ; System call for writing (write message)
    mov     ebx, 1 ; Standard output (stdout)
    mov     ecx, offset message_title ; Point to title prompt message
    mov     edx, strlen message_title ; Message length
    int     80h ; Print message
    call    get_string ; Get user input for title
    mov     edi, esi ; Point to current book record (title)
    mov     ecx, 50 ; Copy user input (limited to 50 bytes)
    rep     movsb ; Repeated move string bytes
    ; Get book author (similar to title)
    mov     eax, 4 ; System call for writing
    mov     ebx, 1 ; Standard output (stdout)
    mov     ecx, offset message_author ; Point to author prompt message
    mov     edx, strlen message_author ; Message length
    int     80h ; Print message
    call    get_string ; Get user input for author
    mov     edi, esi + 50 ; Point to current book record (author)
    mov     ecx, 50 ; Copy user input (limited to 50 bytes)
    rep     movsb
    ; Set book copy count to 1
    mov     word ptr [esi + 2], 1
exit_add_book:
    ret
add_book endp

.data
message_title db "Enter book title: $" ; Prompt message for title
message_author db "Enter book author: $" ; Prompt message for author
buffer db 51 ; Character buffer for user input (including newline)

; Main program to start adding books
mov     eax, main
call    eax

main proc
    ; Call add_book function repeatedly until user exits
loop_add:
    call    add_book
    cmp     eax, -1 ; Check for no empty slot
    je      exit_program
    mov     eax, 4 ; System call for writing
    mov     ebx, 1 ; Standard output (stdout)
    mov     ecx, offset message_add_more ; Point to prompt message
    mov     edx, strlen message_add_more ; Message length
    int     80h ; Print message
    mov     eax, 1 ; System call for reading (read character
