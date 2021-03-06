@profile
Feature: Update information
  So that I can change my twitter account, my name, or other details about my account,
  As a SF member,
  I should be able to update my account profile.

  Scenario: Update my username
    Given the following user records:
      | username | password |
      | lestor   | secret   |
    And I am logged in as "lestor" with password "secret"
    When I go to the edit page for "lestor"
    And I follow "Account" within "#profile-options"
    And I fill in "Username" with "leslie"
    And I press "Save User Details"
    Then I should see "Successfully updated your profile"

  Scenario: Updating password
    Given the following user records:
      | username | password |
      | manny    | secret   |
    And I am logged in as "manny" with password "secret"
    When I go to the edit page for "manny"
    And I follow "Account" within "#profile-options"
    And I fill in "Password" with "betterpassword"
    And I fill in "Password confirmation" with "betterpassword"
    And I press "Save User Details"
    Then I should see "Successfully updated your profile"

    Given I am not logged in
    When I am on the login page
    And I fill in "Username" with "manny"
    And I fill in "Password" with "betterpassword"
    And I press "Login"
    Then I should see "You are now logged in"

  Scenario: Require matching password/confirmation to update
    Given the following user records:
      | username | password |
      | horatio  | secret   |
    And I am logged in as "horatio" with password "secret"
    When I go to the edit page for "horatio"
    And I follow "Account" within "#profile-options"
    And I fill in "Password" with "betterpassword"
    And I fill in "Password confirmation" with "better"
    And I press "Save User Details"
    Then I should see "doesn't match confirmation"

@twitter @javascript
  Scenario: Removing Twitter
    Given the following confirmed, twitter-authorized users:
    | username | password |
    | sammy    | secret   |
    And I am logged in as "sammy" with password "secret"
    When I follow "edit my profile"
    And I follow "Account" within "#profile-options"
    And I follow "Disconnect Twitter"
    Then I should see "Your Twitter account is no longer connected to your SpoonFeed account"
    And "sammy" should not have Twitter linked to his account
    And I should not see "Remove Twitter Information"


  Scenario: Users cannot normally edit other users' accounts
    Given the following confirmed, twitter-authorized users:
    | username | password |
    | angel    | secret   |
    | devil    | demon    |
    And I am logged in as "devil" with password "demon"
    When I go to the edit page for "angel"
    Then I should see "You are not authorized to access this page."
    And I should be on the homepage

  Scenario: A user can set other users who are allowed to edit their account
    Given the following user records:
      | username  | password | name         |
      | horatio   | secret   | Horatio T.   |
      | publicist | secret   | My Publicist |
    And I am logged in as "publicist" with password "secret"
    And I am not logged in
    And I am logged in as "horatio" with password "secret"
    When I go to the edit page for "horatio"
    And I follow "Account" within "#profile-options"
    And I fill in "Allow another user to edit your account?" with "My Publicist"
    And I press "Save Editing Preferences"
    Then I should see "Successfully updated your profile"

    Given I am logged in as "publicist"
    When I go to the edit page for "horatio"
    Then I should see "Edit Profile"

  Scenario: A user can set another user who will receive email messages on their behalf
	Given the following user records:
      | username  | password | name         |
      | horatio   | secret   | Horatio T.   |
    And I am logged in as "horatio" with password "secret"
    When I go to the edit page for "horatio"
    And I follow "Account" within "#profile-options"
    And I fill in "Notification email" with "someone-else@pubmail.com"
	And I press "Save Messages Preferences"
	Then I should see "Successfully updated your profile"
