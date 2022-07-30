class UserPolicy < ApplicationPolicy
  def patient?
    user.has_role? :patient
  end
end
