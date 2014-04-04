require 'test_helper'

class ClassificationFeaturingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should build an image using nested attributes" do
    classification_featuring = build(:classification_featuring)
    classification_featuring.image_attributes = {
      file: fixture_file_upload('minister-of-funk.960x640.jpg')
    }
    classification_featuring.save!

    classification_featuring = ClassificationFeaturing.find(classification_featuring.id)

    assert_match /minister-of-funk/, classification_featuring.image.file.url
  end

  test "should require offsite_title, offsite_summary and offsite_url if edition is nil" do
    assert build(:classification_featuring, edition: build(:edition),
                                            offsite_title: nil,
                                            offsite_summary: nil,
                                            offsite_url: nil).valid?

    assert build(:classification_featuring, edition: nil,
                                            offsite_title: 'title',
                                            offsite_summary: 'summary',
                                            offsite_url: 'http://www.example.com').valid?

    invalid_featuring = build(:classification_featuring, edition: nil,
                                                         offsite_title: nil,
                                                         offsite_summary: nil,
                                                         offsite_url: nil)
    refute invalid_featuring.valid?
    assert invalid_featuring.errors.keys.include?(:offsite_title)
    assert invalid_featuring.errors.keys.include?(:offsite_summary)
    assert invalid_featuring.errors.keys.include?(:offsite_url)
  end

  test "should be invalid with a bad offsite_url" do
    assert build(:offsite_classification_featuring, offsite_url: "http://www.valid.url.com").valid?
    refute build(:offsite_classification_featuring, offsite_url: "url.without.protocol.com").valid?
    refute build(:offsite_classification_featuring, offsite_url: "ftp://silly.protocol.com").valid?
  end

  test "#title returns offsite_title or the edition's title" do
    assert_equal "Some title", build(:offsite_classification_featuring, offsite_title: "Some title").title
    assert_equal "Some other title", build(:classification_featuring, edition: build(:edition, title: "Some other title")).title
  end

  test "#summary returns offsite_summary or the edition's summary" do
    assert_equal "Some summary", build(:offsite_classification_featuring, offsite_summary: "Some summary").summary
    assert_equal "Some other summary", build(:classification_featuring, edition: build(:edition, summary: "Some other summary")).summary
  end

  test "#url returns offsite_url or the edition url" do
    assert_equal "http://www.example.com/some-thing", build(:offsite_classification_featuring, offsite_url: "http://www.example.com/some-thing").url

    edition = create(:published_publication)
    assert_equal Whitehall::url_maker.publication_path(edition.document), build(:classification_featuring, edition: edition).url
  end
end
