require "test_helper"

class PublishStaticPagesTest < ActiveSupport::TestCase
  test 'sends static pages to rummager' do
    Whitehall::FakeRummageableIndex.any_instance.expects(:add).twice.with(kind_of(Hash))

    PublishStaticPages.new.publish
  end

  test "should include browse page taggings in search data" do
    Whitehall.content_api.expects(:artefacts_tagged_to_mainstream_browse_pages).twice.returns([
      {
        "artefact_slug" => "government/how-government-works",
        "mainstream_browse_page_slugs" => ["some/browse-page"]
      }
    ])

    pages = PublishStaticPages.new.send(:pages)

    assert_equal pages.first[:mainstream_browse_pages], ["some/browse-page"]
  end
end
