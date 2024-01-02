# V lang Quantum Simulator 

This is a very basic implementation of a Quantum Simulator in Vlang to learn the basic concepts.
You can understand how work a quamtum computer from the code. The code is devide in two parts, one part allow you create Quantum circuits with basic Quantum Gates, and you can execute it using plain vlang

# Components
- structs
    - Gates: x, rx, ry, rz, z, y, h, cx, m
    - Quantum Circuit

    - Quantum Simulator: 
        - imput: Quantum Circuit
        - outputs: 
            - statevector

# Install

Visit https://vlang.io and install the language

```
git clone https://github.com/ismaelfaro/V_lang-quantum-simulator.git

cd V_lang-quantum-simulator
```

# Run

```
v run .
```

# Example:

```
qubits := i32(10)

mut qc := QuantumCircuit{qubits: qubits}

qc.h(0)
qc.h(1)
qc.h(2)
qc.h(3)
qc.h(4)

qc.cx(0,5)
qc.cx(1,6)
qc.cx(2,7)
qc.cx(3,8)
qc.cx(4,9)

println(qc)

mut qsim := QuantumSimulator{qubits: qubits, circuit: qc}
qsim.init()
qsim.run(1024)

print(qsim) 
```
    
# TODO:
- refactor the code to be more Vlang friendly
- fix the outputs for
    - counts
    - memory

# references
Inspired in MicroQiskit python implementation https://github.com/qiskit-community/MicroQiskit by James Wootton
