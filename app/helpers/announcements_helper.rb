module AnnouncementsHelper
  def announcement_group(annoucements, options = {})
    capture do
      annoucements.in_groups_of(options[:groups_of], false) do |announcement_group|
        row = content_tag(:div, class: ["row", "row_#{announcement_row_number}", options[:class]].compact.join(" ")) do
          cells = announcement_group.map do |announcement|
            render partial: "announcements/home_article", locals: { item: announcement }
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
