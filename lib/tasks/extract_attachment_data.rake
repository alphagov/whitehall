require 'ansi/progressbar'

task extract_attachment_data: :environment do
  count = AttachmentData.count
  progress_bar = ::ANSI::Progressbar.new("Extracting attachment text", count)

  AttachmentData.find_each do |file|
    file.extract_text
    progress_bar.inc
  end

  progress_bar.finish
end
