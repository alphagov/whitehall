module SyncChecker
  class ResultSet
    class NullCSV
      def self.<<(val); end
    end

    def initialize(progress_bar, csv_file_path = nil)
      @progress_bar = progress_bar
      @results = []

      if csv_file_path.present? && !Rails.env.test?
        @csv_file = File.open(File.expand_path(csv_file_path), "w")
        @csv = CSV.new(@csv_file)
        @csv << Failure.members
      else
        @csv = NullCSV
      end

      @failure_file = File.open(Rails.root.join("tmp/.sync_check_failures"), "w")
    end

    def <<(result)
      if result
        @failure_file.puts result.document_id
        results << result
        csv << result.to_row
        progress_bar.log result.to_s
      end

      progress_bar.increment
    end

    attr_reader :results, :progress_bar, :csv
    private :progress_bar, :csv
  end
end
