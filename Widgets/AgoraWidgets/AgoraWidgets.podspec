Pod::Spec.new do |spec|
  spec.name         = "AgoraWidgets"
  spec.version      = "1.0.0"
  spec.summary      = "Agora widgets"
  spec.description  = "Agora native widgets"

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/open-apaas-extapp-ios.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "10.0"
  
  spec.module_name   = 'AgoraWidgets'
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }

  spec.source_files  = "Widgets/AgoraWidgets/**/*.{h,m,swift}", "Chat/*.{h,m,swift}", "Common/*.{h,m,swift}","RenderSpread/*.{h,m,swift}", "Cloud/**/*.{h,m,swift}","Whiteboard/**/*.{h,m,swift}"

  spec.dependency "Masonry"
  spec.dependency "AgoraWidget"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraUIEduBaseViews"
  spec.dependency "Whiteboard"
  spec.dependency "AgoraLog"
  spec.dependency "Armin"
  
  spec.subspec 'Resources' do |ss|
      ss.resource_bundles = {
        'AgoraWidgets' => ["AgoraResources/*/*.{strings}", 
                           "*.xcassets",
                           "Widgets/AgoraWidgets/AgoraResources/*/*.{strings}", 
                           "Widgets/AgoraWidgets/*.xcassets"]
      }
  end
end
