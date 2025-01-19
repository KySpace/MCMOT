There were two proposed way of generating the initial distribution of particles in the 2D MOT simulation.

1. We start from a 3D Maxwell-Boltzmann distribution (characterized by the initial temperature) inside of the cuvette (whose geometry is determined by the parameters `hl` and `hw`), and have it evolve from there. In this case, all particles are confined inside the cuvette. When one particle hits the wall, we simply assign a different velocity (facing inside the wall), with the newly generated velocity also following the MB (characterized by the wall temperature, which should be the same as the initial temperature afterall). 
To predict the realistic flow in the tube from the result. We only need to scale the collected rate from the tube by the ratio of the actual density and the simulation density.
\[
    \dfrac{\text{d}N}{\text{d}t}_\text{real} = \dfrac{\text{d}N}{\text{d}t}_\text{simu} \dfrac{N_\text{real}}{N_\text{simu}}
\]
2. Instead, we can start from only the surfaces of the cuvette. Positionally uniform in 2D. The velocity distribution should be that reflecting the flow of a MB characterized by the wall temperature. In principle, the particles that go out of bound are discarded (or marked as inactive), so after a duration long enough, every particle are either collected as in the tube or not, we should have an acceptance for this initialf flow \(\alpha \in [0, 1]\). The predicted realistic flow in the tube, is the acceptance rate multiplied by the calculated realistic flow on the surface.
\[
    \dfrac{\text{d}N}{\text{d}t}_\text{real} = \dfrac{\text{d}N}{\text{d}t}_\text{real, surf} \alpha
\]

To compare and choose the two methods, we should first question what the actual distribution inside of the cuvette is. Before the MOT has been turned on, the distribution in the chamber is naturally MB. but after a while, while the 2D MOT is actually present and the inward and outward flow balances, it would be harder to predict or even discribe what the distribution would be. 

So, the method 1, in theory, should reflect this dynamics when the MOT just turned on, but only later down in the simulation will the flow reflect the steady MOT flow (which should be the part that contributes mainly to loading a 3D MOT). But if the steady flow is the target, the intial distribution probably doesn't even matter -- the wall will bounce them to the right distribution anyway.

Method 2 predicts the steady flow directly. What justifies our ignorance of the MOT's effect on the wall's distribution is the belief that: no matter what velocity profile is when it hits the wall, the profile reflected by the wall should still be MB. This statement is for velocity profile only, though, so one can doubt about the effect of the MOT on the density profile when hitting the wall. Perhaps one would argue that less would hit the wall where the light beam hit the wall since that's the part that the particles are trapped the most, and I acknowledge this potential discrepency.

A benefit of the Method 2 is, that we can better study the initial state of those particles that ultimately reaches the end of the tube: Where on the wall are the from (what's the last time they hit the wall), and the velocity requirement for that initial state. This allows our simulation to be less than a black box and opens chances for some diagnostics (In fact, we found many bugs by using this method). We can also truncate the velocity profile by discarding the high velocity particles that we see no hope captured by the MOT at all, thus allowing more effectiveness and saving more resources and yet still scale the final number to the realistic predictions.

### What's the distribution?
So what's the distribution we need to generate a surface to reflect a volume MB? Let's rephrase our goals again. We want to generate a collection of particles on a surface, that is equivalent of the flux on the surface from a volume MB (on one side) within \(\Delta t\); or we can say that we want to compress whatever comes through the surface within \(Delta t\) from a volume MB, to an infinitesimal time interval. Therefore, the velocity probability density of our random generation is proportional to the velocity-specific flux rate \(\phi_{\vec v}\) (Here we have already omitted the spatial density because it's obviously uniform for either 2D or 3D). 

The primary thing to consider is that, even with a fixed volume density, the flux should be higher for higher velocity components, but we shouldn't say "the velocity" in general, what really matters is the velocity normal to the surface. In this spirit, we write down a velocity distribution by decomposing the velocity into two orthogonal parts \(v_\text{norm}\) and \(\vec v_\text{para}\): \(\phi_T(\vec v) \propto v_\text{norm}f_{T,\text{1DMB}}(v_\text{norm}) \cdot v_\text{norm}f_{T,\text{2DMB}}(\vec v_\text{para})\)
, where \(f_{T,\text{1DMB}} = v\mapsto \dfrac{1}{\sqrt{2\pi}v_T}e^{-\frac{1}{2}(v/v_T)^2}\), and \(f_{T,\text{2DMB}} = (u,v)\mapsto f_{T,\text{1DMB}}(u)f_{T,\text{1DMB}}(v)\), and \(v_T = \sqrt{k_BT/m}\) is the scale parameter. In this way, the distribution of our 3D velocity is separable to all three orthogonal directional basis, we can also normalize them separately.

\[
    f_{T,\text{norm}} = v \mapsto v e^{-\frac{1}{2}(v/v_T)^2}/v_T^2 \\
    f_{T,\text{para}} = v \mapsto \dfrac{1}{\sqrt{2\pi}v_T} e^{-\frac{1}{2}(v/v_T)^2}
\]
We're simpler refer these two functions as weighted MB (wMB) and MB in the following paragraphs. 
#### Proof
A way of deriving this distribution is by picturing a spatial prism containing the particles with velocity \(\vec v = (\vec v_\text{para}, v_\text{norm})\) that ends up groing through a portion of the surface with area \(S\), which is now the bottom of the prism. It's easy to see that \(\vec v_\text{para}\) would only decide the obliqueness of the prism, and only \(\vec v_\text{norm}\) will decide it's height and contribute to the volume value, which is \( v_\text{norm} \Delta t \, S\). If we know the volume density of this velocity \(n_{\text{MB},T,\vec v}\), we should have the flux number to be \(n_{\text{MB},T,\vec v} v_\text{norm} \Delta t \, S\), and the flux rate density is \(\sigma_{\text{MB},T,\vec v} = n_{\text{MB},T,\vec v} v_\text{norm}\). 

#### Generation
To generate such a distribution on a surface is, fortunately, not hard. This is because that the 3D velocity distribution can be separated to 3 1D distribution. For wMB, the 1D distributions is analytical, and its cumulative density function (CDF), can also be written down analytically, and even the CDF's inverse function can also be analytical. MB's CDF and inverse CDF is not analytical, but it's very well known is a part of the MATLAB's library functions. See `gendist_uniflow` for details.
\[
    \Phi_{\text{MB},T} = v \mapsto \dfrac{1}{2} \Big[1 + \text{erf}\Big(\dfrac{v}{\sqrt{2}v_T}\Big)\Big] \\
    \Phi_{\text{MB},T}^{-1} = c \mapsto \text{erf}^{-1}(2c - 1) \sqrt{2} v_T \\
    \Phi_{\text{wMB},T} = 1 - e^{-\frac{1}{2}(\frac{v}{v_T})^2} \\
    \Phi_{\text{wMB},T}^{-1} = c \mapsto \sqrt{-2 \log (1 - c)} v_T
\]
The only tricky part left is that to generate on different surfaces, we need to decompose the velocity according to the surface direction. 
#### Veryfication
To verify that this is the case. We can start from a uniform 3D MB distribution on the one side of a surface facing \(+z\), and observe the particles that goes through a small area on the surface \(z=0\), which we'll call the target. Of course, we cannot initially fill in the entire space, but at least we can fill a space that is so large, that the particles from outside of that space but will still end up going through our target are neglegibly few. Let's make this space within a boundary of surface \(z=0\) and the half dome centered around the origin with a radius \(R\). 

For example, I set a target to be a square with width \(a\) centered around the origin, with \(a \ll R\). Let's generate plenty of particles within the boundary according to the Maxwell-Boltzmann distribution with temperature \(T\), each with a 3D vector of position and a 3D vector of velocity. We setup a traveling time \(\Delta t\) and examine for each particle on whether it piece the target surface within that time. Or, equivalently, we find the intersection point and time for each particle and examine whether 1. the point is within the target square, and 2. the time falls within \((0, \Delta t)\). The requirement is that \(R \gg v_T \Delta t\). In the end, we do statistics on the distribution of the particles on target. 
#### The balance
#### Conservation in MB
### Diagnostics