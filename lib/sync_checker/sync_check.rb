require 'csv'
require 'ruby-progressbar'

module SyncChecker
  class SyncCheck
    attr_reader :checker, :scope, :hydra, :failures

    def initialize(checker, scope, options = {})
      @checker = checker
      @scope = scope
      @hydra = options[:hydra] || Typhoeus::Hydra.new(max_concurrency: max_concurrency)
      @failures = options[:failures] || ResultSet.new(progress_bar, options[:csv_file_path])
    end

    def run
      progress_bar.total = scope.count
      progress_bar.start

      scope.find_each do |document|
        progress_bar.log "running check for document_id #{document.id}"
        document_check = checker.new(document)
        request = RequestQueue.new(document_check, failures)
        request.requests.each { |req| hydra.queue(req) }
        hydra.run
        progress_bar.increment
      end

      progress_bar.finish
      puts "#{failures.results.count} failures" unless Rails.env.test?
    end

  private

    def max_concurrency
      Rails.env.development? ? 1 : 20
    end

    def progress_bar
      @progress_bar ||= ProgressBar.create(
        autostart: false,
        format: "%e [%b>%i] [%c/%C]"
      )
    end
  end
end
