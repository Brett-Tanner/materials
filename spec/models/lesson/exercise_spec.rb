# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exercise do
  subject(:exercise) do
    create(
      :exercise,
      title: 'Test Exercise',
      summary: 'Summary for test exercise',
      week: 1,
      day: :monday,
      level: :kindy,
      steps: "Step 1\nStep 2",
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when parsing links' do
    let(:link_hash) do
      { 'Example link' => 'http://example.com',
        'Seasonal' => 'http://example.com/seasonal' }
    end

    it 'saves links as hash, pairs split by line and value split by colon' do
      expect(exercise.links).to eq(link_hash)
    end

    it 'strips unnecessary whitespace' do
      whitespace_activity = create(
        :exercise,
        links: "Example link:  http://example.com\n     Seasonal:http://example.com/seasonal"
      )
      expect(whitespace_activity.links).to eq(link_hash)
    end
  end

  context 'when generating PDF guide' do
    it "saves at 'course_root_path/week_?/day/exercise/level/timestampguide.pdf'" do
      exercise.save_guide
      key = exercise.guide.blob.key
      expected_path = %r{#{exercise.course.root_path}/week_1/monday/exercise/kindy/\d*guide.pdf}
      expect(key).to match(expected_path)
    end

    it 'contains title, summary, week, day and links' do
      pdf = exercise.save_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to contain_exactly(
          'Test Exercise', 'Summary for test exercise', 'Week 1', 'Monday', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
