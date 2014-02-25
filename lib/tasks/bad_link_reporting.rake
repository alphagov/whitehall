desc "Generates a report on bad links found in whitehall documents based on a local mirror of the site."
task :generate_bad_link_report, [:mirror_directory, :report_path]  => [:environment] do |t, args|
  report_path = args[:report_path]
  mirror_directory = args[:mirror_directory]

  Whitehall::BadLinkFinder.new(mirror_directory).generate_report(report_path)
end
