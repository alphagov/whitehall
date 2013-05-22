Around("@quarantine-files") do |scenario, block|
  Whitehall::QuarantineFileStorageSimulator.enable do
    block.call
  end
end

# Simulate a mutex to stop these scenarios stomping on each other during parallel test runs
if ENV['TEST_ENV_NUMBER']
  Before("@quarantine-files") do
    while File.exists?("tmp/cucumber_quarantine_files")
      sleep(0.2)
    end
    File.open("tmp/cucumber_quarantine_files", "w") {}
  end

  After("@quarantine-files") do
    File.delete("tmp/cucumber_quarantine_files")
  end
end