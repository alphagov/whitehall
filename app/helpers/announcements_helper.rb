module AnnouncementsHelper
  def announcement_group(annoucements, options = {})
    capture do
      annoucements.in_groups_of(options[:groups_of], false) do |announcement_group|
        row = content_tag(:div, class: ["row", "row_#{announcement_row_number}", options[:class]].compact.join(" ")) do
          announcement_group.each do |announcement|
            if announcement.is_a?(NewsArticle)
              concat(render partial: "announcements/news_article", locals: { news_article: announcement, display: options[:partial] })
            else
              concat(render partial: "announcements/speech", locals: { speech: announcement, display: options[:partial] })
            end
          end
        end
        concat row
      end
    end
  end

  def announcement_row_number
    @announcement_row_number ||= 0
    @announcement_row_number += 1
  end

  def announcement_metadata(announcement, first_published_verb)
    content_tag :span, class: 'metadata' do
      safe_join [first_published_verb, time_ago(announcement.first_published_at, class: 'first_published_at')], ' '
    end
  end
end