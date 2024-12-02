
int arr[] = {20,40,10,23,53,11,43,23,28,53,27,43,12,43,32,29,20};

void _start(void) {
	
    int maxIndex = 0;
	

    // Iterate through the array to find the index of the max element
    for (int i = 1; i < 17; ++i) {
        if (arr[i] > arr[maxIndex]) {
            maxIndex = i;
        }
    }

	*(char*)1 = maxIndex;
	*(char*)2 = arr[maxIndex];

	asm("ebreak");
	
}