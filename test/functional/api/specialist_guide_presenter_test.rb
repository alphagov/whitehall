require 'test_helper'

class Api::SpecialistGuidesPresenterTest < PresenterTestCase
  setup do
    @guide = stub_document(:specialist_guide)
    @guide.stubs(:organisations).returns([])
    @guide.stubs(:published_related_specialist_guides).returns([])
    @presenter = Api::SpecialistGuidePresenter.decorate(@guide)
  end

  test "json includes document title" do
    @guide.stubs(:title).returns('guide-title')
    assert_equal 'guide-title', @presenter.as_json[:title]
  end

  test "json includes the main guide url as web_url" do
    assert_equal specialist_guide_url(@guide.document), @presenter.as_json[:web_url]
  end

  test "json includes the document body as html" do
    stubs_helper_method(:govspeak_edition_to_html).with(@guide).returns('html-body')
    assert_equal 'html-body', @presenter.as_json[:details][:body]
  end

  test "json includes associated organisation names" do
    organisations = [stub_record(:organisation, organisation_type: nil), stub_record(:organisation, organisation_type: nil)]
    @guide.stubs(:organisations).returns(organisations)
    assert_equal organisations.map(&:name), @presenter.as_json[:details][:organisations]
  end

  test "json includes related specialist guides as related artefacts" do
    related_guide = stub_document(:specialist_guide)
    @guide.stubs(:published_related_specialist_guides).returns([related_guide])
    guide_json = {
      title: related_guide.title,
      web_url: specialist_guide_url(related_guide.document)
    }
    assert_equal [guide_json], @presenter.as_json[:related_artefacts]
  end
end
