/*:
 # Contravariance Exercises

 1.) Determine the sign of all the type parameters in the function `(A) -> (B) -> C`. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.
 */
// TODO
/*:
 2.) Determine the sign of all the type parameters in the following function:

 `(A, B) -> (((C) -> (D) -> E) -> F) -> G`
 */
// TODO
/*:
 3.) Recall that [a setter is just a function](https://www.pointfree.co/episodes/ep6-functional-setters#t813) `((A) -> B) -> (S) -> T`. Determine the variance of each type parameter, and define a `map` and `contramap` for each one. Further, for each `map` and `contramap` write a description of what those operations mean intuitively in terms of setters.
 */
// TODO
// A +
// B -
// S -
// T +


/*:
 4.) Define `union`, `intersect`, and `invert` on `PredicateSet`.
 */
// TODO

struct PredicateSet<A> {
    let contains: (A) -> Bool
    func union(_ set: PredicateSet<A>) -> PredicateSet<A> {
        return PredicateSet.init(contains: { a in
            self.contains(a) || set.contains(a)
        })
    }
    
    func intersect(_ set: PredicateSet<A>) -> PredicateSet<A> {
        return PredicateSet.init(contains: { a in
            self.contains(a) && set.contains(a)
        })
    }
    
    func invert() -> PredicateSet<A> {
        return PredicateSet.init(contains: { a in
            !self.contains(a)
        })
    }
}

let xset = PredicateSet(contains: { [1, 2, 3].contains($0) })
let yset = PredicateSet(contains: { [3, 4, 5].contains($0) })
let zset = xset.union(yset)
let r = zset.contains(6)
let zzset = xset.intersect(yset)
let results = [1, 2, 3, 4, 5, 6].map { zzset.contains($0) }
let zzzset = xset.invert()
let results_invert = [1, 2, 3, 4, 5, 6].map { zzzset.contains($0) }


/*:
 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.

 5a.) Create a predicate set `isPowerOf2: PredicateSet<Int>` that determines if a value is a power of `2`, _i.e._ `2^n` for some `n: Int`.
 */
// TODO
let isPowerOf2 = PredicateSet<Int>.init(contains: { a in
    return (a != 0) && ((a & (a - 1)) == 0)
})

isPowerOf2.contains(65)
let powers = (0..<20).map { exp2(Double($0)) }
print(powers.map { isPowerOf2.contains(Int($0)) })



/*:
 5b.) Use the above predicate set to derive a new one `isPowerOf2Minus1: PredicateSet<Int>` that tests if a number is of the form `2^n - 1` for `n: Int`.
 */
// TODO
extension PredicateSet {
    func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
        return PredicateSet<B>(contains: f >>> contains)
    }
}

let isPowerOf2Minus1 = PredicateSet.init(contains: { a in
    isPowerOf2.contains(a + 1)
})
isPowerOf2Minus1.contains(65)
isPowerOf2Minus1.contains(64)
isPowerOf2Minus1.contains(63)
/*:
 5c.) Find an algorithm online for testing if an integer is prime, and turn it into a predicate `isPrime: PredicateSet<Int>`.
 */
// TODO

func prime(_ a: Int) -> Bool {
    func sieveOfEratosthenes(upTo n: Int) -> [Int] {
        var result = [Int]()
        var composite = [Bool](repeating: false, count: n + 1)
        for i in 2...n {
            if !composite[i] {
                result.append(i)
                for multiple in stride(from: i * i, through: n, by: i) {
                    composite[multiple] = true
                }
            }
        }
        return result
    }
    
    let result = sieveOfEratosthenes(upTo: a)
    return result.last == a
}

prime(3)
prime(25)
prime(29)

let isPrime = PredicateSet.init(contains: prime)

isPrime.contains(3)
isPrime.contains(25)
isPrime.contains(29)
/*:
 5d.) The intersection `isPrime.intersect(isPowerOf2Minus1)` consists of numbers known as [Mersenne primes](https://en.wikipedia.org/wiki/Mersenne_prime). Compute the first 10.
 */
// TODO
let mersennePrimes = isPrime.intersect(isPowerOf2Minus1)

func calculateMersennes(count: Int) {
    var x = 3
    var mersennes: [Int] = []
    repeat {
        if mersennePrimes.contains(x) {
            print("\(x) is a Mersenne prime number")
            mersennes.append(x)
        }
        x = x + 1
    } while mersennes.count < count
}

//calculateMersennes(count: 10)


/*:
 5e.) Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and `intersect`?
 */
// If the original set DOES contain the number: only the original set is evaluated the unioning set will never be evaluated if the original set contains the number. But both the intersecting sets have to be evaluated.
// If the original set does not contain the number, the unioning set will always be evaluated. And th

//                             Union            Intersect
//                               ||                &&
//  original set
//  contains                  no evaluation: 1     evaluate: 2
//
// original set does          evaluate; 2         no evaluation: 1
// not contain
//
//                          union is more performant
//                         if original set DOES contain the number
//
//                                          intersect is more permant
//                                            if original set does not contain the number
//

/*:
 6.) What is the difference between `isPrime.intersect(isPowerOf2Minus1)` and `isPowerOf2Minus1.intersect(isPrime)`? Which one represents a more performant predicate set?
 */
// In isPrime.intersect - first we have to find a prime number, then evaluate the pwer of 2
// In powerof2 - first we evaluate the power of 2, then a prime number
// power of 2 is a quicker algorithm
// but are you more or less likely to find a prime number or a power of 2 - 1?
// I think isPowerOf2Minus1.intersect(isPrime) will be more performant because there are less powers of 2 to find and the algorithm itself is much quicker to not find the number
/*:
 7.) It turns out that dictionaries `[K: V]` do not have `map` on `K` for all the same reasons `Set` does not. There is an alternative way to define dictionaries in terms of functions. Do that and define `map` and `contramap` on that new structure.
 */
// TODO

struct PredicateDictionary<Key, Value> {
    let valueForKey: (Key) -> Value?
}

let d: PredicateDictionary<String, String> = PredicateDictionary.init(valueForKey: { key in
    return ["apple", "bear", "coffee"].filter { $0.first! == key.first }.first
})

d.valueForKey("a")

extension PredicateDictionary {
    func map<T>(_ f: @escaping (Value?) -> T) -> PredicateDictionary<Key, T> {
        return PredicateDictionary<Key, T>.init(valueForKey: valueForKey >>> f)
    }
    
    func contramap<L>(_ f: @escaping (L) -> Key) -> PredicateDictionary<L, Value> {
        return PredicateDictionary<L, Value>.init(valueForKey: f >>> valueForKey)
    }
}
/*:
 8.) Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).
 */
// TODO
typealias CharacterSet = PredicateSet<Character>
let capitalizedLetters = CharacterSet.init(contains: { character in
    return ["ABCDEFGHIJKLMNOPQRSTUVWXYZ"].contains(String(character))
})
/*:
 Let's explore happens when a type parameter appears multiple times in a function signature.

 9a.) Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or `contramap` on `A`.
 */
// TODO
/*:
 9b.) Is `A` in positive or negative position in `(A, A) -> B`? Define either `map` or `contramap`.
 */
// TODO
/*:
 9c.) Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because functions whose input type is the same as the output type are called "endomorphisms". Notice that `A` is in both positive and negative position. Does that mean that _both_ `map` and `contramap` can be defined, or that neither can be defined?
 */
// TODO
/*:
 9d.) Turns out, `Endo` has a different structure on it known as an "invariant structure", and it comes equipped with a different kind of function called `imap`. Can you figure out what it’s signature should be?
 */
// TODO
/*:
 10.) Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper around an equality check. You can think of it as a kind of "type erased" `Equatable` protocol. Write `contramap` for this type.
 */
// TODO
/*:
 11.) Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the "type erased" analogy, this is like a "witness" to the `Equatable` conformance of `Int`. Show how to use `contramap` defined above to transform `intEquate` into something that defines equality of strings based on their character count.
 */
// TODO
