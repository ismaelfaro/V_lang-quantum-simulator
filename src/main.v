module main

import math
import rand

const r2 = 0.70710678118

const pi = math.pi

struct Complex {
	r f64
	i f64
}

struct Gate {
	name   string
	qubit  i32
	target i32
	theta  f64
}

pub struct QuantumCircuit {
	qubits i32
mut:
	circuit []Gate
}

pub fn (mut this QuantumCircuit) addgate(gate Gate) {
	this.circuit << gate
}

pub fn (mut this QuantumCircuit) x(qubit i32) {
	this.addgate(Gate{'x', qubit, 0, 0.0})
}

pub fn (mut this QuantumCircuit) rx(qubit i32, theta f64) {
	this.addgate(Gate{'rx', qubit, 0, theta})
}

pub fn (mut this QuantumCircuit) h(qubit i32) {
	this.addgate(Gate{'h', qubit, 0, 0.0})
}

pub fn (mut this QuantumCircuit) cx(qubit i32, target i32) {
	this.addgate(Gate{'cx', qubit, target, 0.0})
}

pub fn (mut this QuantumCircuit) ry(qubit i32, theta f64) {
	this.rx(qubit, pi / 2)
	this.h(qubit)
	this.rx(qubit, theta)
	this.h(qubit)
	this.rx(qubit, -pi / 2)
}

pub fn (mut this QuantumCircuit) rz(qubit i32, theta f64) {
	this.h(qubit)
	this.rx(qubit, theta)
	this.h(qubit)
}

pub fn (mut this QuantumCircuit) z(qubit i32, theta f64) {
	this.rz(qubit, pi)
}

pub fn (mut this QuantumCircuit) y(qubit i32, theta f64) {
	this.rz(qubit, pi)
	this.x(qubit)
}

pub fn (mut this QuantumCircuit) str() string {
	return '${this.circuit}'
}

pub struct QuantumSimulator {
	qubits  i32
	circuit QuantumCircuit
mut:
	state_vector []Complex
}

pub fn (mut this QuantumSimulator) init() {
	leght_sate_vector := int(math.pow(2, this.qubits))
	for _ in 0 .. leght_sate_vector {
		this.state_vector << Complex{0.0, 0.0}
	}
	this.state_vector[0] = Complex{1.0, 0.0}
}

fn (mut this QuantumSimulator) superpose(x Complex, y Complex) []Complex {
	return [Complex{r2 * (x.r + y.r), r2 * (x.i + y.i)}, Complex{r2 * (x.r - y.r), r2 * (x.i - y.i)}]
}

fn (mut this QuantumSimulator) turn(x Complex, y Complex, theta f64) []Complex {
	part1 := Complex{x.r * math.cos(theta / 2) + y.i * math.sin(theta / 2), x.i * math.cos(theta / 2) - y.r * math.sin(theta / 2)}
	part2 := Complex{y.r * math.cos(theta / 2) + x.i * math.sin(theta / 2), y.i * math.cos(theta / 2) - x.r * math.sin(theta / 2)}
	return [part1, part2]
}

fn (mut this QuantumSimulator) probability(shots i32) []string {
	mut probabilities := []f64{}
	for i in 0 .. this.state_vector.len {
		value := this.state_vector[i]
		probabilities << math.pow(value.r, 2) + math.pow(value.i, 2)
	}

	output := []string{}
	for _ in 0 .. shots {
		mut cumu := 0.0
		un := true
		r := rand.int()
		for i in 0 .. probabilities.len {
			cumu += probabilities[i]
			if r < cumu && un {
				// raw_output := i.str(2).padStart(this.qubits, '0');
				// output.push(raw_output)
				// un=false;
			}
		}
	}
	return ['${output}']
}

fn (mut this QuantumSimulator) state_vector2str() string {
	mut output := ''
	for i in 0 .. this.state_vector.len {
		value := this.state_vector[i]
		bits := '[${int(i):b}]'
		// bits := ' '
		output += bits + ' ' + value.r.str() + '+' + value.i.str() + 'j\n'
	}
	return output
}

pub fn (mut this QuantumSimulator) str() string {
	return this.state_vector2str()
}

pub fn (mut this QuantumSimulator) memory(shots i32) []string {
	return this.probability(shots)
}

pub fn (mut this QuantumSimulator) counts(shots i32) map[string]i32 {
	probabilities := this.probability(shots)
	mut counts := map[string]i32{}
	for i in 0 .. probabilities.len {
		value := probabilities[i]
		if value in counts {
			counts[value] = counts[value] + 1
		} else {
			counts[value] = 1
		}
	}
	return counts
}

pub fn (mut this QuantumSimulator) run(shots i32) {
	circuit_list := this.circuit.circuit
	for i in 0 .. circuit_list.len {
		gate := this.circuit.circuit[i]
		// one Gate instructions
		if gate.name in ['x', 'h', 'rx'] {
			for cont_qubit in 0 .. i32(math.pow(2, gate.qubit)) {
				for cont_state in 0 .. i32(math.pow(2, this.qubits - gate.qubit - 1)) {
					b0 := cont_qubit + i32(math.pow(2, gate.qubit + 1) * cont_state)
					b1 := i32(b0 + math.pow(2, gate.qubit))
					if gate.name == 'x' {
						temp := this.state_vector[b0]
						this.state_vector[b0] = this.state_vector[b1]
						this.state_vector[b1] = temp
					}
					if gate.name == 'h' {
						superposition_result := this.superpose(this.state_vector[b0],
							this.state_vector[b1])
						this.state_vector[b0] = superposition_result[0]
						this.state_vector[b1] = superposition_result[1]
					}
					if gate.name == 'rx' {
						turn := this.turn(this.state_vector[b0], this.state_vector[b1],
							gate.theta)
						this.state_vector[b0] = turn[0]
						this.state_vector[b1] = turn[1]
					}
				}
			}
		} else {
			// two Gates Instructions
			if gate.name == 'cx' {
				mut limits := [gate.qubit, gate.target]
				if limits[0] > limits[1] {
					limits = [gate.target, gate.qubit]
				}

				for cx0 in 0 .. i32(math.pow(2, limits[0])) {
					for cx1 in 0 .. i32(math.pow(2, limits[1] - limits[0] - 1)) {
						for cx2 in 0 .. i32(math.pow(2, this.qubits - limits[1] - 1)) {
							b0 := i32(cx0 + math.pow(2, limits[0] + 1) * cx1 +
								math.pow(2, limits[1] + 1) * cx2 + math.pow(2, gate.qubit))

							b1 := i32(b0 + math.pow(2, gate.target))

							temp := this.state_vector[b0]
							this.state_vector[b0] = this.state_vector[b1]
							this.state_vector[b1] = temp
						}
					}
				}
			}
		}
	}
}

fn main() {
	qubits := i32(18)

	mut qc := QuantumCircuit{
		qubits: qubits
	}

	qc.h(0)
	qc.h(1)
	qc.h(2)
	qc.h(3)
	qc.h(4)

	qc.cx(0, 5)
	qc.cx(1, 6)
	qc.cx(2, 7)
	qc.cx(3, 8)
	qc.cx(4, 9)

	println(qc)

	mut qsim := QuantumSimulator{
		qubits: qubits
		circuit: qc
	}
	qsim.init()
	qsim.run(1024)

	print(qsim)
}
