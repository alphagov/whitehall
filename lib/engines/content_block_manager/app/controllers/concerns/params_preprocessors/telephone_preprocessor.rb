class ParamsPreprocessors::TelephonePreprocessor
  def initialize(params)
    @params = params
  end

  def processed_params
    process!
    params
  end

  def process!
    if params.dig("content_block/edition", "details", "telephones", "opening_hours")
      params["hours_available"] ? format_opening_hours : strip_opening_hours
    end
  end

private

  attr_accessor :params

  def format_opening_hours
    params["content_block/edition"]["details"]["telephones"]["opening_hours"].map! do |hours|
      {
        "day_from" => hours["day_from"],
        "day_to" => hours["day_to"],
        "time_from" => format_time(hours, "time_from"),
        "time_to" => format_time(hours, "time_to"),
        "_destroy" => hours["_destroy"],
      }
    end
  end

  def strip_opening_hours
    params["content_block/edition"]["details"]["telephones"]["opening_hours"] = []
  end

  def format_time(hours, prefix)
    h = hours["#{prefix}(h)"]
    m = hours["#{prefix}(m)"]
    meridian = hours["#{prefix}(meridian)"]
    "#{h}:#{m}#{meridian}"
  end
end
