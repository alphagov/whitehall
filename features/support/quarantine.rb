# Simulate a mutex to stop these scenarios stomping on each other during parallel test runs
if ENV['TEST_ENV_NUMBER']
  Before("@quarantine-files") do
    @lock_file = File.open("tmp/cucumber_quarantine_files", "w")
    @lock_file.flock(File::LOCK_EX)

    FileUtils.rm_rf(Whitehall.clean_uploads_root)
  end

  After("@quarantine-files") do
    @lock_file.close
  end
end
