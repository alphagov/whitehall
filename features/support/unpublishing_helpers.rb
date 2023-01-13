module UnpublishingHelpers
  def unpublish_edition(edition)
    visit admin_edition_path(edition)
    click_on "Withdraw or unpublish"
    choose "Unpublish: published in error"
    within ".js-app-view-unpublish-withdraw-form__published-in-error" do
      fill_in "Public explanation", with: "This page should never have existed"
      yield if block_given?
      click_button "Unpublish"
    end
  end
end

World(UnpublishingHelpers)
