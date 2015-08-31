source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "8.0"

inhibit_all_warnings!
use_frameworks!

workspace 'Channels'
xcodeproj 'Channels/Channels'
xcodeproj 'POLYFoundation/POLYFoundation'

# Allows per-dev overrides
local_podfile = "Podfile.local"
eval(File.open(local_podfile).read) if File.exist? local_podfile

def import_pods
  # Language Nicities
  pod 'KVOController'
  pod 'ObjectiveSugar'
  pod 'Bolts'

  # libextobjc
  pod 'libextobjc/EXTScope'
end

target :Channels do
  xcodeproj 'Channels/Channels'
  import_pods
  # Core
  pod 'Mantle'

  # Analytics
  pod 'Mixpanel'

  # Animation/Layout/UI
  pod 'pop', '~> 1.0'
  pod 'FLKAutoLayout'
end

target 'ChannelsTests', :exclusive => true do
  xcodeproj 'Channels/Channels'
  pod 'FBSnapshotTestCase', '~>1.4'
  # pod 'Expecta+Snapshots', '~> 1.2'
  # pod 'OHHTTPStubs', '3.1.2'
  # pod 'XCTest+OHHTTPStubSuiteCleanUp', '1.0.0'
  # pod 'Specta'
  # pod 'Expecta'
  # pod 'OCMock', '2.2.4'
end

target :POLYFoundation do
  xcodeproj 'POLYFoundation/POLYFoundation'
  import_pods
  # Core
  pod "AFNetworking", "~> 2.5.1"
  pod "AFNetworkActivityLogger"
  pod "SDWebImage"

  # AWS - https://github.com/aws/aws-sdk-ios for avail packages
  pod 'AWSCore'
  pod 'AWSS3'
end

target 'POLYFoundationTests', :exclusive => true do
  xcodeproj 'POLYFoundation/POLYFoundation'
  # pod 'OHHTTPStubs', '3.1.2'
  # pod 'XCTest+OHHTTPStubSuiteCleanUp', '1.0.0'
end
