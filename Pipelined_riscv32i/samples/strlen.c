

char* hw = "Hello world!";

void _start(void) {

	int len = 0;
	
    // Calculate length of hw
    while (hw[len] != '\0') {
        len++;
    }

	*(int*)1 = len;
	asm("ebreak");

}