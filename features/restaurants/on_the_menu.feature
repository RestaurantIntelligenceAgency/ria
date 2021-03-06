@otm @restaurant
Feature: On the Menu
  In order to allow restaurants to list current menu offerings,
  restaurant managers should be able to enter a name, description, price, and keywords for a dish

  Background:
    Given a restaurant named "Country Dog" with manager "bland"
    And I am logged in as "bland"
    Given a menu item keyword "farm-to-table" with category "Other"

  Scenario: Managers can access the OTM page
    When I go to my restaurants page
    And I follow "Edit Country Dog"
    And I follow "On the Menu" within "#edit_resto_menu"
    Then I should see "Add a new item"

  Scenario: Managers can enter an OTM item
    When I go to the new on the menu page for "Country Dog"
    And I fill in "Name" with "Pork chop"
    And I fill in "menu_item_description_editor" with "A braised pork chop served with fruit compote"
    And I fill in "Price" with "12.00"
    And I check "farm-to-table"
    And I press "Save"
    Then I should see "saved"
    
  Scenario: Other users can't access the private OTM area
    Given the following confirmed user:
      | name       | username |
      | Marko Tony | mtony    |
    And I am logged in as "mtony"
    And I am an employee of "Country Dog" with role "Chef"
    When I go to the new on the menu page for "Country Dog"
    Then I should not see "On the Menu - New Item"
    And I should see "You don't have permission to access that page"

  Scenario: Other restaurant employees can access the public OTM area
    Given the following confirmed user:
      | name       | username |
      | Marko Tony | mtony    |
    And I am logged in as "mtony"
    And I am an employee of "Country Dog" with role "Chef"
    When I go to the On the Menu page for "Country Dog"
    Then I should see "On the Menu"
