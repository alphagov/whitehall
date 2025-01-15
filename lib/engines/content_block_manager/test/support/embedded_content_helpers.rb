class ActionDispatch::IntegrationTest
  def self.it_returns_embedded_content(&block)
    let(:host_content_items) do
      10.times.map do |i|
        {
          "title" => "Content #{i}",
          "document_type" => "document",
          "base_path" => "/",
          "content_id" => SecureRandom.uuid,
          "last_edited_by_editor_id" => SecureRandom.uuid,
          "last_edited_at" => 2.days.ago.to_s,
          "host_content_id" => "abc12345",
          "primary_publishing_organisation" => {
            "content_id" => SecureRandom.uuid,
            "title" => "Organisation #{i}",
            "base_path" => "/organisation/#{i}",
          },
        }
      end
    end

    let(:host_content_item_users) { build_list(:signon_user, 10) }

    before do
      stub_publishing_api_has_embedded_content_for_any_content_id(
        results: host_content_items,
        total: host_content_items.length,
        order: ContentBlockManager::HostContentItem::DEFAULT_ORDER,
      )

      ContentBlockManager::SignonUser.stubs(:with_uuids).with(host_content_items.map { |i| i["last_edited_by_editor_id"] }).returns(host_content_item_users)
    end

    it "returns host content items" do
      instance_exec(&block)

      host_content_items.each do |content_item|
        assert_text content_item["title"]
      end
    end

    it "supports pagination" do
      pages = []
      3.times do |i|
        pages << host_content_items.map { |item| item.merge("title" => "#{item['title']} - Page #{i}") }
      end

      total = pages.length + host_content_items.length

      stub_publishing_api_has_embedded_content_for_any_content_id(
        results: host_content_items,
        total:,
        total_pages: 4,
        order: ContentBlockManager::HostContentItem::DEFAULT_ORDER,
      )

      pages.each.with_index(2) do |page, i|
        stub_publishing_api_has_embedded_content_for_any_content_id(
          results: page,
          total:,
          total_pages: 4,
          order: ContentBlockManager::HostContentItem::DEFAULT_ORDER,
          page_number: i.to_s,
        )
      end

      instance_exec(&block)
      click_on "Next page"

      pages.each do |page|
        page.each do |item|
          assert_text item["title"]
        end

        click_on "Next page" unless page == pages.last
      end
    end

    it "supports sorting" do
      sorted_by_asc = {}
      sorted_by_desc = {}
      sort_fields = %w[title document_type unique_pageviews primary_publishing_organisation_title last_edited_at]

      sort_fields.each do |key|
        sorted_by_asc[key] = host_content_items.map { |item| item.merge("title" => "#{item['title']} - Sorted by #{key} asc") }
        sorted_by_desc[key] = host_content_items.map { |item| item.merge("title" => "#{item['title']} - Sorted by #{key} desc") }
      end

      sorted_by_asc.each do |key, items|
        stub_publishing_api_has_embedded_content_for_any_content_id(
          results: items,
          total: items.count,
          order: key,
        )
      end

      sorted_by_desc.each do |key, items|
        stub_publishing_api_has_embedded_content_for_any_content_id(
          results: items,
          total: items.count,
          order: "-#{key}",
        )
      end

      should_be_sorted_by = proc do |field, order|
        hash_to_match = order == :asc ? sorted_by_asc : sorted_by_desc
        hash_to_match[field].each do |item|
          assert_text item["title"]
        end
      end

      instance_exec(&block)

      initial_sort = sort_fields.delete("unique_pageviews")

      should_be_sorted_by.call(initial_sort, :desc)

      find("a[href*='order=#{initial_sort}']").click
      should_be_sorted_by.call(initial_sort, :asc)

      sort_fields.each do |field|
        within ".app-c-host-editions-table" do
          find("a[href*='order=#{field}']").click
          should_be_sorted_by.call(field, :asc)

          find("a[href*='order=-#{field}']").click
          should_be_sorted_by.call(field, :desc)
        end
      end
    end
  end
end
