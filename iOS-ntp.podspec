Pod::Spec.new do |s|
  s.name      = 'iOS-ntp'
  s.version   = '0.2.1'
  s.summary   = 'This project is a mirror of the iOS-ntp project hosted on [Google code](http://code.google.com/p/ios-ntp/) by Gavin Eadie'
  s.homepage  = 'http://code.google.com/p/ios-ntp/'
  s.author    = { 'Gavin Eadie' => '' }
  s.source    = { :git => 'https://github.com/tomaszrybakiewicz/iOS-ntp.git', :tag => "v#{s.version}" }
  s.license   = 'MIT'
  
  s.requires_arc = true
  s.ios.deployment_target = "5.0"
  
  s.source_files   = "Code/*.{h,m}"
  s.dependency 'CocoaAsyncSocket'  
  
  s.resource_bundle = { 'Res' => ['LICENSE','ntp.hosts'] }
  s.prefix_header_file = 'Resources/ntpA_Prefix.pch'
  s.frameworks = 'CFNetwork'
end
