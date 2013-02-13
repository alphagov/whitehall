require 'pdf_info'
possible_pdfinfo_binaries = ["/usr/bin/pdfinfo", "/usr/local/bin/pdfinfo"]
pdfinfo_binary = possible_pdfinfo_binaries.find { |path| File.exist?(path) }
PDFINFO_SERVICE = PdfInfo.new(pdfinfo_binary)