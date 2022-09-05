module UnpublishingHelpers
  def unpublish_edition(edition)
    design_system_layout = @user.has_permission? "Preview design system"

    visit admin_edition_path(edition)
    click_on "Withdraw or unpublish"
    choose "Unpublish: published in error"
    within(design_system_layout ? ".js-unpublish-withdraw-form__published-in-error" : "#js-published-in-error-form") do
      fill_in (design_system_layout ? "Public explanation" : "Public explanation (this is shown on the live site)"), with: "This page should never have existed"
      yield if block_given?
      click_button "Unpublish"
    end
  end
end

World(UnpublishingHelpers)
