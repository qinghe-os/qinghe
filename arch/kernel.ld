ENTRY(_start)
SECTIONS
{
	.text : ALIGN(4K) {
		stext = .;
		*(.text.boot)
		*(.text .text.*)
		. = ALIGN(4K);
		etext = .;
	}
}
