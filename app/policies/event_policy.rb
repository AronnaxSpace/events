# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def manage?
    user == record.owner
  end

  def edit?
    update?
  end

  def update?
    manage? && !record.archived?
  end

  def destroy?
    manage?
  end
end
