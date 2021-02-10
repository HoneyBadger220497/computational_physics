# Simulation: Free Dirac Fermion

| Parameter | Simulation 1 | Simulation 2 | Simulation 3 | Simulation 4 |
|---------- | ------------ | ------------ | ------------ | ------------ |
|   c       |   0.0001     |   0.0001     |   0.0001     |   0.0001     |
|   mass    |     0 eV     |   0.0001 eV  |   0.01  eV   |  0.00001 eV  |  
|   E_avg   |   0.0044 eV  |   0.0044 eV  |   0.0109 eV  |   0.0109 eV  |
|   k_x     |   30 ev      |   30 ev      |   30 ev      |   30 ev      |
|   k_y     |   30 ev      |   30 ev      |   30 ev      |   30 ev      |
|           |              |              |              |              |
|   dx      |    0.01      |    0.01      |    0.01      |    0.01      |
|   dy      |    0.01      |    0.01      |    0.01      |    0.01      |
|   c*dt    |    0.004     |    0.004     |    0.4       |    0.2       |
|   rx      |    0.4       |    0.4       |    0.4       |    0.4       |
|   ry      |    0.4       |    0.4       |    0.4       |    0.4       |

The space-time domain of the simulation is allways the same.
There is no potential.

For the other parameter see the simulation script, stored in:
    A_FreeGaussianWavepacket.m

# Simulation: AbsorbingBoundaries

| Parameter |     Pml      |  Imag. Pot.  |
|---------- | ------------ | ------------ |
|   c       |   0.001      |   0.001      |
|   mass    |    0 eV      |    0 eV      |
|   E_avg   |   0.0504 eV  |   0.0504 eV  |
|   k_x     |   30 ev      |   30 ev      |
|   k_y     |   30 ev      |   30 ev      |
|           |              |              |
|   dx      |    0.008     |    0.008     |
|   dy      |    0.008     |    0.008     |
|   c*dt    |    0.0032    |    0.0032    |
|   rx      |    0.4       |    0.4       |
|   ry      |    0.4       |    0.4       |

For the other parameter see the simulation script, stored in:
    A_FreeGaussianWavepacketPml.m
    A_FreeGaussianWavepacketImaginaryPotential.m

The space-time domain of the simulation is allways the same.
There is no potential.

# Simulation: Klein Step

| Parameter | Simulation 1 | Simulation 2 | Simulation 3 | Simulation 4 | Simulation 5 |
|---------- | ------------ | ------------ | ------------ | ------------ | ------------ |
|   angle   |      0       |     0°       |      60°     |     60°      |       0°     |
|   c       |   0.0001     |   0.0001     |   0.0001     |   0.0001     |   0.0001     |
|   mass    |     0 eV     |     0 eV     |     0 eV     |     0 eV     |     0 eV     |
|   V1      |   0.00 eV    |   0.00 eV    |   0.00 eV    |   0.00 eV    |   0.00 eV    |
|   V2      |   0.02  eV   |   0.005 eV   |   0.02 eV    |   0.005 eV   |   0.009 eV   |
|   E_avg   |   0.0101 eV  |   0.0101 eV  |   0.0102 eV  |   0.0102 eV  |   0.0101 eV  |
|   E_var   |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |
|   k_x     |   100 ev     |    100 ev    |    100 ev    |   100 ev     |   100 ev     |
|   k_y     |     0 ev     |      0 ev    |     50 ev    |    50 ev     |      0 ev    |
|           |              |              |              |              |
|   dx      |    0.005     |    0.005     |    0.005     |    0.005     |    0.005     |
|   dy      |    0.005     |    0.005     |    0.005     |    0.005     |    0.005     |
|   c*dt    |    0.002     |    0.002     |    0.002     |    0.002     |    0.002     |
|   rx      |    0.4       |    0.4       |    0.4       |    0.4       |    0.4       |
|   ry      |    0.4       |    0.4       |    0.4       |    0.4       |    0.4       |

The space-time domain of the simulation is allways the same.
There is no potential.

For the other parameter see the simulation script, stored in:
    A_KleinStep.m

# Simulation: Massstep

| Parameter | Simulation 1 | Simulation 2 | Simulation 3 | Simulation 4 | Simulation 5 |
|---------- | ------------ | ------------ | ------------ | ------------ | -----------  |
|   angle   |      0       |     0°       |      60°     |     60°      |     0°       |  
|   c       |   0.0001     |   0.0001     |   0.0001     |   0.0001     |   0.0001     |
|   V       |     0 eV     |     0 eV     |     0 eV     |     0 eV     |     0 eV     |
|   mass1   |   0.00 eV    |   0.00 eV    |   0.00 eV    |     0 eV     |     0 eV     |
|   mass2   |   0.02  eV   |   0.005 eV   |   0.02 eV    |   0.005 eV   |    0.009 eV  |
|   E_avg   |   0.0101 eV  |   0.0101 eV  |   0.0102 eV  |   0.0102 eV  |   0.0102 eV  |
|   E_var   |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |   0.0009 eV  |
|   k_x     |   100 ev     |    100 ev    |    100 ev    |   100 ev     |   100 eV     |
|   k_y     |     0 ev     |      0 ev    |     50 ev    |    50 ev     |     0 eV     |
|           |              |              |              |              |
|   dx      |    0.005     |    0.005     |    0.005     |    0.005     |    0.005     |
|   dy      |    0.005     |    0.005     |    0.005     |    0.005     |    0.005     |
|   c*dt    |    0.002     |    0.002     |    0.002     |    0.002     |    0.002     |
|   rx      |    0.4       |    0.4       |    0.4       |    0.4       |    0.4       |
|   ry      |    0.4       |    0.4       |    0.4       |    0.4       |    0.4       |

The space-time domain of the simulation is allways the same.
There is no potential.

For the other parameter see the simulation script, stored in:
    A_KleinStep.m
