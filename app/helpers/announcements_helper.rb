module AnnouncementsHelper
  def announcement_row_number
    @announcement_row_number ||= 0
    @announcement_row_number += 1
  end
end
