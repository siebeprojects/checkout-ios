Pod::Spec.new do |s|
  s.name             = 'PayoneerCheckout'
  s.version          = '0.6.0'
  s.summary          = 'Payoneer Checkout SDK for iOS-based devices'

  s.homepage         = 'https://github.com/optile/checkout-ios'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Payoneer Germany GmbH' => '' }
  s.source           = { :git => 'https://github.com/optile/checkout-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.5'

  s.source_files = 'Sources/PayoneerCheckout/**/*.swift'
  s.resources = ['Sources/PayoneerCheckout/Resources/*']
end
