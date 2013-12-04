# The precision with which scheduled publishing can be controlled
SCHEDULED_PUBLISHING_PRECISION_IN_MINUTES = 15;
SCHEDULED_PUBLISHING_LOGGER = LogStashLogger.new(
  "#{Rails.root}/log/#{Rails.env}_scheduled_publishing.json.log",
  progname: "Whitehall scheduled publishing",
  default_tags: ["scheduled_publisher"]
)
