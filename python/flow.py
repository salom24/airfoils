import numpy as np
import matplotlib.pyplot as plt

S1x = 0
S1y = 0
S1stren = 2
S2x = 5
S2y = 0
S2stren = 10
stream = np.array([10, 0])

x, y = np.mgrid[-10:10:0.05, -10:10:0.05]

Vx = S1stren * (x-S1x) / ((x-S1x)**2 + (y-S1y)**2) + S2stren * (x-S2x) / \
    ((x-S2x)**2 + (y-S2y)**2) + stream[0]
Vy = S1stren * (y-S1y) / ((x-S1x)**2 + (y-S1y)**2) + S2stren * (y-S2y) / \
    ((x-S2x)**2 + (y-S2y)**2) + stream[1]

plt.streamplot(y, x, Vy, Vx)
plt.plot(S1x, S1y, ".", S2y, S2x, ".")
plt.show()
