graph TD;
    A[Load Balancer] -->|Distributes traffic to| B[API Gateway];
    B -->|Routes to| C[Service 1];
    B -->|Routes to| D[Service 2];
    E[Database Cluster] -->|Serves| C;
    E[Database Cluster] -->|Serves| D;