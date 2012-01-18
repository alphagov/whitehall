Feature: Featuring publications

Background:
  Given I am an editor

Scenario: Featuring a publication
  Given a published publication "My Publication" exists
  When I feature the publication "My Publication"
  Then the publication "My Publication" should be featured on the public publications page

Scenario: Unfeaturing a publication
  Given a featured publication "My Publication" exists
  When I unfeature the publication "My Publication"
  Then the publication "My Publication" should not be featured on the public publications page
