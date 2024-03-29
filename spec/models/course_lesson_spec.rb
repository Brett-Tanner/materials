# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseLesson do
  it 'has a valid factory' do
    expect(build(:course_lesson)).to be_valid
  end
end
