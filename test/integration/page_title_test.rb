require "test_helper"

class PageTitleTest < ActiveSupport::TestCase

  EXCLUDED_TEMPLATES = %w(
    admin/about_pages/edit.html.erb
    admin/about_pages/new.html.erb
    admin/edition_audit_trail/index.html.erb
    admin/edition_workflow/force_publish.html.erb
    admin/preview/preview.html.erb
    layouts/admin.html.erb
    layouts/detailed-guidance.html.erb
    layouts/frontend.html.erb
    layouts/home.html.erb
    layouts/html-publication.html.erb
  ).map do |f|
    File.expand_path(Rails.root + "app/views/" + f )
  end

  def test_every_page_sets_a_title
    tested_templates.each do |template|
      assert_template_sets_page_title_or_uses_page_title_partial(template)
    end
  end

  def test_every_page_title_partial_sets_a_title
    Dir[Rails.root + "app/views/**/_page_title.html.erb"].each do |template|
      assert_template_sets_page_title(template)
    end
  end

  private

  def tested_templates
    Dir[Rails.root + "app/views/**/*.html.erb"].reject do |template|
      is_partial?(template) || is_excluded?(template)
    end
  end

  def is_partial?(template)
    File.basename(template) =~ /^_/
  end

  def is_excluded?(template)
    EXCLUDED_TEMPLATES.include?(template)
  end

  def assert_template_sets_page_title(template)
    assert_match /<% page_title /, File.read(template),
                 "could not locate setting of page title in #{template}"
  end

  def assert_template_sets_page_title_or_uses_page_title_partial(template)
    assert_match /<% page_title |<%= render partial: "page_title"/, File.read(template),
                 "could not locate setting of page title in #{template}"
  end
end
