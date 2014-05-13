Pod::Spec.new do |s|
  s.name         = "VENCore"
  s.version      = "1.0.0"
  s.summary      = "Core Venmo client library"
  s.description  = <<-DESC
                   Core Venmo client library
                   DESC

  s.homepage     = "https://github.com/venmo/VENCore"
  s.license      = { :file => 'LICENSE.md' }
  s.author       = { "Ben Guo" => "ben@venmo.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/venmo/VENCore.git",
                     :tag => "v#{s.version}"
  }
  s.source_files = 'VENCore/**/*.{h,m}'
  s.dependency 'AFNetworking'
  s.requires_arc = true
end
