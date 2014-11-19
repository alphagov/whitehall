require 'test_helper'

module Whitehall
  class OrganisationSlugChangerTest < ActiveSupport::TestCase
    setup do
      @router = stub("router", add_redirect_route: nil)
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
      @router.expects(:add_redirect_route).with(
        "/government/organisations/#{@organisation.slug}",
        "exact",
        "/government/organisations/#{@new_slug}"
      )
      @slug_changer.call
    end

    test 're-registers in search any published editions associated with the organisation' do
      edition = create(:published_publication, organisations: [@organisation])

      indexer = mock("indexer")
      indexer.expects(:index!)
      ServiceListeners::SearchIndexer.expects(:new).with(edition).returns(indexer)

      @slug_changer.call
    end
  end
end
