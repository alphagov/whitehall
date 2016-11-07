require 'test_helper'
require 'gds_api/test_helpers/content_store.rb'

class SyncCheckWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  def dummy_content_item(item)
    presenter = PublishingApiPresenters.presenter_for(item)

    content = presenter.content
    content[:content_id] = presenter.content_id
    content[:links] = {
      available_translations: [
        {content_id: presenter.content_id, locale: "en"}
      ]
    }
    presenter.links.each do |type, ids|
      content[:links][type] = ids.map { |id| {content_id: id} }
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
      check_class: SyncChecker::Formats::CaseStudyCheck,
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
end
