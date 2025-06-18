import subprocess
import os

def analyze_mpi_file(c_file_path):
    ll_file_path = c_file_path.replace(".c", ".ll")
    plugin_path = "./parcoach/build/DetectMPIReduce.so"

    # Try using mpicc or fallback to clang-15 with mpi include path
    try:
        subprocess.run(["mpicc", "-S", "-emit-llvm", c_file_path, "-o", ll_file_path], check=True)
    except:
        subprocess.run(["clang-15", "-S", "-emit-llvm", "-I/usr/include/mpi", c_file_path, "-o", ll_file_path], check=True)

    # Run plugin
    result = subprocess.run([
        "opt-15",
        "-load-pass-plugin", plugin_path,
        "-passes=detect-mpi-reduce",
        "-disable-output",
        ll_file_path
    ], capture_output=True, text=True)

    output = result.stderr + result.stdout

    # Stats estimation (simple grep-based mockup)
    stats = {
        "total_functions": output.count("define "),
        "mpi_calls": output.count("MPI_"),
        "mpi_reduce_calls": output.count("MPI_Reduce")
    }

    return True, output, stats

