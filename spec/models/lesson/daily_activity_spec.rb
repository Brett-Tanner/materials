# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  subject(:daily_activity) do
    create(
      :daily_activity,
      title: 'Test Daily Activity',
      summary: 'Summary for test daily activity',
      week: 1,
      day: :monday,
      level: :kindy,
      subtype: :discovery,
      steps: "Step 1\nStep 2",
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  it 'saves steps as an array split on new lines' do
    expect(daily_activity.steps).to eq(['Step 1', 'Step 2'])
  end

  context 'when parsing links' do
    let(:link_hash) do
      { 'Example link' => 'http://example.com',
        'Seasonal' => 'http://example.com/seasonal' }
    end

    it 'saves links as hash, pairs split by line and value split by colon' do
      expect(daily_activity.links).to eq(link_hash)
    end

    it 'strips unnecessary whitespace' do
      whitespace_activity = create(
        :daily_activity,
        links: "Example link:  http://example.com\n     Seasonal:http://example.com/seasonal"
      )
      expect(whitespace_activity.links).to eq(link_hash)
    end
  end

  it 'correctly sets level' do
    expect(create(:daily_activity, level: :kindy).level).to eq('kindy')
  end

  context 'when generating PDF guide' do
    it "saves at 'course_root_path/week_?/day/daily_activity/level/timestampguide.pdf'" do
      daily_activity.save_guide
      key = daily_activity.guide.blob.key
      expected_path = %r{#{daily_activity.course.root_path}/week_1/monday/daily_activity/kindy/\d*guide.pdf}
      expect(key).to match(expected_path)
    end

    it 'contains title, summary, week, day, subcategory, links and steps' do
      pdf = daily_activity.save_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to contain_exactly(
          'Test Daily Activity', 'Summary for test daily activity', 'Week 1', 'Monday', 'Discovery',
          'Steps:', '1. Step 1', '2. Step 2', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
