module AnnouncementsHelper
  def announcement_group(annoucements, options = {})
    capture do
      annoucements.in_groups_of(options[:groups_of], false) do |announcement_group|
        row = content_tag(:div, class: ["row", "row_#{announcement_row_number}", options[:class]].compact.join(" ")) do
          cells = announcement_group.map do |announcement|
            if announcement.is_a?(NewsArticle)
              render partial: "announcements/news_article", locals: { news_article: announcement, display: options[:partial] }
            else
              render partial: "announcements/speech", locals: { speech: announcement, display: options[:partial] }
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
end
