require 'test_helper'

class WorkerBaseTest < ActiveSupport::TestCase
  def self.worker_has_run!
  end

  class MyWorker < WorkerBase
    sidekiq_options queue: "my-test-queue"
    def perform(*_args)
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
      'args' => [example_arg, { authenticated_user: nil, request_id: nil }],
      'queue' => 'test_queue'
    )
    MyWorker.perform_async_in_queue('test_queue', example_arg)
  end

  test ".perform_async_in_queue uses default queue if queue is nil" do
    example_arg = stub("example arg")
    WorkerBase.expects(:client_push).with(
      'class' => WorkerBaseTest::MyWorker,
      'args' => [example_arg, { authenticated_user: nil, request_id: nil }],
      'queue' => 'my-test-queue'
    )
    MyWorker.perform_async_in_queue(nil, example_arg)
  end

  test ".perform_async_in_queue populates header variables" do
    GdsApi::GovukHeaders.expects(:headers).twice.returns({
      govuk_request_id: "12345",
      x_govuk_authenticated_user: "0a1b2c3d4e5f",
    })
    example_arg = stub("example arg")
    WorkerBase.expects(:client_push).with(
      'class' => WorkerBaseTest::MyWorker,
      'args' => [example_arg, {
        authenticated_user: "0a1b2c3d4e5f", request_id: "12345"
      }],
      'queue' => "test-queue"
    )
    MyWorker.perform_async_in_queue("test-queue", example_arg)
  end
end

