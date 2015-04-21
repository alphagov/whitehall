namespace :reporting  do
  def opts_from_environment
    opts = {}
    [:data_path, :start_date, :end_date].each do |key|
      opts[key] = ENV[key.to_s.upcase] if ENV[key.to_s.upcase]
    end
    opts
  end

  desc "An overview of attachment statistics by organisation as CSV"
  task :attachments_overview => :environment do
    AttachmentDataReporter.new(opts_from_environment).overview
  end

  desc "A report of attachments statistics with related document slugs as CSV"
  task :attachments_report => :environment do
    AttachmentDataReporter.new(opts_from_environment).report
  end

  desc "A report of collection statistics by organisation as CSV"
  task :collections_report => :environment do
    CollectionDataReporter.new(ENV.fetch('OUTPUT_DIR', './tmp')).report
  end
end
