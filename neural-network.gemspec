lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name           = 'neural-network'
  spec.version        = '0.0.5'
  spec.authors        = ['interrobang']
  spec.summary        = 'A simple feed-forward Neural Network gem'
  spec.license        = 'MIT'
  spec.homepage       = 'https://github.com/questionmarkexclamationpoint/neural-network'

  spec.files          = Dir.glob('lib/**/*')
  spec.require_paths  = ['lib']

  spec.add_development_dependency 'distribution', '~> 0.7.3'
end
