# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'MortgageApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MortgageApp
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Eureka', '~> 2.0.0-beta.1'
  pod "GlyuckDataGrid"

  target 'MortgageAppTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
  end

  target 'MortgageAppUITests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase/Auth'
    pod 'Eureka', '~> 2.0.0-beta.1'
    pod "GlyuckDataGrid"
    pod 'Firebase/Database'
  end

end
