@signup
Feature: Create an Account
  So that I can improve my social media networking/marketing
  As a prospective RIA client that is not a journalist,
  I want to create a free SF account.


  Background:
    Given the following account_type records:
    | name      |
    | Concierge |


  Scenario: Brand New account signup
    Given there are no users
    When I am on the signup page
    Then I should see "Sign up for SpoonFeed"

    When I fill in "Username" with "janet"
    And I fill in "Email" with "jparker@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I select "Concierge" from "Account Type"
    And I check "Agree to Contract?"
    And I press "Save"

    Then I should see "Just to make sure you are who you say you are"
    And "jparker@example.com" should receive 1 email
    But "foo@bar.com" should receive no emails

    When "jparker@example.com" opens the email with subject "Welcome to SpoonFeed! Please confirm your account"

    Then I should see "confirm" in the email body
    And I should see "janet" in the email body

    When I click the first link in the email
    Then I should see "Welcome aboard! Your account has been confirmed"
    And "janet" should be a confirmed user
    And "janet" should be logged in
    # And I should see "You are now logged in"


  Scenario: Trying to follow email link twice
    Given I am on the signup page
    When I fill in "Username" with "twice"
    And I fill in "Email" with "twice@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I check "Agree to Contract?"
    And I press "Save"

    Then I should see "Just to make sure you are who you say you are"
    And "twice@example.com" should receive 1 email

    When "twice@example.com" opens the email with subject "Welcome to SpoonFeed! Please confirm your account"
    And I click the first link in the email

    Then I should see "Welcome aboard! Your account has been confirmed"
    And "twice" should be a confirmed user
    And "twice" should be logged in
    And I should see "Confirming your account"

    When "twice@example.com" opens the email with subject "Welcome to SpoonFeed! Please confirm your account"
    And I click the first link in the email
    Then I should see "already set up"

    Given I am not logged in
    When "twice@example.com" opens the email with subject "Welcome to SpoonFeed! Please confirm your account"
    And I click the first link in the email
    Then I should see "that confirmation token has already been used"


  Scenario: Bad email
    Given there are no users
    When I am on the signup page
    Then I should see "Sign up for SpoonFeed"

    When I fill in "Username" with "janet"
    And I fill in "Email" with "janet"
    And I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I check "Agree to Contract?"
    And I press "Save"

    Then I should see "should look like an email address"

  Scenario: Email already taken
    Given the following confirmed user:
    | username | password | email |
    | jimjames | secret   | jimjames@example.com |

    When I am on the signup page
    And I fill in "Username" with "jimmyboy"
    And I fill in "Email" with "jimjames@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I press "Save"

    Then I should see "has already been taken"


  Scenario: Attempting to Log in before confirmed
    Given there are no users
    When I am on the signup page
    And I fill in "Username" with "jimbob"
    And I fill in "Email" with "jimbob@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password Confirmation" with "secret"
    And I check "Agree to Contract?"
    And I press "Save"
    Then "jimbob@example.com" should receive 1 email

    When I am on the login page
    And I fill in "Username" with "jimbob"
    And I fill in "Password" with "secret"
    And I press "Login"
    Then "jimbob" should not be logged in


  Scenario: Logging in
    Given the following confirmed user:
    | username | password |
    | mistered | secret   |

    When I am on the homepage
    And I follow "Login"
    And I fill in "Username" with "mistered"
    And I fill in "Password" with "secret"
    And I press "Login"

    Then I should see "You are now logged in"


  Scenario: Attempting to Log in with incorrect password
     Given the following confirmed user:
      | username | password |
      | mistered | secret   |
    When I am on the login page
    And I fill in "Username" with "mistered"
    And I fill in "Password" with "blue"
    And I press "Login"
    Then I should see "wrong username or password"


  Scenario: Logging Out
    Given the following confirmed user:
    | username | password |
    | shelly   | secret   |
    And I am logged in as "shelly" with password "secret"
    And I am on the homepage
    When I follow "Log out"
    Then I should see "Successfully logged out"

    When I visit the logout path
    Then I should see "You must be logged in"
    And I should be on the login page
