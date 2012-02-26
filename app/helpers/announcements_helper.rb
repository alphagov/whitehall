module AnnouncementsHelper
  def announcement_group(annoucements, options = {})
    capture do
      annoucements.in_groups_of(options[:groups_of], false) do |announcement_group|
        row = content_tag(:div, class: ["row", "row_#{announcement_row_number}", options[:class]].compact.join(" ")) do
          cells = announcement_group.map do |announcement|
            content_tag(:div, class: 'g1') do
              if announcement.is_a?(NewsArticle)
                render partial: "announcements/news_article", locals: { news_article: announcement, display: options[:partial] }
              else
                render partial: "announcements/speech", locals: { speech: announcement, display: options[:partial] }
              end
            end
          end
          cells.join("\n").html_safe
        end
        concat row
      end
    end
  end

  def announcement_row_number
    @announcement_row_number ||= 0
    @announcement_row_number += 1
  end

  def announcement_metadata(announcement)
    content_tag :span, class: 'metadata' do
      first_published_at = safe_join(['Posted', time_ago(announcement.first_published_at, class: 'first_published_at')], ' ')
      if announcement.published_at != announcement.first_published_at
        published_at = safe_join(['updated', time_ago(announcement.published_at, class: 'published_at')], ' ')
      end

      safe_join([first_published_at, published_at].compact, ', ')
    end
  end
end