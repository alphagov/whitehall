require 'test_helper'

class ImportForcePublicationAttemptWorkerTest < ActiveSupport::TestCase

  test '#perform loads and performs the force publishing' do
    attempt  = stub('force_publishing_attempt', id: 'id')
    attempt.expects(:perform)

    ForcePublicationAttempt.expects(:find).with(attempt.id).returns(attempt)

    ImportForcePublicationAttemptWorker.new.perform(attempt.id)
  end
end
