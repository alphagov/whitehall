task extract_attachment_data: :environment do
  require 'open3'
  require 'benchmark'
  tika_logger = Logger.new(Rails.root.join("log/tika.log"))
  tika_logger.formatter = Logger::Formatter.new
  tika_logger.info "Extracting #{AttachmentData.count} files"

  def format_times(bmtimes)
    sprintf("%dms cpu, %dms elapsed", bmtimes.total * 1000, bmtimes.real * 1000)
  end

  AttachmentData.find_each do |attachment_data|
    next if attachment_data.txt? || attachment_data.text_file_exists?
    cmd = %Q{tika -t "#{attachment_data.file.path}" > "#{attachment_data.text_file_path}"}
    error_output = nil
    exit_status = nil

    bmtimes = Benchmark.measure do
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stdin.close
        stdout.close
        error_output = stderr.read
        exit_status = wait_thr.value
      end
    end

    timing = "(took #{format_times(bmtimes)})"

    if exit_status.success?
      message = "#{attachment_data.file.path}: OK #{timing}"
      if ! error_output.strip.empty?
        message << " (#{error_output})"
      end
      tika_logger.info(message)
    else
      tika_logger.error("#{attachment_data.file.path}: ERROR #{timing} (#{error_output})")
    end

  end
end
