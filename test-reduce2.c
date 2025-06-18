#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    int rank, val, max;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    val = rank * 10;

    MPI_Reduce(&val, &max, 1, MPI_INT, MPI_MAX, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Maximum value is %d\n", max);
    }

    MPI_Finalize();
    return 0;
}

