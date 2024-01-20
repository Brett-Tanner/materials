# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    initialize_with { type.constantize.new }
    organisation
    name { 'Test User' }
    email { 'pC9Xp@example.com' }
    password { 'password' }
    type { 'Teacher' }

    trait :curriculum do
      type { 'CurriculumManager' }
    end

    trait :teacher do
      type { 'Teacher' }
    end
  end
end
