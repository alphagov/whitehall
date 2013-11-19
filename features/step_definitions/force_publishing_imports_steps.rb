Given /^I have imported a file that failed$/ do
  organisation = create(:organisation)
  data = %Q{
old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1
http://example.com/1,title,summary,body,weird organisation,,weird type,,14-Dec-2011,,,,,,,,,
  }.strip
  @force_publish_import = import_data_as_document_type_for_organisation(data, 'Publication', organisation)
end

Given /^I have imported a file that succeeded$/ do
  organisation = create(:organisation)
  topic = create(:topic)
  data = %Q{
old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,html_title,html_body,attachment_1_url,attachment_1_title,country_1,topic_1
http://example.com/1,title-1,a-summary,a-body,,,,,14-Dec-2011,,,,,,,html-title-A,html-body-A,,,,#{topic.slug}
http://example.com/2,title-2,a-summary,a-body,,,,,14-Dec-2011,,,,,,,html-title-B,html-body-B,,,,#{topic.slug}
    }.strip
  @force_publish_import = import_data_as_document_type_for_organisation(data, 'Publication', organisation)
end

When /^I speed tag some of the documents and make them draft$/ do
  speed_tag_publication('title-1')
  convert_to_draft('title-1')
end

When /^I speed tag all of the documents and make them draft$/ do
  speed_tag_publication('title-1')
  convert_to_draft('title-1')
  speed_tag_publication('title-2')
  convert_to_draft('title-2')
end

When /^I force publish the import$/ do
  visit admin_imports_path

  within("tr#import_#{@force_publish_import.id}") do
    click_on 'Force publish'
  end
  assert page.has_css?('.flash.notice', text: "Import #{@force_publish_import.id} queued for force publishing!")
end

When /^the force publish import background processor runs$/ do
  make_sure_gds_team_user_exists
  run_last_force_publishing_attempt(@force_publish_import)
end

Then /^I cannot force publish the import(?: again)?$/ do
  visit admin_imports_path

  within("tr#import_#{@force_publish_import.id}") do
    assert page.has_no_button?('Force publish')
  end
end

Then /^I can see the log output of the force publish for my import$/ do
  visit admin_imports_path
  within("tr#import_#{@force_publish_import.id}") do
    click_on 'View log for most recent force publication attempt'
  end

  within '.log' do
    # has_content? would be nicer, but I think the fact that it's a
    # <pre> tag and thus whitespace is important is messing with things
    # better to be explicit
    assert page.has_xpath?("./pre[normalize-space(.) = normalize-space('#{@force_publish_import.most_recent_force_publication_attempt.log}')]", %Q{should have log!})
  end
end

Then /^my imported documents are published$/ do
  visit public_document_path(Edition.find_by_title('title-1'))
  assert page.has_css?('h1', 'title-1')

  visit public_document_path(Edition.find_by_title('title-2'))
  assert page.has_css?('h1', 'title-2')
end
