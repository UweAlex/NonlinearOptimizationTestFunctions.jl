# Alphabetical List of Benchmark Functions

Generated from package metadata on 2025-11-15. Functions are listed alphabetically with their details.

### ackley
- **Description**: Ackley function: a multimodal, non-convex function with a global minimum at x = [0, ..., 0]. Standard bounds are [-32.768, 32.768]^n as per Molga & Smutnicki (2005). Alternative bounds [-5, 5]^n are available.
- **Formula**: f(x) = -20 \exp\left(-0.2 \sqrt{\frac{1}{n} \sum_{i=1}^n x_i^2}\right) - \exp\left(\frac{1}{n} \sum_{i=1}^n \cos(2\pi x_i)\right) + 20 + e
- **Bounds/Minimum**: Bounds: [-32.768, -32.768]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Molga & Smutnicki (2005): 2.9


### ackley2
- **Description**: Ackley2 function: Continuous, partially differentiable, non-separable, non-scalable, unimodal.
- **Formula**: \f(x) = -200 e^{-0.02 \sqrt{x_1^2 + x_2^2}}
- **Bounds/Minimum**: Bounds: [-32.0, -32.0]; Min: -200.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, partially differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013): f2


### ackley4
- **Description**: Modified Ackley Function with multiple local minima for n=2. The provided local minimum is corrected from literature (which had errors in value and position). The global minimum approaches -6 near boundaries, but tests focus on this local minimum near the origin. Implemented as non-scalable with fixed dimension 2, as metadata for other dimensions is unavailable.
- **Formula**: \sum_{i=1}^{D-1} \left[ e^{-0.2 \sqrt{x_i^2 + x_{i+1}^2}} + 3 (\cos(2x_i) + \sin(2x_{i+1})) \right]
- **Bounds/Minimum**: Bounds: [-35.0, -35.0]; Min: -5.297009385988958 at [-1.5812643986108843, -0.7906319137820829]
- **Properties**: controversial, non-separable, bounded, differentiable, highly multimodal, continuous
- **Reference**: Unknown


### adjiman
- **Description**: Adjiman function: Multimodal, non-convex, non-separable, differentiable, bounded test function with a single global minimum at (2.0, 0.10578347).
- **Formula**: \cos(x_1) \sin(x_2) - \frac{x_1}{x_2^2 + 1}
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -2.021806783359787 at [2.0, 0.10578347]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### alpinen1
- **Description**: AlpineN1 function: Multimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: 0 at (0, ..., 0) and other points where xi * sin(xi) + 0.1 * xi = 0.
- **Formula**: \sum_{i=1}^n |x_i \sin(x_i) + 0.1 x_i|
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, partially differentiable, scalable, non-convex
- **Reference**: Unknown


### alpinen2
- **Description**: AlpineN2 function: Multimodal, non-convex, separable, partially differentiable, scalable, bounded. Minimum: - (2.8081311800070053)^n at (7.917052698245946, ..., 7.917052698245946). Note: Negated product for minimization. Defined for all inputs, with bounds [0,10]^n enforced by the optimizer.
- **Formula**: - \prod_{i=1}^n \sqrt{x_i} \sin(x_i)
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -7.885600724127536 at [7.917052698245946, 7.917052698245946]
- **Properties**: multimodal, separable, bounded, partially differentiable, scalable, non-convex
- **Reference**: Unknown


### axisparallelhyperellipsoid
- **Description**: Axis Parallel Hyper-Ellipsoid function: Convex, differentiable, separable, scalable, continuous test function with a global minimum of 0.0 at x = [0, ..., 0] for any n ≥ 1. Typically tested with bounds [-5.12, 5.12]^n, making it bounded for practical purposes. See [Jamil & Yang (2013)] for details.
- **Formula**: \sum_{i=1}^n i x_i^2
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, differentiable, scalable, continuous
- **Reference**: Unknown


### bartelsconn
- **Description**: Bartels Conn function: Multimodal, non-convex, non-separable, partially differentiable, bounded test function with a global minimum at (0.0, 0.0). The subgradient is not well-defined at points where abs arguments are zero.
- **Formula**: |x_1^2 + x_2^2 + x_1 x_2| + |\sin(x_1)| + |\cos(x_2)|
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### beale
- **Description**: Beale function: Unimodal, non-convex, non-separable, differentiable, fixed, bounded, continuous.
- **Formula**: (1.5 - x_1 + x_1 x_2)^2 + (2.25 - x_1 + x_1 x_2^2)^2 + (2.625 - x_1 + x_1 x_2^3)^2
- **Bounds/Minimum**: Bounds: [-4.5, -4.5]; Min: 0.0 at [3.0, 0.5]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, entry 10)


### becker_lago
- **Description**: Becker and Lago function from Price (1977). Properties: continuous, separable, multimodal, bounded. Contains absolute value terms (non-differentiable at x_i=0). Four minima at (5, 5), (5, -5), (-5, 5), (-5, -5). Possibly misidentified as Price 3 (Jamil & Yang, 2013, No. 96) in some contexts.
- **Formula**: f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [5.0, 5.0]
- **Properties**: multimodal, separable, bounded, continuous
- **Reference**: Price (1977); referenced in Jamil & Yang (2013), https://arxiv.org/abs/1308.4008


### biggsexp2
- **Description**: Biggs EXP2 Function, a sum-of-squares function with exact global minimum 0 at [1,10] for n=2. Implemented as non-scalable with fixed dimension 2.
- **Formula**: \sum_{i=1}^{10} \left( e^{-t_i x_1} - 5 e^{-t_i x_2} - y_i \right)^2 \quad t_i=0.1i, \, y_i = e^{-t_i} - 5 e^{-10 t_i}
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 10.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp3
- **Description**: Biggs EXP Function 3 (Biggs, 1971), as described in Jamil & Yang (2013).
This is a multimodal function with fixed dimension n=3.
It models an exponential fitting problem.

- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left( e^{-t_i x_1} - x_3 e^{-t_i x_2} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 5.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp4
- **Description**: Biggs EXP Function 4 (Biggs, 1971), as described in Jamil & Yang (2013).
This is a multimodal function with fixed dimension n=4.
It models an exponential fitting problem.

- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp5
- **Description**: Biggs EXP Function 5 (Biggs, 1971), as described in Jamil & Yang (2013).
This is a multimodal function with fixed dimension n=5.
It models an exponential fitting problem.

- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{11} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + 3 e^{-t_i x_5} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0, 4.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp6
- **Description**: Biggs EXP Function 6 (Biggs, 1971): A multimodal, non-separable test function for nonlinear optimization.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{13} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + x_6 e^{-t_i x_5} - y_i \right)^2, \quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}.
- **Bounds/Minimum**: Bounds: [-20.0, -20.0, -20.0, -20.0, -20.0, -20.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0, 4.0, 3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### bird
- **Description**: Bird function: Multimodal, non-convex, non-separable, differentiable, fixed.
- **Formula**: \sin(x_1) \exp\left((1 - \cos(x_2))^2\right) + \cos(x_2) \exp\left((1 - \sin(x_1))^2\right) + (x_1 - x_2)^2
- **Bounds/Minimum**: Bounds: [-6.283185307179586, -6.283185307179586]; Min: -106.76453674926465 at [4.701043130195973, 3.1529385037484228]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### bohachevsky1
- **Description**: Bohachevsky Function 1 (Bohachevsky et al., 1986): A scalable, separable, multimodal test function for nonlinear optimization.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[ x_i^2 + 2 x_{i+1}^2 - 0.3 \cos(3 \pi x_i) - 0.4 \cos(4 \pi x_{i+1}) + 0.7 \right].
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Unknown


### bohachevsky2
- **Description**: Bohachevsky 2 function: Multimodal, non-convex, non-separable, differentiable, bounded. Minimum: 0 at (0, 0). Bounds: [-100, 100]^2.
- **Formula**: f(x) = x_1^2 + 2x_2^2 - 0.3\cos(3\pi x_1)\cos(4\pi x_2) + 0.3
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, non-convex
- **Reference**: Unknown


### bohachevsky3
- **Description**: Bohachevsky 3 function from Bohachevsky et al. (1986), f19 in Jamil & Yang (2013): Multimodal, differentiable, non-separable test function with a global minimum at (0, 0).
- **Formula**: f(\mathbf{x}) = x_1^2 + 2x_2^2 - 0.3 \cos(3\pi x_1 + 4\pi x_2) + 0.3.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### booth
- **Description**: Booth function: Unimodal, convex, separable, differentiable, bounded quadratic test function with a single global minimum at (1, 3). Properties based on [Surjanovic & Bingham (2013)]; originally from [Booth (1976)].
- **Formula**: (x_1 + 2x_2 - 7)^2 + (2x_1 + x_2 - 5)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 3.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, continuous
- **Reference**: Surjanovic & Bingham (2013), Virtual Library of Simulation Experiments: Test Functions and Datasets, retrieved from https://www.sfu.ca/~ssurjano/booth.html


### boxbetts
- **Description**: Box-Betts Quadratic Sum function: Continuous, differentiable, non-separable, nonscalable, multimodal.
- **Formula**: \sum_{i=1}^{10} \left( e^{-0.1i x_1} - e^{-0.1i x_2} - (e^{-0.1i} - e^{-i}) x_3 \right)^2
- **Bounds/Minimum**: Bounds: [0.9, 9.0, 0.9]; Min: 0.0 at [1.0, 10.0, 1.0]
- **Properties**: multimodal, differentiable, continuous
- **Reference**: MVF - Multivariate Test Functions Library in C, Ernesto P. Adorio, Revised January 14, 2005


### brad
- **Description**: Brad Function (Brad, 1970): A multimodal, non-separable test function for nonlinear optimization.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{15} \left( y_i - x_1 - \frac{u_i}{v_i x_2 + w_i x_3} \right)^2, \quad u_i = i, \ v_i = 16 - i, \ w_i = \min(u_i, v_i), \ \mathbf{y} = [0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39, 0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]^\top.
- **Bounds/Minimum**: Bounds: [-0.25, 0.01, 0.01]; Min: 0.008214877306578994 at [0.0824105597447766, 1.1330360919212203, 2.343695178745316]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### branin
- **Description**: Branin function: A multimodal, non-convex function with three global minima at [-π, 12.275], [π, 2.275], [9.424778, 2.475]. Only defined for n=2.
- **Formula**: f(x) = a (x_2 - b x_1^2 + c x_1 - r)^2 + s (1 - t) \cos(x_1) + s, a=1, b=5.1/(4\pi^2), c=5/\pi, r=6, s=10, t=1/(8\pi)
- **Bounds/Minimum**: Bounds: [-5.0, 0.0]; Min: 0.39788735772973816 at [-3.141592653589793, 12.275]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### braninrcos2
- **Description**: Branin RCOS Function 2 (Muntenau and Lazarescu, 1998): A multimodal, non-separable test function for nonlinear optimization. Note: Paper reports min=5.559 at [-3.2, 12.53], but computation yields -39.196 at ≈[-3.172, 12.586] – likely paper transcription error; validated via optimization.
- **Formula**: f(\mathbf{x}) = \left( x_2 - \frac{5.1 x_1^2}{4\pi^2} + \frac{5 x_1}{\pi} - 6 \right)^2 + 10 \left( 1 - \frac{1}{8\pi} \right) \cos(x_1) \cos(x_2) \ln(x_1^2 + x_2^2 + 1) + 10.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -39.19565391797774 at [-3.1721041516027824, 12.58567479697034]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### brent
- **Description**: The Brent function is a non-scalable, unimodal test function with a parabolic bowl centered at (-10, -10) and a Gaussian bump at the origin. Properties based on [Jamil & Yang (2013, p. 9)]; originally from [Brent (1960)].
- **Formula**: f(\mathbf{x}) = (x_1 + 10)^2 + (x_2 + 10)^2 + \exp(-x_1^2 - x_2^2)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [-10.0, -10.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 9)


### brown
- **Description**: Brown function: Unimodal, non-separable, differentiable, scalable, continuous, bounded. Highly sensitive to changes in variables due to exponential terms. Properties based on [Jamil & Yang (2013, p. 5)]; originally from [Brown (1966)].
- **Formula**: \sum_{i=1}^{n-1} \left[ (x_i^2)^{(x_{i+1}^2 + 1)} + (x_{i+1}^2)^{(x_i^2 + 1)} \right]
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Jamil & Yang (2013, p. 5)


### bukin2
- **Description**: Bukin 2 function: Continuous, differentiable, non-separable, non-scalable, multimodal. Minimum: 0.0 at (-10.0, 0.0). Bounds: x1 in [-15, -5], x2 in [-3, 3]. Note: Formula corrected with ^2 to match minimum per Jamil & Yang (2013) due to original definition inconsistency.
- **Formula**: f(x) = 100 (x_2 - 0.01 x_1^2 + 1)^2 + 0.01 (x_1 + 10)^2
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 0.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### bukin4
- **Description**: Bukin 4 function: Multimodal, non-convex, separable, partially differentiable, bounded, continuous. Has a deep valley along x1 = -10.
- **Formula**: f(\mathbf{x}) = 100 x_2^2 + 0.01 |x_1 + 10|
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 0.0]
- **Properties**: multimodal, separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### bukin6
- **Description**: Bukin function N.6: Multimodal, partially differentiable, non-convex function with global minimum at zero, defined for 2 dimensions.
- **Formula**: 100 \sqrt{|x_2 - 0.01 x_1^2|} + 0.01 |x_1 + 10|
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 1.0]
- **Properties**: multimodal, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### carromtable
- **Description**: Four global minima due to sign choices; Properties based on Jamil & Yang (2013, p. 34); originally from Mishra (2004).
- **Formula**: f(\mathbf{x}) = -\frac{\left[ \left( \cos(x_1) \cos(x_2) \exp \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right)^2 \right]}{30}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.156815547391208 at [9.646167670438874, 9.646167670438874]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### chen
- **Description**: Chen V function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: -2000.0 at (0.388888888888889, 0.722222222222222). Bounds: [-500, 500]^2. Dimensions: n=2. Formulated as a minimum problem by negating the maximum problem from [Naser et al. (2024)] and [al-roomi.org], where f(0.388888888888889, 0.722222222222222) = 2000. [Jamil & Yang (2013): f32] reports a different function with minimum f(-0.3888889, 0.7222222) = -2000.
- **Formula**: -\left(\frac{0.001}{0.000001 + (x_1 - 0.4 x_2 - 0.1)^2} + \frac{0.001}{0.000001 + (2 x_1 + x_2 - 1.5)^2}\right)
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -2000.0 at [0.388888888888889, 0.722222222222222]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### chenv
- **Description**: Chen V function from Chen (2003). Continuous, differentiable, non-separable, multimodal with three overlapping terms creating complex landscape.
- **Formula**: f(\mathbf{x}) = -\frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 1)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 0.5)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 - x_2^2)^2}
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -2000.0039999840005 at [0.500000000004, 0.500000000004]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### chichinadze
- **Description**: Chichinadze function (continuous, differentiable, separable, non-scalable, multimodal). Source: Jamil & Yang (2013). Global minimum at approximately [6.18987, 0.5].
- **Formula**: f(\mathbf{x}) = x_1^2 - 12 x_1 + 11 + 10 \cos\left(\frac{\pi x_1}{2}\right) + 8 \sin\left(\frac{5 \pi x_1}{2}\right) - \sqrt{\frac{1}{5}} \exp\left(-0.5 (x_2 - 0.5)^2 \right) 
- **Bounds/Minimum**: Bounds: [-30.0, -30.0]; Min: -42.944387018991 at [6.18986658696568, 0.5]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Unknown


### chungreynolds
- **Description**: Chung Reynolds function (continuous, differentiable, partially separable, scalable, unimodal). Source: Jamil & Yang (2013) and Chung & Reynolds (1998). Global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \left( \sum_{i=1}^n x_i^2 \right)^2 
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: bounded, unimodal, differentiable, continuous, partially separable, scalable
- **Reference**: Jamil & Yang (2013, Entry 34)


### cola
- **Description**: Cola function (continuous, differentiable, non-separable, non-scalable, multimodal). Source: Adorio & Diliman (2005). 17D positioning problem with fixed points (x1=y1=y2=0). Literature global min f*=11.7464 (MVF-Library); approximate position from Jamil & Yang yields f≈11.828.
- **Formula**: f(\mathbf{u}) = \sum_{1 \le j < i \le 10} (r_{i,j} - d_{i,j})^2, \quad r_{i,j} = \sqrt{(x_i - x_j)^2 + (y_i - y_j)^2} 
- **Bounds/Minimum**: Bounds: [0.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0]; Min: 10.533719093221547 at [0.6577179521834655, 1.3410086494718647, 0.0621925866606903, -0.9215843284021408, -0.8587539108194528, 0.0398894904746407, -3.3508073710903923, 0.6714854553331792, -3.3960325842653383, 2.381549919707253, -1.3565015163235619, 1.3510478875312162, -3.3405083834260405, 1.8923144784852317, -2.7015951415440593, -0.9050732332838868, -1.677429264374116]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### colville
- **Description**: Colville function: Unimodal, non-convex, non-separable, differentiable, bounded, continuous. Known for its narrow, curved valleys challenging optimization algorithms. Properties based on [Jamil & Yang (2013, p. 13)]; originally from [Colville (1968)].
- **Formula**: f(\mathbf{x}) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 1.0, 1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 13)


### corana
- **Description**: Corana function (discontinuous, non-differentiable, separable, scalable, multimodal). Source: Corana et al. (1990). Global minimum f(x*)=0 at x*=(0,...,0).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \begin{cases} 0.15 d_i (z_i - 0.05 \sgn(z_i))^2 & |x_i - z_i| < 0.05 \\ d_i x_i^2 & \text{otherwise} \end{cases}, \\ z_i = 0.2 \left\lfloor \frac{|x_i|}{0.2} + 0.49999 \right\rfloor \sgn(x_i), \\ d_i \text{ cycles over } [1, 1000, 10, 100].
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, scalable
- **Reference**: Unknown


### cosinemixture
- **Description**: Cosine Mixture Function: A multimodal, separable benchmark with global minimum -0.1*n at origin.
- **Formula**: f(\mathbf{x}) = -0.1 \sum_{i=1}^n \cos(5 \pi x_i) - \sum_{i=1}^n x_i^2
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -0.2 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Unknown


### crossintray
- **Description**: Cross-in-Tray function: A multimodal, non-convex, non-separable test function with four global minima at [1.349406575769872, 1.349406575769872], [-1.349406575769872, 1.349406575769872], [1.349406575769872, -1.349406575769872], [-1.349406575769872, -1.349406575769872].
- **Formula**: -0.0001 \left( \left| \sin(x_1) \sin(x_2) \exp\left( \left| 100 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right| + 1 \right)^{0.1}
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -2.062611870822739 at [1.349406575769872, 1.349406575769872]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### csendes
- **Description**: Csendes function (continuous, differentiable, separable, scalable, multimodal). Source: Csendes and Ratz (1997). Global minimum f(x*)=0 at x*=(0,...,0).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n x_i^2 (2 + \sin x_i). 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### cube
- **Description**: Cube function (continuous, differentiable, non-separable, unimodal). Source: Vogel (1966). Global minimum f(x*)=0 at x*=(1,1). Properties based on [Jamil & Yang (2013, Entry 41)].
- **Formula**: f(\mathbf{x}) = 100 (x_2 - x_1^3)^2 + (1 - x_1)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 41)


### damavandi
- **Description**: Damavandi function (Damavandi & Safavi-Naeini, 2005): A multimodal, non-separable 2D function with a global minimum of 0 at (2,2). Features a deceptive landscape due to the sinc-like terms.
- **Formula**: f(\mathbf{x}) = \left[1 - \left| \frac{\sin[\pi (x_1 - 2)]\sin[\pi (x_2 - 2)]}{\pi^2 (x_1 - 2)(x_2 - 2)} \right|^5 \right] \left[ 2 + (x_1 - 7)^2 + 2(x_2 - 7)^2 \right] 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [2.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### deb1
- **Description**: Deb's Function No.1 (Rönkkönen, 2009): A scalable, separable, multimodal function with 10^D evenly spaced global minima at f=-1.
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^{6}(5 \pi x_i) 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [-0.9, -0.9]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### deb3
- **Description**: Deb's Function No.3 (Rönkkönen, 2009): A scalable, separable, multimodal function with 5^D evenly spaced global minima at f=-1.
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^6 \left(5 \pi (x_i^{3/4} - 0.05)\right) 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [0.07969939268869583, 0.07969939268869583]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### dejongf4
- **Description**: De Jong F4 function: Unimodal, convex, separable, partially differentiable due to Gaussian noise, scalable to any dimension n, with global minimum at x = [0, ..., 0], f* ≈ 0 (depending on noise). Bounds are [-1.28, 1.28] per dimension.
- **Formula**: \sum_{i=1}^n i x_i^4 + \text{Gaussian noise}
- **Bounds/Minimum**: Bounds: [-1.28, -1.28]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, partially differentiable, scalable, continuous, has_noise
- **Reference**: Unknown


### dejongf5modified
- **Description**: Modified De Jong F5 (Shekel's Foxholes): Multimodal, non-convex, non-separable, differentiable, bounded, finite at infinity, continuous. Minimum: 0.9980038377944507 at x ≈ [-31.97833, -31.97833]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.
- **Formula**: -\left( \frac{1}{500} + \sum_{i=1}^{25} \frac{1}{i + (x_1 - a_{1i})^6 + (x_2 - a_{2i})^6} \right)^{-1}
- **Bounds/Minimum**: Bounds: [-65.536, -65.536]; Min: 0.9980038377944507 at [-31.97833, -31.97833]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Unknown


### dejongf5original
- **Description**: Original De Jong F5 (Shekel variant) as per Molga & Smutnicki (2005): Multimodal, non-convex, non-separable, differentiable, bounded, continuous, finite at infinity. Minimum: ≈0.998001998667 at x ≈ [-32, -32]. Bounds: [-65.536, 65.536]^2. Dimensions: n=2.
- **Formula**: f(x) = \left( 0.002 + \sum_{j=1}^{25} \frac{1}{j + (x_1 - a_{1j})^6 + (x_2 - a_{2j})^6} \right)^{-1}
- **Bounds/Minimum**: Bounds: [-65.536, -65.536]; Min: 0.9980038378086058 at [-31.97987349299719, -31.979873489712844]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Unknown


### dekkersaarts
- **Description**: Dekkers-Aarts function: Multimodal with two global minima at [0, ±14.94511215174121]. Literature (Ali et al., 2005) reports minima at (0, ±15), f* ≈ -24777, but exact minima are at (0, ±14.94511215174121), f* ≈ -24776.51834231769.
- **Formula**: 10^5 x_1^2 + x_2^2 - (x_1^2 + x_2^2)^2 + 10^{-5} (x_1^2 + x_2^2)^4
- **Bounds/Minimum**: Bounds: [-20.0, -20.0]; Min: -24776.518342317686 at [0.0, 14.945112151891959]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### devilliersglasser1
- **Description**: De Villiers-Glasser Function 1, from De Villiers and Glasser (1981). Returns NaN if x2 < 0 to avoid complex exponentiation; literature bounds -500 ≤ x ≤ 500. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \sin(x_3 t_i + x_4) - y_i \right]^2, \quad t_i = 0.1(i-1), \quad y_i = 60.137 \times 1.371^{t_i} \sin(3.112 t_i + 1.761).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [60.137, 1.371, 3.112, 1.761]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### devilliersglasser2
- **Description**: De Villiers-Glasser function no. 2 (de Villiers and Glasser, 1981). A 5-dimensional nonlinear least squares problem for parameter estimation. Global minimum f(x*)=0. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \tanh\left(x_3 t_i + \sin(x_4 t_i)\right) \cos\left(t_i e^{x_5}\right) - y_i \right]^2 \\
\text{where } t_i = 0.1(i-1), \\
y_i = 53.81 \cdot 1.27^{t_i} \tanh(3.012 t_i + \sin(2.13 t_i)) \cos(e^{0.507} t_i).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [53.81, 1.27, 3.012, 2.13, 0.507]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### dixonprice
- **Description**: Dixon-Price function: Unimodal, non-convex, scalable function with global minimum at zero. Properties based on [Jamil & Yang (2013, Entry 14)]; originally from [Dixon & Price (1971)].
- **Formula**: (x_1 - 1)^2 + \sum_{i=2}^n i (2 x_i^2 - x_{i-1})^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 0.7071067811865476]
- **Properties**: bounded, unimodal, differentiable, scalable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, Entry 14)


### dolan
- **Description**: Dolan function (continuous, differentiable, non-separable, non-scalable, multimodal). Properties based on Jamil & Yang (2013). Global minimum corrected from literature (f=0 at [0,...] incorrect) using Al-Roomi (2015). Ill-conditioned Hessian.
- **Formula**: f(\mathbf{x}) = (x_1 + 1.7 x_2) \sin(x_1) - 1.5 x_3 - 0.1 x_4 \cos(x_4 + x_5 - x_1) + 0.2 x_5^2 - x_2 - 1
- **Bounds/Minimum**: Bounds: [-100.0, -100.0, -100.0, -100.0, -100.0]; Min: -529.8714387324576 at [98.9642583122371, 100.0, 100.0, 99.2243236725547, -0.249987527588471]
- **Properties**: multimodal, controversial, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### dropwave
- **Description**: Drop-Wave function: A multimodal, non-convex, non-separable, differentiable function defined for 2 dimensions, with a global minimum at [0, 0].
- **Formula**: -\frac{1 + \cos(12 \sqrt{x_1^2 + x_2^2})}{0.5 (x_1^2 + x_2^2) + 2}
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### easom
- **Description**: Easom function: Multimodal test function with a small global minimum area relative to the search space.
- **Formula**: -\cos(x_1)\cos(x_2)\exp(-((x_1-\pi)^2 + (x_2-\pi)^2))
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -1.0 at [π, π]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### eggcrate
- **Description**: Egg Crate test function as standardized in Jamil & Yang (2013). Multimodal, separable function in 2 dimensions. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = x_1^2 + x_2^2 + 25 (\sin^2 x_1 + \sin^2 x_2).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### eggholder
- **Description**: Eggholder function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous test function with a global minimum of -959.6406627208506 at [512.0, 404.2318058008512]. Bounds: [-512, 512]^2. Dimensions: n=2. Used for benchmarking nonlinear optimization algorithms due to its many local minima. See [Jamil & Yang (2013)] for details.
- **Formula**: - (x_2 + 47) \sin\left(\sqrt{\left|x_2 + \frac{x_1}{2} + 47\right|}\right) - x_1 \sin\left(\sqrt{\left|x_1 - (x_2 + 47)\right|}\right)
- **Bounds/Minimum**: Bounds: [-512.0, -512.0]; Min: -959.6406627208506 at [512.0, 404.2318058008512]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### elattavidyasagardutta
- **Description**: El-Attar-Vidyasagar-Dutta test function from El-Attar et al. (1979), as standardized in Jamil & Yang (2013). Unimodal, non-separable function in 4 dimensions. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = (x_1^2 + x_2 - 10)^2 + 5(x_3 - x_4)^2 + (x_2 - x_3)^2 + 10(x_4 - 1)^2.
- **Bounds/Minimum**: Bounds: [-5.2, -5.2, -5.2, -5.2]; Min: 0.0 at [3.0, 1.0, 1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 16)


### exponential
- **Description**: The Exponential test function, a scalable, non-separable function with a unique global minimum at the origin. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = -\exp\left( -\frac{1}{2} \sum_{i=1}^n x_i^2 \right). 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Ramanujan et al. (2007)


### freudensteinroth
- **Description**: Freudenstein-Roth function: Multimodal, non-convex, non-separable, differentiable, fixed dimension (n=2).
- **Formula**: f(x) = \left( x_1 - 13 + \left( (5 - x_2)x_2 - 2 \right)x_2 \right)^2 + \left( x_1 - 29 + \left( (x_2 + 1)x_2 - 14 \right)x_2 \right)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [5.0, 4.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### giunta
- **Description**: Giunta function: Multimodal, non-convex, separable, differentiable, bounded, continuous. Minimum: 0.06447 at [0.46732, 0.46732]. Bounds: [-1, 1]^2. Dimensions: n=2.
- **Formula**: 0.6 + \sum_{i=1}^2 \left[ \sin\left(\frac{16}{15}x_i - 1\right) + \sin^2\left(\frac{16}{15}x_i - 1\right) + \frac{1}{50} \sin\left(4 \left(\frac{16}{15}x_i - 1\right)\right) \right]
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.06447042053690566 at [0.46732002530945826, 0.46732002530945826]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### goldsteinprice
- **Description**: Goldstein-Price function: Multimodal, non-convex, non-separable, differentiable, bounded (n=2 only).
- **Formula**: (1 + (x_1 + x_2 + 1)^2 (19 - 14x_1 + 3x_1^2 - 14x_2 + 6x_1x_2 + 3x_2^2)) \cdot (30 + (2x_1 - 3x_2)^2 (18 - 32x_1 + 12x_1^2 + 48x_2 - 36x_1x_2 + 27x_2^2))
- **Bounds/Minimum**: Bounds: [-2.0, -2.0]; Min: 3.0 at [0.0, -1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### griewank
- **Description**: Griewank function: A scalable, multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with a global minimum at (0, ..., 0) with value 0.0. References: Jamil & Yang (2013), al-roomi.org.
- **Formula**: f(x) = \sum_{i=1}^n \frac{x_i^2}{4000} - \prod_{i=1}^n \cos\left(\frac{x_i}{\sqrt{i}}\right) + 1
- **Bounds/Minimum**: Bounds: [-600.0, -600.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### gulfresearch
- **Description**: The Gulf Research and Development problem, a 3D multimodal function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{99} \left[ \exp\left( -\frac{(u_i - x_2)^{x_3}}{x_1} \right) - 0.01 i \right]^2, \quad u_i = 25 + \left[-50 \ln(0.01 i)\right]^{2/3}.
- **Bounds/Minimum**: Bounds: [0.1, 0.0, 0.0]; Min: 0.0 at [50.0, 25.0, 1.5]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hansen
- **Description**: The Hansen function, a 2D multimodal separable function with multiple global minima. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=0}^{4} (i+1)\cos(i x_1 + i+1) \sum_{j=0}^{4} (j+1)\cos((j+2) x_2 + j+1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -176.5417931367457 at [-7.589893010800888, -7.708313735499348]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hartman6
- **Description**: The Hartman Function 6, a 6D multimodal non-separable function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{4} c_i \exp\left( -\sum_{j=1}^{6} a_{ij} (x_j - p_{ij})^2 \right).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]; Min: -3.3223680114155147 at [0.20168951265373836, 0.15001069271431358, 0.4768739727643224, 0.2753324306183083, 0.31165161653706114, 0.657300534163256]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hartmanf3
- **Description**: Hartmann function: Multimodal, non-convex, non-separable, differentiable, defined for n=3 only, with a global minimum at [0.114614339099637, 0.5556488499706311, 0.8525469535196916].
- **Formula**: -\sum_{i=1}^4 \alpha_i \exp\left(-\sum_{j=1}^3 A_{ij} (x_j - P_{ij})^2\right), \quad \alpha=[1,1.2,3,3.2], \quad A=\begin{bmatrix}3 & 10 & 30 \\ 0.1 & 10 & 35 \\ 3 & 10 & 30 \\ 0.1 & 10 & 35\end{bmatrix}, \quad P=\begin{bmatrix}0.3689 & 0.1170 & 0.2673 \\ 0.4699 & 0.4387 & 0.7470 \\ 0.1091 & 0.8732 & 0.5547 \\ 0.03815 & 0.5743 & 0.8828\end{bmatrix}
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: -3.862782147820755 at [0.1146143386186895, 0.5556488499736022, 0.8525469535210816]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### helicalvalley
- **Description**: The Helical Valley function, a 3D multimodal non-separable function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = 100 \left[ (x_2 - 10\theta)^2 + \left(\sqrt{x_1^2 + x_2^2} - 1\right)^2 \right] + x_3^2, \quad \theta = \frac{1}{2\pi} \atantwo(x_2, x_1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### himmelblau
- **Description**: Himmelblau function: Multimodal, non-convex, non-separable, differentiable, bounded, continuous. Minimum: 0.0 at [3.0, 2.0], [-2.805118, 3.131312], [-3.779310, -3.283186], [3.584428, -1.848126]. Bounds: [-5, 5]^2. Dimensions: n=2.
- **Formula**: (x_1^2 + x_2 - 11)^2 + (x_1 + x_2^2 - 7)^2
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [3.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### holder_table1
- **Description**: Properties based on Jamil & Yang (2013, p. 34); four global minima; adapted formula from Surjano for consistency (sin/cos and abs in exp); originally from Mishra (2006). Non-separable due to interactions despite source claim.
- **Formula**: f(\mathbf{x}) = -\left| \sin(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -19.208502567886743 at [8.05502347573655, -9.664590019241274]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### holder_table2
- **Description**: Properties based on Jamil & Yang (2013, p. 34); four global minima; adapted formula from Surjano/Al-Roomi for consistency (sin/sin and Euclidean norm in exp); source minimum -19.2085 not matching formula (computed -11.6839); originally from Mishra (2006). Non-separable due to interactions.
- **Formula**: f(\mathbf{x}) = -\left| \sin(x_1) \sin(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -11.683926748430029 at [8.051008722128277, -9.999999999999]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### holdertable
- **Description**: Holder Table function: Multimodal, continuous, partially differentiable, separable, bounded, non-convex. Four global minima at (±8.055023, ±9.664590), f* = -19.2085025678845. Bounds: [-10, 10]^2. Dimensions: n=2.
- **Formula**: -\left| \sin(x_1) \cos(x_2) \exp\left(\left|1 - \sqrt{x_1^2 + x_2^2}/\pi\right|\right) \right|
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -19.2085025678845 at [8.055023, 9.66459]
- **Properties**: multimodal, separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### hosaki
- **Description**: The Hosaki function, a 2D multimodal non-separable function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left(1 - 8x_1 + 7x_1^2 - \frac{7}{3}x_1^3 + \frac{1}{4}x_1^4\right) x_2^2 e^{-x_2}.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.345811576101292 at [4.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### jennrichsampson
- **Description**: The Jennrich-Sampson function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left(2 + 2i - (e^{i x_1} + e^{i x_2})\right)^2 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 124.36218235561489 at [0.2578252136705121, 0.2578252136701835]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jennrich and Sampson (1968)


### keane
- **Description**: Keane function: Multimodal, continuous, differentiable, non-separable, bounded, non-convex. Two global minima at (0.0, 1.39325) and (1.39325, 0.0), f* = -0.673668. Bounds: [0, 10]^2. Dimensions: n=2.
- **Formula**: -\frac{\sin^2(x_1 - x_2) \sin^2(x_1 + x_2)}{\sqrt{x_1^2 + x_2^2}}
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -0.6736675211468548 at [0.0, 1.3932490753257145]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### kearfott
- **Description**: Kearfott function: Multimodal, continuous, differentiable, non-separable, bounded, non-convex. Global minima where x₁² + x₂² = 1.25, e.g., at (0.7905694150420949, -0.7905694150420949) and (-0.7905694150420949, 0.7905694150420949), f* = 1.125. Note: Jamil & Yang (2013) incorrectly lists minima at (0.70710678, -0.70710678) and (-0.70710678, 0.70710678) with f* = 0; those yield f = 1.25.
- **Formula**: (x_1^2 + x_2^2 - 2)^2 + (x_1^2 + x_2^2 - 0.5)^2
- **Bounds/Minimum**: Bounds: [-3.0, -3.0]; Min: 1.125 at [0.7905694150420949, -0.7905694150420949]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### langermann
- **Description**: Langermann function: Multimodal, non-convex, non-separable test function with unevenly distributed local minima. Minimum at [2.002992119907532, 1.0060959403343601] with value -5.162126159963982, confirmed by high-precision calculations in Al-Roomi (2015) and verified via tf.f(tf.meta[:min_position]()) with atol=1e-6. Gradient norm at minimum is ~1.748e-9 within atol=0.01. Warning: Some sources (e.g., GlomPo, GEATbx) report a local minimum at approximately [2.002992, 1.006096] with value ≈-1.4, likely due to confusion with a local minimum or documentation error. See Al-Roomi (2015) for details.
- **Formula**: -\sum_{i=1}^m c_i \exp \left[-\frac{1}{\pi} \sum_{j=1}^n (x_j - a_{ij})^2 \right] \cos \left[ \pi \sum_{j=1}^n (x_j - a_{ij})^2 \right]
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -5.162126159963982 at [2.002992119907532, 1.0060959403343601]
- **Properties**: multimodal, controversial, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### leon
- **Description**: The Leon function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = 100(x_2 - x_1^2)^2 + (1 - x_1)^2 
- **Bounds/Minimum**: Bounds: [-1.2, -1.2]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Lavi and Vogel (1966)


### levyjamil
- **Description**: Levy function (Jamil & Yang, 2013): Multimodal, differentiable, non-convex, scalable, bounded, continuous. Global minimum at x* = (1, ..., 1), f* = 0. Bounds: [-10, 10]^n. Note: Follows Jamil & Yang (2013), which may contain typos (e.g., missing coefficient, incorrect 3π scaling). The standard Levy function (see levy.jl) uses w_i = 1 + (x_i - 1)/4. The function is also non-separable, but this property is omitted in tests for consistency.
- **Formula**: \sin^2(3\pi x_1) + \sum_{i=1}^{n-1} (x_i - 1)^2 [1 + \sin^2(3\pi x_{i+1})] + (x_n - 1)^2 [1 + \sin^2(2\pi x_n)]
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### matyas
- **Description**: Matyas function; Properties based on Jamil & Yang (2013, p. 20).
- **Formula**: f(\mathbf{x}) = 0.26 (x_1^2 + x_2^2) - 0.48 x_1 x_2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 20)


### mccormick
- **Description**: McCormick function: Multimodal, non-convex function with global minimum at approximately -1.91322295, defined for 2 dimensions.
- **Formula**: \sin(x_1 + x_2) + (x_1 - x_2)^2 - 1.5 x_1 + 2.5 x_2 + 1
- **Bounds/Minimum**: Bounds: [-1.5, -3.0]; Min: -1.9132229549810367 at [-0.54719755, -1.54719755]
- **Properties**: multimodal, bounded, differentiable, continuous, non-convex
- **Reference**: molga&smutnicki(2005)


### michalewicz
- **Description**: Michalewicz function: Multimodal, non-separable, with many local minima.
- **Formula**: f(x) = -\sum_{i=1}^n \sin(x_i) \sin^{2m}(i x_i^2 / \pi), m=10
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -1.8013034100985528 at [2.2029055201726, 1.5707963267949]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous
- **Reference**: Unknown


### mielcantrell
- **Description**: The Miele-Cantrell function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = (e^{x_1} - x_2)^4 + 100 (x_2 - x_3)^6 + [\tan(x_3 - x_4)]^4 + x_1^8 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0, -1.0, -1.0]; Min: 0.0 at [0.0, 1.0, 1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Cragg and Levy (1969)


### mishra1
- **Description**: The Mishra Function 1. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left(1 + g_n\right)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} x_i 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 2.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Mishra (2006a)


### mishra10
- **Description**: Mishra Function 10: 2D multimodal function involving floor operations. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left[ \lfloor x_1 x_2 \rfloor - \lfloor x_1 \rfloor - \lfloor x_2 \rfloor \right]^2.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f83


### mishra11
- **Description**: Mishra Function 11 (AMGM): Scalable multimodal function based on arithmetic-geometric mean inequality. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left[ \frac{1}{n} \sum_{i=1}^n |x_i| - \left( \prod_{i=1}^n |x_i| \right)^{1/n} \right]^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f84


### mishra2
- **Description**: The Mishra Function 2. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = (1 + g_n)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} \frac{x_i + x_{i+1}}{2} 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 2.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Mishra (2006a)


### mishra3
- **Description**: The Mishra Function 3. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left| \cos \left( \sqrt{ | x_1^2 + x_2 | } \right) \right|^{0.5} + 0.01 (x_1 + x_2) 
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.184651333342989 at [-8.466613775046579, -9.998521309]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra4
- **Description**: The Mishra Function 4. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sqrt{ \left| \sin \sqrt{ |x_1^2 + x_2| } \right| } + 0.01(x_1 + x_2) 
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.19941146886776687 at [-9.94114880716358, -9.999999996365672]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra5
- **Description**: Mishra Function 5: A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: PDF reports erroneous min position; validated via optimization.
- **Formula**: f(\mathbf{x}) = \left[ \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) + \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right]^2 + 0.01(x_1 + x_2)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.11982951993 at [-1.98682, -10.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra6
- **Description**: Mishra Function 6: A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: f3 term outside log; coeff. 0.1 (Jamil lists 0.01, likely typo).
- **Formula**: f(\mathbf{x}) = -\ln \left[ \left( \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) - \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right)^2 \right] + 0.1 \left( (x_1 - 1)^2 + (x_2 - 1)^2 \right)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -2.28394983847 at [2.88630721544, 1.82326033142]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006)


### mishra7
- **Description**: Mishra Function 7: A 2D multimodal test function with multiple global minima where prod(x) = 2. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \left[ x_1 x_2 - 2! \right]^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 2.0]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra8
- **Description**: Mishra Function 8 (Decanomial): A 2D multimodal test function. Properties based on Jamil & Yang (2013). Note: Corrected coeff. 13340 for x1^4; multiplication between polys.
- **Formula**: f(\mathbf{x}) = 0.001 \left[ \left| x_1^{10} - 20 x_1^9 + 180 x_1^8 - 960 x_1^7 + 3360 x_1^6 - 8064 x_1^5 + 13340 x_1^4 - 15360 x_1^3 + 11520 x_1^2 - 5120 x_1 + 2624 \right| \cdot \left| x_2^4 + 12 x_2^3 + 54 x_2^2 + 108 x_2 + 81 \right| \right]^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [2.0, -3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra9
- **Description**: Mishra Function 9 (Dodecal Polynomial): A 3D multimodal test function. Properties based on Jamil & Yang (2013). Corrected terms in b and c from al-roomi.org for f(1,2,3)=0.
- **Formula**: f(\mathbf{x}) = \left[ f_1 f_2^2 f_3 + f_1 f_2 f_3^2 + f_2^2 + (x_1 + x_2 - x_3)^2 \right]^2 \\ where \\ f_1 = 2x_1^3 + 5x_1 x_2 + 4x_3 - 2x_1^2 x_3 - 18, \\ f_2 = x_1 + x_2^3 + x_1 x_2^2 + x_1 x_3^2 - 22, \\ f_3 = 8x_1^2 + 2x_2 x_3 + 2x_2^2 + 3x_2^3 - 52.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 2.0, 3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishrabird
- **Description**: Mishra's Bird function is a multimodal, non-separable function with two known global minima. It is often cited with the constraint (x+5)^2+(y+5)^2 < 25, but this implementation is unconstrained.
- **Formula**: f(x, y) = \sin(y) e^{(1 - \cos(x))^2} + \cos(x) e^{(1 - \sin(y))^2} + (x - y)^2
- **Bounds/Minimum**: Bounds: [-10.0, -6.5]; Min: -106.76453674926466 at [-3.1302468034308637, -1.5821421769356672]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### mvf_shubert
- **Description**: mvfShubert (Adorio variant, 2D fixed, additive sine with index shift j=0..4); separable with ≈400 local minima; properties based on Adorio (2005, p. 12–13); similar to Shubert 3 but with offsets.
- **Formula**: f(\mathbf{x}) = -\sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.062498884334282 at [-0.4913908362396234, 5.791794471580817]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Adorio (2005, p. 12)


### mvf_shubert2
- **Description**: mvfShubert2 (Adorio variant, 2D fixed, additive cosine with index shift j=0..4); separable with ≈400 local minima; properties based on Adorio (2005, p. 13); similar to Shubert 2 but with offsets.
- **Formula**: f(\mathbf{x}) = \sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\cos((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.74177099545137 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Adorio (2005, p. 13)


### mvf_shubert3
- **Description**: mvfShubert3 (Adorio nD generalization, additive sine with index shift j=0..4); separable with ≈400 local minima in 2D; properties based on Adorio (2005, p. 13); generalization of mvfShubert.
- **Formula**: f(\mathbf{x}) = -\sum_{i=0}^{n-1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.062498884334275 at [-0.4913908340773322, -0.4913908340773322]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Adorio (2005, p. 13)


### parsopoulos
- **Description**: Parsopoulos Function: 2D multimodal periodic function with infinite minima. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \cos^2(x_1) + \sin^2(x_2).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [1.5707963267948966, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, non-convex
- **Reference**: Parsopoulos et al., via Jamil & Yang (2013): f85


### pathological
- **Description**: Pathological Function: Scalable multimodal function with interdependent variables. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left( 0.5 + \frac{\sin^2 \sqrt{100 x_i^2 + x_{i+1}^2} - 0.5}{1 + 0.001 (x_i^2 - 2 x_i x_{i+1} + x_{i+1}^2)^2} \right).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Rahnamayan et al. (2007a), via Jamil & Yang (2013): f87


### paviani
- **Description**: Paviani Function: 10D multimodal function involving logs and product. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left[ \left(\ln (x_i - 2)\right)^2 + \left(\ln (10 - x_i)\right)^2 \right] - \left( \prod_{i=1}^{10} x_i \right)^{0.2}. 
- **Bounds/Minimum**: Bounds: [2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001]; Min: -45.77846970744629 at [9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Himmelblau (1972), via Jamil & Yang (2013): f88


### penholder
- **Description**: Pen Holder Function: 2D multimodal function with four global minima. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = -\exp\left( -\frac{1}{\left| \cos(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|} \right).
- **Bounds/Minimum**: Bounds: [-11.0, -11.0]; Min: -0.9635348327265058 at [9.6461676710434, 9.6461676710434]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f86


### periodic
- **Description**: Periodic function (also known as Price's Function No. 02) with 49 local minima at f=1 and global minimum at origin f=0.9. Non-separable due to coupled exponential term. Properties based on Jamil & Yang (2013), adapted for separability analysis.
- **Formula**: f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1 e^{-(x_1^2 + x_2^2)}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.9 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Ali et al. (2005)


### pinter
- **Description**: Pintér Function: Scalable multimodal function with cyclic dependencies. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n i x_i^2 + \sum_{i=1}^n 20 i \sin^2 A + \sum_{i=1}^n i \log_{10} (1 + i B^2), \\ A = x_{i-1} \sin x_i + \sin x_{i+1}, \\ B = x_{i-1}^2 - 2 x_i + 3 x_{i+1} - \cos x_i + 1 \\ (cyclic: x_0 = x_n, x_{n+1} = x_1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Pintér (1996), via Jamil & Yang (2013): f89


### powell
- **Description**: Powell function; Properties based on Jamil & Yang (2013, p. 28); originally from Powell (1962).
- **Formula**: f(\mathbf{x}) = (x_1 + 10x_2)^2 + 5(x_3 - x_4)^2 + (x_2 - 2x_3)^4 + 10(x_1 - x_4)^4.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0, -5.0, -5.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 28)


### powellsingular
- **Description**: Powell Singular Function, a quartic function with singular Hessian at the global minimum. Scalable in blocks of 4 dimensions. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n/4} \left[ (x_{4i-3} + 10 x_{4i-2})^2 + 5 (x_{4i-1} - x_{4i})^2 + (x_{4i-2} - 2 x_{4i-1})^4 + 10 (x_{4i-3} - x_{4i})^4 \right].
- **Bounds/Minimum**: Bounds: [-4.0, -4.0, -4.0, -4.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Powell (1962)


### powellsingular2
- **Description**: Powell Singular Function 2, a quartic function with singular Hessian at the global minimum. Scalable in blocks of 4 dimensions. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n/4} \left[ (x_{4i-3} + 10 x_{4i-2})^2 + 5 (x_{4i-1} - x_{4i})^2 + (x_{4i-2} - 2 x_{4i-1})^4 + 10 (x_{4i-3} - x_{4i})^4 \right].
- **Bounds/Minimum**: Bounds: [-4.0, -4.0, -4.0, -4.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Fu et al. (2006)


### powellsum
- **Description**: Powell Sum Function with separable terms. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n |x_i|^{i+1}.
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Rahnamyan et al. (2007a)


### price1
- **Description**: Price Function 1 (Price, 1977). Properties based on Jamil & Yang (2013). Non-differentiable at x=0 due to absolute value terms. Has four global minima at the corners.
- **Formula**: f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [5.0, 5.0]
- **Properties**: multimodal, separable, continuous
- **Reference**: Price (1977)


### price2
- **Description**: Price Function 2 (Price, 1977). Properties based on Jamil & Yang (2013). Combines trigonometric and exponential terms.
- **Formula**: f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1e^{-x_1^2 - x_2^2}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.9 at [0.0, 0.0]
- **Properties**: multimodal, differentiable, continuous
- **Reference**: Price (1977)


### price4
- **Description**: Price 4 function from Jamil & Yang (2013, No. 97). Properties: continuous, differentiable, non-separable, multimodal, bounded. Multiple minima at (0, 0) and (2, 4).
- **Formula**: f(\mathbf{x}) = (2x_1^3 x_2 - x_2^3)^2 + (6x_1 - x_2^2 + x_2)^2
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013), https://arxiv.org/abs/1308.4008


### qing
- **Description**: Qing Function. Properties based on Jamil & Yang (2013). Multiple global minima due to sign choices.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 - i)^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [1.0, 1.4142135623730951]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Qing (2006)


### quadratic
- **Description**: Quadratic function. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = -3803.84 - 138.08 x_1 - 232.92 x_2 + 128.08 x_1^2 + 203.64 x_2^2 + 182.25 x_1 x_2.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -3873.72418218627 at [0.193880172788953, 0.485133909126923]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### quartic
- **Description**: Quartic Function with additive uniform noise from [0,1). The deterministic part is strictly convex. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} i x_i^4 + \mathcal{U}[0, 1).
- **Bounds/Minimum**: Bounds: [-1.28, -1.28]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, unimodal, differentiable, continuous, scalable, has_noise
- **Reference**: Jamil & Yang (2013)


### quintic
- **Description**: The Quintic function is a separable multimodal benchmark function with absolute value terms on a quintic polynomial per dimension. Note: Due to the absolute value, it is not strictly differentiable at the roots of the inner polynomial (x_i = -1 or 2), but a subgradient is provided. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D |x_i^5 - 3x_i^4 + 4x_i^3 + 2x_i^2 - 10x_i - 4|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [-1.0, -1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### rana
- **Description**: Rana function incorporates a complex iterative trigonometric mechanism on square roots of absolute differences and sums of pairs. Due to trigonometric sensitivity, minor input changes lead to significant output alterations. Operates in broad range [-500,500]; numerous local minima/maxima characterize its landscape. Properties based on Jamil & Yang (2013) and Naser et al. (2024). Note: Naser et al. reports f(x*) = -928.5478 at x=[-500,-500], but computed value is ≈ -464.274; possible discrepancy in formula interpretation or typo in source.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_{i+1} + 1) \cos(t_2) \sin(t_1) + x_i \cos(t_1) \sin(t_2), \\
t_1 = \sqrt{|x_{i+1} + x_i + 1|}, \quad t_2 = \sqrt{|x_{i+1} - x_i + 1|}. 
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -464.27392770239135 at [-500.0, -500.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Price et al. (2005). Differential Evolution: A Practical Approach to Global Optimization. Springer; Naser et al. (2024). A Review of 315 Benchmark and Test Functions.


### rastrigin
- **Description**: Rastrigin function: a multimodal, non-convex function with a global minimum at x = [0, ..., 0]. Bounds are [-5.12, 5.12].
- **Formula**: f(x) = 10n + \sum_{i=1}^n [x_i^2 - 10 \cos(2\pi x_i)]
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### ripple1
- **Description**: Ripple 1 function. Volatile due to high-frequency cosine and strong sin^6 power; complex range from oscillations, depending on x distribution/values. Represented in [0,1] with global min at x=[0.1,0.1], f=-2.2. Non-separable. Multimodal with 252004 local minima. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \left(\sin^6(5 \pi x_i) + 0.1 \cos^2(500 \pi x_i)\right). 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.2 at [0.1, 0.1]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.


### ripple25
- **Description**: Ripple 25 function. Volatile due to high-frequency sine^6 term and Gaussian envelope; complex range from oscillations, depending on x distribution/values. Represented in [0,1] with global min at x=[0.1,0.1], f=-2.0. Non-separable. Multimodal with numerous local minima. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \sin^6(5 \pi x_i). 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.0 at [0.1, 0.1]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.


### rosenbrock
- **Description**: Rosenbrock function: sum_{i=1}^{n-1} [100 (x_{i+1} - x_i^2)^2 + (x_i - 1)^2]. Features a narrow parabolic valley, making it ill-conditioned and challenging for gradient-based methods. Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} [100(x_{i+1} - x_i^2)^2 + (x_i - 1)^2]. 
- **Bounds/Minimum**: Bounds: [-30.0, -30.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable, ill-conditioned
- **Reference**: Jamil & Yang (2013), Benchmark Function #105


### rosenbrock_modified
- **Description**: Rosenbrock Modified function: 74 + 100(x_2 - x_1^2)^2 + (1 - x_1)^2 - 400 exp(-[(x_1 + 1)^2 + (x_2 + 1)^2]/0.1). Multimodal variant with Gaussian perturbation creating a deceptive local minimum near (1,1). Computed min_value via implementation for precision; literature values approximate (e.g., 34.04). Properties based on Jamil & Yang (2013).
- **Formula**: f(\mathbf{x}) = 74 + 100(x_2 - x_1^2)^2 + (1 - x_1)^2 - 400 e^{-\frac{(x_1 + 1)^2 + (x_2 + 1)^2}{0.1}}.
- **Bounds/Minimum**: Bounds: [-2.0, -2.0]; Min: 34.04024310664062 at [-0.9095537365025769, -0.9505717126589607]
- **Properties**: multimodal, deceptive, controversial, non-separable, bounded, differentiable, continuous, ill-conditioned
- **Reference**: Jamil & Yang (2013), Benchmark Function #106


### rotatedellipse
- **Description**: Rotated Ellipse function. A convex quadratic function with elliptical contours rotated due to the cross-term. Properties based on [Jamil & Yang (2013, Entry 107)].
- **Formula**: f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 107)


### rotatedellipse2
- **Description**: Rotated Ellipse N.2 function: A variant of the Rotated Ellipse, convex quadratic with elliptical contours rotated by cross-term. Properties based on [Jamil & Yang (2013, Entry 107)].
- **Formula**: f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 107)


### rump
- **Description**: The Rump function modified for optimization benchmarks: absolute value ensures non-negativity (global min 0), and denominator 2 + x_2 avoids division by zero. Adapted from original Moore (1988) via Jamil & Yang (2013). Properties based on Al-Roomi (2015).
- **Formula**: f(\mathbf{x}) = \left| (333.75 - x_1^2) x_2^6 + x_1^2 (11 x_1^2 x_2^2 - 121 x_2^4 - 2) + 5.5 x_2^8 + \frac{x_1}{2 + x_2} \right|.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, partially differentiable, unimodal, continuous
- **Reference**: https://al-roomi.org/benchmarks/unconstrained/2-dimensions/128-rump-function


### salomon
- **Description**: The Salomon function. Properties based on Jamil & Yang (2013, p. 27); originally from Salomon (1996).
- **Formula**: f(\mathbf{x}) = 1 - \cos\left(2\pi \sqrt{\sum_{i=1}^D x_i^2}\right) + 0.1 \sqrt{\sum_{i=1}^D x_i^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 27)


### sargan
- **Description**: The Sargan function. Properties based on Jamil & Yang (2013, p. 27); originally from Dixon & Szegö (1978).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 + 0.4 \sum_{j \neq i} x_i x_j).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 27)


### schaffer1
- **Description**: Schaffer's Function No. 01. Highly multimodal with concentric rings of local minima caused by the squared sine term. The function is non-separable due to coupling through x₁² + x₂².
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 + x_2^2) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 136, Function 112)


### schaffer2
- **Description**: 2D unimodal test function with fixed dimension (non-scalable); Properties based on Jamil & Yang (2013, p. 28); Note: The denominator in Jamil & Yang appears to omit the outer square (likely a typographical error with forgotten parentheses and square, deviating from referenced Mishra (2007)), implemented as per Jamil for consistency; originally from Schaffer.
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 - x_2^2) - 0.5}{1 + 0.001 (x_1^2 + x_2^2)^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 28)


### schaffer3
- **Description**: Schaffer Function No. 3; Properties based on Jamil & Yang (2013, p. 28); ursprünglich aus Schaffer (1984). Note: Denominator interpreted as [1 + 0.001(x_1^2 + x_2^2)]^2 to match reported minimum.
- **Formula**: f(\mathbf{x}) = 0.5 + \sin^2(\cos |x_1^2 - x_2^2|) - \frac{0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}. 
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0015668553065719681 at [0.0, 1.253115587]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 28)


### schaffer6
- **Description**: Schaffer's Function No. 06. Continuous, single-objective benchmark function for unconstrained global optimization in 2D. Highly multimodal with concentric rings of local minima due to the oscillatory sine term applied to the radius. The function is non-separable due to coupling through x₁² + x₂².
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Al-Roomi (2015, Schaffer's Function No. 06)


### schafferf6
- **Description**: Schaffer F6 function; multimodal with cyclic dependency; properties based on Jamil & Yang (2013, p. 32, f136); originally from Schaffer et al. (1989).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \frac{\sin^2 \sqrt{x_i^2 + x_{i+1}^2}}{(1 + 0.001 (x_i^2 + x_{i+1}^2))^2}, \quad x_{n+1} = x_1.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 32)


### schaffern2
- **Description**: Schaffer N.2 function: A multimodal function with a global minimum at the origin and many local minima. Variant without sqrt in sine argument; Properties based on Mishra (2007, p. 4); originally from Schaffer.
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 - x_2^2) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2007, p. 4)


### schaffern4
- **Description**: Modified Schaffer N.4 function: A multimodal function with global minimum at (0, 1.25313) and other equivalent points. Properties adapted from Al-Roomi (2015, Modified Schaffer's Function No. 04) for the variant with |x₁² - x₂²|; originally from Jamil & Yang (2013, p. 27) with sin(x₁ - x₂).
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\cos^2(\sin(|x_1^2 - x_2^2|)) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.29257863203598033 at [0.0, 1.253131828792882]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Al-Roomi (2015, Modified Schaffer's Function No. 04)


### schmidtvetters
- **Description**: Schmidt Vetters Function; Properties based on Jamil & Yang (2013, p. 116); Local minimum reported in source (rounded to 3, computed 2.998); global lower at boundary in wide bounds; partially differentiable due to singularity at x2=0; ursprünglich aus Schmidt & Vetter (1980).
- **Formula**: f(\mathbf{x}) = \frac{1}{1 + (x_1 - x_2)^2} + \sin\left( \frac{\pi x_2 + x_3}{2} \right) + e^{\left( \frac{x_1 + x_2}{x_2} - 2 \right)^2}. 
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: 0.19397252244395102 at [7.07083412, 10.0, 3.14159293]
- **Properties**: multimodal, controversial, non-separable, partially differentiable
- **Reference**: Jamil & Yang (2013, p. 116)


### schumersteiglitz
- **Description**: Schumer-Steiglitz function: A simple separable unimodal function with global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} x_i^4
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
- **Properties**: separable, unimodal, differentiable, continuous, scalable
- **Reference**: Schumer, M. A. and Steiglitz, K. (1968). Adaptive Step Size Random Search. IEEE Transactions on Automatic Control, 13(3), 270–276.


### schwefel
- **Description**: The Schwefel Function [7] with α=2.0 (chosen for concrete unimodal variant; general α≥0 per source). Properties based on Jamil & Yang (2013, p. 118); originally from Schwefel (various works).
- **Formula**: f(\mathbf{x}) = \left( \sum_{i=1}^{D} x_i^2 \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: unimodal, differentiable, continuous, partially separable, scalable
- **Reference**: Jamil & Yang (2013, p. 118)


### schwefel12
- **Description**: Schwefel 1.2 function; also known as Rotated Hyper-Ellipsoid or Double-Sum Function. Properties based on Jamil & Yang (2013, p. 29); originally from Schwefel (1977).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \left( \sum_{j=1}^i x_j \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 29)


### schwefel220
- **Description**: Schwefel's Problem 2.20 test function (positive sum variant as in benchmarks); Properties based on Jamil & Yang (2013, p. 77) [adapted to standard form without erroneous n-factor or minus]; originally from Schwefel (1977). Global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 77)


### schwefel221
- **Description**: Schwefel's Problem 2.21 test function; Properties based on Jamil & Yang (2013, p. 123); originally from Schwefel (1977). Global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \max_{1 \leq i \leq D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 123)


### schwefel222
- **Description**: Schwefel's Problem 2.22 test function; Properties based on Jamil & Yang (2013, p. 124); originally from Schwefel (1977). Global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} |x_i| + \prod_{i=1}^{D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 124)


### schwefel223
- **Description**: Schwefel's Problem 2.23 test function; Properties based on Jamil & Yang (2013, p. 125) [adapted to 'separable' as function is additive]; originally from Schwefel (1977). Global minimum at the origin.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} x_i^{10}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 125)


### schwefel225
- **Description**: Schwefel's Problem 2.25 test function; Properties based on Jamil & Yang (2013, p. 127) [separable per source, though coupled terms]; originally from Schwefel (1977).
- **Formula**: f(\mathbf{x}) = (x_2 - 1)^2 + (x_1 - x_2^2)^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 127)


### schwefel226
- **Description**: Schwefel's Problem 2.26 test function; Properties based on Jamil & Yang (2013, p. 30); originally from Schwefel (1977). Multiple global minima due to periodic sin term.
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} x_i \sin \sqrt{|x_i|}.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -418.9828872724338 at [420.96874357691473, 420.96874357691473]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 30)


### schwefel236
- **Description**: Schwefel's Problem 2.36 test function; Properties based on Jamil & Yang (2013, p. 129) [adapted: non-separable due to coupling, unimodal as quadratic]; originally from Schwefel (1981).
- **Formula**: f(\mathbf{x}) = -x_1 x_2 (72 - 2 x_1 - 2 x_2).
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -3456.0 at [12.0, 12.0]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 129)


### schwefel24
- **Description**: Schwefel's Problem 2.4 test function; Properties based on Jamil & Yang (2013, p. 30); originally from Schwefel (1977).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} (x_i - 1)^2 + (x_1 - x_i^2)^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 30)


### schwefel26
- **Description**: Schwefel's Problem 2.6 test function (piecewise linear); Properties based on Jamil & Yang (2013, p. 31); originally from Schwefel (1981). Global minimum where both arguments are zero.
- **Formula**: f(\mathbf{x}) = \max(|x_1 + 2x_2 - 7|, |2x_1 + x_2 - 5|).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [1.0, 3.0]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 31)


### shekel
- **Description**: Shekel function (m=10): Multimodal, finite at infinity, non-convex, non-separable, differentiable function defined for n=4, with multiple local minima and a global minimum near [4,4,4,4]. Properties based on Jamil & Yang (2013, p. 30) [f_{132}]; originally from Molga & Smutnicki (2005).
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{10} \frac{1}{\sum_{j=1}^4 (x_j - a_{ij})^2 + c_i}
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.536409816692043 at [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 30)


### shekel5
- **Description**: Shekel 5 test function; Properties based on Jamil & Yang (2013, p. 130) [minimum controversial: source -10.1532 (rounded) and pos [4,4,4,4], precise -10.15319967905822 at ≈[4.00003715, 4.00013327, 4.00003715, 4.00013327]]; originally from Box (1966).
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{5} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4].
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.15319967905822 at [4.00003715, 4.00013327, 4.00003715, 4.00013327]
- **Properties**: multimodal, controversial, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 130)


### shekel7
- **Description**: Shekel 7 test function; Properties based on Jamil & Yang (2013, p. 131) [minimum controversial: source -10.3999 (rounded) and pos [4,4,4,4], precise -10.402940566818653 at ≈[4.00057291, 4.00068936, 3.99948971, 3.99960616]]; originally from Box (1966).
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{7} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \\ 2 & 9 & 2 & 9 \\ 5 & 5 & 3 & 3 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3].
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.402940566818653 at [4.00057291, 4.00068936, 3.99948971, 3.99960616]
- **Properties**: multimodal, controversial, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 131)


### shubert_additive_cosine
- **Description**: Additive cosine Shubert function (Shubert 2); separable with ≈400 local minima in 2D; properties based on Jamil & Yang (2013, p. 56, f135); originally from Yao (1999).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.74177099545136 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_additive_sine
- **Description**: Additive sine Shubert function (Shubert 3); separable and asymmetric with ≈400 local minima in 2D; properties based on Jamil & Yang (2013, p. 55, f134); originally from Yao (1999).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 j \sin((j+1)x_i + j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -29.675900051421173 at [-7.397285, -7.397285]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_classic
- **Description**: Classical Shubert function (product of cosine sums); highly multimodal with 760 local minima in 2D; properties based on Jamil & Yang (2013, p. 55, f133); originally from Shubert (1970).
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^{2} \left( \sum_{j=1}^{5} j \cos((j+1) x_i + j) \right).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: controversial, non-separable, differentiable, highly multimodal, continuous
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_coupled
- **Description**: Coupled Shubert function (Shubert 4); non-separable with 760 local minima in 2D; for n=2 identical to classical; properties based on Jamil & Yang (2013, p. 56, f135-related); originally from Yao (1999).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[\sum_{j=1}^5 j \cos((j+1)x_i + j)\right] \left[\sum_{j=1}^5 j \cos((j+1)x_{i+1} + j)\right].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_generalized
- **Description**: Generalized Shubert function (parametric additive cosine); separable with ≈400 local minima in 2D; standard params (a_j=j, b_j=j+1, c_j=j) identical to Shubert 2; properties based on Jamil & Yang (2013, p. 56, f135-Generalized); CEC 2008–2013.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 a_j \cos(b_j x_i + c_j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.741770995451372 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_hybrid_rastrigin
- **Description**: Hybrid Shubert-Rastrigin composition (weights 0.5/0.5, n=2); non-separable multimodal hybrid; properties based on Jamil & Yang (2013, p. 56, Hybrid-Variante); CEC 2020 F10.
- **Formula**: f(\mathbf{x}) = 0.5 \cdot \text{Shubert}(\mathbf{x}) + 0.5 \cdot \text{Rastrigin}(\mathbf{x}).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -79.36953021020285 at [-0.8130518668176654, -1.4178774389880957]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, ill-conditioned
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_noisy
- **Description**: Noisy variant of Shubert function; additive uniform [0,1) noise. Properties based on Jamil & Yang (2013, p. 55) for base; noise adapted for stochastic benchmark. Gradient is deterministic (noise constant per call). Multiple global minima (18 in 2D).
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^D \sum_{j=1}^5 j \cos((j + 1) x_i + j) + \varepsilon, \quad \varepsilon \sim U[0,1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.7309088310239 at [-7.083506405745021, -7.708313737307907]
- **Properties**: multimodal, non-separable, differentiable, continuous, has_noise
- **Reference**: Jamil & Yang (2013, p. 55); noise adapted


### shubert_rotated
- **Description**: Rotated Shubert function; non-separable with ≈760 local minima in 2D; fixed Q=identity for reproducibility (in CEC random orthogonal Q, Kond=1); properties based on Jamil & Yang (2013, p. 55, f133-Rotated); CEC 2021 F7.
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(Q\mathbf{x})_i + j), \ Q \ orthogonal.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_shifted
- **Description**: Shifted Shubert function; non-separable with 760 local minima in 2D; fixed o=0 for reproducibility (in CEC random o~U[-10,10]); properties based on Jamil & Yang (2013, p. 55, f133-Shifted); CEC 2013 F6.
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(x_i - o_i) + j), \ o_i \sim U[-10,10].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_shifted_rotated
- **Description**: Shifted Rotated Shubert (CEC 2014 variant, product form with Q(x - o), fixed 2D); non-separable, highly multimodal (~760 local minima); tests invariance and coupling; based on classic Shubert with orthogonal rotation Q and shift o ~ U[-80,80].
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^2 \sum_{j=1}^5 j \cos((j+1)[\mathbf{Q}(\mathbf{x}-\mathbf{o})]_i + j).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -186.730908831 at [55.82260356132168, -69.31153726530631]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: CEC 2014; Jamil & Yang (2013, extended transformations)


### sineenvelope
- **Description**: Sine Envelope function: A multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with global minimum at (0,0). Properties based on Molga & Smutnicki (2005); also in Gaviano et al. (2003).
- **Formula**: f(\mathbf{x}) = -0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Molga & Smutnicki (2005)


### sixhumpcamelback
- **Description**: Six-Hump Camelback function: A multimodal, non-convex, non-separable, differentiable, continuous, bounded test function with six local minima and two equivalent global minima at (±0.089842, ∓0.712656) with value -1.031628. Properties based on Jamil & Yang (2013, p. 10) [f_{30}]; originally from Dixon & Szegő (1978). Bounds: [-3,3] x [-2,2].
- **Formula**: f(\mathbf{x}) = \left(4 - 2.1 x_1^2 + \frac{x_1^4}{3}\right) x_1^2 + x_1 x_2 + (-4 + 4 x_2^2) x_2^2
- **Bounds/Minimum**: Bounds: [-3.0, -2.0]; Min: -1.031628453489877 at [0.08984201368301331, -0.7126564032704135]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 10)


### sphere
- **Description**: Sphere function: f(x) = Σ x_i^2; Properties based on Jamil & Yang (2013, p. 33); adapted correcting multimodal to unimodal and adding convex based on standard analyses (e.g., sfu.ca/~ssurjano). Bounds adapted from sfu.ca; original in source: [0,10]^D.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D x_i^2.
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 33)


### sphere_noisy
- **Description**: Noisy Sphere benchmark function with additive uniform [0,1) noise; Properties based on BBOB f101 / Nevergrad 'NoisySphere'. Additive uniform [0,1) noise.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \epsilon, \epsilon \sim U[0,1].
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, differentiable, continuous, scalable, has_noise
- **Reference**: BBOB f101 / Nevergrad


### sphere_rotated
- **Description**: Rotated Sphere benchmark function; Properties based on CEC 2005 Problem Definitions and BBOB-Suiten.
- **Formula**: f(\mathbf{x}) = \| Q \mathbf{x} \|^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous, scalable
- **Reference**: CEC 2005 Problem Definitions


### sphere_shifted
- **Description**: Shifted Sphere benchmark function; Properties based on CEC 2005 Special Session.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n (x_i - o_i)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: separable, convex, unimodal, differentiable, continuous, scalable
- **Reference**: CEC 2005 Special Session


### step
- **Description**: Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 138); originally from benchmark collections.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \lfloor |x_i| \rfloor.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 138)


### step2
- **Description**: Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 139).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \left( \lfloor x_i + 0.5 \rfloor \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [-0.5, -0.5]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 139)


### step3
- **Description**: Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 140).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \lfloor x_i^2 \rfloor.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 140)


### step_ellipsoidal
- **Description**: Step Ellipsoidal (BBOB f7/f18) benchmark function with plateaus and discontinuities; Properties based on BBOB 2009 Noiseless Functions f7 (Step Ellipsoidal); gradient zero almost everywhere except near boundaries.
- **Formula**: f(\mathbf{z}) = 0.1 \max\left( \frac{|\tilde{z}_1|}{10^4}, \sum_{i=1}^D 10^{2(i-1)/(D-1)} \tilde{z}_i^2 \right) + f_\mathrm{pen}(x) + f_\mathrm{opt}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, partially differentiable, unimodal, continuous, scalable, ill-conditioned
- **Reference**: BBOB 2009 Noiseless Functions f7


### stepint
- **Description**: Discontinuous and non-differentiable due to floor function; Properties based on Jamil & Yang (2013, function 141); Adapted for consistency: paper states min=0 at x=0 but formula gives f(0)=25; actual global min=25-6D at x_i≈-5.12 (floor(x_i)=-6 for all i).
- **Formula**: f(\mathbf{x}) = 25 + \sum_{i=1}^D \lfloor x_i \rfloor.
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 13 at [-5.12, -5.12]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 141)


### stretched_v_sine_wave
- **Description**: Properties based on Jamil & Yang (2013, function 142); originally from Schaffer et al. (1989).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_i^2 + x_{i+1}^2)^{0.25} \left[ \sin^2 \left\{ 50 (x_i^2 + x_{i+1}^2)^{0.1} \right\} + 0.1 \right].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, function 142)


### styblinski_tang
- **Description**: Properties based on Jamil & Yang (2013, function 144); formula indicates separable and scalable, adapted accordingly despite source listing non-separable/non-scalable; Minimum computed precisely via solving derivative=0 (source approx -39.16618); originally from [80].
- **Formula**: f(\mathbf{x}) = \frac{1}{2} \sum_{i=1}^D (x_i^4 - 16x_i^2 + 5x_i).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -78.33233140754282 at [-2.903534027771177, -2.903534027771177]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 144)


### sumofpowers
- **Description**: Sum of Different Powers function: A unimodal, convex, differentiable, separable, scalable function with global minimum at origin. Properties based on Jamil & Yang (2013, p. 32) [f_{145}]; originally from Bingham (1995).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n |x_i|^{i+1}
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 32)


### testtubeholder
- **Description**: Two global minima due to sign choices; Properties based on Jamil & Yang (2013, p. 34); Contains absolute value terms; originally from literature circa 2006.
- **Formula**: f(\mathbf{x}) = -4 \sin(x_1) \cos(x_2) \exp\left( \left| \cos\left( \frac{x_1^2 + x_2^2}{200} \right) \right| \right).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -10.872300105622745 at [1.5706026141696665, 4.534236385313213e-12]
- **Properties**: multimodal, non-separable, bounded, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### threehumpcamel
- **Description**: Three-Hump Camel function: Multimodal, non-convex, non-separable, differentiable, bounded test function with three local minima and a global minimum at (0.0, 0.0).
- **Formula**: 2x_1^2 - 1.05x_1^4 + \frac{x_1^6}{6} + x_1 x_2 + x_2^2
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### trecanni
- **Description**: Two global minima at [-2,0] and [0,0]; Properties based on Jamil & Yang (2013, p. 35); originally from Dixon & Szegő (1978).
- **Formula**: f(\mathbf{x}) = x_1^4 + 4x_1^3 + 4x_1^2 + x_2^2.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [-2.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 35)


### trefethen
- **Description**: Properties based on Jamil & Yang (2013, p. 35); originally from MVF Library (Adorio & Diliman, 2005).
- **Formula**: f(\mathbf{x}) = e^{\sin(50 x_1)} + \sin(60 e^{x_2}) + \sin(70 \sin(x_1)) + \sin(\sin(80 x_2)) - \sin(10(x_1 + x_2)) + \frac{1}{4}(x_1^2 + x_2^2). 
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -3.306868647475232 at [-0.0244030799684242, 0.210612427873691]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 35)


### trid
- **Description**: Trid function; Properties based on Jamil & Yang (2013, p. 35); Adapted for scalable unimodal variant; ursprünglich aus Dixon & Szegö (1978).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n (x_i - 1)^2 - \sum_{i=2}^n x_i x_{i-1}.
- **Bounds/Minimum**: Bounds: [-4, -4]; Min: -2.0 at [2, 2]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 35)


### trid10
- **Description**: Properties based on Jamil & Yang (2013, p. 35); adapted for confirmed unimodal nature (no local minima per multiple sources); originally from Neumaier/Hedar.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} (x_i - 1)^2 - \sum_{i=2}^{10} x_i x_{i-1}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0]; Min: -210.0 at [10.0, 18.0, 24.0, 28.0, 30.0, 30.0, 28.0, 24.0, 18.0, 10.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 35)


### trid6
- **Description**: Properties based on Jamil & Yang (2013, p. 35); originally from Hedar (2005).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{6} (x_i - 1)^2 - \sum_{i=2}^{6} x_i x_{i-1}.
- **Bounds/Minimum**: Bounds: [-36.0, -36.0, -36.0, -36.0, -36.0, -36.0]; Min: -50.0 at [6.0, 10.0, 12.0, 12.0, 10.0, 6.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 35)


### trigonometric1
- **Description**: The Trigonometric 1 function is a multimodal, non-separable trigonometric benchmark. Properties based on Jamil & Yang (2013, p. 36).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} \left[ n - \sum_{j=1}^{n} \cos x_j + i (1 - \cos( x_i ) - \sin( x_i )) \right]^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 36)


### trigonometric2
- **Description**: The Trigonometric 2 function is a multimodal, non-separable benchmark with asymmetric oscillatory terms centered around 0.9. Properties based on Jamil & Yang (2013, p. 36).
- **Formula**: f(\mathbf{x}) = 1 + \sum_{i=1}^n \left[ 8 \sin^2 \left( 7 (x_i - 0.9)^2 \right) + (x_i - 0.9)^2 \right] + 6 \sin^2 \left( 14 (x_1 - 0.9)^2 \right).
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 1.0 at [0.9, 0.9]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 36)


### tripod
- **Description**: The Tripod function is a discontinuous, non-differentiable, non-separable multimodal benchmark with a tripod-shaped surface due to absolute values and step functions. Properties based on Jamil & Yang (2013, p. 37); contains step functions leading to discontinuities and absolute values causing non-differentiability.
- **Formula**: f(\mathbf{x}) = p(x_2)(1 + p(x_1)) + |x_1 + 50 p(x_2)(1 - 2 p(x_1))| + |x_2 + 50(1 - 2 p(x_2))|, \\ \text{where } p(x) = \begin{cases} 1 & x \geq 0 \\ 0 & x < 0 \end{cases}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, -50.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable
- **Reference**: Jamil & Yang (2013, p. 37)


### ursem1
- **Description**: Implementation of the Ursem 1 test function. Properties based on Jamil & Yang (2013, p. 36); originally from Rönkkönen (2009). Single global minimum.
- **Formula**: f(\mathbf{x}) = -\sin(2x_1 - 0.5\pi) - 3\cos(x_2) - 0.5x_1.
- **Bounds/Minimum**: Bounds: [-2.5, -2.0]; Min: -4.816814063734245 at [1.697137, 0.0]
- **Properties**: separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 36)


### ursem3
- **Description**: Implementation of the Ursem 3 test function. Properties based on Jamil & Yang (2013, p. 36); formula and minimum adapted from Al-Roomi (2015) to match reported global minimum of -2.5 (Jamil & Yang transcription appears erroneous); originally from Rönkkönen (2009). Contains absolute value terms.
- **Formula**: f(\mathbf{x}) = -\frac{3 - |x_1|}{2} \cdot \frac{2 - |x_2|}{2} \cdot \sin(2.2\pi x_1 + 0.5\pi) - \frac{2 - |x_1|}{2} \cdot \frac{2 - |x_2|}{2} \cdot \sin(0.5\pi x_2^2 + 0.5\pi).
- **Bounds/Minimum**: Bounds: [-2.0, -1.5]; Min: -2.5 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 36)


### ursem4
- **Description**: The Ursem No. 4 function; Properties based on Jamil & Yang (2013, p. 36); Contains square root terms making it non-differentiable at the origin.
- **Formula**: f(\mathbf{x}) = -\frac{3}{4} \sin\left(0.5 \pi x_1 + 0.5 \pi\right) \left(2 - \sqrt{x_1^2 + x_2^2}\right). 
- **Bounds/Minimum**: Bounds: [-2.0, -2.0]; Min: -1.5 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 36)


### ursem_waves
- **Description**: The Ursem Waves function; Properties based on Jamil & Yang (2013, p. 36); has single global minimum and nine local minima.
- **Formula**: f(\mathbf{x}) = -0.9 x_1^2 + (x_2^2 - 4.5 x_2^2) x_1 x_2 + 4.7 \cos(3 x_1 - x_2^2 (2 + x_1)) \sin(2.5 \pi x_1). 
- **Bounds/Minimum**: Bounds: [-0.9, -1.2]; Min: -8.5536 at [1.2, 1.2]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 36)


### venter_sobiezcczanski_sobieski
- **Description**: The Venter Sobiezcczanski-Sobieski function; Properties based on Jamil & Yang (2013, p. 37); originally from Begambre and Laier (2009). Multimodal with multiple local minima due to cosine terms.
- **Formula**: f(\mathbf{x}) = x_1^2 - 100 \cos^2(x_1) - 100 \cos\left(\frac{x_1^2}{30}\right) + x_2^2 - 100 \cos^2(x_2) - 100 \cos\left(\frac{x_2^2}{30}\right). 
- **Bounds/Minimum**: Bounds: [-50.0, -50.0]; Min: -400.0 at [0.0, 0.0]
- **Properties**: separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 37)


### watson
- **Description**: Standard Watson function (n=6); polynomial approximation residual model. Properties based on Moré et al. (1981). Jamil & Yang (2013, p. 37) formula variant inconsistent (missing (j-1) factors leads to wrong minimum ~154); adapted to verified standard form.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{29} \left[ \sum_{j=2}^{6} (j-1) x_j t_i^{j-2} - \left( \sum_{j=1}^{6} x_j t_i^{j-1} \right)^2 - 1 \right]^2 + x_1^2, \quad t_i = i / 29.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0, -5.0, -5.0, -5.0, -5.0]; Min: 0.00193306874741329 at [-0.01367625, 1.02929024, -0.33159222, 1.50042489, -1.75935227, 1.08739726]
- **Properties**: controversial, non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Moré et al. (1981). Testing Unconstrained Optimization Software. ACM TOMS, 7(1), 17–41.


### wavy
- **Description**: Wavy Function; Properties based on Jamil & Yang (2013, p. 38); originally from [23]. Multimodal with ~10^n local minima for k=10.
- **Formula**: f(\mathbf{x}) = 1 - \frac{1}{n} \sum_{i=1}^{n} \cos(10 x_i) e^{-x_i^2 / 2}.
- **Bounds/Minimum**: Bounds: [-3.141592653589793, -3.141592653589793]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 38)


### wayburnseader1
- **Description**: The Wayburn Seader 1 function; Properties based on Jamil & Yang (2013, p. 37); originally from Wayburn and Seader (1987). Multiple global minima at (1,2) and approximately (1.597, 0.806). Marked as scalable in source, but formula only uses first 2 variables; adapted to fixed n=2.
- **Formula**: f(\mathbf{x}) = (x_1^6 + x_2^4 - 17)^2 + (2x_1 + x_2 - 4)^2.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [1.0, 2.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 37)


### wayburnseader2
- **Description**: Wayburn Seader 2 function; Properties based on Jamil & Yang (2013, p. 63); multiple global minima at (0.2,1) and (0.425,1); originally from Wayburn & Seader (1987). Formel only uses first 2 variables; marked as scalable in source but adapted to fixed n=2.
- **Formula**: f(\mathbf{x}) = \left[ 1.613 - 4(x_1 - 0.3125)^2 - 4(x_2 - 1.625)^2 \right]^2 + (x_2 - 1)^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.2, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 63)


### wayburnseader3
- **Description**: Wayburn Seader 3 Function; Properties based on Jamil & Yang (2013); originally from Wayburn & Seader (1987). Fixed n=2 (formula uses only first 2 variables; 'scalable' in source ignored per consistency rule). Corrected minimum from numerical optimization (source reports approximate 21.35 at [5.611,6.187], but actual global minimum is 19.10588 at [5.1469,6.8396]).
- **Formula**: f(\mathbf{x}) = \frac{2 x_1^3}{3} - 8 x_1^2 + 33 x_1 - x_1 x_2 + 5 + \left[ (x_1 - 4)^2 + (x_2 - 5)^2 - 4 \right]^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 19.105879794568022 at [5.14689674946688, 6.83958974367702]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### weierstrass
- **Description**: Weierstrass function (f_166). Formula from Jamil & Yang (2013, p. 38).
Parameters a=0.5, b=3, k_max=20 are standard in literature (e.g. Al-Roomi, 2015; Surjanovic & Bingham) 
but not specified in Jamil & Yang. This is an adapted implementation for practical use.
The function is continuous and differentiable (finite sum). 
Theoretical global minimum: 0 at x=zeros(n); in practice f(0) ≈ 0.0 (exact with finite precision).

- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} \left[ \sum_{k=0}^{20} a^k \cos(2 \pi b^k (x_i + 0.5)) \right] - n \sum_{k=0}^{20} a^k \cos(\pi b^k), \quad a=0.5, b=3.
- **Bounds/Minimum**: Bounds: [-0.5, -0.5]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 38); parameters adapted from Al-Roomi (2015)


### whitley
- **Description**: The Whitley function is a multimodal, non-separable test function for global optimization. Properties based on Jamil & Yang (2013, #167); originally from Whitley et al. (1996).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \sum_{j=1}^D \left[ \frac{\left(100(x_i^2 - x_j)^2 + (1 - x_j)^2\right)^2}{4000} - \cos\left(100(x_i^2 - x_j)^2 + (1 - x_j)^2\right) + 1 \right]
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, #167)


### wolfe
- **Description**: The Wolfe function; Properties based on Al-Roomi (2015) and adapted from Jamil & Yang (2013, p. 39) (partially separable due to x1-x2 coupling in u; unimodal; fixed n=3, not scalable). Contains power term ^{0.75} differentiable at u=0 (grad limit=0).
- **Formula**: f(\mathbf{x}) = \frac{4}{3} (x_1^2 + x_2^2 - x_1 x_2)^{0.75} + x_3.
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: 0.0 at [0.0, 0.0, 0.0]
- **Properties**: bounded, unimodal, differentiable, continuous, partially separable
- **Reference**: Al-Roomi (2015); adapted from Jamil & Yang (2013, p. 39)


### wood
- **Description**: Wood function: Multimodal, non-convex, non-separable, differentiable test function with a single global minimum. Also known as Colville function.
- **Formula**: f(x) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 1.0, 1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### xin_she_yang1
- **Description**: Xin-She Yang Function 1; Properties based on Jamil & Yang (2013, Section 3); stochastic with ε_i ~ U[0,1] per evaluation (has_noise, f noisy but min=0 deterministic at zeros); separable (independent terms); partially differentiable due to abs at 0.
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \epsilon_i |x_i|^i, \quad \epsilon_i \sim U(0,1).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, unimodal, partially differentiable, scalable, has_noise
- **Reference**: Jamil & Yang (2013, Section 3)


### xin_she_yang2
- **Description**: Xin-She Yang Function 2; Properties based on Jamil & Yang (2013, p. 30); multimodal non-separable with abs and sin^2; partially differentiable at 0.
- **Formula**: f(\mathbf{x}) = \left( \sum_{i=1}^{D} |x_i| \right) \exp \left[ - \sum_{i=1}^{D} \sin^2(x_i) \right].
- **Bounds/Minimum**: Bounds: [-6.283185307179586, -6.283185307179586]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 30)


### xin_she_yang3
- **Description**: Xin-She Yang No. 3 function; Properties based on Jamil & Yang (2013, p. 39); originally proposed by Xin-She Yang.
- **Formula**: f(\mathbf{x}) = \left[ e^{-\sum_{i=1}^{D} \left( \frac{x_i}{\beta} \right)^2 m} - 2 e^{-\sum_{i=1}^{D} x_i^2} \cdot \prod_{i=1}^{D} \cos^2 (x_i) \right]
- **Bounds/Minimum**: Bounds: [-20.0, -20.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 39)


### xin_she_yang4
- **Description**: Xin-She Yang No. 4 function; Properties based on Jamil & Yang (2013, p. 39); originally proposed by Xin-She Yang.
- **Formula**: f(\mathbf{x}) = \left[ \sum_{i=1}^{D} \sin^2(x_i) - e^{-\sum_{i=1}^{D} x_i^2} \right] \cdot e^{-\sum_{i=1}^{D} \sin^2 \sqrt{|x_i|}}
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 39)


### zakharov
- **Description**: Zakharov function; Properties based on Jamil & Yang (2013, p. 40); originally from Rahnamyan et al. (2007).
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \left( \frac{1}{2} \sum_{i=1}^n i x_i \right)^2 + \left( \frac{1}{2} \sum_{i=1}^n i x_i \right)^4.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 40)


### zettl
- **Description**: Zettl function; Properties based on Jamil & Yang (2013, p. 40); non-scalable (fixed n=2); originally from [78].
- **Formula**: f(\mathbf{x}) = (x_1^2 + x_2^2 - 2x_1)^2 + 0.25 x_1.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -0.0037912371501199 at [-0.0299, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 40)


### zirilli_aluffipentini
- **Description**: Zirilli or Aluffi-Pentini’s function; Properties based on Jamil & Yang (2013, p. 40); non-scalable (fixed n=2); originally from [4].
- **Formula**: f(\mathbf{x}) = 0.25 x_1^4 - 0.5 x_1^2 + 0.1 x_1 + 0.5 x_2^2.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.352386073800036 at [-1.046680529537701, 5.558876e-9]
- **Properties**: separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 40)


## Generation
Run `julia --project=. examples/generate_functions_md.jl` to update from TEST_FUNCTIONS.
