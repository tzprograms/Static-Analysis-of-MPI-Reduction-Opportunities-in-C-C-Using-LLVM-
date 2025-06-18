# Static-Analysis-of-MPI-Reduction-Opportunities-in-C-C-Using-LLVM-
Static analysis tool for detecting MPI reduction patterns in C/C++ using LLVM compiler passes
![snap1](https://github.com/user-attachments/assets/bd6f0bc7-9587-4d61-8f2b-ab0122260dd9)
A compiler-based tool to detect and analyze MPI reduction patterns in C/C++ programs through LLVM static analysis.
## Key Features  
- **Automatic Detection** of explicit MPI reductions (`MPI_Reduce`, `MPI_Allreduce`)  
- **Pattern Recognition** for manual implementations using `MPI_Send`/`MPI_Recv`  
- **LLVM Pass** for low-level IR analysis  
- **Interactive Web Interface** (Streamlit) for visualization  
- **Cross-Validation** with PARCOACH static analyzer  
- **Visualization & Reporting**  
  ✓ Generate metrics (counts of explicit/manual reductions)  
  ✓ Plot results (e.g., pie charts) for quick insights  
  ✓ Automate PDF report generation with analysis summaries  

![snap2](https://github.com/user-attachments/assets/19133f38-5d41-4e6a-8b28-5e746775dbab)
![snap3](https://github.com/user-attachments/assets/a73f7b9a-4fe4-4dd0-a80a-ee9b0c7aec70)
![snap4](https://github.com/user-attachments/assets/3ab736f4-9703-48a2-91a1-fa79440a3364)
![snap5](https://github.com/user-attachments/assets/9cedff34-8757-42d4-b1df-e052b1287e84)


## Installation  

- Clone repository:  
  `git clone https://github.com/tzprograms/Static-Analysis-of-MPI-Reduction-Opportunities-in-C-C-Using-LLVM-  

- Build LLVM pass:  
  `mkdir build && cd build`  
  `cmake -DLUM_DIR=/usr/lib/lum-15/cmake ..`  

## Usage  

- Command line analysis:  
  `clang-15 -S -emit-llvm input.c -o input.ll`  
  `opt-15 -load-pass-plugin=./DetectMPIReduce.so -passes=detect-mpi-reduce input.ll`  

- Web interface:  
  `streamlit run app.py`  

## Test Cases  

- Standard reductions (`MPI_SUM`, `MPI_MAX`)  
- Custom reduction operations  
- Manual tree reduction patterns


## License  

MIT License - See [LICENSE](LICENSE) for details.  
