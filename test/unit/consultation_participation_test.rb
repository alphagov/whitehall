require "test_helper"

class ConsultationParticipationTest < ActiveSupport::TestCase
  test 'should be invalid with malformed link url' do
    participation = build(:consultation_participation, link_url: "invalid-url")
    refute participation.valid?
  end

  test 'should be valid with link url with HTTP protocol' do
    participation = build(:consultation_participation, link_url: "http://example.com")
    assert participation.valid?
  end

  test 'should be valid with link url with HTTPS protocol' do
    participation = build(:consultation_participation, link_url: "https://example.com")
    assert participation.valid?
  end

  test 'should be valid without link url' do
    participation = build(:consultation_participation, link_url: nil)
    assert participation.valid?
  end

  test 'should be invalid with malformed email' do
    participation = build(:consultation_participation, email: "invalid-email")
    refute participation.valid?
  end

  test 'should be valid without an email' do
    participation = build(:consultation_participation, email: nil)
    assert participation.valid?
  end

  test "allows attachment of a consultation response form" do
    form = build(:consultation_response_form)
    assert build(:consultation_participation, consultation_response_form: form).valid?
  end

  test "should allow building of response forms via nested attributes" do
    data_attributes = attributes_for(:consultation_response_form_data)
    form_attributes = attributes_for(:consultation_response_form, consultation_response_form_data_attributes: data_attributes)
    participation = build(:consultation_participation, consultation_response_form_attributes: form_attributes)
    assert participation.valid?
  end

  test "should be invalid if the response form has no title" do
    data_attributes = attributes_for(:consultation_response_form_data)
    form_attributes = attributes_for(:consultation_response_form, title: nil, consultation_response_form_data_attributes: data_attributes)
    participation = build(:consultation_participation, consultation_response_form_attributes: form_attributes)
    refute participation.valid?
  end

  test "should be invalid if the response form's data has no file" do
    data_attributes = attributes_for(:consultation_response_form_data, file: nil)
    form_attributes = attributes_for(:consultation_response_form, consultation_response_form_data_attributes: data_attributes)
    participation = build(:consultation_participation, consultation_response_form_attributes: form_attributes)
    refute participation.valid?
  end

  test "should allow deletion of response form via nested attributes" do
    form = create(:consultation_response_form)
    participation = create(:consultation_participation, consultation_response_form: form)

    participation.update_attributes(consultation_response_form_attributes: {id: form.id, "_destroy" => "1"})

    participation.reload
    refute participation.consultation_response_form.present?
  end

  test "destroys attached form when no editions are associated" do
    participation = create(:consultation_participation)
    form = create(:consultation_response_form, consultation_participation: participation)

    participation.destroy

    assert_raise(ActiveRecord::RecordNotFound) do
      form.reload
    end
  end

  test "does not destroy attached file when if more participations are associated" do
    participation = create(:consultation_participation)
    form = create(:consultation_response_form, consultation_participation: participation)
    other_participation = create(:consultation_participation, consultation_response_form: form)

    participation.destroy

    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      form.reload
    end
  end

  test "can be destroyed without an associated form" do
    participation = create(:consultation_participation, consultation_response_form: nil)
    participation.destroy
    assert_raise(ActiveRecord::RecordNotFound) do
      participation.reload
    end
  end
end
