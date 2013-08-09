# Blow away the incoming/clean test uploads for this env to avoid clashes during test run
  [(Whitehall.incoming_uploads_root + '/system'), (Whitehall.clean_uploads_root + '/system'), (Whitehall.infected_uploads_root + '/system')].each do |folder|
    FileUtils.rm_rf(folder) if Dir.exists?(folder)
  end
