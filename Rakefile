require 'spec/rake/spectask'
Spec::Rake::SpecTask.new

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "missingno"
    s.summary = "automated method_missing generator"
    s.email = "me@tobiascohen.com"
    s.homepage = "http://github.com/tobico/missingno"
    s.description = "Automated method_missing and respond_to? generator"
    s.authors = ["Tobias Cohen"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end