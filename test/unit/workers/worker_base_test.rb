class WorkerBaseTest < ActiveSupport::TestCase
  def self.worker_has_run!
  end

  class MyWorker < WorkerBase
    def perform
      WorkerBaseTest.worker_has_run!
    end
  end

  test ".perform_async runs the job" do
    self.class.expects(:worker_has_run!)
    MyWorker.perform_async
  end

  test ".perform_async_in_queue runs the job in the specified queue" do
    example_arg = stub("example arg")
    WorkerBase.expects(:client_push).with(
      'class' => WorkerBaseTest::MyWorker,
      'args' => [example_arg],
      'queue' => 'test_queue'
    )
    MyWorker.perform_async_in_queue('test_queue', example_arg)
  end

end

