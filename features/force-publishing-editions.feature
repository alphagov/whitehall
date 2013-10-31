Feature: Force Publishing editions

Background:
  Given I am an editor

@not-quite-as-fake-search
Scenario: Force-publishing a submitted edition
  Given I draft a new policy "Ban Beards"
  When I force publish the policy "Ban Beards"
  Then the policy "Ban Beards" should have a force publish reason
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public

Scenario: Retrospective second-pair of eyes
  Given I draft a new policy "Ban Beards"
  And I force publish the policy "Ban Beards"
  When another editor retrospectively approves the "Ban Beards" policy
  Then the "Ban Beards" policy should not be flagged as force-published any more
