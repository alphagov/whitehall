require 'test_helper'
require 'rake'

class AddNonWhitehallLinkToGroupTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/document_collection'
    Rake::Task.define_task(:environment)
    Rake::Task['document_collection:add_non_whitehall_link_to_group'].reenable
  end

  test 'it should add a non-whitehall link to a group' do
    content_id = SecureRandom.uuid
    group = create(:document_collection_group, heading: 'Foo bar')
    stub_publishing_api_has_item(content_id: content_id,
                                 title: 'Vat Rates',
                                 base_path: '/vat-rates',
                                 publishing_app: 'content-publisher')

    Rake.application.invoke_task "document_collection:add_non_whitehall_link_to_group[#{content_id}, #{group.id}]"

    assert_equal 1, group.non_whitehall_links.count
    non_whitehall_link = group.non_whitehall_links.first
    assert_equal [content_id, 'Vat Rates', '/vat-rates', 'content-publisher'],
                 non_whitehall_link.as_json.values_at("content_id", "title", "base_path", "publishing_app")
  end
end
