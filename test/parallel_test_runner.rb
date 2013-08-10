class ParallelTestRunner < TestQueue::Runner::MiniTest
  def after_fork(number)
    super

    # Use separate mysql database for each fork.
    ActiveRecord::Base.configurations['test']['database'] << database_number_for(number)
    ActiveRecord::Base.establish_connection(:test)

    # Allow the app to instrospect the current test environment number
    ENV['TEST_ENV_NUMBER'] = number.to_s

    # Blow away the incoming/clean test uploads for this env to avoid clashes during test run
    [(Whitehall.incoming_uploads_root + '/system'), (Whitehall.clean_uploads_root + '/system'), (Whitehall.infected_uploads_root + '/system')].each do |folder|
      FileUtils.rm_rf(folder) if Dir.exists?(folder)
    end
  end

  # We are relying on the parallel test databases created and used by parallel_test, which are
  # whitehall_test, whitehall_test2 ,whitehall_test3, whitehall_test4, etc.
  def database_number_for(number)
    number == 1 ? '' : number.to_s
  end
end
