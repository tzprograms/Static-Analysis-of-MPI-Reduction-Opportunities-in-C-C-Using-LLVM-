import streamlit as st
import subprocess
import os
import uuid
import matplotlib.pyplot as plt
import base64
from io import StringIO, BytesIO
from xhtml2pdf import pisa
import chardet

# Helper Functions
def detect_encoding(file_bytes):
    result = chardet.detect(file_bytes)
    return result['encoding'] or 'utf-8'

def safe_read(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()
        encoding = detect_encoding(content)
        return content.decode(encoding, errors='replace')

def run_command(cmd, cwd=None):
    result = subprocess.run(cmd, 
                          cwd=cwd,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
    return {
        'stdout': safe_decode(result.stdout),
        'stderr': safe_decode(result.stderr),
        'returncode': result.returncode
    }

def safe_decode(byte_data):
    if isinstance(byte_data, str):
        return byte_data
    try:
        return byte_data.decode('utf-8')
    except UnicodeDecodeError:
        try:
            return byte_data.decode('latin-1')
        except:
            return str(byte_data)

# Streamlit App
def main():
    st.set_page_config(layout="wide", page_title="MPI Reduction Detector")
    st.title("🧠 MPI Reduction Analysis Tool")
    
    # File Upload
    uploaded_file = st.file_uploader("📤 Upload MPI C File", type=["c"])
    if not uploaded_file:
        st.info("👆 Upload an MPI C file to begin analysis")
        return
    
    # Save uploaded file
    file_id = str(uuid.uuid4())[:8]
    filename = f"upload_{file_id}.c"
    ll_filename = f"{filename}.ll"
    
    with open(filename, "wb") as f:
        f.write(uploaded_file.getbuffer())
    
    # Display original code
    with st.expander("📝 Source Code", expanded=True):
        try:
            code = safe_read(filename)
            st.code(code, language='c')
        except Exception as e:
            st.error(f"Failed to display file: {str(e)}")
            return
    
    # Compilation
    st.subheader("🔧 Compilation")
    include_flags = ["-I/usr/lib/x86_64-linux-gnu/openmpi/include",
                   "-I/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi"]
    
    compile_cmd = [
        "clang-15", "-S", "-emit-llvm",
        filename,
        *include_flags,
        "-L/usr/lib/x86_64-linux-gnu/openmpi/lib",
        "-lmpi",
        "-o", ll_filename
    ]
    
    with st.spinner("Compiling to LLVM IR..."):
        compile_result = run_command(compile_cmd)
    
    if compile_result['returncode'] != 0:
        st.error("❌ Compilation Failed")
        st.code(compile_result['stderr'], language='bash')
        os.remove(filename)
        return
    
    st.success("✅ LLVM IR Generated Successfully")
    
    # Analysis
    st.subheader("🧠 Analysis Results")
    tab1, tab2 = st.tabs(["LLVM Plugin", "PARCOACH"])
    
    with tab1:
        plugin_path = os.path.abspath("../parcoach/plugins/DetectMPIReduce/DetectMPIReduce.so")
        
        if not os.path.exists(plugin_path):
            st.error(f"Plugin not found at {plugin_path}")
        else:
            with st.spinner("Running LLVM Analysis..."):
                analysis_cmd = [
                    "opt-15",
                    "-load-pass-plugin", plugin_path,
                    "-passes=detect-mpi-reduce",
                    ll_filename
                ]
                analysis_result = run_command(analysis_cmd)
                
                if analysis_result['returncode'] != 0:
                    st.error("❌ Analysis Failed")
                    st.code(analysis_result['stderr'], language='bash')
                else:
                    output = analysis_result['stderr']
                    st.success("✅ Analysis Complete")
                    
                    # Parse results - UPDATED PARSING LOGIC
                    explicit_reductions = output.count("✅ Explicit")
                    manual_patterns = output.count("🔍 CONFIRMED")
                    
                    # Display metrics
                    col1, col2 = st.columns(2)
                    col1.metric("Explicit Reductions", explicit_reductions)
                    col2.metric("Manual Patterns", manual_patterns)
                    
                    # Display full output
                    with st.expander("📋 Detailed Output"):
                        st.code(output, language='text')
                    
                    # Visualization
                    if explicit_reductions + manual_patterns > 0:
                        fig, ax = plt.subplots()
                        labels = ['Explicit Reductions', 'Manual Patterns']
                        sizes = [explicit_reductions, manual_patterns]
                        ax.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=90)
                        ax.axis('equal')
                        st.pyplot(fig)
    
    with tab2:
        parcoach_path = os.path.abspath("../parcoach/build/parcoach")
        
        if not os.path.exists(parcoach_path):
            st.warning("PARCOACH not found - using demo data")
            st.code("""✅ Demo PARCOACH Output:
[MPI_REDUCE] Found reduction at line 15 (MPI_SUM)
[MPI_REDUCE] Found reduction at line 16 (MPI_MAX)
[MPI_ALLREDUCE] Found reduction at line 17 (MPI_MIN)
[MPI_REDUCE] Found custom reduction at line 21""")
        else:
            with st.spinner("Running PARCOACH Analysis..."):
                parcoach_cmd = [
                    parcoach_path,
                    "-mpi-reduce",
                    filename
                ]
                parcoach_result = run_command(parcoach_cmd)
                
                st.code(parcoach_result['stdout'], language='text')
                
                if "MPI_REDUCE" in parcoach_result['stdout']:
                    st.success("✅ PARCOACH found reduction opportunities")
                else:
                    st.warning("⚠️ No reduction patterns found by PARCOACH")
    
    # Report Generation
    st.subheader("📊 Generate Report")
    if st.button("Generate PDF Report"):
        with st.spinner("Generating report..."):
            try:
                report_html = f"""
                <h1>MPI Reduction Analysis Report</h1>
                <h2>File: {uploaded_file.name}</h2>
                <h3>Source Code:</h3>
                <pre>{code}</pre>
                <h3>LLVM Plugin Results:</h3>
                <pre>{output}</pre>
                <h3>PARCOACH Results:</h3>
                <pre>{parcoach_result.get('stdout', 'No PARCOACH output')}</pre>
                """
                
                pdf = BytesIO()
                pisa.CreatePDF(StringIO(report_html), dest=pdf)
                pdf.seek(0)
                
                b64 = base64.b64encode(pdf.read()).decode()
                href = f'<a href="data:application/pdf;base64,{b64}" download="mpi_report.pdf">📄 Download Full Report</a>'
                st.markdown(href, unsafe_allow_html=True)
                
            except Exception as e:
                st.error(f"Report generation failed: {str(e)}")
    
    # Cleanup
    for f in [filename, ll_filename]:
        if os.path.exists(f):
            os.remove(f)

if __name__ == "__main__":
    main()
