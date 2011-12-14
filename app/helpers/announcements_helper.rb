module AnnouncementsHelper
  def announcement_group(annoucements, options = {})
    capture do
      annoucements.in_groups_of(options[:groups_of], false) do |announcement_group|
        row = content_tag(:div, class: "group row #{options[:class]} row_#{announcement_row_number}") do
          announcement_group.each do |announcement|
            if announcement.is_a?(NewsArticle)
              concat(render partial: "news_article", locals: { news_article: announcement, display: options[:partial] })
            else
              concat(render partial: "speech", locals: { speech: announcement, display: options[:partial] })
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

end