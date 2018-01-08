require 'test_helper'

class GovspeakContentTest < ActiveSupport::TestCase
  test 'queues a job to compute the HTML on creation' do
    Sidekiq::Testing.fake! do
      govspeak_content = create(:html_attachment).govspeak_content

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id, {"authenticated_user" => nil, "request_id" => nil}], job['args']
    end
  end

  test 'clears computed values and queues a job to re-compute the HTML when the body changes' do
    govspeak_content = create(:html_attachment,
                         body: "## A heading\nSome content").govspeak_content
    compute_govspeak(govspeak_content)

    Sidekiq::Testing.fake! do
      govspeak_content.body = "Updated body"
      govspeak_content.save!

      assert_nil govspeak_content.computed_body_html
      assert_nil govspeak_content.computed_headers_html

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id, {"authenticated_user" => nil, "request_id" => nil}], job['args']
    end
  end

  test "doesn't clear computed values and doesn't queue a job to re-compute the HTML when the body has not changed" do
    govspeak_content = create(:html_attachment,
                         body: "## A heading\nSome content").govspeak_content
    compute_govspeak(govspeak_content)

    Sidekiq::Testing.fake! do
      govspeak_content.save!

      assert govspeak_content.computed_body_html.present?
      assert govspeak_content.computed_headers_html.present?

      assert_empty GovspeakContentWorker.jobs
    end
  end

  test 'clears computed values and queues a job to re-compute the HTML when the numbering scheme changes' do
    govspeak_content = create(:html_attachment,
                        manually_numbered_headings: false,
                        body: "## 1.0 A heading\nSome content").govspeak_content
    compute_govspeak(govspeak_content)

    Sidekiq::Testing.fake! do
      govspeak_content.manually_numbered_headings = true
      govspeak_content.save!

      assert_nil govspeak_content.computed_body_html
      assert_nil govspeak_content.computed_headers_html

      assert job = GovspeakContentWorker.jobs.last
      assert_equal [govspeak_content.id, {"authenticated_user" => nil, "request_id" => nil}], job['args']
    end
  end

  test "#render_govspeak sets computed_headers_html correctly" do
    govspeak_content = create(:html_attachment,
                        manually_numbered_headings: false,
                        body: "## 1.0 A heading\nSome content").govspeak_content
    govspeak_content.render_govspeak!
    expected_headers_html = <<-HTML
      <ol>
        <li>
          <a href="#a-heading">1.0 A heading</a>
        </li>
      </ol>
      HTML
    assert_equivalent_html expected_headers_html, govspeak_content.computed_headers_html
  end

  test "#render_govspeak sets computed_headers_html correctly when manually
    numbered headings is true" do
    govspeak_content = create(:html_attachment,
                        manually_numbered_headings: true,
                        body: "## 1.0 A heading\nSome content").govspeak_content
    govspeak_content.render_govspeak!
    expected_headers_html = <<-HTML
      <ol class="unnumbered">
        <li class="numbered">
          <a href="#a-heading">
            <span class="heading-number">1.0</span>
            A heading
          </a>
        </li>
      </ol>
      HTML
    assert_equivalent_html expected_headers_html, govspeak_content.computed_headers_html
  end

  test "#render_govspeak sets computed_body_html correctly" do
    govspeak_content = create(:html_attachment,
                        manually_numbered_headings: false,
                        body: "## 1.0 A heading\nSome content").govspeak_content
    govspeak_content.render_govspeak!
    expected_body_html = <<-HTML
      <div class="govspeak">
        <h2 id="a-heading">
          <span class="number">1. </span>
          1.0 A heading
        </h2>
        <p>Some content</p>
      </div>
    HTML
    assert_equivalent_html expected_body_html, govspeak_content.computed_body_html
  end

private

  def compute_govspeak(govspeak_content)
    GovspeakContentWorker.new.perform(govspeak_content.id)
    govspeak_content.reload
  end
end
