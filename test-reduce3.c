#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    int rank;
    double send_val, recv_val;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    send_val = (rank + 1) * 1.5;

    MPI_Reduce(&send_val, &recv_val, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Reduced value = %f\n", recv_val);
    }

    MPI_Finalize();
    return 0;
}

