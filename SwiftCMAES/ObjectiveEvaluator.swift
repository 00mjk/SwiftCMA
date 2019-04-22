//
//  ObjectiveEvaluator.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

protocol ObjectiveEvaluator {
	associatedtype Genome
	func objective(genome: Genome, solutionCallback: (Genome, Double) -> ()) -> Double
}


struct SphereObjectiveEvaluator: ObjectiveEvaluator {
	typealias Genome = Vector
	
	func objective(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let diff = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.01 {
			solutionCallback(genome, diff)
		}
		return genome.squared.sum
	}
}

struct RastriginObjectiveEvaluator: ObjectiveEvaluator {
	typealias Genome = Vector
	
	func rastrigin(invec: Vector) -> Double {
		let sumTerms = invec.map { $0 * $0 - 10.0 * cos(2.0 * Double.pi * $0) }
		let summedTerm = sumTerms.reduce(0.0, { $0 + $1 })
		return 10.0 * Double(invec.count) + summedTerm
	}
	
	func objective(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let diff = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.1 {
			solutionCallback(genome, diff)
		}
		return rastrigin(invec: genome)
	}
}


struct AckleyObjectiveEvaluator: ObjectiveEvaluator {
	typealias Genome = Vector
	
	func ackley(invec: Vector) -> Double {
		let cosTerms = invec.map { cos(2.0 * Double.pi * $0) }
		let e = 2.71828
		return -20.0 * exp(-0.2 * sqrt(invec.squared.sum)) - exp(0.5 * cosTerms.sum) + e + 20.0
	}
	
	func objective(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let diff = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.1 {
			solutionCallback(genome, diff)
		}
		return ackley(invec: genome)
	}
}
