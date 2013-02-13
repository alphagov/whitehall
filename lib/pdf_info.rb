require 'shellwords'
class PdfInfo
  def initialize(pdfinfo_executable_path)
    raise "'#{pdfinfo_executable_path}' not found" unless File.exist?(pdfinfo_executable_path)
    raise "'#{pdfinfo_executable_path}' not executable" unless File.executable?(pdfinfo_executable_path)
    @pdfinfo_executable_path = pdfinfo_executable_path
  end

  def count_pages(pdf_file)
    pages_line = `#{@pdfinfo_executable_path} #{Shellwords.shellescape(pdf_file)}`.split("\n").grep(/^Pages:/).first
    parse_pages_line(pages_line) if pages_line
  end

private
  def parse_pages_line(pages_line)
    pages_line.split(":")[1].strip.to_i
  end
end
