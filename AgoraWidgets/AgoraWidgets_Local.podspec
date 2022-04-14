Pod::Spec.new do |spec|
  spec.name         = "AgoraWidgets"
  spec.version      = "2.1.2"
  spec.summary      = "Agora widgets"
  spec.description  = "Agora native widgets"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.module_name  = "AgoraWidgets"

  spec.ios.deployment_target = "10.0"
  spec.swift_versions        = ["5.0", "5.1", "5.2", "5.3", "5.4"]

  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/open-apaas-extapp-ios.git", :tag => "AgoraWidgets_v" + "#{spec.version.to_s}" }
  spec.source_files = "Common/*.{h,m,swift}","RenderSpread/**/*.{h,m,swift}","Cloud/**/*.{h,m,swift}","Whiteboard/**/*.{h,m,swift}","RtmIM/**/*.{h,m,swift}","ChatWidget/**/*.{h,m,swift}"
  
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraWidget"
  spec.dependency "AgoraLog"
  spec.dependency "Armin", '>=1.0.9'

  spec.dependency "SwifterSwift"
  spec.dependency "Masonry"
  spec.dependency "FLAnimatedImage"
  
  # Netless
  spec.dependency "Whiteboard"
  
  # Hyphenate
  spec.dependency 'HyphenateChat'
  spec.dependency 'SDWebImage'
  spec.dependency 'WHToast'

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" } 
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }
  
  spec.subspec "Resources" do |ss|
      ss.resource_bundles = {
        "AgoraWidgets" => ["AgoraResources/**/*.{xcassets,strings,gif,mp3}"]
      }
  end
end
