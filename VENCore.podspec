Pod::Spec.new do |s|
  s.name         = "VENCore"
  s.version      = "0.0.1"
  s.summary      = "Venmo API iOS client"
  s.description  = <<-DESC
                   Venmo API iOS client
                   DESC

  s.homepage     = "https://github.braintreeps.com/venmo/VENCore.git"
  s.license      = { :file => 'LICENSE.md' }
  s.author       = { "Ben Guo" => "ben@venmo.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.braintreeps.com/venmo/VENCore.git",
                     :tag => "v#{s.version}"
  }
  s.source_files = 'VENCore/**/*.{h,m}'
  s.dependency 'AFNetworking'
  s.requires_arc = true
end
