# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

workspace 'ApiReachable'
use_frameworks!

def shared
  pod 'ObjectMapper', '~> 3.4'
  pod 'Alamofire', '~> 4.8.2'
  pod 'RxSwift',    '~> 5.0'
  pod 'Quick'
  pod 'Nimble'
end

target 'ApiReachable' do

  shared

end


target 'ApiReachableTests' do
  
  shared
  
end


target 'ApiReachable-Demo' do
  
  shared
  pod 'RxCocoa',    '~> 5.0'
  pod 'Kingfisher', '~> 5.0'
  
  project 'ApiReachable-Demo/ApiReachable-Demo'
end


target 'ApiReachable-DemoTests' do
  
  shared
  pod 'RxCocoa',    '~> 5.0'
  
  project 'ApiReachable-Demo/ApiReachable-Demo'
end
