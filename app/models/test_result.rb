# frozen_string_literal: true

class TestResult < ApplicationRecord
  include Levels

  store_accessor :answers, :listening
  store_accessor :answers, :reading
  store_accessor :answers, :speaking
  store_accessor :answers, :writing

  enum :new_level, LEVELS, prefix: true
  enum :prev_level, LEVELS, prefix: true

  after_save :update_student_level

  belongs_to :test
  belongs_to :student
  delegate :organisation_id, to: :student

  validate :reason_given?
  validates :new_level, :prev_level, :total_percent, presence: true
  validates :listen_percent, :read_percent,
            :speak_percent, :total_percent,
            :write_percent, numericality:
            { allow_nil: true, only_integer: true,
              greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def radar_data
    {
      label: test.name,
      data: [
        read_percent || 0,
        write_percent || 0,
        speak_percent || 0,
        listen_percent || 0
      ]
    }
  end

  def recommended_level
    test.thresholds.reduce(prev_level) do |_lvl, threshold|
      threshold.first.tr(' ', '_').downcase if total_percent >= threshold.last
    end
  end

  def total_score
    answers.values.flatten.sum
  end

  private

  def reason_given?
    return true unless reason.blank? && new_level != recommended_level

    errors.add(:reason,
               I18n.t('test_results.errors.reason_required'))
  end

  def update_student_level
    student.update!(level: new_level)
  end
end
