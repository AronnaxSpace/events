# frozen_string_literal: true

class OfferPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    user == record.offerer
  end

  def destroy?
    update?
  end
end
