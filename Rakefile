require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "coherent"
    gem.summary = "Tools for building Coherent application or modules."
    gem.description = gem.summary
    gem.email = "jeff@metrocat.org"
    gem.homepage = "http://coherentjs.org"
    gem.authors = ["Jeff Watkins"]
    gem.files= Dir['lib/**/*', 'app_generators/**/*', 'generators/**/*',
                   'demo_generators/**/*', 'bin/*', '[A-Za-z]*', 'vendor/**/*']
    gem.files.reject! { |f| File.directory?(f) }
    gem.add_dependency('distil', '>= 0.8.4')
    gem.add_dependency('rubigen', '>= 1.5.2')
    # gem.extensions= ['vendor/extconf.rb']
    
    # gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new

  task :push => "gemcutter:release"
  
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "coherent #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
