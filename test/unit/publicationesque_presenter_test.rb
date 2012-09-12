require "test_helper"

class PublicationesquePresenterTest < ActiveSupport::TestCase
  test "should use header title for display publication type on consultation" do
    consultation = build(:consultation)
    presenter = PublicationesquePresenter.decorate(consultation)
    presenter.stubs(:consultation_header_title).returns("header-title")
    assert_equal "header-title", presenter.display_publication_type
  end

  test "should indicate that a consultation is never part of a series" do
    consultation = build(:consultation)
    presenter = PublicationesquePresenter.decorate(consultation)
    refute presenter.part_of_series?
  end

  test "should return display publication type on publication" do
    publication = build(:publication, publication_type: PublicationType::ImpactAssessment)
    presenter = PublicationesquePresenter.decorate(publication)
    assert_equal "Impact assessment", presenter.display_publication_type
  end

  test "should indicate when publication is part of a series" do
    publication = build(:publication, document_series: build(:document_series))
    presenter = PublicationesquePresenter.decorate(publication)
    assert presenter.part_of_series?
  end

  test "should indicate when publication is not part of a series" do
    publication = build(:publication, document_series: nil)
    presenter = PublicationesquePresenter.decorate(publication)
    refute presenter.part_of_series?
  end
end
