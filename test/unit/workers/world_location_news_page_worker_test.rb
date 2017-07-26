require "test_helper"

class WorldLocationNewsPageWorkerTest < ActiveSupport::TestCase
  MockNewsPagePresenter = Struct.new("NewsPagePresenter") do
    def content_id
      "a_guid"
    end

    def content
      Hash.new(title: "title", description: "description")
    end

    def update_type
      "major"
    end

    def content_for_rummager
      Hash.new(title: "title", link: "link")
    end
  end

  test "sends to the publishing api and rummager" do
    wl = create(:world_location, name: "Aardistan", title: "Aardistan and the Uk")

    mock_news_page_presenter = MockNewsPagePresenter.new

    WorldLocationNewsPageWorker.any_instance.stubs(:news_page_presenter).returns(mock_news_page_presenter)

    Whitehall::FakeRummageableIndex.any_instance.expects(:add).at_least_once.with(kind_of(Hash))

    Services.publishing_api.expects(:put_content)
      .with(
        "a_guid",
        Hash.new(title: "title", description: "description", update_type: "major")
    )

    Services.publishing_api.expects(:publish)
      .with(
        "a_guid",
        nil,
        locale: "en"
    )

    WorldLocationNewsPageWorker.new.perform(wl.id)
  end
end
