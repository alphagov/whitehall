require 'typhoeus'

module SyncChecker
  class SyncCheck
    attr_reader :document_checks, :hydra, :failures, :mutex

    def initialize(document_checks, options = {})
      @document_checks = document_checks
      @hydra = options[:hydra] || Typhoeus::Hydra.new(max_concurrency: max_concurrency)
      @failures = options[:failures] || []
      @mutex = options[:mutex] || Mutex.new
    end

    def run
      document_checks.each do |document_check|
        request = RequestQueue.new(document_check, failures, mutex)
        request.requests.each { |req| hydra.queue(req) }
      end
      hydra.run
    end

  private

    def max_concurrency
      if defined? Rails
        Rails.env.development? ? 1 : 20
      else
        20
      end
    end
  end
end
