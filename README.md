# SwiftCMA
## by Santiago Gonzalez
### ***A pure-Swift implementation of the Covariance Matrix Adaptation Evolutionary Strategy (CMA-ES) algorithm.***

**SwiftCMA** is a *de novo* implementation of [Covariance Matrix Adaptation Evolutionary Strategy](https://en.wikipedia.org/wiki/CMA-ES) (CMA-ES). CMA-ES is a wonderful population-based optimization technique that can optimize non-convex, non-smooth, non-differentiable functions. While CMA-ES is conceptually simple, it's rather complex mathematically. **SwiftCMA** is written in pure Swift, and makes proper use of functional programming and Swift's type system. This project is provided under the MIT License (see the `LICENSE` file for more info).

**SwiftCMA** can be added to your project as a dependency with the Swift Package Manager.

## Functionality

### CMA-ES

The specific implementation of CMA-ES is inspired by the MATLAB reference implementation on [Wikipedia](https://en.wikipedia.org/wiki/CMA-ES). The implementation supports arbitrarily-high dimension solution spaces. The specific flavor of CMA-ES that's implemented is (mu/mu,lambda)-CMA-ES with weighted rank-mu updates.

The primary `CMAES` object has two slightly different implementations of the main `epoch()` method.
* One takes a closure that takes an array of candidate solution vectors and returns an array of corresponding objective function values. This allows your code to potentially calculate objective function values concurrently.
* Alternatively, for simplicity, you can use the flavor of `epoch()` that takes an objective evaluator. Objective functions can be represented by types that conform to the `ObjectiveEvaluator` protocol. In this case, objective function values are calculated sequentially on the same thread.

### Linear Algebra API

Swift isn't traditionally thought of as a good language for linear algebra code, though I feel that's mainly due to the lack of linear algebra APIs. **SwiftCMA** provides a clean API for vectors and matrices, based on top of Swift arrays, that should feel familiar if you've used Eigen / MATLAB / Octave, or similar systems. This API has not been optimized to be as fast as it could be since objective-function evaluation is the biggest bottleneck by far for what I created this library for (metalearning). Pull requests are welcome!

Features:
* Vectors and vector operations
* Matrices and matrix operations
* Vector-matrix operations
* Eigendecomposition of matrices to get eigenvalues and an eigenbasis
* Covariance matrix wrapper

### Tests

Testing is great, so we have some unit and integration tests as part of the package! More tests would be great, right now the tests mostly just cover the linear algebra APIs.

### Built-in Objective Functions

**SwiftCMA** has some built-in objective functions. These are useful for testing / benchmarking how well the system is able to optimize some relatively well-understood functions.

* N-dimensional sphere: `SphereObjectiveEvaluator`
* Rastrigin function: `RastriginObjectiveEvaluator`
* Ackley function: `AckleyObjectiveEvaluator`

### Checkpointing

Every state object in **SwiftCMA** conforms to the Swift `Codable` protocol, allowing serialization and deserialization. The `CMAES` class provides a lovely abstraction for this that allows writing and reading checkpoints in one line:

```swift
let cmaes: CMAES = ...
let checkpointFile: URL = ...
// Create a checkpoint.
try cmaes.save(checkpoint: checkpointFile)
// Read the checkpoint.
let reconstituted = try CMAES.from(checkpoint: checkpointFile)
```

## Usage

Everything you need to use **SwiftCMA** is in the `Sources/` directory.

```swift
let startSolution: Vector = ...
var fitness = MyObjectiveEvaluator()
let populationSize = CMAES.populationSize(forDimensions: startSolution.count)
let stepSigma: Double = ...

let cmaes = CMAES(startSolution: startSolution, populationSize: populationSize, stepSigma: stepSigma)
var bestSolution: (Vector, Double)?
for i in 0..<1000 {
	cmaes.epoch(evaluator: &fitness) { newSolution, newFitness in
		print("Found solution with fitness \(fitness): \(solution)")
	}

	if bestSolution == nil || bestSolution!.1 > cmaes.bestSolution!.1 {
		bestSolution = cmaes.bestSolution
	}
	print("\(i):   \(cmaes.bestSolution!.1)")
}

print("Best: \(bestSolution!.1): \(bestSolution!.0)")
```

### Defining an Objective Function

CMA-ES aims to find the global minimum, so your objective function must be formulated so that smaller values are better.

```swift
struct SphereObjectiveEvaluator: ObjectiveEvaluator {
	typealias Genome = Vector

	func objective(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let value = genome.squaredMagnitude // We want to minimize our distance from the origin.
		if value < 0.01 { // We have found a solution when our value is below a threshold.
			solutionCallback(genome, value)
		}
		return value
	}
}
```

### Dependencies

The only external dependency is `LAPACK` (for eigendecomposition). On macOS, this is fulfilled by the built-in `Accelerate` framework. On Linux, you should use the [CLapacke-Linux](https://github.com/indisoluble/CLapacke-Linux) Swift wrapper around `LAPACK`. If your Linux installation does not have `LAPACK` you can install it with this command: `sudo apt-get install liblapacke-dev`

## Citing

If you use **SwiftCMA** in a publication, you can use the following BibTeX entry to cite this project:

```
@misc{swiftcma,
	Title = {SwiftCMA},
	Author = {Santiago Gonzalez},
	howpublished = {\url{https://github.com/sgonzalez/SwiftCMA}}
}
```

## Future Work

* Separate linear algebra API into its own library.
* Faster.
* Support fun variants of CMA-ES.
* More tests (unit, integration, performance).
* An engaging test app that visualizes the CMA-ES process.
