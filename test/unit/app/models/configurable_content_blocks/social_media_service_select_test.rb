require "test_helper"

class ConfigurableContentBlocks::SocialMediaServiceSelectRenderingTest < ActionView::TestCase
  setup do
    @schema = {
      "test_attribute" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "block" => "social_media_service_select",
      },
    }
    @path = Path.new(%w[test_attribute])
  end

  test "it renders a select with all of the SocialMediaService options" do
    services = create_list(:social_media_service, 3)
    block = ConfigurableContentBlocks::SocialMediaServiceSelect.new

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    services.each do |service|
      assert_dom "option", text: service.name
    end
  end

  test "it renders a select with the selected social media service" do
    services = create_list(:social_media_service, 3)
    block = ConfigurableContentBlocks::SocialMediaServiceSelect.new

    render block, {
      schema: @schema["test_attribute"],
      content: services.last.id,
      path: @path,
    }

    assert_dom "select[name='edition[block_content][test_attribute]']"
    assert_dom "option[selected]", text: services.last.name
    services.each do |service|
      assert_dom "option", text: service.name
    end
  end

  test "it uses the translated content value when provided" do
    services = create_list(:social_media_service, 3)
    block = ConfigurableContentBlocks::SocialMediaServiceSelect.new

    render block, {
      schema: @schema["test_attribute"],
      content: nil,
      translated_content: services.first.id,
      path: @path,
    }

    assert_dom "select[name=?]", "edition[block_content][test_attribute]"
    assert_dom "option[selected][value=#{services.first.id}]", text: services.first.name
  end
end
