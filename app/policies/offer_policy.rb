# frozen_string_literal: true

class OfferPolicy < ApplicationPolicy
  def manage?
    user == record.offerer
  end
end
