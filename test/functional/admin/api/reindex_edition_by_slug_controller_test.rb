require "test_helper"

class Admin::Api::ReindexEditionBySlugControllerTest < ActionController::TestCase

  def setup
    login_as :user
  end

  test "#create reindexes the all published editions for the given slug" do
    slug_to_reindex = "log-in-register-to-online-services"
    slug_not_to_reindex = "embassy-closure-for-holiday"
    document = create :document, slug: slug_to_reindex
    control_document = create :document, slug: slug_not_to_reindex
    create(:publication, :published, document: control_document)

    list_of_editions_to_reindex = [
      create(:publication, :published, document: document),
      create(:detailed_guide, :published, document: document)
    ]

    list_of_editions_to_reindex.each do |edition_to_reindex|
      Whitehall::SearchIndex.expects(:add).with(edition_to_reindex).once
    end

    post :create,
      { slug: slug_to_reindex },
      { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }
  end
end
