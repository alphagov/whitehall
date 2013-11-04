module UnpublishingHelpers
    def unpublish_edition(edition)
      visit admin_edition_path(edition)
      click_button 'Unpublish'
      choose 'Unpublish: published in error'
      fill_in 'Further explanation', with: 'This page should never have existed'
      fill_in 'Alternative URL', with: Whitehall.url_maker.how_government_works_url
      yield if block_given?
      click_button 'Unpublish'
    end
end

World(UnpublishingHelpers)
