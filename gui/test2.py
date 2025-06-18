import streamlit as st
import subprocess
import os
import uuid
import matplotlib.pyplot as plt
import seaborn as sns
import base64
from io import StringIO, BytesIO
from xhtml2pdf import pisa
import chardet
import re

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
    result = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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

def extract_line_numbers(output, source_code):
    """Extracts line numbers from LLVM output and maps to source code"""
    findings = []
    lines = source_code.split('\n')
    
    # Find all MPI calls in source code
    mpi_calls = []
    for i, line in enumerate(lines, 1):
        if any(f"MPI_{op}" in line for op in ["Reduce", "Allreduce", "Send", "Recv"]):
            mpi_calls.append((i, line.strip()))
    
    # Process analysis output
    for line in output.split('\n'):
        if "✅ Explicit" in line:
            # Find the closest MPI call in source
            if mpi_calls:
                line_num, call = mpi_calls.pop(0)
                findings.append(f"{line} (Line {line_num}: `{call}`)")
            else:
                findings.append(line)
        elif "🔍 CONFIRMED" in line:
            # For manual patterns, show the communication operation
            if mpi_calls:
                line_num, call = mpi_calls.pop(0)
                findings.append(f"{line}\n   Found at Line {line_num}: `{call}`")
            else:
                findings.append(line)
        elif line.strip().startswith("%"):
            continue  # Skip raw LLVM lines
        else:
            findings.append(line)
    
    return "\n".join(findings)

# Streamlit App
def main():
    st.set_page_config(layout="wide", page_title="MPI Reduction Analyzer")
    st.title("🧠 MPI Reduction Analysis Tool")

    uploaded_file = st.file_uploader("📤 Upload an MPI C File", type=["c"])
    if not uploaded_file:
        st.info("👆 Please upload an MPI C file to start the analysis.")
        return

    file_id = str(uuid.uuid4())[:8]
    filename = f"upload_{file_id}.c"
    ll_filename = f"{filename}.ll"

    with open(filename, "wb") as f:
        f.write(uploaded_file.getbuffer())

    # Read source code for line mapping
    with open(filename, "rb") as f:
        source_code = safe_decode(f.read())

    with st.expander("📄 Uploaded Source Code", expanded=True):
        st.code(source_code, language='c')

    st.subheader("🛠️ Compilation to LLVM IR")
    include_flags = ["-I/usr/lib/x86_64-linux-gnu/openmpi/include", 
                    "-I/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi"]

    compile_cmd = [
        "clang-15", "-S", "-emit-llvm", "-g",
        filename,
        *include_flags,
        "-L/usr/lib/x86_64-linux-gnu/openmpi/lib",
        "-lmpi",
        "-o", ll_filename
    ]

    with st.spinner("Compiling..."):
        compile_result = run_command(compile_cmd)

    if compile_result['returncode'] != 0:
        st.error("❌ Compilation Failed")
        st.code(compile_result['stderr'], language='bash')
        os.remove(filename)
        return

    st.success("✅ Compilation Successful")

    st.subheader("🔍 LLVM Plugin Analysis")
    plugin_path = os.path.abspath("../parcoach/plugins/DetectMPIReduce/DetectMPIReduce.so")

    if not os.path.exists(plugin_path):
        st.error(f"Plugin not found at: {plugin_path}")
    else:
        with st.spinner("Running analysis with custom LLVM plugin..."):
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
                raw_output = analysis_result['stderr']
                annotated_output = extract_line_numbers(raw_output, source_code)
                explicit_count = raw_output.count("✅ Explicit")
                manual_count = raw_output.count("🔍 CONFIRMED")

                col1, col2 = st.columns(2)
                col1.metric("🔁 Explicit Reductions", explicit_count)
                col2.metric("📚 Manual Patterns", manual_count)

                with st.expander("🧾 Detailed Analysis Output", expanded=True):
                    st.code(annotated_output, language='text')

                if explicit_count + manual_count > 0:
                    st.subheader("📊 Visualization")
                    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
                    
                    # Pie chart
                    ax1.pie(
                        [explicit_count, manual_count],
                        labels=["Explicit", "Manual"],
                        autopct="%1.1f%%",
                        startangle=90,
                        colors=["#4CAF50", "#2196F3"]
                    )
                    ax1.set_title("Reduction Types")
                    
                    # Bar plot
                    sns.barplot(
                        x=["Explicit", "Manual"],
                        y=[explicit_count, manual_count],
                        palette="Set2",
                        ax=ax2
                    )
                    ax2.set_title("Reduction Counts")
                    ax2.set_ylabel("Count")
                    
                    st.pyplot(fig)

    # Report Generation
    st.subheader("📄 Export Report as PDF")
    if st.button("Generate PDF Report"):
        with st.spinner("Generating PDF..."):
            try:
                report_html = f"""
                <h1>MPI Reduction Analysis Report</h1>
                <h2>Analysis of: {uploaded_file.name}</h2>
                <h3>Key Findings</h3>
                <ul>
                    <li>Explicit Reductions: {explicit_count}</li>
                    <li>Manual Patterns: {manual_count}</li>
                </ul>
                <h3>Detailed Findings</h3>
                <pre>{annotated_output}</pre>
                <h3>Source Code</h3>
                <pre>{source_code}</pre>
                """
                pdf = BytesIO()
                pisa.CreatePDF(StringIO(report_html), dest=pdf)
                pdf.seek(0)
                b64 = base64.b64encode(pdf.read()).decode()
                href = f'<a href="data:application/pdf;base64,{b64}" download="mpi_report.pdf">📥 Download Full Report</a>'
                st.markdown(href, unsafe_allow_html=True)
            except Exception as e:
                st.error(f"Report generation failed: {str(e)}")

    # Cleanup
    for f in [filename, ll_filename]:
        if os.path.exists(f):
            os.remove(f)

if __name__ == "__main__":
    main()
