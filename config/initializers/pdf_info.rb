require 'pdf_info'
possible_pdfinfo_binaries = ["/usr/bin/pdfinfo", "/usr/local/bin/pdfinfo"]
pdfinfo_binary = possible_pdfinfo_binaries.detect { |path| File.exist?(path) }
if pdfinfo_binary
  PDFINFO_SERVICE = PdfInfo.new(pdfinfo_binary)
else
  Rails.logger.warn "WARNING: pdfinfo binary not found. PDF Page counting will not work."
end