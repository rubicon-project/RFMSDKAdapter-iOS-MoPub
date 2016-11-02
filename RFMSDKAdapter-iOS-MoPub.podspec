Pod::Spec.new do |s|
  s.name         = "RFMSDKAdapter-iOS-MoPub"
  s.version      = "3.0.0"
  s.summary      = "Rubicon Project Mobile MoPub Adapter for iOS"
  s.description  = <<-DESC
        You will need Revv for Mobile's iOS MoPub adapter if you wish to use MoPub as the primary ad serving SDK and Revv for Mobile SDK as the secondary ad serving SDK via MoPub's custom events. This adapter will ensure seamless callflow between MoPub and Revv for Mobile SDKs in your application.
                   DESC

  s.homepage     = "http://sdk.rubiconproject.com/"
  s.license      = { :type => "Copyright", :text => "Copyright 2012-2016 Rubicon Project. All Rights Reserved" }
  s.author       = { "Rubicon Project" => "mobileappdev@rubiconproject.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/rubicon-project/RFMSDKAdapter-iOS-MoPub.git", :tag => "3.0.0" }
  s.source_files = '*.{h,m}'
  s.requires_arc = true
  s.dependency 'mopub-ios-sdk'
  s.dependency 'RFMAdSDK'
end
