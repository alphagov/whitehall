require "test_helper"

class Admin::CabinetMinistersHelperTest < ActionView::TestCase
  test "#organisation_ordering_fields returns input for org" do
    org1 = build(:organisation, id: 1, ministerial_ordering: 1, name: "first org")
    org2 = build(:organisation, id: 2, ministerial_ordering: 2, name: "second org")

    html = organisation_ordering_fields([org1, org2])

    assert_select_within_html(html, "div label[for='organisation_#{org1.id}_ordering']", text: "first org")
    assert_select_within_html(html, "div label[for='organisation_#{org2.id}_ordering']", text: "second org")

    assert_select_within_html(html, "div input[name='organisation[#{org1.id}][ordering]']", value: "1")
    assert_select_within_html(html, "div input[name='organisation[#{org2.id}][ordering]']", value: "2")
  end
end
