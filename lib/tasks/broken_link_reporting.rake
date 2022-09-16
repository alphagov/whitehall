desc "Generates and emails CSV reports of all public documents containing broken links."
task :generate_broken_link_reports, %i[reports_dir email_address organisation_slug] => [:environment] do |_, args|
  include ActionView::Helpers::NumberHelper
  begin
    reports_dir       = args[:reports_dir]
    email_address     = args[:email_address]
    organisation_slug = args[:organisation_slug]
    report_zip_name   = "broken-link-reports-#{Time.zone.today.strftime}.zip"
    report_zip_path   = Pathname.new(reports_dir).join(report_zip_name)

    puts "Cleaning up any existing reports."
    FileUtils.mkpath reports_dir
    FileUtils.rm Dir.glob("#{reports_dir}/*_links_report.csv")
    FileUtils.rm(report_zip_path) if File.exist?(report_zip_path)

    puts "Generating broken link reports..."
    organisation = Organisation.where(slug: organisation_slug).first if organisation_slug
    LinkReporterCsvService
      .new(reports_dir:, organisation:)
      .generate do |processed, total|
        processed_str = number_with_delimiter(processed)
        total_str = number_with_delimiter(total)
        puts "Processed #{processed_str} of #{total_str}" if (processed % 10_000).zero?
      end

    if Dir.glob("#{reports_dir}/*_links_report.csv").any?
      puts "Reports generated. Zipping..."
      system "zip #{report_zip_path} #{reports_dir}/*_links_report.csv --junk-paths"

      puts "Reports zipped. Uploading..."
      S3FileHandler.save_file_to_s3(report_zip_name, File.open(report_zip_path, "rb").read)
      public_url = Plek.find("whitehall-admin", external: true) + "/export/broken_link_reports/#{Time.zone.today.strftime}"

      puts "Reports uploaded. Emailing to #{email_address}"
      MailNotifications.broken_link_reports(public_url, email_address).deliver_now
      puts "Email sent."
    else
      puts "There are no broken link reports so hopefully this means there " \
        "are no broken links 🎉"
    end
  rescue StandardError => e
    GovukError.notify(e, extra: { error_message: "Exception raised during broken link report generation: '#{e.message}'" })
    raise
  end
end
