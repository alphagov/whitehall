class GovspeakContentWorkerTest < ActiveSupport::TestCase
  setup do
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
  end

  test "saves generated HTML to the GovspeakContent instance" do
    govspeak_content =  create(:html_attachment,
                          body: example_govspeak).govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_equivalent_html example_govspeak_html,
      govspeak_content.computed_body_html
  end

  test "saves generated HTML with manual numbering" do
    govspeak_content =  create(:html_attachment,
                          body: example_govspeak,
                          manually_numbered_headings: true).govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_equivalent_html example_govspeak_manually_numbered_html,
      govspeak_content.computed_body_html
  end

  test "saves generated HTML with image interpolation" do
    image = create(:image, alt_text: 'Alt')
    publication = create(:publication, images: [image])
    govspeak_content =  create(:html_attachment,
                          attachable: publication,
                          body: example_govspeak_with_image).govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_equivalent_html example_govspeak_with_image_html(image),
      govspeak_content.computed_body_html
  end

  test "saves generated govspeak headers HTML to the GovspeakContent instance" do
    govspeak_content =  create(:html_attachment,
                          body: example_govspeak).govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_equivalent_html example_headers_html,
      govspeak_content.computed_headers_html
  end

  test "handles embedded contacts" do
    contact = create(:contact)

    govspeak_content =  create(:html_attachment,
                          body: "[Contact:#{contact.id}]").govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_select_within_html govspeak_content.computed_body_html,
      "div.contact#contact_#{contact.id}"
  end

  test "saves generated govspeak headers HTML with manual numbering" do
    govspeak_content =  create(:html_attachment,
                          body: example_govspeak,
                          manually_numbered_headings: true).govspeak_content

    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload

    assert_equivalent_html example_manually_numbered_headers_html,
      govspeak_content.computed_headers_html
  end

  test "silently handles non-existant GovspeakContent" do
    GovspeakContentWorker.new.perform(non_existant_id = 123)
  end

private

  def example_govspeak
    "## Heading\nSome content."
  end

  def example_govspeak_with_image
    "## Heading\nSome content.\n\n!!1"
  end

  def example_govspeak_html
    <<-END
      <div class="govspeak">
        <h2 id="heading"><span class="number">1. </span>Heading</h2>
        <p>Some content.</p>
      </div>
    END
  end

  def example_govspeak_manually_numbered_html
    <<-END
      <div class="govspeak">
        <h2 id="heading">Heading</h2>
        <p>Some content.</p>
      </div>
    END
  end

  def example_govspeak_with_image_html(image)
    <<-END
      <div class="govspeak">
        <h2 id="heading"><span class="number">1. </span>Heading</h2>
        <p>Some content.</p>

        <figure class="image embedded">
          <div class="img">
            <img alt="#{image.alt_text}" src="#{Whitehall.asset_root}#{image.url}">
          </div>
        </figure>
      </div>
    END
  end

  def example_headers_html
    <<-END
      <ol>
        <li class=""><a href="#heading">Heading</a></li>
      </ol>
    END
  end

  def example_manually_numbered_headers_html
    <<-END
      <ol class="unnumbered">
        <li class=""><a href="#heading">Heading</a></li>
      </ol>
    END
  end
end
