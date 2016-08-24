module SyncChecker
  class ResultSet
    class NullCSV
      def self.<<(val); end
    end

    def initialize(progress_bar, csv_file_path = nil)
      @progress_bar = progress_bar

      if csv_file_path.present? && !Rails.env.test?
        file = File.open(File.expand_path(csv_file_path), "w")
        @csv = CSV.new(file)
      else
        @csv = NullCSV
      end
    end

    def <<(result)
      results << result unless result.nil?
      csv << result.to_row unless result.nil?
      progress_bar.increment
    end

    attr_reader :results, :progress_bar, :csv
    private :results, :progress_bar, :csv
  end
end
