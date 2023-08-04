
Pod::Spec.new do |spec|

  spec.name         = "ZeusGuardTestSDK"
  spec.version      = "0.0.3"
  spec.summary      = "A CocoaPods library written in Swift for generating tokens"

  spec.description  = <<-DESC
This CocoaPods library helps you protect requests from malicious users.
                   DESC

  spec.homepage     = "https://github.com/vladimir-zivanov-htec/ZeusGuardTestSDK"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Vladimir Zivanov" => "vladimir.zivanov@htecgroup.com" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/vladimir-zivanov-htec/ZeusGuardTestSDK.git", :tag => "#{spec.version}" }
  spec.source_files  = "ZeusGuardTestSDK/**/*.{h,m,swift}"


  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "FirebaseAppCheck"

end
