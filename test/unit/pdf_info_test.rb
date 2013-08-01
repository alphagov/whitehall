unless defined? Rails
  lib = File.expand_path("../../../lib", __FILE__)
  $:.unshift lib unless $:.include?(lib)
end
require 'fast_test_helper'
require "pdf_info"
require "tempfile"
require "shellwords"

class PdfInfoTest < ActiveSupport::TestCase
  def test_raises_if_executable_missing
    assert_raise RuntimeError do
      PdfInfo.new("/this/path/does/not/exist")
    end
  end

  def test_invokes_pdfinfo_with_the_given_pdf_file
    File.stubs(:exist?).with('/usr/bin/nonsense').returns(true)
    File.stubs(:executable?).with('/usr/bin/nonsense').returns(true)
    pdf_info = PdfInfo.new("/usr/bin/nonsense")
    pdf_info.expects(:`).with('/usr/bin/nonsense /path/to/my\\ pdf\\ file.pdf').returns("Pages: 1")
    pdf_info.count_pages("/path/to/my pdf file.pdf")
  end

  def test_can_parse_pdfinfo_output
    pdf_info = PdfInfo.new(fixture_file("pdfinfo_dummy.sh"))
    assert_equal 1, pdf_info.count_pages("this-file-doesnt-matter.pdf")
  end

  def fixture_file(filename)
    File.expand_path("../fixtures/#{filename}", File.dirname(__FILE__))
  end
end
