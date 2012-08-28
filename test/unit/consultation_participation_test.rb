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
end
