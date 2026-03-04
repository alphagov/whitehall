require "test_helper"

class JobBaseTest < ActiveSupport::TestCase
  def self.job_has_run!; end

  class MyJob < JobBase
    sidekiq_options queue: "my-test-queue"
    def perform(*_args)
      JobBaseTest.job_has_run!
    end
  end

  test ".perform_async runs the job" do
    self.class.expects(:job_has_run!)
    Sidekiq::Testing.inline! do
      MyJob.perform_async
    end
  end

  test ".perform_async_in_queue runs the job in the specified queue" do
    example_arg = stub("example arg")
    JobBase.expects(:client_push).with(
      "class" => JobBaseTest::MyJob,
      "args" => [example_arg],
      "queue" => "test_queue",
    )
    MyJob.perform_async_in_queue("test_queue", example_arg)
  end

  test ".perform_async_in_queue uses default queue if queue is nil" do
    example_arg = stub("example arg")
    JobBase.expects(:client_push).with(
      "class" => JobBaseTest::MyJob,
      "args" => [example_arg],
      "queue" => "my-test-queue",
    )
    MyJob.perform_async_in_queue(nil, example_arg)
  end
end
