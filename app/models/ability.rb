# defines what each type of user can do in the system

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    
    if user.role? :admin # if the user is an administrator
      # they can do anything in the system
      can :manage, :all
    elsif user.role? :manager # if the user is a manager
      # they can update and show the employees at their store
      can [:update, :show], Employee do |employee|
        employee.id == user.employee_id || employee.current_assignment.store = user.employee.current_assignment.store
      end
      # they can perform all actions on shifts at their store
      can [:create, :update, :show, :destroy], Shift do |shift|
        shift.assignment.store_id == user.employee.current_assignment.store_id
      end
      # they can read store info
      can :read, Store
    elsif user.role? :employee # if the user is an employee
      # they can view info on themselves
      can :view, Employee do |employee|
        employee.id == user.employee_id
      end
      # they can read store info
      can :read, Store
    else # a guest is accessing the web page
      # they can only read store info
      can :read, Store
    end
  end
end
