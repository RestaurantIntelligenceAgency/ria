@restaurant_profile
Feature: Restaurant profile
  So that a restaurant can see their profile

  Background:
    Given a restaurant named "Piece"

  Scenario: Show basic data
  	Given I am logged in as an admin
    When I go to the restaurant photo upload page for Piece
    And I attach the file "/features/images/bourgeoispig.jpg" to "image_attachment"
    And I press "Upload"
    When I go to the edit restaurant page for Piece
    And I attach the file "/features/images/bourgeoispig_logo.gif" to "logo_attachment"
    And I press "Upload"
    When I go to the soapbox restaurant profile for Piece
    Then I see the restaurant's name as "Piece"
    And I see the restaurant's description
    And I see the address
    And I see the phone number
    And I see the restaurant's website as a link
    And I see the restaurant's Twitter username
    And I see the restaurant's Facebook page
    And I see the restaurant's hours
    And I see media contact name, phone, and email
    And I see the management company name as a link
    And I see the primary photo
		And I see the restaurant logo for the profile
    And I see the opening date

  Scenario: Show management data without link if no link specified
    Given the restaurant has no website for it's management company
    When I go to the soapbox restaurant profile for Piece
    Then I see the management company name without a link

  Scenario: Show no management data if not specified
    Given the restaurant has no management data
    When I go to the soapbox restaurant profile for Piece
    Then I do not see management data

  Scenario: The restaurant doesn't like social networking
    Given the restaurant has no Twitter of Facebook info
    When I go to the soapbox restaurant profile for Piece
    Then I do not see the Twitter username
    And I do not see the Facebook username

