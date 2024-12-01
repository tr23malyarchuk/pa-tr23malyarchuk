#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <math.h>
#include <time.h>

#define PORT 8081
#define BUFFER_SIZE 1024

double calculate_arctangent(double x, int n) {
    double sum_n = 0;
    for (int i = 0; i < n; ++i) {
        double term = (pow(-1, i) * pow(x, 2 * i + 1)) / (2 * i + 1);
        sum_n += term;
    }
    return sum_n;
}

void sort_array(double *array, int size) {
    for (int i = 0; i < size - 1; ++i) {
        for (int j = i + 1; j < size; ++j) {
            if (array[i] > array[j]) {
                double temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
        }
    }
}

void send_response(int client_socket, const char *status, const char *content_type, const char *body) {
    char response[BUFFER_SIZE];
    sprintf(response, "%s\r\nContent-Type: %s\r\nContent-Length: %ld\r\n\r\n%s",
            status, content_type, strlen(body), body);
    write(client_socket, response, strlen(response));
}

// Define TEST_MODE to exclude the main function when testing
#ifndef TEST_MODE
int main() {
    int server_socket, client_socket;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_addr_len = sizeof(client_addr);

    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        close(server_socket);
        exit(EXIT_FAILURE);
    }

    listen(server_socket, 5);
    printf("Server listening on port %d\n", PORT);

    while (1) {
        client_socket = accept(server_socket, (struct sockaddr *)&client_addr, &client_addr_len);
        if (client_socket < 0) {
            perror("Accept failed");
            continue;
        }

        char buffer[BUFFER_SIZE] = {0};
        read(client_socket, buffer, sizeof(buffer) - 1);
        printf("Received request:\n%s\n", buffer);

        if (strncmp(buffer, "GET /arctangent?", 16) == 0) {
            char *x_str = strstr(buffer, "x=") + 2;
            char *n_str = strstr(buffer, "n=") + 2;

            double x = atof(x_str);
            int n = atoi(n_str);

            clock_t start = clock();
            double result = calculate_arctangent(x, n);
            clock_t end = clock();

            double elapsed_time = ((double)(end - start)) / CLOCKS_PER_SEC;

            char body[BUFFER_SIZE];
            sprintf(body, "<html><body><h1>Arctangent Result</h1>"
                          "<p>arctan(%lf) with n=%d is approximately: %lf</p>"
                          "<p>Elapsed time for arctangent calculation: %lf seconds</p></body></html>",
                    x, n, result, elapsed_time);

            send_response(client_socket, "HTTP/1.1 200 OK", "text/html", body);
        } else if (strncmp(buffer, "GET /sort?", 10) == 0) {
            char *size_str = strstr(buffer, "size=") + 5;

            int size = atoi(size_str);
            double *array = (double *)malloc(size * sizeof(double));
            if (!array) {
                perror("Memory allocation failed");
                close(client_socket);
                continue;
            }

            for (int i = 0; i < size; ++i) {
                array[i] = calculate_arctangent(0.5 + i * 0.01, 100);
            }

            clock_t start = clock();
            sort_array(array, size);
            clock_t end = clock();

            double elapsed_time = ((double)(end - start)) / CLOCKS_PER_SEC;

            char body[BUFFER_SIZE];
            sprintf(body, "<html><body><h1>Sorting Completed</h1>"
                          "<p>Array size: %d</p>"
                          "<p>Elapsed time for sorting: %lf seconds</p></body></html>",
                    size, elapsed_time);

            send_response(client_socket, "HTTP/1.1 200 OK", "text/html", body);
            free(array);
        } else {
            send_response(client_socket, "HTTP/1.1 404 Not Found", "text/html", "<html><body><h1>404 Not Found</h1></body></html>");
        }

        close(client_socket);
    }

    close(server_socket);
    return 0;
}
#endif

