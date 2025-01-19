# MCMOT: Monte Carlo Simulation of 2D/3D MOT in a chamber
A n-D MOT Monte-Carlo simulation for atomic particles.
### 2D MOT Cuboid Cuvette
This program generates particles in the cuboid with velocities and positions in 3D, and calculates its trajectory under the influence of cooling light beams, magnetic field, gravity, and cuvette wall scatterings etc. The setup conditions such as the cuvette size, temperature, light and current parameters can be tuned to study their effect on cooling, trapping or forming a atomic flow.
## Required Libraries
This repo already includes three submodules: `[MatlabFunctional]`, `[UltracoldCommons]`, `[VisualHelpers]`. It also requires Matlab add-ons: `Statistics and Machine Learning Toolbox`. Other than that it should be ready to run. To clone with all submodules, use 

```git clone --recurse-submodules https://github.gatech.edu/kwang407/MCMOT.git```.
## MOT setup
### Transverse Cooling Beams
### Coils and Magnetic Field
### Spontaneous emission 
## Thermaldynamics
### Initial velocity distribution
### Wall interactions
## Statistics
## Visualization
#### Figure
- setter
the setter function is required to return the following ouputs
  - figure handle: a single figure that the setter created
  - updaters: a structure of the updating functions (can be used to save graphic resources and avoid re-plotting)
  - graphic objects: a structure containing objects such as axes, annotations, indicators etc.
## Fields
The following classes setup a cooling or magnetic field and how they are calculated during simulation.
- `CurrUnit` & `BeamUnit` & `GravUnit`, contains unit segments of the field source. The unit is with simple shape that the field generated can be easily calculated, e.g. gaussian beam, line current or circular coils.
- `FieldSettings`, contains multiple units that can be used for field calculation. 
- `EnvLight, EnvMagnetic, EnvGrav < EnvField`. Provide details on how the fields are calculated. (in-situ or baked). 
