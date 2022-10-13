Pod::Spec.new do |spec|
  spec.name         = "AgoraWidgets"
  spec.version      = "2.8.0"
  spec.summary      = "SDKs/AgoraWidgets."
  spec.description  = "Agora native widgets"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  
  spec.platform              = :ios
  spec.ios.deployment_target = "10.0"
  spec.swift_versions        = ["5.0", "5.1", "5.2", "5.3", "5.4"]

  spec.source       = { :git => "git@github.com:AgoraIO-Community/apaas-extapp-ios.git", :tag => "AgoraWidgets_v" + "#{spec.version.to_s}" }
    
  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }

  # common libs
  spec.dependency "AgoraUIBaseViews", ">=2.8.0"
  spec.dependency "AgoraWidget", ">=2.8.0"
  spec.dependency "AgoraLog", "1.0.2"
  spec.dependency "Armin", ">=1.1.0"

  spec.dependency "SwifterSwift"
  spec.dependency "Masonry"
  
  # Netless
  spec.dependency "Whiteboard"
  
  # Hyphenate
  spec.dependency "Agora_Chat_iOS", "1.0.6"
  spec.dependency "SDWebImage", "<=5.12.0"

  spec.subspec "Source" do |ss|
    ss.source_files = "SDKs/AgoraWidgets/**/**/*.{h,m,swift}"
  end
  
  spec.subspec "Binary" do |ss|
    ss.vendored_frameworks = [
      "Products/Libs/*.framework"
    ]
  end

  spec.default_subspec = "Source"
end
