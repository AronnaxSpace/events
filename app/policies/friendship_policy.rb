# frozen_string_literal: true

class FriendshipPolicy < ApplicationPolicy
  def destroy?
    user == record.user || user == record.friend
  end

  def accept?
    user == record.friend
  end

  def reject?
    accept?
  end
end
