import pdfkit

def export_html_to_pdf(html_code: str, output_path: str):
    with open("temp_export.html", "w") as f:
        f.write(html_code)
    pdfkit.from_file("temp_export.html", output_path)

