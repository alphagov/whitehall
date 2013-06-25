namespace :development do
  desc "Copy uploaded files from incoming to clean, faking a virus scan"
  task fake_virus_scan: :environment do
    FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
  end
end
