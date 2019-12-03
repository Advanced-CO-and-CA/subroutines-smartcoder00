/*************************************************************************************************
* file: subroutine.s (Lab Assingment-6)                                                          *
* Author: Jethin Sekhar R (CS18M523)                                                             *
* Assembly code for Character-Coded Data                                                         *
*    Part 1: Write an assembly program for searching a given integer number in an array of       *
*            integer numbers. Assume that the numbers in the array are not in sorted order.      *
*            The program must ask the user to enter the number of elements of the array and      *
*            accept each element of the array through keyboard (for this, you need to use        *
*            software interrupts). Also, the user must enter the element to be searched through  *
*            keyboard. You must pass the array and the searching element as parameters to a      *
*            subroutine, SEARCH. The program outputs the position of the given element,          *
*            if it is present in the array, otherwise, it outputs -1.                            *
*    Part 2: In the above problem, as the elements of the array are not in sorted order, we have *
*            to search all the elements to find whether a given element is present or not. Now,  *
*            assume that the elements of the array are in sorted order. Write an assembly        *
*            language program that can efficiently search a given element in the sorted array of *
*            elements. (Note that here we define the efficiency in terms of the number           *
*            of searches. )                                                                      *
*    Part 3: Fibonacci number sequence is defined as 1, 1, 2, 3, 5, 8, 13, 21, ... A number in   *
*            the Fibonacci sequence is the sum of the immediate two previous numbers,            *
*            i.e., Fn = F{n-1}+F{n-2}, n>2. Note that F1 = F2 = 1.                               *
*            Write an assembly language program that accepts an integer number, N,               *
*            through keyboard and computes the Nth Fibonacci number in recursive way.            *
*************************************************************************************************/

/*** Constant Defines ***************************************************************************/
    .equ SWI_PrStr,       0x69                      @ Write a null-ending string
    .equ SWI_PrInt,       0x6b                      @ Write an Integer
    .equ SWI_RdInt,       0x6c                      @ Read an Integer
    .equ StdOut,          1                         @ Set output mode to be Stdout View
    .equ StdIn,           0                         @ Set Input mode to be Stdin View
    .equ Max_Num_Elems,   16                        @ Max Elements in Array
    .equ EOL,             0x00                      @ EOL

@ bss section
    .bss

@ data section
    .data
    res_str_eof:          .asciz    ""
    res_str_space:        .asciz    " "
    res_str_comma:        .asciz    ","
    res_str_new_line:     .asciz    "\n"
    res_str_num_elem1:    .asciz    "Enter Number of Elements   : "
    res_str_num_elem2:    .asciz    "Array Elements are         : "
    res_str_num_elem3:    .asciz    "Enter Array Elements- size : "
    res_str_idx_name:     .asciz    " Index :"
    res_str_val_name:     .asciz    " Value :"
    res_str_search:       .asciz    "Enter Value to Search      : "
    res_str_found:        .asciz    "Value Found at Index       : "
    res_str_not_found:    .asciz    "Value Not Found"
    res_str_fibo_input:   .asciz    "Enter Fibonacci input n    : "
    res_str_fibo_val:     .asciz    "Fibonacci Number           : "
    res_str_menu_line1:   .asciz    "Assingment-6 Menu          : "
    res_str_menu_line2:   .asciz    "  1. Enter the Array"
    res_str_menu_line3:   .asciz    "  2. Linear Search (Part1)"
    res_str_menu_line4:   .asciz    "  3. Binary Search (Part2)"
    res_str_menu_line5:   .asciz    "  4. Fibonacci Series (Part3)"
    res_str_menu_line6:   .asciz    "  5. Quit"
    .ALIGN 4
    res_val_num_elem:     .word     Max_Num_Elems
    res_val_to_search:    .word     0x00
    res_val_idx_found:    .word     0x00
    res_val_fibo_input:   .word     0x00
    data_array:           .skip     Max_Num_Elems * 0x04

@ text section
      .text

@ Globals Defines for Functions
retVal               .req r0                        @ Return Value
param0               .req r0                        @ Function Param0
param1               .req r1                        @ Function Param1
param2               .req r2                        @ Function Param2
param3               .req r3                        @ Function Param3
param4               .req r4                        @ Function Param4
temp                 .req r8                        @ Temporary Variable
temp1                .req r8                        @ Temporary Variable
temp2                .req r9                        @ Temporary Variable

.global _main
    bl _main
  _end_of_main:
    bl   _end_of_program                            @ End of the program is here

/*** main Function ******************************************************************************/
result_store_idx     .req r10                       @ Index for result Store
value_idx            .req r11                       @ Index for Values

_main:                                              @
  menu_loop:                                        @
    bl    _fnStartMenu                              @ Initiate Menu
    movs  temp, retVal                              @
    cmp   temp, #1                                  @
    bleq  _fnReadAllValues                          @ Read the Array Values
    cmp   temp, #2                                  @
    bleq  _fnDoLinearSearch                         @ Part 1: Do Linear Search
    cmp   temp, #3                                  @
    bleq  _fnDoBinarySearch                         @ Part 2: Do Binary Search(Recursive)
    cmp   temp, #4                                  @
    bleq  _fnDoFibonacci                            @ Part 3: Do Fibonacci(Recursive)
    cmp   temp, #5                                  @
    bleq  _end_of_main                              @ End of the main is here
    bl    menu_loop

/*** Function: DoLinearSearch *******************************************************************
* Do Linear Search                                                                              *
************************************************************************************************/
_fnDoLinearSearch:
    push  {param1, param2, param3, temp, lr}        @
    bl    _fnReadSearchValue                        @ Read Search Value
    ldr   param1, =data_array                       @ Read Array Pointer
    ldr   param2, =res_val_num_elem                 @ Read Array Size
    ldr   param2, [param2]                          @
    ldr   param3, =res_val_to_search                @ Read Value to Search
    ldr   param3, [param3]                          @
    bl    _fnLinearSearchforInt                     @ Do Linear Search
    movs  temp, retVal                              @
    ldr   param1, =res_val_idx_found                @ Set Display String
    str   temp, [param1]                            @
    mov   param1, temp                              @
    bl    _fnDisplaySearchResult                    @ Print Result
    pop   {param1, param2, param3, temp, pc}        @

/*** Function: DoBinarySearch *******************************************************************
* Do Binary Search                                                                              *
************************************************************************************************/
_fnDoBinarySearch:
    push  {param1, param2, param3, param4, temp, lr}@
    bl    _fnReadSearchValue                        @ Read Search Value
    ldr   param1, =data_array                       @ Read Array Pointer
    mov   param2, #0                                @ Set Left Value as Zero
    ldr   param3, =res_val_num_elem                 @ Set Right Value as Array Size
    ldr   param3, [param3]                          @
    sub   param3, #1                                @
    ldr   param4, =res_val_to_search                @ Set the Search Value
    ldr   param4, [param4]                          @
    bl    _fnBinarySearch                           @ Do Binary Search
    movs  temp, retVal                              @
    ldr   param1, =res_val_idx_found                @ Set the Display String
    str   temp, [param1]                            @
    mov   param1, temp                              @
    bl    _fnDisplaySearchResult                    @ Print Result
    pop   {param1, param2, param3, param4, temp, pc}@

/*** Function: DoFibonacci **********************************************************************
* Do Fibonacci Series                                                                           *
************************************************************************************************/
_fnDoFibonacci:
    push  {param1, temp, lr}                        @
    bl    _fnReadFiboInput                          @ Read n
    mov   param1, retVal                            @
    bl    _fnFiboNumber                             @ Calulate nth fibonacci value
    movs  temp, retVal                              @
    ldr   param1, =res_str_fibo_val                 @ Set the Display String
    bl    _fnPrintToStdOut                          @
    mov   param1, temp                              @
    bl    _fnPrintIntegerNL                         @ Print Result
    pop   {param1, temp, pc}                        @

/*** Function: StartMenu ************************************************************************
* Start the Menu and Get the Option                                                             *
************************************************************************************************/
_fnStartMenu:
    push  {param1, lr}                              @ Store local variables & return address to stack
    ldr   param1, =res_str_menu_line1               @ Set all display lines and printing
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =res_str_menu_line2               @
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =res_str_menu_line3               @
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =res_str_menu_line4               @
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =res_str_menu_line5               @
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =res_str_menu_line6               @
    bl    _fnPrintToStdOutNL                        @
  _fnStartMenu_repeat:                              @
    bl    _fnReadInteger                            @ Read the Choice
    cmp   retVal, #6                                @ Limit the choice from 1 to 6
    bgt   _fnStartMenu_repeat                       @
    cmp   retVal, #1                                @
    blt   _fnStartMenu_repeat                       @
    pop   {param1, pc}                              @ Restore and Return

/*** Function: FiboNumber ***********************************************************************
* Find nth Fibonacci Series                                                                     *
************************************************************************************************/
_fnFiboNumber:
    push  {param1, temp1, temp2, lr}                @ Store local variables & return address to stack
    cmp   param1 , #1                               @ Check n = 1 and stop recursion
    ble   _fnBinarySearch_stoprecursion             @
    sub   param1, #1                                @
    bl    _fnFiboNumber                             @ Calculuate F(n-1)
    mov   temp1, retVal                             @
    sub   param1, #1                                @
    bl    _fnFiboNumber                             @ Calculate F(n-2)
    mov   temp2, retVal                             @
    add   param1, temp1, temp2                      @ F(n-1) + F(n-2)
  _fnBinarySearch_stoprecursion:                    @
    mov   retVal, param1                            @ Store Result
  _fnFiboNumber_end:                                @
    pop   {param1, temp1, temp2, pc}                @ Restore and Return

/*** Function: BinarySearch *********************************************************************
* Do Binary Search in Sorted Array                                                              *
************************************************************************************************/
input_arr            .req param1                    @ Function Param1
left                 .req param2                    @ Function Param2
right                .req param3                    @ Function Param3
search_val           .req param4                    @ Function Param4
mid                  .req temp1                     @ Local Variable
_fnBinarySearch:
    push  {input_arr, left, right, search_val, lr}  @ Store local variables & return address to stack
    push  {mid, temp2}                              @
    mov   retVal , #-1                              @ Set Invalid Search as -1
    cmp   right, left                               @ check right < left, then stop,
    blt   _fnBinarySearch_end                       @    no value found
    sub   mid, right, left                          @ Calculate mid = left + (right - left)/2
    asr   mid, #1                                   @
    add   mid, left                                 @
    ldr   temp2, [input_arr, mid, LSL #2]           @ Load input_arr[mid]
    cmp   temp2, search_val                         @ Compare input_arr[mid] with search_val
    beq   _fnBinarySearch_found                     @    if equal found the index as mid
    subgt mid, #1                                   @    else if greater
    movgt right, mid                                @       then right = mid -1
    addlt mid, #1                                   @    else if lesser
    movlt left, mid                                 @       then left = mid + 1
    bl    _fnBinarySearch                           @ Do recursive Search with new left/right
    b     _fnBinarySearch_end                       @
  _fnBinarySearch_found:                            @
    mov   retVal, mid                               @ Store the result
  _fnBinarySearch_end:                              @
    pop   {mid, temp2}                              @
    pop   {input_arr, left, right, search_val, pc}  @ Restore and Return

/*** Function: Display Search Result ************************************************************
* Display Search Result                                                                         *
************************************************************************************************/
_fnDisplaySearchResult:                             @
    push  {param1, temp, lr}                        @ Store local variables & return address to stack
    movs  temp, param1                              @ Check of -1
    bmi   _fnDisplaySearchResult_NotFound           @   if true, Set Not found string
    ldr   param1, =res_str_found                    @   else, Set Found String and
    bl    _fnPrintToStdOut                          @       Print Index
    mov   param1, temp                              @
    bl    _fnPrintIntegerNL                         @
    b     _fnDisplaySearchResult_end                @
  _fnDisplaySearchResult_NotFound:                  @
    ldr   param1, =res_str_not_found                @   Print Not found
    bl    _fnPrintToStdOutNL                        @
  _fnDisplaySearchResult_end:                       @
    pop   {param1, temp, pc}                        @ Restore and Return

/*** Function: Read All Elements ***************************************************************
* Read All Values                                                                              *
************************************************************************************************/
_fnReadAllValues:                                   @
    push  {param1, param2, temp, lr}                @ Store local variables & return address to stack
    ldr   param1, =res_str_num_elem1                @
    bl    _fnPrintToStdOutNL                        @ Set Display String
    bl    _fnReadInteger                            @
    ldr   temp, =res_val_num_elem                   @ Read Array Size
    cmp   retVal, #Max_Num_Elems                    @ Limit to Max_Num_Elems
    movgt retVal, #Max_Num_Elems                    @
    str   retVal, [temp]                            @ Store the Array Size
    ldr   param1, =res_str_num_elem3                @
    bl    _fnPrintToStdOut                          @
    ldr   param1, [temp]                            @
    bl    _fnPrintIntegerNL                         @
    ldr   param1, =data_array                       @
    ldr   param2, =res_val_num_elem                 @
    ldr   param2, [param2]                          @
    bl    _fnReadIntegerArray                       @ Read Array
    ldr   param1, =res_str_num_elem2                @
    bl    _fnPrintToStdOutNL                        @
    ldr   param1, =data_array                       @
    bl    _fnPrintIntegerArray                      @ Print the Array
    pop   {param1, param2, temp, pc}                @ Restore and Return

/*** Function: Read Value to Search *************************************************************
* Read Search Value                                                                             *
************************************************************************************************/
_fnReadSearchValue:                                 @
    push  {param1, lr}                              @ Store local variables & return address to stack
    ldr   param1, =res_str_search                   @
    bl    _fnPrintToStdOut                          @ Set Display String
    bl    _fnReadInteger                            @ Read the Value from StdIn
    ldr   param1, =res_val_to_search                @ Store the value
    str   retVal, [param1]                          @
    pop   {param1, pc}                              @ Restore and Return

/*** Function: Read Value to Fibo ***************************************************************
* Read Value for Fibo                                                                           *
************************************************************************************************/
_fnReadFiboInput:                                   @
    push  {param1, lr}                              @ Store local variables & return address to stack
    ldr   param1, =res_str_fibo_input               @
    bl    _fnPrintToStdOut                          @ Set Display String
    bl    _fnReadInteger                            @ Read Value from StdIn
    ldr   param1, =res_val_fibo_input               @ Store the value
    str   retVal, [param1]                          @
    pop   {param1, pc}                              @ Restore and Return

/*** Function: LinearSearchforInt ***************************************************************
* Print Array of Integers                                                                       *
************************************************************************************************/
_fnLinearSearchforInt:                              @ Read Integer
    push  {param1, param2, param3, lr}              @ Store local variables & return address to stack
    push  {temp1, temp2}                            @ param1 - array pointer and param2 - array size
    mov   retVal, #-1                               @ Set the Invalid Result
    mov   temp1, #0                                 @ Intialize loop variable
  _fnLinearSearchforIntLoop:                        @
    cmp   temp1, param2                             @ Check of end of the loop with array size
    beq   _fnLinearSearchforInt_end                 @
    ldr   temp2, [param1, temp1 , LSL #2]           @ Load the array[temp1]
    cmp   temp2, param3                             @ compare with search value(param3)
    moveq retVal, temp1                             @ Store Index as result and break
    beq   _fnLinearSearchforInt_end                 @
    add   temp, #1                                  @ Increment the loop and continue search
    b     _fnLinearSearchforIntLoop                 @
  _fnLinearSearchforInt_end:                        @
    pop   {temp1, temp2}                            @
    pop   {param1, param2, param3, pc}              @ Restore all values and return

/*** Function: PrintIntegerArray ****************************************************************
* Print Array of Integers                                                                       *
************************************************************************************************/
_fnPrintIntegerArray:                               @ Read Integer
    push  {param1, param2, param4, temp1, temp2, lr}@ Store local variables & return address to stack
    mov   param4, param1                            @ Store Array Pointer(param1) locally
    mov   temp1, #0                                 @ Initialize loop variable
    mov   temp2, param2                             @ Store array_size(param2) locally(temp2)
  _fnPrintIntegerArrayLoop:                         @
    cmp   temp1, temp2                              @ Check of loop ending condition
    beq   _fnPrintIntegerArray_end                  @
    ldr   param2, =res_str_comma                    @
    ldr   param1, [param4, temp1, LSL #2]           @
    bl    _fnPrintIntegerSP                         @ Print Array Elements
    add   temp, #1                                  @
    b     _fnPrintIntegerArrayLoop                  @
  _fnPrintIntegerArray_end:                         @
    ldr   param1, =res_str_new_line                 @ Print a new line
    bl    _fnPrintSpecialCharater                   @
    pop   {param1, param2, param4, temp1, temp2, pc}@ Restore all values and return

/*** Function: ReadIntegerArray *****************************************************************
* Read Array of Integers                                                                        *
************************************************************************************************/
_fnReadIntegerArray:                                @ Read Integer
    push  {param1, param2, temp1, lr}               @ Store local variables & return address to stack
    mov   temp, #0                                  @ Initialize loop variable
  _fnReadIntegerArrayLoop:                          @
    cmp   temp, param2                              @ check for loop ending condition
    beq   _fnReadIntegerArray_end                   @
    bl    _fnReadInteger                            @ Read and integer
    str   retVal, [param1, temp, LSL #2]            @ Store Value to Array
    add   temp, #1                                  @ increment loop variable
    b     _fnReadIntegerArrayLoop                   @
  _fnReadIntegerArray_end:                          @
    pop   {param1, param2, temp1, pc}               @ Restore all values and return

/*** Function: ReadInteger **********************************************************************
* Read an Integer                                                                               *
************************************************************************************************/
_fnReadInteger:                                     @ Read Integer
    push  {lr}                                      @ Store local variables & return address to stack
    mov   retVal, #StdIn                            @ mode is StdIn
    swi   SWI_RdInt                                 @ Read from StdIn an Integer
  _fnReadInteger_end:                               @
    pop   {pc}                                      @ Restore all values and return

/*** Function: PrintInteger *********************************************************************
* Print an Integer                                                                              *
************************************************************************************************/
_fnPrintInteger:                                    @ Print Integer
    push  {param1, lr}                              @ Store local variables & return address to stack
    mov   retVal, #StdOut                           @ mode is StdOut
    swi   SWI_PrInt                                 @ StdOut an Integer
  _fnPrintInteger_end:                              @
    pop   {param1, pc}                              @ Restore all values and return

/*** Function: PrintSpecialCharater *************************************************************
* Print special character at end                                                                *
************************************************************************************************/
_fnPrintSpecialCharater:                            @ Print Integer
    push  {param1, lr}                              @ Store local variables & return address to stack
    mov   param0, #StdOut                           @ mode is Stdout
    swi   SWI_PrStr                                 @ display message to Stdout
  _fnPrintSpecialCharater_end:                      @
    pop   {param1, pc}                              @ Restore all values and return

/*** Function: PrintIntegerSP *******************************************************************
* Print an Integer with special character at end                                                *
************************************************************************************************/
_fnPrintIntegerSP:                                  @ Print Integer
    push  {param1, param2, lr}                      @ Store local variables & return address to stack
    bl    _fnPrintInteger                           @
    mov   param1, param2                            @ Load special line pointer
    bl    _fnPrintSpecialCharater
  _fnPrintIntegerSP_end:                            @
    pop   {param1, param2, pc}                      @ Restore all values and return

/*** Function: PrintIntegerNL *******************************************************************
* Print an Integer with newline                                                                 *
************************************************************************************************/
_fnPrintIntegerNL:                                  @ Print Integer
    push  {param1, lr}                              @ Store local variables & return address to stack
    bl    _fnPrintInteger                           @
    ldr   param1, =res_str_new_line                 @ Load new line pointer
    bl    _fnPrintSpecialCharater
  _fnPrintIntegerNL_end:                            @
    pop   {param1, pc}                              @ Restore all values and return

/*** Function: PrintToStdOut ********************************************************************
* Print the Value to String to StdOut                                                           *
************************************************************************************************/
_fnPrintToStdOut:                                   @ Print String
    push  {param0, param1, lr}                      @ Store local variables & return address to stack
    mov   param0, #StdOut                           @ mode is Stdout
    swi   SWI_PrStr                                 @ display message to Stdout
  _fnPrintToStdOut_end:                             @
    pop   {param0, param1, pc}                      @ Restore all values and return

/*** Function: PrintToStdOutNL ******************************************************************
* Print the Value to String to StdOut with new line                                             *
************************************************************************************************/
_fnPrintToStdOutNL:                                 @ Print String with new line
    push  {param0, param1, lr}                      @ Store local variables & return address to stack
    bl    _fnPrintToStdOut                          @
    ldr   param1, =res_str_new_line                 @ Load new line pointer
    bl    _fnPrintSpecialCharater                   @
  _fnPrintToStdOutNL_end:                           @
    pop   {param0, param1, pc}                      @ Restore all values and return

/*** End ****************************************************************************************/
_end_of_program:
    .end