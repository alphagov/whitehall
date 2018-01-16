require 'minitest/autorun'
require 'mocha/setup'
require 'ruby-progressbar'

require_relative '../../../config/environment'
require_relative '../../../lib/sync_checker/request_queue'
require_relative '../../../lib/sync_checker/sync_check'

module SyncChecker
  class SyncCheckTest < Minitest::Test
    class FakeRelation < Array
      def initialize(*args)
        super(*args)
        replace(self.map { |v| OpenStruct.new(v) })
      end

      alias find_each each
    end

    Check = Struct.new(:id) do
      def base_paths
        { draft: [[:en, "/#{id}"]], live: [[:en, "/#{id}"]] }
      end
    end

    def setup
      ProgressBar.stubs(:create).returns(stub_everything)
    end

    def test_it_creates_a_queued_request_for_each_check
      options = {
        failures: stub(:<< => true, results: []),
        hydra: stub(run: nil, queue: nil, queued_requests: [])
      }

      scope = FakeRelation.new([{ id: 1 }, { id: 2 }])

      sync_check = SyncCheck.new(Check, scope, options)

      scope.each do |document|
        RequestQueue.expects(:new).with(
          Check.new(document),
          options[:failures]
        ).returns(stub(requests: []))
      end

      sync_check.run
    end

    def test_queues_the_requests
      scope = FakeRelation.new([{ id: 1 }, { id: 2 }])

      sync_check = SyncCheck.new(Check, scope, hydra: hydra = stub(queue: nil, run: nil, queued_requests: []))

      RequestQueue.stubs(:new).returns(stub(requests: [1, 2]))
      hydra.expects(:queue).with(1)
      hydra.expects(:queue).with(2)

      sync_check.run
    end

    def test_it_creates_a_hydra
      Typhoeus::Hydra.expects(:new).with(max_concurrency: 20).returns(hydra = stub)
      sync_check = SyncCheck.new(Check, FakeRelation.new)
      sync_check.hydra == hydra
    end

    def test_runs_the_hydra
      Typhoeus::Hydra.expects(:new)
        .with(max_concurrency: 20)
        .returns(hydra = stub(queued_requests: [], queue: nil))
      hydra.expects(:run)
      sync_check = SyncCheck.new(Check, FakeRelation.new([{ id: 1 }]))
      sync_check.run
    end
  end
end
