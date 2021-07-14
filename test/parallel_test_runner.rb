class ParallelTestRunner < TestQueue::Runner::MiniTest
  def after_fork(number)
    super

    # Use separate mysql database for each fork.
    db_config = ActiveRecord::Base.configurations.configs_for(env_name: "test", name: "primary")
    db_config.configuration_hash.merge(database: database_number_for(number))
    ActiveRecord::Base.establish_connection(:test)

    # Allow the app to instrospect the current test environment number
    ENV["TEST_ENV_NUMBER"] = number.to_s
  end

  # We are relying on the parallel test databases created and used by parallel_test, which are
  # whitehall_test, whitehall_test2 ,whitehall_test3, whitehall_test4, etc.
  def database_number_for(number)
    number == 1 ? "" : number.to_s
  end
end
