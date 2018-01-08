require 'test_helper'

module Whitehall
  class OrganisationSlugChangerTest < ActiveSupport::TestCase
    setup do
      @router = stub("router", add_redirect_route: nil, commit_routes: nil)
      @organisation = create(:organisation)
      @organisation.stubs(:remove_from_search_index)
      @new_slug = 'new-slug'
      @slug_changer = OrganisationSlugChanger.new(@organisation, @new_slug, router: @router)
      ServiceListeners::SearchIndexer.any_instance.stubs(:index!)
    end

    test 'it removes the org from search index' do
      @organisation.expects(:remove_from_search_index)

      @slug_changer.call
    end

    test 'changes the org slug' do
      @slug_changer.call

      assert_equal @new_slug, @organisation.reload.slug
    end

    test 'changes org slugs of any users' do
      user = create(:user, organisation: @organisation)

      @slug_changer.call

      assert_equal @new_slug, user.reload.organisation_slug
    end

    test 'adds to search index' do
      @organisation.expects(:update_in_search_index)

      @slug_changer.call
    end

    test 'adds redirect route' do
      order = sequence('order')

      @router.expects(:add_redirect_route).with(
        "/government/organisations/#{@organisation.slug}",
        "exact",
        "/government/organisations/#{@new_slug}"
      ).in_sequence(order)
      @router.expects(:commit_routes).in_sequence(order)

      @slug_changer.call
    end

    test 'adds redirect route for all published CIPs' do
      @router.unstub(:add_redirect_route) # Necessary otherwise the .never assertion below would never fail.
      @router.stubs(:add_redirect_route).with("/government/organisations/#{@organisation.slug}", any_parameters)

      about = create(:about_corporate_information_page, organisation: @organisation)
      cip1 = create(:published_corporate_information_page, organisation: @organisation,
                    corporate_information_page_type_id: CorporateInformationPageType::PublicationScheme.id)
      cip2 = create(:published_corporate_information_page, organisation: @organisation,
                    corporate_information_page_type_id: CorporateInformationPageType::ComplaintsProcedure.id)
      draft = create(:corporate_information_page, organisation: @organisation,
                    corporate_information_page_type_id: CorporateInformationPageType::Research.id)

      @router
        .expects(:add_redirect_route)
        .with(
          "/government/organisations/#{@organisation.slug}/about",
          "exact",
          "/government/organisations/#{@new_slug}/about"
        )

      @router
        .expects(:add_redirect_route)
        .with(
          "/government/organisations/#{@organisation.slug}/about/#{cip1.slug}",
          "exact",
          "/government/organisations/#{@new_slug}/about/#{cip1.slug}"
        )

      @router
        .expects(:add_redirect_route)
        .with(
          "/government/organisations/#{@organisation.slug}/about/#{cip2.slug}",
          "exact",
          "/government/organisations/#{@new_slug}/about/#{cip2.slug}"
        )

      @router
        .expects(:add_redirect_route)
        .with("/government/organisations/#{@organisation.slug}/about/#{draft.slug}", any_parameters)
        .never

      @slug_changer.call
    end

    test 're-registers in search any published editions associated with the organisation' do
      edition = create(:published_publication, organisations: [@organisation])

      indexer = mock("indexer")
      indexer.expects(:index!)
      ServiceListeners::SearchIndexer.expects(:new).with(edition).returns(indexer)

      @slug_changer.call
    end

    test 're-registers in search any statistics announcements with published publications associated with the organisation' do
      statistics_announcement = create(:statistics_announcement, organisations: [@organisation])

      indexer = mock("indexer")
      indexer.expects(:index!)
      ServiceListeners::SearchIndexer.expects(:new).with(statistics_announcement).returns(indexer)

      @slug_changer.call
    end
  end
end
