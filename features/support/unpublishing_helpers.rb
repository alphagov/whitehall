module UnpublishingHelpers
  def unpublish_edition(edition)
    visit admin_edition_path(edition)
    click_on 'Archive or unpublish'
    choose 'Unpublish: published in error'
    within '#js-published-in-error-form' do
      fill_in 'Public explanation (this is shown on the live site)', with: 'This page should never have existed'
      yield if block_given?
      click_button 'Unpublish'
    end
  end
end

World(UnpublishingHelpers)
