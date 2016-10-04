require "rails_helper"
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/user_management_helpers'
#require File.expand_path('../../helpers/unactivated_user_helpers',__FILE__)

feature "Password management, admin resets user password", :js => true do
  include LoggedInEnAdminUserHelper # logs in as admin
  include NavigationHelpers
  include UserManagementHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage users")
  end

  # chrome is required so that the keystore contains the private and public keys of the user
  scenario "normal operation", :driver => :chrome do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    expect(page_heading).to eq "Manage users"
    expect(flash_message).to match /A password reset email has been sent to/
    click_link('Logout')
    # user whose password was reset responds to the link in the email
    visit(new_password_activation_link)
    configure_keystore
    expect(page_heading).to match /Select new password for/
    fill_in(:user_password, :with => "shinynewsecret")
    fill_in(:user_password_confirmation, :with => "shinynewsecret")
    original_public_key = User.last.public_key
    submit_button.click
    sleep(3)
    expect(flash_message).to eq "Your new password has been saved, you may login below."
    expect(User.last.public_key).to eq original_public_key
    fill_in "User name", :with => "staff"
    fill_in "Password", :with => "shinynewsecret"
    login_button.click
    expect(flash_message).to eq "Logged in successfully"
  end

  scenario "user enters different passwords" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    expect(page_heading).to eq "Manage users"
    expect(flash_message).to match /A password reset email has been sent to/
    click_link('Logout')
    # user whose password was reset responds to the link in the email
    visit(new_password_activation_link)
    expect(page_heading).to match /Select new password for/
    fill_in(:user_password, :with => "shinynewsecret")
    fill_in(:user_password_confirmation, :with => "differentsecret")
    submit_button.click
    expect(page_heading).to match /Select new password for/
    expect(flash_message).to eq "Password confirmation doesn't match password, please try again."
  end

  scenario "user uses incorrect password reset_token" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    click_link('Logout')

    # user whose password was reset responds to the link in the email
    url_with_bogus_password_reset_token = new_password_activation_link.gsub(/[^\/]*$/,'bogus_password_reset_code')
    visit(url_with_bogus_password_reset_token  )
    expect(flash_message).to eq "User not found"
  end

  scenario "user uses blank password reset token" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    click_link('Logout')

    # user whose password was reset responds to the link in the email
    url_with_blank_password_reset_token = new_password_activation_link.gsub(/[^\/]*$/,'')
    visit(url_with_blank_password_reset_token  )
    expect(flash_message).to eq "Invalid password reset."
  end

  xscenario "reset user password, user does not insert token" do
  end

  xscenario "reset user password, user has the wrong token" do
  end
end
