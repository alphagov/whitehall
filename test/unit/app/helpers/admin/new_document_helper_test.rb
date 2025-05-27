require "test_helper"

class Admin::NewDocumentHelperTest < ActionView::TestCase
  test "new_document_type_list returns a list of document type list items" do
    enforcer = Minitest::Mock.new
    NEW_DOCUMENT_LIST.each do |edition_type|
      enforcer.expect :can?, true, [:create]
      edition_type.stubs(:enforcer).returns(enforcer)
    end

    result = new_document_type_list(User.new)

    assert result.is_a?(Array)
    assert result.size == NEW_DOCUMENT_LIST.size
    NEW_DOCUMENT_LIST.each do |edition_type|
      assert_includes result, {
        value: edition_type.name.underscore,
        text: edition_type.name.underscore.humanize,
        bold: true,
        hint_text: hint_text(edition_type.name.underscore.to_sym),
      }
    end
  end

  test "new_document_type_list includes flexible page if flip flop is enabled" do
    enforcer = Minitest::Mock.new
    NEW_DOCUMENT_LIST.each do |edition_type|
      enforcer.expect :can?, true, [:create]
      edition_type.stubs(:enforcer).returns(enforcer)
    end

    test_strategy = Flipflop::FeatureSet.current.test!
    test_strategy.switch!(:flexible_pages, true)
    enforcer.expect :can?, true, [:create]
    FlexiblePage.stubs(:enforcer).returns(enforcer)

    result = new_document_type_list(User.new)

    assert_includes result, {
      value: "flexible_page",
      text: "Flexible page",
      bold: true,
      hint_text: nil,
    }
  end

  def hint_text(new_document_type)
    hint_text = {
      call_for_evidence: "Use this to request people's views when it is not a consultation.",
      case_study: "Use this to share real examples that help users understand a process or an important aspect of government policy covered on GOV.UK.",
      consultation: "Use this for documents requiring a collective agreement across government, and requests for people's view on a question with an outcome.",
      detailed_guide: "Use this to tell users the steps they need to take to complete a clearly defined task. They are usually aimed at specialist or professional audiences.",
      document_collection: "Use this to group related documents on a single page for a specific audience or around a specific theme.",
      fatality_notice: "Use this to provide official confirmation of the death of a member of the armed forces while on deployment. Ministry of Defence only.",
      news_article: "Use this for news story, press release, government response, and world news story.",
      publication: "Use this for standalone government documents, white papers, strategy documents, and reports.",
      speech: "Use this for speeches by ministers or other named spokespeople, and ministerial statements to Parliament.",
      statistical_data_set: "Use this for data that you publish monthly or more often without analysis.",
      worldwide_organisation: "Use this to create a new worldwide organisation page. Do not create a worldwide organisation unless you have permission from your managing editor or GOV.UK department lead.",
      landing_page: "EXPERIMENTAL Use this to create landing pages.",
    }
    hint_text[new_document_type]
  end
end
