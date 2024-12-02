ENTRY(_start)

SECTIONS {
  . = 0x0;           /* Set the starting address to 0x0 */
  .text : {
    *(.text)         /* .text section */
  }

  . = ALIGN(4);       /* Align to 4 bytes */

  .data : {
    *(.data)         /* .data section */
  }

  . = ALIGN(4);

  .rodata : {
    *(.rodata)       /* .rodata section */
  }

  . = ALIGN(4);

  .bss : {
    *(.bss)          /* .bss section */
  }
}