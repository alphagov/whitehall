minister_reshuffle = SitewideSetting.new(
  key: :minister_reshuffle_mode,
  on: false,
  description: "This setting enables you to turn on or off reshuffle mode. During a reshuffle, the ministers count on the[how government works](http://www.gov.uk/government/how-government-works)
  will be hidden, and the govspeak text that has been entered in the govspeak field for this setting will be displayed in a banner
  on the [ministers](http://www.gov.uk/government/ministers) page",
  govspeak: "Some ministerial roles and responsibilities are [changing at the moment](http://example.com) so the information here may change"
)
minister_reshuffle.save
