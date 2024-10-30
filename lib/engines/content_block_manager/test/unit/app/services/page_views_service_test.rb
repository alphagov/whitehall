require "test_helper"
require "google/cloud/bigquery"
require "googleauth"

class ContentBlockManager::PageViewsServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:paths) { %w[foo bar] }
  let(:start_date) { "2024-01-01" }
  let(:end_date) { "2024-01-31" }

  before do
    travel_to Date.parse(end_date)
  end

  describe "ContentBlockManager::PageViewsService::Local" do
    describe "#call" do
      it "returns random results for each path" do
        result = ContentBlockManager::PageViewsService::Local.new(paths:).call

        assert_equal result.count, 2
        assert_equal result.first.path, "foo"
        assert_includes 10_000..2_000_000, result.first.page_views
        assert_equal result.last.path, "bar"
        assert_includes 10_000..2_000_000, result.last.page_views
      end
    end
  end

  describe "ContentBlockManager::PageViewsService::Google" do
    describe "#call" do
      let(:client_email) { "foo@example.com" }
      let(:private_key) { "PRIVATE_KEY" }
      let(:project_id) { "some-project-id" }
      let(:credentials) do
        {
          "client_email" => client_email,
          "private_key" => private_key,
        }
      end

      let(:creds_stub) { stub }
      let(:bigquery_stub) { stub }
      let(:stub_response) do
        [
          {
            cleaned_page_location: "foo",
            unique_pageviews: 123,
          },
          {
            cleaned_page_location: "bar",
            unique_pageviews: 345,
          },
        ]
      end

      def stub_creds
        Google::Auth::ServiceAccountCredentials.stubs(:make_creds).with { |args|
          args[:json_key_io].read == StringIO.new(credentials.to_json).read &&
            args[:scope] == ContentBlockManager::PageViewsService::Google::SCOPE
        }.returns(creds_stub)
      end

      def stub_big_query
        Google::Cloud::Bigquery.stubs(:new).with(
          project_id:,
          credentials: creds_stub,
          ).returns(bigquery_stub)
        bigquery_stub.stubs(:query).with(
          ContentBlockManager::PageViewsService::Google::SQL,
          params: { paths:, start_date:, end_date: },
          ).returns(stub_response)
      end

      before do
        stub_creds
        stub_big_query
      end

      it "returns results from BigQuery" do
        ClimateControl.modify BIGQUERY_PROJECT_ID: project_id, BIGQUERY_CLIENT_EMAIL: client_email, BIGQUERY_PRIVATE_KEY: private_key do
          result = ContentBlockManager::PageViewsService::Google.new(paths:).call

          assert_equal result.count, 2
          assert_equal result.first.path, "foo"
          assert_equal result.first.page_views, 123
          assert_equal result.last.path, "bar"
          assert_equal result.last.page_views, 345
        end
      end
    end
  end
end
