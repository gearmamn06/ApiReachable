Pod::Spec.new do |spec|

  spec.name         = "ApiReachable"
  spec.version      = "0.1.4"
  spec.summary      = "Embed networking logic in your model."


  spec.description  = <<-DESC
                      Model based networking module using Alamofire
                      DESC

  spec.homepage     = "https://github.com/gearmamn06/ApiReachable"

  spec.license      = { :type => "MIT", :text => <<-LICENSE
    MIT License

Copyright (c) 2019 gearmamn06

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

    LICENSE
  }

  spec.author             = { "gearmamn06" => "gearmamn06@gmail.com" }


  spec.swift_version = "5.0"
  spec.platform     = :ios
  # spec.platform     = :ios, "10.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"

  # spec.source       = { :git => "https://github.com/gearmamn06/AnimationSeries.git", :tag => spec.version }

  # spec.ios.vendored_frameworks = 'AnimationSeries.framework'
  spec.source_files  = ["Sources/*.swift", "Sources/ApiReachable.h"]
  spec.public_header_files = ["Sources/ApiReachable.h"]
  spec.source = { :git => "https://github.com/gearmamn06/ApiReachable.git", :tag => spec.version }
  # spec.source = { :http => 'https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-291822295618/AnimationSeriesFramework.zip'}
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = ["AnimationSeries/Sources/AnimationSeries.h"]
  spec.requires_arc = true

  spec.dependency 'ObjectMapper', '~> 3.4'
  spec.dependency 'Alamofire', '~> 4.8.2'
  spec.dependency 'RxSwift', '~> 5.0'

end