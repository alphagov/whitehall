require "test_helper"

class PublicationesquePresenterTest < PresenterTestCase
  test "should use header title for display publication type on consultation" do
    consultation = Consultation.new(opening_on: 1.day.ago, closing_on: 2.days.from_now)
    presenter = PublicationesquePresenter.new(consultation, @view_context)
    assert_equal "Open consultation", presenter.display_type
  end

  test "should return display publication type on publication" do
    publication = Publication.new(publication_type: PublicationType::ImpactAssessment)
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert_equal "Impact assessment", presenter.display_type
  end

  test "should indicate when publication is part of a series" do
    publication = Publication.new
    publication.expects(:part_of_series?).returns(true)
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert presenter.part_of_series?
  end

  test "should return display publication type on statistical data set" do
    publication = StatisticalDataSet.new
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert_equal "Statistical data set", presenter.display_type
  end

  test "should indicate when publication is not part of a series" do
    publication = Publication.new(document_series: [])
    presenter = PublicationesquePresenter.new(publication, @view_context)
    refute presenter.part_of_series?
  end

  test 'should add publication series link to hash' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Defence", organisation_type: stub_record(:organisation_type))
    operational_field = stub_record(:operational_field, name: "Name")
    series = stub_record(:document_series, name: 'SeriesName', organisation: organisation)
    publication = stub_record(:publication,
      document: document,
      public_timestamp: Time.zone.now,
      organisations: [organisation],
      document_series: [series])
    publication.expects(:part_of_series?).returns(true)
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    publication.stubs(:organisations).returns([organisation])
    hash = PublicationesquePresenter.new(publication, @view_context).as_hash
    assert hash[:publication_series] =~ /#{series.name}/
  end
end
