task :default => [:build]

task :build do
  ruby "resume.rb"
  Rake::Task["display"].execute
end

task :display do
  `open -a Preview ElizabethDay.pdf`
end

