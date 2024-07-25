require "test_helper"
require "rake"

class BulkContentUpdatesRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#remove_links_to_domain" do
    let(:task) { Rake::Task["bulk_content_updates:remove_links_to_domain"] }

    it "removes links to the provided domain when in live mode" do
      article = create(:news_article, {
        body: "Some markdown including [a link to example dot com](https://example.com) and [another link to a different domain](https://www.gov.uk)",
      })

      out, _err = capture_io { task.invoke("example.com", "live") }

      assert_match(/Replacing links in #{Regexp.escape(article.base_path)} \(live\)/, out)
      assert_match(/- will replace '\[a link to example dot com\]\(https:\/\/example.com\)' with 'a link to example dot com'/, out)

      assert_equal "Some markdown including a link to example dot com and [another link to a different domain](https://www.gov.uk)", article.reload.body
    end

    it "reports the links it would remove when in dry-run mode" do
      article = create(:news_article, {
        body: "Some markdown including [a link to example dot com](https://example.com) and [another link to a different domain](https://www.gov.uk)",
      })
      original_body = article.body

      out, _err = capture_io { task.invoke("example.com", "dry-run") }

      assert_match(/Replacing links in #{Regexp.escape(article.base_path)} \(dry-run\)/, out)
      assert_match(/- will replace '\[a link to example dot com\]\(https:\/\/example.com\)' with 'a link to example dot com'/, out)

      assert_equal original_body, article.reload.body
    end

    it "skips documents which match the domain, but don't actually link to it" do
      article = create(:news_article, {
        body: "Some markdown including a reference to example.com but not in a markdown / HTML link",
      })

      original_body = article.body.dup

      out, _err = capture_io { task.invoke("example.com", "live") }

      assert_equal("", out)

      assert_equal original_body, article.reload.body
    end
  end
end
