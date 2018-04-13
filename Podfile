# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'HenriPotier' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HenriPotier
  
  pod 'HenriPotierApiClient', :git => "https://github.com/rokridi/HenriPotierApiClient.git"
  pod 'SDWebImage', '~> 4.0'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'RxDataSources', '~> 3.0'
  pod 'ParallaxHeader', '~> 2.0.0'
  pod 'ReachabilitySwift'
  pod 'SwiftMessages'
  pod 'DZNEmptyDataSet'
  pod "MIBadgeButton-Swift", :git => 'https://github.com/mustafaibrahim989/MIBadgeButton-Swift.git', :branch => 'master'

  target 'HenriPotierTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs/Swift'
    pod 'Quick'
    pod 'RxNimble'
  end

  target 'HenriPotierUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
