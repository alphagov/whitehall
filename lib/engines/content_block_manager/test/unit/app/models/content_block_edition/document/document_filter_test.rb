require "test_helper"

class ContentBlockManager::DocumentFilterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "paginated_documents" do
    let(:document_scope_mock) { mock }

    before do
      ContentBlockManager::ContentBlock::Document
        .expects(:where)
        .with(block_type: ContentBlockManager::ContentBlock::Schema.valid_schemas)
        .returns(document_scope_mock)
      document_scope_mock.expects(:live).returns(document_scope_mock)
      document_scope_mock.expects(:joins).with(:latest_edition).returns(document_scope_mock)
      document_scope_mock.expects(:distinct).returns(document_scope_mock)
      document_scope_mock.expects(:order).with("content_block_editions.updated_at DESC").returns(document_scope_mock)
      document_scope_mock.expects(:per).with(15).returns([])
    end

    describe "when no filters are given" do
      it "returns live documents" do
        document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

        document_scope_mock.expects(:with_keyword).never
        document_scope_mock.expects(:where).never
        document_scope_mock.expects(:with_lead_organisation).never

        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({}).paginated_documents
      end
    end

    describe "when a keyword filter is given" do
      it "returns live documents with keyword" do
        document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

        document_scope_mock.expects(:with_keyword).with("ministry of example").returns(document_scope_mock)
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ keyword: "ministry of example" }).paginated_documents
      end
    end

    describe "when a block type is given" do
      it "returns live documents of the type given" do
        document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

        document_scope_mock.expects(:where).with(block_type: %w[email_address]).returns(document_scope_mock)
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ block_type: %w[email_address] }).paginated_documents
      end
    end

    describe "when a lead organisation id is given" do
      it "returns live documents with lead org given" do
        document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

        document_scope_mock.expects(:with_lead_organisation).with("123").returns(document_scope_mock)
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ lead_organisation: "123" }).paginated_documents
      end
    end

    describe "when block types, keyword and organisation is given" do
      it "returns live documents with the filters given" do
        document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

        document_scope_mock.expects(:with_keyword).with("ministry of example").returns(document_scope_mock)
        document_scope_mock.expects(:where).with(block_type: %w[email_address]).returns(document_scope_mock)
        document_scope_mock.expects(:with_lead_organisation).with("123").returns(document_scope_mock)
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new(
          { block_type: %w[email_address], keyword: "ministry of example", lead_organisation: "123" },
        ).paginated_documents
      end
    end

    describe "when a page is given" do
      it "passes the page to the query" do
        document_scope_mock.expects(:page).with(2).returns(document_scope_mock)
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ page: 2 }).paginated_documents
      end
    end

    describe "last updated dates" do
      describe "when dates are missing" do
        it "does not filter by date if one or more date element is missing" do
          document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

          ContentBlockManager::ContentBlock::Document::DocumentFilter.new(
            {
              last_updated_from: { "3i" => "", "2i" => "2", "1i" => "2025" },
              last_updated_to: { "3i" => "", "2i" => "", "1i" => ""  },
            },
          ).paginated_documents
        end
      end

      describe "when dates are valid" do
        it "filters using last updated from date" do
          document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

          expected_date_time = Time.zone.local(2025, 2, 1)

          document_scope_mock.expects(:from_date).with(expected_date_time).returns(document_scope_mock)
          ContentBlockManager::ContentBlock::Document::DocumentFilter.new(
            {
              last_updated_from: { "3i" => "1", "2i" => "2", "1i" => "2025" },
            },
          ).paginated_documents
        end

        it "filters using last updated to date" do
          document_scope_mock.expects(:page).with(1).returns(document_scope_mock)

          expected_date_time = Time.zone.local(2026, 4, 3).end_of_day

          document_scope_mock.expects(:to_date).with(expected_date_time).returns(document_scope_mock)
          ContentBlockManager::ContentBlock::Document::DocumentFilter.new(
            {
              last_updated_to: { "3i" => "3", "2i" => "4", "1i" => "2026" },
            },
          ).paginated_documents
        end
      end
    end
  end

  describe "date validation" do
    let(:document_filter) { ContentBlockManager::ContentBlock::Document::DocumentFilter.new(filters) }

    %i[last_updated_from last_updated_to].each do |attribute|
      describe "when #{attribute} contains non-date values" do
        let(:filters) do
          {
            "#{attribute}": { "3i" => "ddddd", "2i" => "ffsdfsd", "1i" => "ffff" },
          }
        end

        it "returns invalid" do
          assert_not document_filter.valid?
        end

        it "returns errors" do
          errors = document_filter.errors
          assert_equal errors.count, 1
          assert_equal errors.first.attribute, attribute.to_s
          assert_equal errors.first.full_message, I18n.t("content_block_document.index.errors.date.invalid", attribute: attribute.to_s.humanize)
        end
      end

      describe "when #{attribute} contains has missing values" do
        let(:filters) do
          {
            "#{attribute}": { "3i" => "", "2i" => "3", "1i" => "2026" },
          }
        end

        it "returns invalid" do
          assert_not document_filter.valid?
        end

        it "returns errors" do
          errors = document_filter.errors
          assert_equal errors.count, 1
          assert_equal errors.first.attribute, attribute.to_s
          assert_equal errors.first.full_message, I18n.t("content_block_document.index.errors.date.invalid", attribute: attribute.to_s.humanize)
        end
      end
    end

    describe "when last_updated_from is after last_updated_to" do
      let(:filters) do
        {
          last_updated_from: { "3i" => "3", "2i" => "2", "1i" => "2026" },
          last_updated_to: { "3i" => "1", "2i" => "1", "1i" => "2025" },
        }
      end

      it "returns invalid" do
        assert_not document_filter.valid?
      end

      it "returns errors" do
        errors = document_filter.errors
        assert_equal errors.count, 1
        assert_equal errors.first.attribute, "last_updated_from"
        assert_equal errors.first.full_message, I18n.t("content_block_document.index.errors.date.range.invalid")
      end
    end
  end
end
