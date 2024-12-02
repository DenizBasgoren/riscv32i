
void _start(void) {
	int a = 10;
	int b = 15;
	if (a+b>20) {
		*(int*)1 = 1;
	}
	else {
		*(int*)1 = 2;
	}
	asm("ebreak");
}