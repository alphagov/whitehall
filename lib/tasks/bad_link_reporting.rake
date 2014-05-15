desc "Generates a report on bad links found in whitehall documents based on a local mirror of the site."
task :generate_bad_link_reports, [:mirror_directory, :reports_dir, :email_address]  => [:environment] do |t, args|
  reports_dir      = args[:reports_dir]
  mirror_directory = args[:mirror_directory]
  email_address    = args[:email_address]
  report_zip_name  = 'bad_link_reports.zip'
  report_zip_path  = Pathname.new(reports_dir).join(report_zip_name)
  logger           = Logger.new(Rails.root.join('log/bad_link_reporting.log'))

  # clean up any existing reports to ensure we start from a clean slate
  FileUtils.mkpath reports_dir
  FileUtils.rm Dir.glob(reports_dir + '/*_bad_links.csv')
  FileUtils.rm(report_zip_path) if File.exists?(report_zip_path)

  # Generate the reports
  Whitehall::BadLinkReporter.new(mirror_directory, reports_dir, logger).generate_reports

  # zip up reports
  system "zip #{report_zip_path} #{reports_dir}/*_bad_links.csv --junk-paths"

  # email the zipped reports
  Notifications.bad_link_reports(report_zip_path, email_address).deliver
end
