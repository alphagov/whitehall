require "test_helper"

class AccessAndOpeningTimesFormTest < ActiveSupport::TestCase
  should_not_accept_footnotes_in :body
  should_validate_with_safe_html_validator

  test "#save returns false when invalid" do
    organisation = create(:worldwide_organisation, default_access_and_opening_times: "default")
    access_and_opening_times = AccessAndOpeningTimesForm.new(body: "")

    assert_not access_and_opening_times.save(organisation)
  end

  test "#save assigns `body` to the `access_and_opening_times` of the model" do
    organisation = create(:worldwide_organisation, default_access_and_opening_times: "default")
    access_and_opening_times = AccessAndOpeningTimesForm.new(body: "new access and opening times")

    access_and_opening_times.save(organisation) # rubocop:disable Rails/SaveBang

    assert_equal "new access and opening times", organisation.access_and_opening_times
  end
end
