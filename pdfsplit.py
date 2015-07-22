import os
import sys
# From the PyPDF2 module
# pip install PyPDF2
from PyPDF2 import PdfFileWriter, PdfFileReader
if len(sys.argv) == 0:
    print('Script requires at least one argument')


def splitpdf(pdf_file, output_dir):
    pdf_file_sans_prefix = os.path.splitext(pdf_file)[0]
    inputpdf = PdfFileReader(open(pdf_file, "rb"))
    for page in range(inputpdf.numPages):
        output = PdfFileWriter()
        output.addPage(inputpdf.getPage(page))
        with open(os.path.join(output_dir, pdf_file_sans_prefix) + "%s.pdf" % page, "wb")\
                as outputStream:
            output.write(outputStream)


def determinedir(start_dir):
    filter(os.path.isdir, [os.path.join(start_dir, subdir)
                           for subdir in os.listdir(start_dir)])

for arg in sys.argv[1:]:
    splitpdf(arg)
