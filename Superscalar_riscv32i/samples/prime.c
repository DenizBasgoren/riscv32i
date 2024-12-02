
int nthPrime(int n);
int mul(int a, int b);
int modulo(int dividend, int divisor);
int isPrime(int n);

void _start(void) {
	*(int*)1 = nthPrime(6);

	asm("ebreak");
}

// Function to perform multiplication without using the multiplication operator
int mul(int a, int b) {
    int result = 0;
    
    for (int i = 0; i < b; ++i) {
        result += a;
    }

    return result;
}

// Function to perform modulus without using the modulus operator
int modulo(int dividend, int divisor) {
    while (dividend >= divisor) {
        dividend -= divisor;
    }
    return dividend;
}

// Function to check if a number is prime
int isPrime(int n) {
    if (n < 2) {
        return 0; // Not prime
    }

    int i = 2;
    while (mul(i, i) <= n) {
        if (modulo(n, i) == 0) {
            return 0; // Not prime
        }
        i++;
    }

    return 1; // Prime
}

// Function to find the nth prime number
int nthPrime(int n) {
    int count = 0;
    int number = 1;
    
    while (count < n) {
        ++number;
        if (isPrime(number)) {
            ++count;
        }
    }
    
    return number;
}
