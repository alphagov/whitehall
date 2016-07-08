require "test_helper"

class CaseStudySerializerTest < ActiveSupport::TestCase
  def stubbed_item
    stub(
      summary: 'A summary',
      rendering_app: 'whitehall',
      public_timestamp: 'a timestamp'
    )
  end

  def serializer
    CaseStudySerializer.new(stubbed_item)
  end

  test 'it includes a description' do
    assert_equal serializer.description, stubbed_item.summary
  end

  test 'it includes a document type' do
    assert_equal serializer.document_type, 'case_study'
  end

  test 'it includes a rendering app' do
    assert_equal(
      serializer.rendering_app,
      Whitehall::RenderingApp::GOVERNMENT_FRONTEND
    )
  end

  test 'it includes a schema name' do
    assert_equal serializer.schema_name, 'case_study'
  end

  test 'it includes a details hash' do
    case_study_details_mock = MiniTest::Mock.new
    case_study_details_mock.expect(:as_json, { details: 'bar' })

    withdrawn_notice_mock = MiniTest::Mock.new
    withdrawn_notice_mock.expect(:as_json, { withdrawn_notice: 'foo' })

    CaseStudyDetailsSerializer.stub(:new, case_study_details_mock) do
      WithdrawnNoticeSerializer.stub(:new, withdrawn_notice_mock) do
        assert_equal(
          serializer.details,
          { details: 'bar', withdrawn_notice: 'foo' }
        )
      end
    end
  end

  test 'it includes a public updated at timestamp' do
    assert_equal serializer.public_updated_at, stubbed_item.public_timestamp
  end
end
