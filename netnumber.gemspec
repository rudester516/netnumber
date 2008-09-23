Gem::Specification.new do |s|
  s.name     = "netnumber"
  s.version  = "0.0.3"
  s.date     = "2008-09-23"
  s.summary  = "Object model interface to a git repo"
  s.email    = "rsombillo@gmail.com"
  s.homepage = "http://github.com/rudester516"
  s.description = "A ruby gem that uses the NetNumber interface to determine the service provider of a phone number."
  s.author   = "Rudy A. Sombillo"
  s.files    = s.files    = ["History.txt", 
  		"Manifest.txt", 
  		"README.txt", 
  		"Rakefile", 
  		"netnumber.gemspec", 
  		"lib/netnumber/version.rb", 
  		"lib/netnumber.rb"]
  s.test_files = "test/test_netnumber.rb"
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency "dnsruby", ">= 1.1"
end

