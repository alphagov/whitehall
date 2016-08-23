require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../../lib/sync_checker/request_queue'
require_relative '../../../lib/sync_checker/sync_check'

class SyncCheckTest < Minitest::Test
  def test_it_creates_a_queued_request_for_each_check
    document_checks = [
      stub,
      stub
    ]

    options = {
      mutex: Mutex.new,
      failures: stub(:<< => true),
      hydra: stub(run: nil, queue: nil)
    }

    checker = SyncChecker::SyncCheck.new(document_checks, options)

    document_checks.each do |document_check|
      SyncChecker::RequestQueue.expects(:new).with(
        document_check,
        options[:failures],
        options[:mutex]
      ).returns(stub(requests: []))
    end

    checker.run
  end

  def test_queues_the_requests
    document_checks = [
      stub(id: 1, base_path: "/one"),
      stub(id: 2, base_path: "/one"),
    ]

    checker = SyncChecker::SyncCheck.new(document_checks, hydra: hydra = stub(queue: nil, run: nil))

    SyncChecker::RequestQueue.stubs(:new).returns(stub(requests: [1, 2]))
    hydra.expects(:queue).with(1)
    hydra.expects(:queue).with(2)

    checker.run
  end

  def test_it_creates_a_hydra
    Typhoeus::Hydra.expects(:new).with(max_concurrency: 20).returns(hydra = stub)
    checker = SyncChecker::SyncCheck.new([])
    checker.hydra == hydra
  end

  def test_runs_the_hydra
    Typhoeus::Hydra.expects(:new).with(max_concurrency: 20).returns(hydra = stub)
    hydra.expects(:run)
    checker = SyncChecker::SyncCheck.new([])
    checker.run
  end
end
