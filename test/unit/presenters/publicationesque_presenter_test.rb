require "test_helper"

class PublicationesquePresenterTest < PresenterTestCase
  test "should use header title for display publication type on consultation" do
    consultation = Consultation.new(opening_on: 1.day.ago, closing_on: 2.days.from_now)
    presenter = PublicationesquePresenter.decorate(consultation)
    assert_equal "Open consultation", presenter.display_type
  end

  test "should indicate that a consultation is never part of a series" do
    consultation = Consultation.new
    presenter = PublicationesquePresenter.decorate(consultation)
    refute presenter.part_of_series?
  end

  test "should return display publication type on publication" do
    publication = Publication.new(publication_type: PublicationType::ImpactAssessment)
    presenter = PublicationesquePresenter.decorate(publication)
    assert_equal "Impact assessment", presenter.display_type
  end

  test "should indicate when publication is part of a series" do
    publication = Publication.new(document_series: [DocumentSeries.new])
    presenter = PublicationesquePresenter.decorate(publication)
    assert presenter.part_of_series?
  end

  test "should return display publication type on statistical data set" do
    publication = StatisticalDataSet.new
    presenter = PublicationesquePresenter.decorate(publication)
    assert_equal "Statistical data set", presenter.display_type
  end

  test "should indicate when publication is not part of a series" do
    publication = Publication.new(document_series: [])
    presenter = PublicationesquePresenter.decorate(publication)
    refute presenter.part_of_series?
  end
end
