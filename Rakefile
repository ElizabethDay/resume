task :default do
  Rake::Task["build"].execute
  Rake::Task["display"].execute
end

task :build do
  ruby "src/resume.rb"
end

task :display do
  `open -a Preview ElizabethDay.pdf`
end

