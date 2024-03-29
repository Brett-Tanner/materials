# frozen_string_literal: true

class ProposedChangePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def new?
    false
  end

  def edit?
    user.is?('Admin') || record.proponent_id == user.id
  end

  def create?
    false
  end

  def update?
    user.is?('Admin', 'Writer')
  end

  def destroy?
    user.is?('Admin')
  end
end
