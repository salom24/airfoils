import numpy as np
import matplotlib.pyplot as plt
from re import match

# Nodes in each face
nodes = 100

# Get input
# name = ""
# while not match(r"^\d\d\d\d$", name):
#     name = input("Naca 4 digit: ")
name = "6515"

# Naca airfoil data
h = int(name[0])/100
p = int(name[1])/10
t = int(name[2:])/100

# Velocity and angle of attack
aoa = 0
aoa = np.deg2rad(aoa)
speed = 10
U = np.array([speed * np.cos(aoa), speed * np.sin(aoa)])

# Distribution of nodes in x axis
cx = (1 - np.cos(np.pi * np.arange(nodes) / (nodes - 1))) / 2

# Width of symetric airfoil
width = t*5*(0.2969*np.sqrt(cx) - 0.126*cx - 0.3516*cx**2 + 0.2843*cx**3 - 0.1036*cx**4)

# Curvature of foil
cy = np.where(cx <= p,\
    (h/p**2) * (2 * p * cx - cx**2),\
    (h/(1 - p)**2) * (1 - 2*p + 2*p*cx - cx**2))

# Slope of the airfoil chord
dy = np.where(cx <= p,\
    2 * (h/p**2) * (p - cx),\
    2 * (h/(1 - p)**2) * (p - cx))
theta = np.arctan(dy)

# Airfoil node points
nx = np.concatenate(((cx - width * np.sin(theta))[-2:0:-1],\
    cx + width * np.sin(theta)))
ny = np.concatenate(((cy + width * np.cos(theta))[-2:0:-1],\
    cy - width * np.cos(theta)))

# Panel middle points
P = np.array([(nx + np.roll(nx, 1)) / 2,\
    (ny + np.roll(ny, 1)) / 2])

# Size of panels
s = np.sqrt((nx - np.roll(nx, 1))**2 +\
    (ny - np.roll(ny, 1))**2)

# Normal and tangent to pannel
T = np.array([(nx - np.roll(nx, 1)) / s,\
    (ny - np.roll(ny, 1)) / s])
N = np.array([[0, 1],[-1, 0]]).dot(T)

# Relative velocity to pannel
Ut = U.dot(T)
Un = U.dot(N)

###### Pannel method ######
# Shapes = [2d, control, pannel travelled]

# Distance between pannels
D = P[:,:,None] - P[:,None,:]
Dt = np.einsum("ijk,ik->jk", D, T)
print(Dt[0])
Dn = np.einsum("ijk,ik->jk", D, N)


# Induced velocity
Sp = np.array([0.5*(np.log((Dt + s/2)**2 + Dn**2) - np.log((Dt - s/2)**2 + Dn**2)),\
    0.5*(np.log((Dt + s/2)**2 + Dn**2) - np.log((Dt - s/2)**2 + Dn**2))])

S = np.array([np.einsum("ijk,ik->jk", Sp, -T), np.einsum("ijk,ik->jk", Sp, -N)])
Ss = np.array([np.einsum("ijk,ij->jk", S, T), np.einsum("ijk,ij->jk", S, N)])

lam = np.linalg.solve(Ss[1], -Un)

Cp = 1 - ((np.einsum("jk,k->j", Ss[0], lam) + Ut) / speed)**2

####### Falta termnar....

# Plotting
plt.grid()
plt.plot(nx, ny, "b") # Airfoil
plt.plot(cx, cy, "r--") # Chord
# plt.plot(P[0], P[1], "m.") # Pannels
# plt.plot(px, s) # Pannel size
# plt.quiver(P[0], P[1], N[0], N[1]) # Normals
# plt.quiver(P[0], P[1], Speed[0], Speed[1])
# plt.plot(P[0], Cp)
plt.gca().set_ylim([-0.5,0.5])
plt.gca().set_aspect("equal")
plt.show()