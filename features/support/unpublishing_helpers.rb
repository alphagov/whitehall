module UnpublishingHelpers
    def unpublish_edition(edition)
      visit admin_edition_path(edition)
      click_button 'Archive or unpublish'
      choose 'Unpublish: published in error'
      fill_in 'Public explanation (this is shown on the live site)', with: 'This page should never have existed'
      fill_in 'Alternative URL', with: Whitehall.url_maker.how_government_works_url
      yield if block_given?
      click_button 'Unpublish'
    end
end

World(UnpublishingHelpers)
