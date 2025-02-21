Around("@disable_transactions") do |_scenario, block|
  Cucumber::Rails::World.use_transactional_tests = false
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.start

  block.call

  DatabaseCleaner.clean
end
