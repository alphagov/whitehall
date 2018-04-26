desc "Generates and emails CSV reports of all public documents containing broken links."
task :generate_broken_link_reports, %i[reports_dir email_address organisation_slug] => [:environment] do |_, args|
  include ActionView::Helpers::NumberHelper
  begin
    reports_dir       = args[:reports_dir]
    email_address     = args[:email_address]
    organisation_slug = args[:organisation_slug]
    report_zip_name   = "broken-link-reports-#{Date.today.strftime}.zip"
    report_zip_path   = Pathname.new(reports_dir).join(report_zip_name)

    puts "Cleaning up any existing reports."
    FileUtils.mkpath reports_dir
    FileUtils.rm Dir.glob(reports_dir + '/*_links_report.csv')
    FileUtils.rm(report_zip_path) if File.exist?(report_zip_path)

    puts "Generating broken link reports..."
    organisation = Organisation.where(slug: organisation_slug).first if organisation_slug
    LinkReporterCsvService
      .new(reports_dir: reports_dir, organisation: organisation)
      .generate do |processed, total|
        processed_str = number_with_delimiter(processed)
        total_str = number_with_delimiter(total)
        puts "Processed #{processed_str} of #{total_str}" if (processed % 10000).zero?
      end

    if Dir.glob("#{reports_dir}/*_links_report.csv").any?
      puts "Reports generated. Zipping..."
      system "zip #{report_zip_path} #{reports_dir}/*_links_report.csv --junk-paths"

      puts "Reports zipped. Emailing to #{email_address}"
      Notifications.broken_link_reports(report_zip_path, email_address).deliver_now
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
