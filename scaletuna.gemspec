Gem::Specification.new do |s|
  s.name        = 'scaletuna'
  s.version     = '0.1.2'
  s.date        = '2015-09-01'
  s.summary     = "Curses AWS autoscaling"
  s.description = "Scaling AWS autoscalers using a curses interface"
  s.authors     = ["Samuel Kleiner"]
  s.email       = 'samuel.kleiner@bambooloans.com'
  s.files       = ["bin/scaletuna"]
  s.executables << 'scaletuna'
  s.homepage    =
    'http://rubygems.org/gems/scaletuna'
  s.license       = 'GPL2'
  s.add_runtime_dependency 'curses', '~> 1'
  s.add_runtime_dependency 'aws-sdk', '~> 2'
end
