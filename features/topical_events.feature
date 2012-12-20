Feature: As an editor
I want to be able to create and publish topical events
So that I can communicate about them

Background:
  Given I am an editor

Scenario: Adding a new topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  Then I should see the topical event "Moustache Growing Convention" in the admin interface
  And I should see the topical event "Moustache Growing Convention" on the frontend

# Scenario: Associating policies with topical events
#   Given a topical event "Moustache Growing Convention" exists
#   And the draft policy "Hirsuitness" exists
#   When I associate the policy "Hirsuitness" with the topical event "Moustache Growing Convention"
#   And publish the policy "Hirsuitness"
#   Then I should see the policy "Hirsuitness" on the topical event "G8 Summit"
#