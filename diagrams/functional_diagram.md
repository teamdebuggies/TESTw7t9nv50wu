graph TD;
    A[Client] -->|Uses| B[API Gateway];
    B -->|Routes to| C[Service 1];
    B -->|Routes to| D[Service 2];
    C -->|Stores in| E[Database];
    D -->|Stores in| F[Database];