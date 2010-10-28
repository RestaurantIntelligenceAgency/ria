include SubscriptionsControllerHelper

Then /^I see my account status is not premium$/ do
  response.should have_selector("#plans .current", :content => "Basic")
end

Then /^I see that the restaurant's account status is basic$/ do
  response.should have_selector("#account_status", :content => "Basic")
end

Then /^I see that the restaurant's account status is premium$/ do
  response.should have_selector("#account_status", :content => "Premium")
end

Then /^I do not see a premium badge$/ do
  response.should_not have_selector(".premium_badge")
end

Then /^I see a link to update my account to premium$/ do
  response.should have_selector("#plans #upgrade_link a",
      :content => "Upgrade to Premium")
end

Given /^user "([^"]*)" has a premium account$/ do |username|
  user = User.find_by_username(username)
  user.make_premium!(stub(:subscription => stub(:id => "abcd")))
end

Given /^user "([^"]*)" does not have a premium account$/ do |username|
  user = User.find_by_username(username)
  user.subscription = nil
  user.save!
end

Then /^I see a premium badge$/ do
  response.should have_selector(".premium_badge")
end

Then /^I see my account status is premium$/ do
  response.should have_selector("#plans .current", :content => "Premium")
end

Then /^I see a link to cancel my account$/ do
  response.should have_selector("#plans #upgrade_link a",
      :content => "Downgrade to basic")
end

When /^I simulate braintree create behavior$/ do
  BraintreeConnector.any_instance.stubs(
      :braintree_customer => nil)
end

When /^I simulate braintree update behavior$/ do
  BraintreeConnector.any_instance.stubs(
      :braintree_customer => stub(:kind => 'update_customer', :credit_cards => [stub(:token => "token_abcd")])
      )
end

When /^I simulate a successful call from braintree for user "([^"]*)"$/ do |username|
  user = User.find_by_username(username)
  BraintreeConnector.any_instance.stubs(
      :confirm_request_and_start_subscription => stub(:success? => true,
          :subscription => stub(:id => "abcd")))
  visit(bt_callback_subscription_url(user))
end

When /^I simulate a successful call from braintree for the restaurant "([^"]*)"$/ do |name|
  restaurant = Restaurant.find_by_name(name)
  BraintreeConnector.any_instance.stubs(
      :braintree_customer => nil)
  BraintreeConnector.any_instance.stubs(
      :confirm_request_and_start_subscription => stub(:success? => true,
          :subscription => stub(:id => "abcd")))
  visit(bt_callback_subscription_url(restaurant))
end

When /^I simulate an unsuccessful call from braintree for user "([^"]*)"$/ do |username|
  user = User.find_by_username(username)
  BraintreeConnector.any_instance.stubs(
      :braintree_customer => nil)
  BraintreeConnector.any_instance.stubs(
      :confirm_request_and_start_subscription => stub(:success? => false))
  visit(bt_callback_subscription_url(user))
end

When /^I simulate an unsuccessful call from braintree for the restaurant "([^"]*)"$/ do |name|
  restaurant = Restaurant.find_by_name(name)
  BraintreeConnector.any_instance.stubs(
      :braintree_customer => nil)
  BraintreeConnector.any_instance.stubs(
      :confirm_request_and_start_subscription => stub(:success? => false))
  visit(bt_callback_subscription_url(restaurant))
end

When /^I simulate a successful cancel from braintree$/ do
  BraintreeConnector.any_instance.stubs(
      :cancel_subscription => stub(:success? => true))
  BraintreeConnector.stubs(:find_subscription).returns(
          stub(:billing_period_end_date => 1.month.from_now.to_date))
end

When /^I simulate an unsuccessful cancel from braintree$/ do
  BraintreeConnector.any_instance.stubs(
      :cancel_subscription => stub(:success? => false))
end

Then /^I see my account is paid for by myself$/ do
  response.should_not have_selector(".current", :content => "Complimentary")
  response.should have_selector(".current #start_date",
      :content => "since #{Date.today.to_s(:long)}")
end

When /^I traverse the delete link for subscriptions for user "([^"]*)"$/ do |username|
  visit(user_subscription_path(User.find_by_username(username).id),
      :delete)
end

When /^I traverse the delete link for subscriptions for the restaurant "([^"]*)"$/ do |name|
  visit(restaurant_subscription_path(Restaurant.find_by_name(name)),
      :delete)
end

Then /^I see that the account for "([^"]*)" lasts until the end of the billing cycle$/ do |username|
  user = User.find_by_username(username)
  response.should have_selector("#end_date",
      :content => user.subscription.end_date.to_s(:long))
end

Then /^I see that the restaurant account for "([^"]*)" lasts until the end of the billing cycle$/ do |restaurant_name|
  restaurant = Restaurant.find_by_name(restaurant_name)
  response.should have_selector("#end_date",
      :content => restaurant.subscription.end_date.to_s(:long))
end


Then /^I don't see that the account for "([^"]*)" lasts until the end of the billing cycle$/ do |username|
  response.should_not have_selector("#end_date")
end

Then /^I don't see that the restaurant account for "([^"]*)" lasts until the end of the billing cycle$/ do |arg1|
  response.should_not have_selector("#end_date")
end


Then /^I do not see any account change options$/ do
  response.should_not have_selector("#upgrade_link")
end

Given /^the restaurant "([^"]*)" has a premium account$/ do |restaurant_name|
  restaurant = Restaurant.find_by_name(restaurant_name)
  restaurant.make_premium!(stub(:subscription => stub(:id => "abcd")))
  BraintreeConnector.stubs(:cancel_subscription).with(
      restaurant.subscription).returns(stub(:success? => true))
end

Given /^the restaurant "([^"]*)" has an overtime account$/ do |restaurant_name|
  restaurant = Restaurant.find_by_name(restaurant_name)
  restaurant.make_premium!(stub(:subscription => stub(:id => "abcd")))
  restaurant.subscription.update_attributes(:end_date => 1.month.from_now)
  # The cancel subscription call should never be made
  BraintreeConnector.stubs(:cancel_subscription).never
end

Given /^the restaurant "([^"]*)" does not have a premium account$/ do |restaurant_name|
  restaurant = Restaurant.find_by_name(restaurant_name)
  restaurant.subscription = nil
  restaurant.save!
end

Given /^I simulate braintree search billing history behavior with the following:$/ do |table|
  @transactions = []
  table.hashes.each do |row|
    @transactions << stub(
            :id => row['transaction_id'],
            :amount => row['amount'],
            :status => row['status'],
            :created_at => eval(row['date']),
            :credit_card_details => stub(
                :last_4 => row['card_number'],
                :card_type => row['card_type'],
                :expiration_date => row['expiration_date']
            ),
            :class => Braintree::Transaction
          )
    # we are simulating a collection of the following braintree transaction objects
    # <Braintree::Transaction id: "bssvmm", type: "sale", amount: "250.0", status: "submitted_for_settlement", created_at: Wed Oct 27 14:25:10 UTC 2010, credit_card_details: #<token: "5bgy", bin: "411111", last_4: "1111", card_type: "Visa", expiration_date: "01/2011", cardholder_name: "", customer_location: "US">, customer_details: #<id: "Restaurant_35", first_name: nil, last_name: nil, email: "sonia@neotericdesign.com", company: nil, website: nil, phone: nil, fax: nil>, updated_at: Wed Oct 27 14:25:11 UTC 2010>
  end
  BraintreeConnector.any_instance.stubs(:transaction_history => @transactions)
end

Then /^I should see all of my transaction details$/ do
  response.should have_selector("table#transactions")
  @transactions.each do |transaction|
    response.should have_selector("tr##{dom_id(transaction)}") do |trans_block|
      trans_block.should have_selector("td", :content => transaction.id)
      trans_block.should have_selector("td", :content => transaction.amount)
      trans_block.should have_selector("td", :content => transaction.status)
      trans_block.should have_selector("td", :content => transaction.created_at.strftime("%m/%d/%Y"))
      trans_block.should have_selector("td", :content => transaction.credit_card_details.last_4)
      trans_block.should have_selector("td", :content => transaction.credit_card_details.card_type)
      trans_block.should have_selector("td", :content => transaction.credit_card_details.expiration_date)
    end
  end
end
