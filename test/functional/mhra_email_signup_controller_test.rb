require "test_helper"

class MhraEmailSignupControllerTest < ActionController::TestCase
  view_test "GET :show renders MHRA email signup page" do
    mhra = create(:organisation,
                  slug: "medicines-and-healthcare-products-regulatory-agency",
                  acronym: "MHRA")

    get :show, params: { organisation_slug: mhra.slug }

    assert_equal @controller.status, 200

    assert_select ".gem-c-title__text", text: I18n.t("mhra_email_signup.title", acronym: mhra.acronym)
    assert_select "h2", text: I18n.t("mhra_email_signup.pages.drug_alerts.title")
    assert_select "h2", text: I18n.t("mhra_email_signup.pages.drug_safety.title")
    assert_select "h2", text: I18n.t("mhra_email_signup.pages.news_and_publications.title")
  end

  test "GET :show renders not found for non-mhra organisation slug" do
    random_org = create(:organisation)
    get :show, params: { organisation_slug: random_org }

    assert_equal @controller.status, 404
  end
end
