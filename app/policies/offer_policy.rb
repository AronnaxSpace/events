# frozen_string_literal: true

class OfferPolicy < ApplicationPolicy
  def manage?
    user == record.offerer
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
