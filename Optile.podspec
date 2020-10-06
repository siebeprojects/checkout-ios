Pod::Spec.new do |s|
  s.name             = 'Optile'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Optile.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/optile/ios-sdk'
  s.license          = { :type => 'MIT' }
  s.author           = { 'optile GmbH' => '' }
  s.source           = { :git => 'https://github.com/optile/ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.4'

  s.source_files = 'Sources/**/*.swift'
  
  s.resources = ['Sources/Assets/*']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'MaterialComponents/TextFields', '103.1.0'

end
