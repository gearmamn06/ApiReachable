import UIKit
import RxSwift
import RxCocoa


var str = "Hello, playground"

enum MyError: Error {
    case def
}

func fetch() -> Single<Int> {
    
    return Observable.create { observer in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let isFail = Int.random(in: 0...1) % 2 == 0
            if isFail {
                observer.onNext(1)
                print("onNext")
//                observer.onCompleted()
                
            }else{
                observer.onError(MyError.def)
            }
        })
        return Disposables.create()
    }.asSingle()
}


//let observableSubscription = fetch()
//    .subscribe { event in
//        print("as observable: \(event)")
//    }
//
//let singleSubscrition = fetch().asSingle()
//    .subscribe(onSuccess: {
//        print("as single, success: \($0)")
//    }, onError: {
//        print("as single fail: \($0)")
//    })

let trigger = PublishRelay<Void>()
let busy = BehaviorRelay<Bool>(value: false)

Single.zip(trigger.asSingle(), busy.asSingle())
    .map{ _ in
        print("in mapp..")
        return ()
    }
//    .asSingle()
    .flatMap(fetch)
    .debug()
    .subscribe(onSuccess: {
        print("suc: \($0)")
    }, onError: {
        print("error: \($0)")
    })

trigger.accept(())
busy.accept(false)
//busy.accept(true)

print("\n end")
