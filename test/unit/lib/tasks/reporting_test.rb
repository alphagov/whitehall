require "test_helper"
require "rake"

class ReportingRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "rake reporting:matching_docs" do
    teardown do
      Rake::Task["reporting:matching_docs"].reenable
    end

    context "for editions" do
      setup do
        @document_1 = create(:published_edition, body: "Some text 1")
        @document_2 = create(:draft_edition, body: "Some text 2")
        @document_3 = create(:published_edition, body: "Some other text 1")
      end

      test "it prints the content IDs of the matching documents from published editions" do
        assert_output(/#{@document_1.document.content_id},#{@document_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the matching documents from draft editions" do
        refute_output(/#{@document_2.document.content_id},#{@document_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from published editions" do
        refute_output(/#{@document_3.document.content_id},#{@document_3.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end

    context "for HTML attachments" do
      setup do
        @html_attachment_1 = create(:html_attachment, body: "Some text on a published edition", attachable: create(:published_edition))
        @html_attachment_2 = create(:html_attachment, body: "Some other text on a published edition", attachable: create(:published_edition))
        @html_attachment_3 = create(:html_attachment, body: "Some text on a draft edition", attachable: create(:draft_edition))
      end

      test "it prints the content IDs of the matching documents from published HTML attachments" do
        assert_output(/#{@html_attachment_1.content_id},#{@html_attachment_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from published HTML attachments" do
        refute_output(/#{@html_attachment_2.content_id},#{@html_attachment_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the matching documents from draft HTML attachments" do
        refute_output(/#{@html_attachment_3.content_id},#{@html_attachment_3.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end

    context "for people" do
      setup do
        @person_1 = create(:person, biography: "Some text")
        @person_2 = create(:person, biography: "Some other text")
      end

      test "it prints the content IDs of the matching documents from people" do
        assert_output(/#{@person_1.content_id},#{@person_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from people" do
        refute_output(/#{@person_2.content_id},#{@person_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end

    context "for policy groups" do
      setup do
        @policy_group_1 = create(:policy_group, description: "Some text")
        @policy_group_2 = create(:policy_group, description: "Some other text")
      end

      test "it prints the content IDs of the matching documents from policy groups" do
        assert_output(/#{@policy_group_1.content_id},#{@policy_group_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from policy groups" do
        refute_output(/#{@policy_group_2.content_id},#{@policy_group_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end

    context "for world location news" do
      setup do
        @world_location_news_1 = create(:world_location_news, mission_statement: "Some text", world_location: create(:world_location))
        @world_location_news_2 = create(:world_location_news, mission_statement: "Some other text", world_location: create(:world_location))
      end

      test "it prints the content IDs of the matching documents from world location news" do
        assert_output(/#{@world_location_news_1.content_id},#{@world_location_news_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from world location news" do
        refute_output(/#{@world_location_news_2.content_id},#{@world_location_news_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end

    context "for worldwide offices" do
      setup do
        @worldwide_office_1 = create(:worldwide_office, access_and_opening_times: "Some text")
        @worldwide_office_2 = create(:worldwide_office, access_and_opening_times: "Some other text")
      end

      test "it prints the content IDs of the matching documents from worldwide offices" do
        assert_output(/#{@worldwide_office_1.content_id},#{@worldwide_office_1.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end

      test "it does not print the content IDs of the non-matching documents from worldwide offices" do
        refute_output(/#{@worldwide_office_2.content_id},#{@worldwide_office_2.base_path}/) { Rake.application.invoke_task "reporting:matching_docs[Some text]" }
      end
    end
  end

  describe "rake tasks for reporting invalid editions" do
    setup do
      Edition.delete_all
      @edition_with_multiple_issues = create(:published_edition, created_at: 1.year.ago)
      @edition_with_multiple_issues.translations.first.update_columns(body: "[Contact:9999999] [and a bad link](http:::::://gov.uk)")
      @edition_with_missing_contact = create(:published_edition, created_at: 1.year.ago)
      @edition_with_missing_contact.translations.first.update_columns(body: "[Contact:9999999]")
      # can't use `create(:withdrawn_edition)` here as it creates an additional edition and throws off the counts
      @edition_with_bad_link_1 = create(:edition, state: "withdrawn", body: "[bad link](http:::::://gov.uk)", created_at: 1.year.ago)
      @edition_with_bad_link_2 = create(:edition, body: "[another bad link](http:::::://gov.uk)", created_at: Time.zone.now)
      @blank_edition = create(:edition, created_at: 1.year.ago)
      @blank_edition.translations.first.update_columns(body: "")

      invalid_editions = [
        @edition_with_multiple_issues,
        @edition_with_missing_contact,
        @edition_with_bad_link_1,
        @edition_with_bad_link_2,
        @blank_edition,
      ]

      invalid_editions.each { |edition| edition.valid?(:publish) }
    end

    describe "rake reporting:invalid_editions" do
      teardown do
        Rake::Task["reporting:invalid_editions"].reenable
      end

      test "it groups and summarises all of the invalid editions" do
        expected_output = <<~OUTPUT
          Found 5 invalid editions. Analysing (this could take a few minutes)...
          All invalid editions (5)
          -------------------------------
          3 editions have the error `Invalid external link structure`. Example edition IDs: #{@edition_with_multiple_issues.id}, #{@edition_with_bad_link_1.id}, #{@edition_with_bad_link_2.id}
          2 editions have the error `Invalid Contact ID`. Example edition IDs: #{@edition_with_multiple_issues.id}, #{@edition_with_missing_contact.id}
          1 editions have the error `Body cannot be blank`. Example edition IDs: #{@blank_edition.id}

          Invalid published editions (2)
          -------------------------------
          2 editions have the error `Invalid Contact ID`. Example edition IDs: #{@edition_with_multiple_issues.id}, #{@edition_with_missing_contact.id}
          1 editions have the error `Invalid external link structure`. Example edition IDs: #{@edition_with_multiple_issues.id}

          Invalid withdrawn editions (1)
          -------------------------------
          1 editions have the error `Invalid external link structure`. Example edition IDs: #{@edition_with_bad_link_1.id}

        OUTPUT

        assert_output(expected_output) do
          Rake.application.invoke_task "reporting:invalid_editions"
        end
      end
    end

    describe "rake reporting:invalid_editions_created_since" do
      teardown do
        Rake::Task["reporting:invalid_editions_created_since"].reenable
      end

      test "it groups and summarises all of the invalid editions created since the given date" do
        expected_output = <<~OUTPUT
          Found 1 invalid editions. Analysing (this could take a few minutes)...
          All invalid editions (1)
          -------------------------------
          1 editions have the error `Invalid external link structure`. Example edition IDs: #{@edition_with_bad_link_2.id}

          Invalid published editions (0)
          -------------------------------

          Invalid withdrawn editions (0)
          -------------------------------

        OUTPUT

        assert_output(expected_output) do
          Rake.application.invoke_task "reporting:invalid_editions_created_since[#{Time.zone.now.strftime('%Y-%m-%d')}]"
        end
      end
    end
  end
end
