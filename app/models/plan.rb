# frozen_string_literal: true

class Plan < ApplicationRecord
  validates :finish_date, :name, :start, :student_limit, :total_cost, presence: true

  belongs_to :course
  belongs_to :organisation

  scope :active, -> { where('finish_date > ?', Time.zone.now) }
end
