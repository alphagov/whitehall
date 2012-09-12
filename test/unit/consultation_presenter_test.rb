require "test_helper"

class ConsultationPresenterTest < ActiveSupport::TestCase
  test "should use header title for publication type" do
    consultation = build(:consultation)
    presenter = ConsultationPresenter.decorate(consultation)
    presenter.stubs(:consultation_header_title).returns("header-title")
    assert_equal "header-title", presenter.display_publication_type
  end

  test "should never be part of a series" do
    consultation = build(:consultation)
    presenter = ConsultationPresenter.decorate(consultation)
    refute presenter.part_of_series?
  end
end
