Pod::Spec.new do |s|
  s.name         = "VENCore"
  s.version      = "2.0.0"
  s.summary      = "Core Venmo client library"
  s.description  = <<-DESC
                   Core iOS client library for the Venmo api
                   DESC

  s.homepage     = "https://github.com/venmo/VENCore"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Ben Guo" => "ben@venmo.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/venmo/VENCore.git",
                     :tag => "v#{s.version}"
  }
  s.source_files = 'VENCore/**/*.{h,m}'
  s.dependency 'CMDQueryStringSerialization', '~>0.2.0'
  s.requires_arc = true
end
