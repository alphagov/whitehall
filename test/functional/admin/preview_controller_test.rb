require 'test_helper'

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "renders the body param using govspeak into a document body template" do
    post :preview, body: "# gov speak"
    assert_select "section.document_view .body h1", "gov speak"
  end
  
  test "renders attached images if a document id is passed" do
    document = create(:policy, body: '!!1')
    image = create(:image, document: document)
    
    post :preview, body: document.body, image_ids: document.images.map(&:id)
    assert_select "section.document_view .body figure.image.embedded img[src=?]", %r{#{image.url}}
  end
  
end