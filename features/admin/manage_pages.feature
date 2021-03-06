@cms
Feature: Manage pages
  So that I can learn what the SpoonFeed product and service is about,
  As a member of the general public, who does not have an account,
  I want to view videos, marketing pages, and public static content regarding SpoonFeed.

  So that I can control the marketing content
  As an RIA staff member
  I want to be able to manage the pages and their content easily


  Background:
    Given I am logged in as an admin

  Scenario: Creating a page and viewing it
    When I create a new page with:
      | Title   | About Us                  |
      | Slug    | about-us                  |
      | Content | This page explains a lot. |
    Then I should see "Successfully created page"
    And there should be a page with slug "about-us"
    When I logout
    And I go to "/about-us"
    Then I should see "About Us"
    And I should see "This page explains a lot."


  Scenario: New pages can auto-generate slugs
    When I create a new page with:
      | Title   | Contact                   |
      | Content | This page explains a lot. |
    Then I should see "Successfully created page"
    And there should be a page with slug "contact"


  Scenario: Non-logged-in user page
    Given the special "about" page exists
    When I update the "about" page with:
      | Title   | Welcome                 |
      | Content | You've finally made it! |
    And I logout
    And I go to "/about"
    Then I should see "You've finally made it!"

@mediafeed    
  Scenario: Able to create a media feed page
    When I go to the admin landing page
    Then I should see "Mediafeed Pages" as a link
