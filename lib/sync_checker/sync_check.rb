require 'ruby-progressbar'

module SyncChecker
  class SyncCheck
    attr_reader :document_checks, :hydra, :failures, :mutex

    def initialize(document_checks, options = {})
      @document_checks = document_checks
      @hydra = options[:hydra] || Typhoeus::Hydra.new(max_concurrency: max_concurrency)
      @failures = options[:failures] || ResultSet.new(progress_bar)
      @mutex = options[:mutex] || Mutex.new
    end

    def run
      document_checks.each do |document_check|
        request = RequestQueue.new(document_check, failures, mutex)
        request.requests.each { |req| hydra.queue(req) }
      end
      progress_bar.total = hydra.queued_requests.count
      progress_bar.start
      hydra.run
      progress_bar.finish
    end

  private

    def max_concurrency
      if defined? Rails
        Rails.env.development? ? 1 : 20
      else
        20
      end
    end

    def progress_bar
      @progress ||= ProgressBar.create(
        autostart: false,
        format: "%e [%b>%i] [%c/%C]"
      )
    end
  end
end
