require "test_helper"

class PublicationesquePresenterTest < PresenterTestCase
  test "should use header title for display publication type on consultation" do
    consultation = Consultation.new(opening_at: 1.day.ago, closing_at: 2.days.from_now)
    presenter = PublicationesquePresenter.new(consultation, @view_context)
    assert_equal "Open consultation", presenter.display_type
  end

  test "should return display publication type on publication" do
    publication = Publication.new(publication_type: PublicationType::ImpactAssessment)
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert_equal "Impact assessment", presenter.display_type
  end

  test "should indicate when publication is part of a published collection" do
    publication = Publication.new
    publication.expects(:part_of_published_collection?).returns(true)
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert presenter.part_of_published_collection?
  end

  test "should return display publication type on statistical data set" do
    publication = StatisticalDataSet.new
    presenter = PublicationesquePresenter.new(publication, @view_context)
    assert_equal "Statistical data set", presenter.display_type
  end

  test 'should add publication collection link to hash' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Defence", organisation_type_key: :ministerial_department)
    operational_field = stub_record(:operational_field, name: "Name")
    collection = stub_record(:document_collection, title: 'SeriesTitle', document: stub_record(:document))
    publication = stub_record(:publication,
      document: document,
      public_timestamp: Time.zone.now,
      attachments: [],
      organisations: [organisation])
    publication.stubs(:published_document_collections).returns([collection])
    publication.expects(:part_of_published_collection?).returns(true)
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    publication.stubs(:organisations).returns([organisation])
    hash = PublicationesquePresenter.new(publication, @view_context).as_hash
    assert hash[:publication_collections] =~ /SeriesTitle/
  end

  test '#time_until_closure should return "Closed" for closed consultations' do
    assert_equal "Closed", PublicationesquePresenter.new(build(:closed_consultation), @view_context).time_until_closure
  end

  test '#time_until_closure should return "Closing today" for consultations closing on the current day' do
    Timecop.freeze("2013-01-01 12:00:00") do
      consultation = build(:consultation, opening_at: "2012-12-01 00:00:00", closing_at: "2013-01-01 18:00:00")
      assert_equal "Closing today", PublicationesquePresenter.new(consultation, @view_context).time_until_closure
    end
  end

  test '#time_until_closure should return "Closes tomorrow" for consultations closing tomorrow' do
    Timecop.freeze("2013-01-01 12:00:00") do
      consultation = build(:consultation, opening_at: "2012-12-01 00:00:00", closing_at: "2013-01-02 00:00:00")
      assert_equal "Closes tomorrow", PublicationesquePresenter.new(consultation, @view_context).time_until_closure
    end
  end

  test '#time_until_closure should return "<n> days left" for consultations closing after tomorrow current day' do
    Timecop.freeze("2013-01-01 12:00:00") do
      consultation = build(:consultation, opening_at: "2012-12-01 00:00:00", closing_at: "2013-01-04 00:00:00")
      assert_equal "3 days left", PublicationesquePresenter.new(consultation, @view_context).time_until_closure
    end
  end
end

