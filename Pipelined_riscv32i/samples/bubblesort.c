void swap(char *xp, char *yp) {
    char temp = *xp;
    *xp = *yp;
    *yp = temp;
}

char arr[] = {10,20,3,4};
void bubbleSort(char arr[], int n);

void _start() {
	int len = 4;
	bubbleSort(arr, len);
	for (int i = 0; i<len; i++) {
		*(char*)i = arr[i];
	}
	asm("ebreak");
}

void bubbleSort(char arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(&arr[j], &arr[j + 1]);
            }
        }
    }
}

