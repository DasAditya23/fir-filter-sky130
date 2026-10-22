import numpy as np

NUM_TAPS = 8
# Sum of coefficients is exactly 1.0 for a DC gain of 1
coefficients = np.array([-0.015, 0.06, 0.175, 0.28, 0.28, 0.175, 0.06, -0.015])
coeff_fixed = np.round(coefficients * (2**15)).astype(int)
print(f"Coefficients (Q1.15): {coeff_fixed}")

NUM_SAMPLES = 50
np.random.seed(42)
inputs = np.random.randint(-32768, 32767, NUM_SAMPLES)

expected_outputs = []
for i in range(NUM_SAMPLES):
    acc = 0
    for j in range(NUM_TAPS):
        if i - j >= 0:
            acc += inputs[i - j] * coeff_fixed[j]
    out = acc >> 15
    if out > 32767: out = 32767
    if out < -32768: out = -32768
    expected_outputs.append(out)

with open("tb_vectors.txt", "w") as f:
    for i in range(NUM_SAMPLES):
        f.write(f"{inputs[i]:04x} {expected_outputs[i] & 0xFFFF:04x}\n")
print("Generated tb_vectors.txt")
