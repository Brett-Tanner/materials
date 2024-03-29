# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course do
  it 'has a valid factory' do
    course = build(:course)
    expect(course).to be_valid
  end
end
