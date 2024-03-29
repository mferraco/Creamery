require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should belong_to(:employee)
  
  # Validating email...
  should allow_value("fred@fred.com").for(:email)
  should allow_value("fred@andrew.cmu.edu").for(:email)
  should allow_value("my_fred@fred.org").for(:email)
  should allow_value("fred123@fred.gov").for(:email)
  should allow_value("my.fred@fred.net").for(:email)
  
  should_not allow_value("fred").for(:email)
  should_not allow_value("fred@fred,com").for(:email)
  should_not allow_value("fred@fred.uk").for(:email)
  should_not allow_value("my fred@fred.com").for(:email)
  should_not allow_value("fred@fred.con").for(:email)
  
  # Need to do the rest with a context
  context "Creating a context of three employees" do
    # create the objects I want with factories
    setup do 
      @ed = FactoryGirl.create(:employee)
      @ed_user = FactoryGirl.create(:user, :employee => @ed, :email => "ed@example.com")
      @ralph = FactoryGirl.create(:employee, :first_name => "Ralph", :last_name => "Wilson", :active => false, :date_of_birth => 17.years.ago.to_date)
      @kathryn = FactoryGirl.create(:employee, :first_name => "Kathryn", :last_name => "Janeway", :role => "manager", :date_of_birth => 30.years.ago.to_date)
    end

    # and provide a teardown method as well
    teardown do
      @ed.destroy
      @ralph.destroy
      @kathryn.destroy
    end

    should "allow active employees to be users" do
      active_employee = FactoryGirl.build(:user, :employee => @kathryn, :email => "kathryn@example.com")
      assert active_employee.valid?
    end

    should "not allow inactive employees to be users" do
      inactive_employee = FactoryGirl.build(:user, :employee => @ralph, :email => "ralph@example.com")
      deny inactive_employee.valid?
    end
    
    should "not allow an email address to be used by more than one user" do
      email_taken = FactoryGirl.build(:user, :employee => @kathryn, :email => "ed@example.com")
      deny email_taken.valid?
    end
    
    should "return true if correct role is passed into role? method" do
      @employee = FactoryGirl.create(:employee, :role => 'employee')
      @admin = FactoryGirl.create(:employee, :role => 'admin')
      
      @employee_user = FactoryGirl.create(:user, :employee => @employee, :email => 'employee@employee.com')
      @admin_user = FactoryGirl.create(:user, :employee => @admin, :email => 'admin@admin.com')
      @nil_user = FactoryGirl.build(:user, :employee => nil, :email => 'mike@mike.com')
      
      assert_equal true, @employee_user.role?(:employee)
      assert_equal true, @admin_user.role?(:admin)
      
      assert_equal false, @employee_user.role?(:admin)
      assert_equal false, @nil_user.role?(:employee)
      
      @employee.destroy
      @admin.destroy
      @employee_user.destroy
      @admin_user.destroy
    end
    
    should "find the user by email" do
      @employee = FactoryGirl.create(:employee, :role => 'employee')
      @admin = FactoryGirl.create(:employee, :role => 'admin')
      
      @employee_user = FactoryGirl.create(:user, :employee => @employee, :email => 'employee@employee.com')
      @admin_user = FactoryGirl.create(:user, :employee => @admin, :email => 'admin@admin.com', :password => 'secret')
      
      assert_equal @admin_user, User.authenticate('admin@admin.com', 'secret')
      
      @employee.destroy
      @admin.destroy
      @employee_user.destroy
      @admin_user.destroy
    end
  end
end
