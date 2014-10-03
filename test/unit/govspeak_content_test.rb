require 'test_helper'

class GovspeakContentTest < ActiveSupport::TestCase

  test 'queues a job to compute the HTML on creation' do
    Sidekiq::Testing.fake! do
      govspeak_content = create(:html_attachment).govspeak_content
      job = GovspeakContentWorker.jobs.last

      assert_equal [govspeak_content.id], job['args']
    end
  end

  test 'queues a job to re-compute the HTML on updates' do
    govspeak_content = create(:html_attachment).govspeak_content

    Sidekiq::Testing.fake! do
      govspeak_content.body = "Updated body"
      govspeak_content.save!
      job = GovspeakContentWorker.jobs.last

      assert_equal [govspeak_content.id], job['args']
    end
  end
end
