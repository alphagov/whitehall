require "test_helper"

class PublishingApi::PersonPresenterTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def present(...)
    PublishingApi::PersonPresenter.new(...)
  end

  test "presents a Person ready for adding to the publishing API" do
    person = create(
      :person,
      title: "Sir",
      forename: "Winston",
      surname: "Churchill",
      letters: "PM",
      privy_counsellor: true,
      image: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
      biography: "Sir Winston Churchill was a Prime Minister.",
    )

    public_path = Whitehall.url_maker.person_path(person)

    expected_hash = {
      base_path: public_path,
      title: "The Rt Hon Sir Winston Churchill PM",
      description: "Sir Winston Churchill was a Prime Minister.",
      schema_name: "person",
      document_type: "person",
      locale: "en",
      publishing_app: "whitehall",
      rendering_app: "collections",
      public_updated_at: person.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        full_name: "Sir Winston Churchill PM",
        privy_counsellor: true,
        image: {
          url: person.image_url(:s465),
          alt_text: "The Rt Hon Sir Winston Churchill PM",
        },
        body: [
          {
            content_type: "text/govspeak",
            content: "Sir Winston Churchill was a Prime Minister.",
          },
        ],
      },
      update_type: "major",
    }

    presented_item = present(person.reload)

    assert_equal expected_hash, presented_item.content
    assert_equal presented_item.links, {}
    assert_equal "major", presented_item.update_type
    assert_equal person.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "person")
  end

  test "accepts people without an image" do
    person = create(
      :person,
      title: "Sir",
      forename: "Winston",
      surname: "Churchill",
      letters: "PM",
      privy_counsellor: true,
    )

    presented_item = present(person)

    assert_valid_against_publisher_schema(presented_item.content, "person")
  end
end
