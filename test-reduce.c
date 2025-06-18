#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

// Add this custom reduction function
void my_sum(void *invec, void *inoutvec, int *len, MPI_Datatype *type) {
    int *in = (int *)invec;
    int *inout = (int *)inoutvec;
    for (int i = 0; i < *len; i++) {
        inout[i] += in[i];
    }
}

void explicit_reductions(int rank) {
    int val = rank + 1;
    int sum, max, min;
    
    // Standard reductions
    MPI_Reduce(&val, &sum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&val, &max, 1, MPI_INT, MPI_MAX, 0, MPI_COMM_WORLD);
    MPI_Allreduce(&val, &min, 1, MPI_INT, MPI_MIN, MPI_COMM_WORLD);
    
    // Custom reduction
    MPI_Op custom_op;
    MPI_Op_create((MPI_User_function*)my_sum, 1, &custom_op);
    MPI_Reduce(&val, &sum, 1, MPI_INT, custom_op, 0, MPI_COMM_WORLD);
    MPI_Op_free(&custom_op);
}

void manual_reduction(int rank, int size) {
    float partial = rank * 1.5f;
    float total = 0;

    // Manual tree reduction
    for (int step = 1; step < size; step *= 2) {
        if (rank % (2*step) == 0) {
            float received;
            MPI_Recv(&received, 1, MPI_FLOAT, rank+step, 0, 
                    MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            partial += received;
        } 
        else if (rank % step == 0) {
            MPI_Send(&partial, 1, MPI_FLOAT, rank-step, 0, 
                    MPI_COMM_WORLD);
        }
    }
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    explicit_reductions(rank);
    manual_reduction(rank, size);

    MPI_Finalize();
    return 0;
}
