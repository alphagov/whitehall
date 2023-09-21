module DatetimeFieldHelper
  def fill_in_date_and_time_field(date)
    if date.is_a? String
      date = Time.zone.parse(date)
    end

    fill_in_date_fields(date)

    select date.strftime("%H"), from: "Hour"
    select date.strftime("%M"), from: "Minute"
  end

  def fill_in_date_fields(date)
    if date.is_a? String
      date = Time.zone.parse(date)
    end

    fill_in "Year", with: date.year
    fill_in "Month", with: date.month
    fill_in "Day", with: date.day
  end
end
World(DatetimeFieldHelper)
