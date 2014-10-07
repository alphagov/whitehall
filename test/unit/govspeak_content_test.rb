require 'test_helper'

class GovspeakContentTest < ActiveSupport::TestCase

  test 'queues a job to compute the HTML on creation' do
    Sidekiq::Testing.fake! do
      govspeak_content = create(:html_attachment).govspeak_content

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id], job['args']
    end
  end

  test 'queues a job to re-compute the HTML when the body changes' do
    govspeak_content = create(:html_attachment).govspeak_content

    Sidekiq::Testing.fake! do
      govspeak_content.body = "Updated body"
      govspeak_content.save!

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id], job['args']
    end
  end

  test 'queues a job to re-compute the HTML when the numbering scheme changes' do
    govspeak_content = create(:html_attachment, manually_numbered_headings: false).govspeak_content

    Sidekiq::Testing.fake! do
      govspeak_content.manually_numbered_headings = true
      govspeak_content.save!

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id], job['args']
    end
  end
end
