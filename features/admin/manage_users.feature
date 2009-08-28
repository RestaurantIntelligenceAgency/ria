Feature: Manage users
  So that staff can fix things
  As an Admin 
  I want to edit user accounts

  Background:
    Given the following confirmed users:
    | username | email       |
    | jimbob   | jim@bob.com |

  Scenario: Editing a username
    Given I am logged in as an admin
    When I go to the admin edit page for "jimbob"
    And I fill in "Username" with "boomoo"
    And I press "Update"
    Then I should be on the admin users landing page
    And I should see "User was successfully updated"
