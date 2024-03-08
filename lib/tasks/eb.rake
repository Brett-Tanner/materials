# frozen_string_literal: true

namespace :eb do
  desc 'Deploys current version of the app to elastic beanstalk'
  task deploy: :environment do
    current_version = find_current_version
    version = request_new_version(current_version)
    build_docker_image(version)
    push_docker_image(version)
    update_dockerrun(version)
    commit_changes(version)
    deploy_to_eb
  end
end

def find_current_version
  puts 'Querying elastic beanstalk for current version...'
  `eb status | grep 'Deployed Version' | cut -d':' -f2 | tr -d '[:space:]'`
end

def request_new_version(current_version)
  puts "Current version is: #{current_version}"
  print 'Enter the new version: '
  version = $stdin.gets.chomp
  puts "Current version is: #{current_version}"
  puts "Will deploy version: #{version}"
  puts 'Is this ok? (y/n/change)'
  ok = $stdin.gets.chomp
  case ok
  when 'n'
    puts 'Aborting'
    exit
  when 'y'
    puts 'Building Docker image...'
    version
  when 'change'
    puts 'Retrying...'
    raise ArgumentError, 'Input wrong version'
  else
    puts "You struggle with reading comprehension, don't you"
    raise ArgumentError, "Can't read"
  end
rescue ArgumentError
  retry
end

def build_docker_image(version)
  puts "Tag will be 'thatbballguy/materials:#{version}'"
  `docker build . -t thatbballguy/materials:#{version}`
end

def push_docker_image(version)
  puts "Pushing 'thatbballguy/materials:#{version}' to docker hub..."
  system("docker push thatbballguy/materials:#{version}")
end

def update_dockerrun(version)
  puts "Updating dockerrrun.aws.json with 'thatbballguy/materials:#{version}' as image"
  data = File.open('dockerrun.aws.json') do |file|
    JSON.parse(file.read)
  end
  data['Image']['Name'] = "thatbballguy/materials:#{version}"
  File.write('dockerrun.aws.json', JSON.pretty_generate(data))
end

def commit_changes(version)
  puts 'Committing changes...'
  `git add .`
  `git commit -m "Deploy #{version}"`
end

def deploy_to_eb
  system('eb deploy')
end