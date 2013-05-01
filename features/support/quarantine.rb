Around("@quarantine-files") do |scenario, block|
  Whitehall::QuarantineFileStorageSimulator.enable do
    block.call
  end
end
