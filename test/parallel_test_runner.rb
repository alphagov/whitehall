class ParallelTestRunner < TestQueue::Runner::MiniTest
  def after_fork(number)
    super

    # Use separate mysql database for each fork.
    ActiveRecord::Base.configurations['test']['database'] << database_number_for(number)
    ActiveRecord::Base.establish_connection(:test)
  end

  # We are relying on the parallel test databases created and used by parallel_test, which are
  # whitehall_test, whitehall_test2 ,whitehall_test3, whitehall_test4, etc.
  def database_number_for(number)
    number == 1 ? '' : number.to_s
  end
end
