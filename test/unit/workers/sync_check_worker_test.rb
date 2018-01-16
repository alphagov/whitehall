require 'test_helper'
require 'gds_api/test_helpers/content_store.rb'

class SyncCheckWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  setup do
    SyncChecker::DraftTopicContentIds.stubs(:fetch)
    SyncCheckWorker.unstub(:enqueue)
  end

  def dummy_content_item(item)
    presenter = PublishingApiPresenters.presenter_for(item)

    content = presenter.content
    content[:content_id] = presenter.content_id
    content[:links] = {
      available_translations: [
        { content_id: presenter.content_id, locale: "en" }
      ]
    }
    presenter.links.each do |type, ids|
      content[:links][type] = ids.map { |id| { content_id: id } }
    end

    content
  end

  test "it tests a content item without errors and records the result" do
    case_study = create(:published_case_study)

    content_item = dummy_content_item(case_study)

    content_store_has_item(case_study.search_link, content_item)
    content_store_has_item(case_study.search_link, content_item, draft: true)

    SyncCheckWorker.new.perform(SyncChecker::Formats::CaseStudyCheck, case_study.document_id)

    assert_equal 1, SyncCheckResult.where(
      failures: nil,
      check_class: 'SyncChecker::Formats::CaseStudyCheck',
      item_id: case_study.document_id
    ).count
  end

  test "it tests a content item with errors and records the result" do
    case_study = create(:published_case_study)

    content_item = dummy_content_item(case_study)
    content_item[:content_id] = "foobar"

    content_store_has_item(case_study.search_link, content_item)
    content_store_has_item(case_study.search_link, content_item, draft: true)

    SyncCheckWorker.new.perform(SyncChecker::Formats::CaseStudyCheck, case_study.document_id)

    result = SyncCheckResult.first

    assert_equal "SyncChecker::Formats::CaseStudyCheck", result.check_class
    assert_equal case_study.document_id, result.item_id
    assert_equal 2, result.failures.size
    assert_match %r{expected content_id}, result.failures.first.errors.first
    assert_match %r{expected content_id}, result.failures.last.errors.first
  end

  test "it determines the correct check class" do
    case_study = create(:published_case_study)
    assert_equal SyncChecker::Formats::CaseStudyCheck, SyncCheckWorker.check_class_for(case_study)

    assert_nil SyncCheckWorker.check_class_for(User.first)
  end

  test "it determines the correct id to send for Editioned formats" do
    case_study = create(:published_case_study)
    html_attachment = create(:html_attachment)

    assert_equal case_study.document_id, SyncCheckWorker.item_id_for(case_study)
    assert_equal html_attachment.id, SyncCheckWorker.item_id_for(html_attachment)
  end

  test "it schedules the job for 5 minutes time" do
    case_study = create(:published_case_study)

    Sidekiq::Testing.fake! do
      SyncCheckWorker.enqueue(case_study)

      assert_equal 1, SyncCheckWorker.jobs.size

      job = SyncCheckWorker.jobs.first
      assert_equal SyncChecker::Formats::CaseStudyCheck.name, job["args"][0]
      assert_equal case_study.document_id, job["args"][1]
      assert_in_delta 5.minutes, job["at"] - job["created_at"], 1
    end
  end

  test "it doesn't schedule a job that a check doesn't exist for" do
    Sidekiq::Testing.fake! do
      SyncCheckWorker.enqueue(create(:user))

      assert_empty SyncCheckWorker.jobs
    end
  end
end
