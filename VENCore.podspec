Pod::Spec.new do |s|
  s.name         = 'VENCore'
  s.version      = '3.1.5'
  s.summary      = 'Core Venmo client library'
  s.description  = 'Core iOS client library for the Venmo api'
  s.homepage     = 'https://github.com/venmo/VENCore'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Venmo' => 'ios@venmo.com' }
  s.platform     = :ios, '7.1'
  s.source       = { :git => 'https://github.com/venmo/VENCore.git',
                     :tag => "v#{s.version}" }
  s.source_files = 'VENCore/**/*.{h,m}'
  s.dependency 'CMDQueryStringSerialization', '~> 0.4'
end
