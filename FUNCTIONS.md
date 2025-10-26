# Established Benchmark Functions

Generated from package metadata on 2025-10-26. Functions are listed vertically by category for easy reading.

## Inhaltsverzeichnis
- [Classical Benchmarks](#classical-benchmarks)
  - [ackley2: Standard](#ackley2-standard)
  - [beale: Standard](#beale-standard)
  - [booth: Standard](#booth-standard)
  - [brent: Standard](#brent-standard)
  - [brown: Standard](#brown-standard)
  - [chungreynolds: Standard](#chungreynolds-standard)
  - [colville: Standard](#colville-standard)
  - [cube: Standard](#cube-standard)
  - [dixonprice: Standard](#dixonprice-standard)
  - [elattavidyasagardutta: Standard](#elattavidyasagardutta-standard)
  - [exponential: Standard](#exponential-standard)
  - [leon: Standard](#leon-standard)
  - [matyas: Standard](#matyas-standard)
  - [powell: Standard](#powell-standard)
  - [powellsingular: Standard](#powellsingular-standard)
  - [powellsingular2: Standard](#powellsingular2-standard)
  - [powellsum: Standard](#powellsum-standard)
  - [quadratic: Standard](#quadratic-standard)
  - [rosenbrock: Standard](#rosenbrock-standard)
  - [rotatedellipse: Standard](#rotatedellipse-standard)
  - [rotatedellipse2: Standard](#rotatedellipse2-standard)
  - [rotatedhyperellipsoid: Standard](#rotatedhyperellipsoid-standard)
  - [rump: Standard](#rump-standard)
  - [schaffer2: Standard](#schaffer2-standard)
  - [schaffer3: Standard](#schaffer3-standard)
  - [schumersteiglitz: Standard](#schumersteiglitz-standard)
  - [schwefel: Standard](#schwefel-standard)
  - [schwefel12: Standard](#schwefel12-standard)
  - [schwefel220: Standard](#schwefel220-standard)
  - [schwefel221: Standard](#schwefel221-standard)
  - [schwefel222: Standard](#schwefel222-standard)
  - [schwefel223: Standard](#schwefel223-standard)
  - [schwefel236: Standard](#schwefel236-standard)
  - [schwefel26: Standard](#schwefel26-standard)
  - [sphere: Standard](#sphere-standard)
  - [sphere_rotated: rotated](#sphere_rotated-rotated)
  - [sphere_shifted: shifted](#sphere_shifted-shifted)
  - [step: Standard](#step-standard)
  - [step2: Standard](#step2-standard)
  - [step3: Standard](#step3-standard)
  - [step_ellipsoidal: ellipsoidal](#step_ellipsoidal-ellipsoidal)
  - [stepint: Standard](#stepint-standard)
  - [stretched_v_sine_wave: wave](#stretched_v_sine_wave-wave)
  - [sumofpowers: Standard](#sumofpowers-standard)
  - [trid: Standard](#trid-standard)
  - [zakharov: Standard](#zakharov-standard)
- [Extended Benchmarks](#extended-benchmarks)
  - [ackley: Standard](#ackley-standard)
  - [adjiman: Standard](#adjiman-standard)
  - [alpinen1: Standard](#alpinen1-standard)
  - [alpinen2: Standard](#alpinen2-standard)
  - [bartelsconn: Standard](#bartelsconn-standard)
  - [becker_lago: lago](#becker_lago-lago)
  - [biggsexp2: Standard](#biggsexp2-standard)
  - [biggsexp3: Standard](#biggsexp3-standard)
  - [biggsexp4: Standard](#biggsexp4-standard)
  - [biggsexp5: Standard](#biggsexp5-standard)
  - [biggsexp6: Standard](#biggsexp6-standard)
  - [bird: Standard](#bird-standard)
  - [bohachevsky1: Standard](#bohachevsky1-standard)
  - [bohachevsky2: Standard](#bohachevsky2-standard)
  - [bohachevsky3: Standard](#bohachevsky3-standard)
  - [boxbetts: Standard](#boxbetts-standard)
  - [brad: Standard](#brad-standard)
  - [branin: Standard](#branin-standard)
  - [braninrcos2: Standard](#braninrcos2-standard)
  - [bukin2: Standard](#bukin2-standard)
  - [bukin4: Standard](#bukin4-standard)
  - [bukin6: Standard](#bukin6-standard)
  - [carromtable: Standard](#carromtable-standard)
  - [chen: Standard](#chen-standard)
  - [chenv: Standard](#chenv-standard)
  - [chichinadze: Standard](#chichinadze-standard)
  - [cola: Standard](#cola-standard)
  - [corana: Standard](#corana-standard)
  - [cosinemixture: Standard](#cosinemixture-standard)
  - [crossintray: Standard](#crossintray-standard)
  - [csendes: Standard](#csendes-standard)
  - [damavandi: Standard](#damavandi-standard)
  - [deb1: Standard](#deb1-standard)
  - [deb3: Standard](#deb3-standard)
  - [dejongf4: Standard](#dejongf4-standard)
  - [dejongf5modified: Standard](#dejongf5modified-standard)
  - [dejongf5original: Standard](#dejongf5original-standard)
  - [dekkersaarts: Standard](#dekkersaarts-standard)
  - [devilliersglasser1: Standard](#devilliersglasser1-standard)
  - [devilliersglasser2: Standard](#devilliersglasser2-standard)
  - [dolan: Standard](#dolan-standard)
  - [dropwave: Standard](#dropwave-standard)
  - [easom: Standard](#easom-standard)
  - [eggcrate: Standard](#eggcrate-standard)
  - [eggholder: Standard](#eggholder-standard)
  - [freudensteinroth: Standard](#freudensteinroth-standard)
  - [giunta: Standard](#giunta-standard)
  - [goldsteinprice: Standard](#goldsteinprice-standard)
  - [griewank: Standard](#griewank-standard)
  - [gulfresearch: Standard](#gulfresearch-standard)
  - [hansen: Standard](#hansen-standard)
  - [hartman6: Standard](#hartman6-standard)
  - [hartmanf3: Standard](#hartmanf3-standard)
  - [helicalvalley: Standard](#helicalvalley-standard)
  - [himmelblau: Standard](#himmelblau-standard)
  - [holder_table1: table1](#holder_table1-table1)
  - [holder_table2: table2](#holder_table2-table2)
  - [holdertable: Standard](#holdertable-standard)
  - [hosaki: Standard](#hosaki-standard)
  - [jennrichsampson: Standard](#jennrichsampson-standard)
  - [keane: Standard](#keane-standard)
  - [kearfott: Standard](#kearfott-standard)
  - [langermann: Standard](#langermann-standard)
  - [levyjamil: Standard](#levyjamil-standard)
  - [mccormick: Standard](#mccormick-standard)
  - [michalewicz: Standard](#michalewicz-standard)
  - [mielcantrell: Standard](#mielcantrell-standard)
  - [mishra1: Standard](#mishra1-standard)
  - [mishra10: Standard](#mishra10-standard)
  - [mishra11: Standard](#mishra11-standard)
  - [mishra2: Standard](#mishra2-standard)
  - [mishra3: Standard](#mishra3-standard)
  - [mishra4: Standard](#mishra4-standard)
  - [mishra5: Standard](#mishra5-standard)
  - [mishra6: Standard](#mishra6-standard)
  - [mishra7: Standard](#mishra7-standard)
  - [mishra8: Standard](#mishra8-standard)
  - [mishra9: Standard](#mishra9-standard)
  - [mishrabird: Standard](#mishrabird-standard)
  - [mvf_shubert: shubert](#mvf_shubert-shubert)
  - [mvf_shubert2: shubert2](#mvf_shubert2-shubert2)
  - [mvf_shubert3: shubert3](#mvf_shubert3-shubert3)
  - [parsopoulos: Standard](#parsopoulos-standard)
  - [pathological: Standard](#pathological-standard)
  - [paviani: Standard](#paviani-standard)
  - [penholder: Standard](#penholder-standard)
  - [periodic: Standard](#periodic-standard)
  - [pinter: Standard](#pinter-standard)
  - [price1: Standard](#price1-standard)
  - [price2: Standard](#price2-standard)
  - [price4: Standard](#price4-standard)
  - [qing: Standard](#qing-standard)
  - [quartic: Standard](#quartic-standard)
  - [quintic: Standard](#quintic-standard)
  - [rana: Standard](#rana-standard)
  - [rastrigin: Standard](#rastrigin-standard)
  - [ripple1: Standard](#ripple1-standard)
  - [ripple25: Standard](#ripple25-standard)
  - [rosenbrock_modified: modified](#rosenbrock_modified-modified)
  - [salomon: Standard](#salomon-standard)
  - [sargan: Standard](#sargan-standard)
  - [schaffer1: Standard](#schaffer1-standard)
  - [schaffer6: Standard](#schaffer6-standard)
  - [schafferf6: Standard](#schafferf6-standard)
  - [schaffern2: Standard](#schaffern2-standard)
  - [schaffern4: Standard](#schaffern4-standard)
  - [schmidtvetters: Standard](#schmidtvetters-standard)
  - [schwefel225: Standard](#schwefel225-standard)
  - [schwefel226: Standard](#schwefel226-standard)
  - [schwefel24: Standard](#schwefel24-standard)
  - [shekel: Standard](#shekel-standard)
  - [shekel5: Standard](#shekel5-standard)
  - [shekel7: Standard](#shekel7-standard)
  - [shubert_additive_cosine: cosine](#shubert_additive_cosine-cosine)
  - [shubert_additive_sine: sine](#shubert_additive_sine-sine)
  - [shubert_generalized: generalized](#shubert_generalized-generalized)
  - [shubert_hybrid_rastrigin: rastrigin](#shubert_hybrid_rastrigin-rastrigin)
  - [shubert_noisy: noisy](#shubert_noisy-noisy)
  - [shubert_shifted_rotated: rotated](#shubert_shifted_rotated-rotated)
  - [sineenvelope: Standard](#sineenvelope-standard)
  - [sixhumpcamelback: Standard](#sixhumpcamelback-standard)
  - [sphere_noisy: noisy](#sphere_noisy-noisy)
  - [styblinski_tang: tang](#styblinski_tang-tang)
  - [styblinskitang: Standard](#styblinskitang-standard)
  - [testtubeholder: Standard](#testtubeholder-standard)
  - [threehumpcamel: Standard](#threehumpcamel-standard)
  - [trecanni: Standard](#trecanni-standard)
  - [wood: Standard](#wood-standard)
- [Other Benchmarks](#other-benchmarks)
  - [ackley4: Standard](#ackley4-standard)
  - [axisparallelhyperellipsoid: Standard](#axisparallelhyperellipsoid-standard)
  - [shubert_classic: classic](#shubert_classic-classic)
  - [shubert_coupled: coupled](#shubert_coupled-coupled)
  - [shubert_rotated: rotated](#shubert_rotated-rotated)
  - [shubert_shifted: shifted](#shubert_shifted-shifted)

## Classical Benchmarks {#classical-benchmarks}

### ackley2: Standard {#ackley2-standard}
- **Formula**: \f(x) = -200 e^{-0.02 \sqrt{x_1^2 + x_2^2}}
- **Bounds/Minimum**: Bounds: [-32.0, -32.0]; Min: -200.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, partially differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013): f2


### beale: Standard {#beale-standard}
- **Formula**: (1.5 - x_1 + x_1 x_2)^2 + (2.25 - x_1 + x_1 x_2^2)^2 + (2.625 - x_1 + x_1 x_2^3)^2
- **Bounds/Minimum**: Bounds: [-4.5, -4.5]; Min: 0.0 at [3.0, 0.5]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, entry 10)


### booth: Standard {#booth-standard}
- **Formula**: (x_1 + 2x_2 - 7)^2 + (2x_1 + x_2 - 5)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 3.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, continuous
- **Reference**: Surjanovic & Bingham (2013), Virtual Library of Simulation Experiments: Test Functions and Datasets, retrieved from https://www.sfu.ca/~ssurjano/booth.html


### brent: Standard {#brent-standard}
- **Formula**: f(\mathbf{x}) = (x_1 + 10)^2 + (x_2 + 10)^2 + \exp(-x_1^2 - x_2^2)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [-10.0, -10.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 9)


### brown: Standard {#brown-standard}
- **Formula**: \sum_{i=1}^{n-1} \left[ (x_i^2)^{(x_{i+1}^2 + 1)} + (x_{i+1}^2)^{(x_i^2 + 1)} \right]
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Jamil & Yang (2013, p. 5)


### chungreynolds: Standard {#chungreynolds-standard}
- **Formula**: f(\mathbf{x}) = \left( \sum_{i=1}^n x_i^2 \right)^2 
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: bounded, unimodal, differentiable, continuous, partially separable, scalable
- **Reference**: Jamil & Yang (2013, Entry 34)


### colville: Standard {#colville-standard}
- **Formula**: f(\mathbf{x}) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 1.0, 1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, p. 13)


### cube: Standard {#cube-standard}
- **Formula**: f(\mathbf{x}) = 100 (x_2 - x_1^3)^2 + (1 - x_1)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 41)


### dixonprice: Standard {#dixonprice-standard}
- **Formula**: (x_1 - 1)^2 + \sum_{i=2}^n i (2 x_i^2 - x_{i-1})^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 0.7071067811865476]
- **Properties**: bounded, unimodal, differentiable, scalable, continuous, non-convex
- **Reference**: Jamil & Yang (2013, Entry 14)


### elattavidyasagardutta: Standard {#elattavidyasagardutta-standard}
- **Formula**: f(\mathbf{x}) = (x_1^2 + x_2 - 10)^2 + 5(x_3 - x_4)^2 + (x_2 - x_3)^2 + 10(x_4 - 1)^2.
- **Bounds/Minimum**: Bounds: [-5.2, -5.2, -5.2, -5.2]; Min: 0.0 at [3.0, 1.0, 1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 16)


### exponential: Standard {#exponential-standard}
- **Formula**: f(\mathbf{x}) = -\exp\left( -\frac{1}{2} \sum_{i=1}^n x_i^2 \right). 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Ramanujan et al. (2007)


### leon: Standard {#leon-standard}
- **Formula**: f(\mathbf{x}) = 100(x_2 - x_1^2)^2 + (1 - x_1)^2 
- **Bounds/Minimum**: Bounds: [-1.2, -1.2]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Lavi and Vogel (1966)


### matyas: Standard {#matyas-standard}
- **Formula**: 0.26 (x^2 + y^2) - 0.48 x y
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Unknown


### powell: Standard {#powell-standard}
- **Formula**: f(x) = (x_1 + 10x_2)^2 + 5(x_3 - x_4)^2 + (x_2 - 2x_3)^4 + 10(x_1 - x_4)^4
- **Bounds/Minimum**: Bounds: [-4.0, -4.0, -4.0, -4.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: non-separable, unimodal, differentiable, non-convex
- **Reference**: Unknown


### powellsingular: Standard {#powellsingular-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n/4} \left[ (x_{4i-3} + 10 x_{4i-2})^2 + 5 (x_{4i-1} - x_{4i})^2 + (x_{4i-2} - 2 x_{4i-1})^4 + 10 (x_{4i-3} - x_{4i})^4 \right].
- **Bounds/Minimum**: Bounds: [-4.0, -4.0, -4.0, -4.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Powell (1962)


### powellsingular2: Standard {#powellsingular2-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n/4} \left[ (x_{4i-3} + 10 x_{4i-2})^2 + 5 (x_{4i-1} - x_{4i})^2 + (x_{4i-2} - 2 x_{4i-1})^4 + 10 (x_{4i-3} - x_{4i})^4 \right].
- **Bounds/Minimum**: Bounds: [-4.0, -4.0, -4.0, -4.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Fu et al. (2006)


### powellsum: Standard {#powellsum-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n |x_i|^{i+1}.
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Rahnamyan et al. (2007a)


### quadratic: Standard {#quadratic-standard}
- **Formula**: f(\mathbf{x}) = -3803.84 - 138.08 x_1 - 232.92 x_2 + 128.08 x_1^2 + 203.64 x_2^2 + 182.25 x_1 x_2.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -3873.72418218627 at [0.193880172788953, 0.485133909126923]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### rosenbrock: Standard {#rosenbrock-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} [100(x_{i+1} - x_i^2)^2 + (x_i - 1)^2]. 
- **Bounds/Minimum**: Bounds: [-30.0, -30.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable, ill-conditioned
- **Reference**: Jamil & Yang (2013), Benchmark Function #105


### rotatedellipse: Standard {#rotatedellipse-standard}
- **Formula**: f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 107)


### rotatedellipse2: Standard {#rotatedellipse2-standard}
- **Formula**: f(\mathbf{x}) = 7x_1^2 - 6\sqrt{3}x_1x_2 + 13x_2^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, Entry 107)


### rotatedhyperellipsoid: Standard {#rotatedhyperellipsoid-standard}
- **Formula**: \sum_{i=1}^{n} \left( \sum_{j=1}^{i} x_j \right)^2
- **Bounds/Minimum**: Bounds: [-65.536, -65.536]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Unknown


### rump: Standard {#rump-standard}
- **Formula**: f(\mathbf{x}) = \left| (333.75 - x_1^2) x_2^6 + x_1^2 (11 x_1^2 x_2^2 - 121 x_2^4 - 2) + 5.5 x_2^8 + \frac{x_1}{2 + x_2} \right|.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, partially differentiable, unimodal, continuous
- **Reference**: https://al-roomi.org/benchmarks/unconstrained/2-dimensions/128-rump-function


### schaffer2: Standard {#schaffer2-standard}
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 - x_2^2) - 0.5}{1 + 0.001 (x_1^2 + x_2^2)^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 28)


### schaffer3: Standard {#schaffer3-standard}
- **Formula**: f(\mathbf{x}) = 0.5 + \sin^2(\cos |x_1^2 - x_2^2|) - \frac{0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}. 
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0015668553065719681 at [0.0, 1.253115587]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 28)


### schumersteiglitz: Standard {#schumersteiglitz-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} x_i^4
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
- **Properties**: separable, unimodal, differentiable, continuous, scalable
- **Reference**: Schumer, M. A. and Steiglitz, K. (1968). Adaptive Step Size Random Search. IEEE Transactions on Automatic Control, 13(3), 270–276.


### schwefel: Standard {#schwefel-standard}
- **Formula**: f(\mathbf{x}) = \left( \sum_{i=1}^{D} x_i^2 \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: unimodal, differentiable, continuous, partially separable, scalable
- **Reference**: Jamil & Yang (2013, p. 118)


### schwefel12: Standard {#schwefel12-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} \left( \sum_{j=1}^{i} x_j \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 29)


### schwefel220: Standard {#schwefel220-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 77)


### schwefel221: Standard {#schwefel221-standard}
- **Formula**: f(\mathbf{x}) = \max_{1 \leq i \leq D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 123)


### schwefel222: Standard {#schwefel222-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} |x_i| + \prod_{i=1}^{D} |x_i|.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, partially differentiable, unimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 124)


### schwefel223: Standard {#schwefel223-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D} x_i^{10}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 125)


### schwefel236: Standard {#schwefel236-standard}
- **Formula**: f(\mathbf{x}) = -x_1 x_2 (72 - 2 x_1 - 2 x_2).
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -3456.0 at [12.0, 12.0]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 129)


### schwefel26: Standard {#schwefel26-standard}
- **Formula**: f(\mathbf{x}) = \max(|x_1 + 2x_2 - 7|, |2x_1 + x_2 - 5|).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [1.0, 3.0]
- **Properties**: non-separable, unimodal, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 31)


### sphere: Standard {#sphere-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D x_i^2.
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 33)


### sphere_rotated: rotated {#sphere_rotated-rotated}
- **Formula**: f(\mathbf{x}) = \| Q \mathbf{x} \|^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, unimodal, differentiable, continuous, scalable
- **Reference**: CEC 2005 Problem Definitions


### sphere_shifted: shifted {#sphere_shifted-shifted}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n (x_i - o_i)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: separable, convex, unimodal, differentiable, continuous, scalable
- **Reference**: CEC 2005 Special Session


### step: Standard {#step-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \lfloor |x_i| \rfloor.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 138)


### step2: Standard {#step2-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \left( \lfloor x_i + 0.5 \rfloor \right)^2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [-0.5, -0.5]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 139)


### step3: Standard {#step3-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D \lfloor x_i^2 \rfloor.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 140)


### step_ellipsoidal: ellipsoidal {#step_ellipsoidal-ellipsoidal}
- **Formula**: f(\mathbf{z}) = 0.1 \max\left( \frac{|\tilde{z}_1|}{10^4}, \sum_{i=1}^D 10^{2(i-1)/(D-1)} \tilde{z}_i^2 \right) + f_\mathrm{pen}(x) + f_\mathrm{opt}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, partially differentiable, unimodal, continuous, scalable, ill-conditioned
- **Reference**: BBOB 2009 Noiseless Functions f7


### stepint: Standard {#stepint-standard}
- **Formula**: f(\mathbf{x}) = 25 + \sum_{i=1}^D \lfloor x_i \rfloor.
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 13 at [-5.12, -5.12]
- **Properties**: separable, bounded, partially differentiable, unimodal, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 141)


### stretched_v_sine_wave: wave {#stretched_v_sine_wave-wave}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_i^2 + x_{i+1}^2)^{0.25} \left[ \sin^2 \left\{ 50 (x_i^2 + x_{i+1}^2)^{0.1} \right\} + 0.1 \right].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: non-separable, bounded, unimodal, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, function 142)


### sumofpowers: Standard {#sumofpowers-standard}
- **Formula**: \sum_{i=1}^n |x_i|^{i+1}
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Unknown


### trid: Standard {#trid-standard}
- **Formula**: \sum_{i=1}^n (x_i - 1)^2 - \sum_{i=2}^n x_i x_{i-1}
- **Bounds/Minimum**: Bounds: [-4, -4]; Min: -2.0 at [2, 2]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Unknown


### zakharov: Standard {#zakharov-standard}
- **Formula**: \sum_{i=1}^n x_i^2 + \left( \sum_{i=1}^n 0.5 i x_i \right)^2 + \left( \sum_{i=1}^n 0.5 i x_i \right)^4
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: convex, non-separable, bounded, unimodal, differentiable, scalable, continuous
- **Reference**: Unknown


## Extended Benchmarks {#extended-benchmarks}

### ackley: Standard {#ackley-standard}
- **Formula**: f(x) = -20 \exp\left(-0.2 \sqrt{\frac{1}{n} \sum_{i=1}^n x_i^2}\right) - \exp\left(\frac{1}{n} \sum_{i=1}^n \cos(2\pi x_i)\right) + 20 + e
- **Bounds/Minimum**: Bounds: [-32.768, -32.768]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Molga & Smutnicki (2005): 2.9


### adjiman: Standard {#adjiman-standard}
- **Formula**: \cos(x_1) \sin(x_2) - \frac{x_1}{x_2^2 + 1}
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -2.021806783359787 at [2.0, 0.10578347]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### alpinen1: Standard {#alpinen1-standard}
- **Formula**: \sum_{i=1}^n |x_i \sin(x_i) + 0.1 x_i|
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, partially differentiable, scalable, non-convex
- **Reference**: Unknown


### alpinen2: Standard {#alpinen2-standard}
- **Formula**: - \prod_{i=1}^n \sqrt{x_i} \sin(x_i)
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -7.885600724127536 at [7.917052698245946, 7.917052698245946]
- **Properties**: multimodal, separable, bounded, partially differentiable, scalable, non-convex
- **Reference**: Unknown


### bartelsconn: Standard {#bartelsconn-standard}
- **Formula**: |x_1^2 + x_2^2 + x_1 x_2| + |\sin(x_1)| + |\cos(x_2)|
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### becker_lago: lago {#becker_lago-lago}
- **Formula**: f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [5.0, 5.0]
- **Properties**: multimodal, separable, bounded, continuous
- **Reference**: Price (1977); referenced in Jamil & Yang (2013), https://arxiv.org/abs/1308.4008


### biggsexp2: Standard {#biggsexp2-standard}
- **Formula**: \sum_{i=1}^{10} \left( e^{-t_i x_1} - 5 e^{-t_i x_2} - y_i \right)^2 \quad t_i=0.1i, \, y_i = e^{-t_i} - 5 e^{-10 t_i}
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 10.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp3: Standard {#biggsexp3-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left( e^{-t_i x_1} - x_3 e^{-t_i x_2} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 5.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp4: Standard {#biggsexp4-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp5: Standard {#biggsexp5-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{11} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + 3 e^{-t_i x_5} - y_i \right)^2,
\quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}

- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0, 4.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### biggsexp6: Standard {#biggsexp6-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{13} \left( x_3 e^{-t_i x_1} - x_4 e^{-t_i x_2} + x_6 e^{-t_i x_5} - y_i \right)^2, \quad t_i = 0.1 i, \quad y_i = e^{-t_i} - 5 e^{-10 t_i} + 3 e^{-4 t_i}.
- **Bounds/Minimum**: Bounds: [-20.0, -20.0, -20.0, -20.0, -20.0, -20.0]; Min: 0.0 at [1.0, 10.0, 1.0, 5.0, 4.0, 3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### bird: Standard {#bird-standard}
- **Formula**: \sin(x_1) \exp\left((1 - \cos(x_2))^2\right) + \cos(x_2) \exp\left((1 - \sin(x_1))^2\right) + (x_1 - x_2)^2
- **Bounds/Minimum**: Bounds: [-6.283185307179586, -6.283185307179586]; Min: -106.76453674926465 at [4.701043130195973, 3.1529385037484228]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### bohachevsky1: Standard {#bohachevsky1-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[ x_i^2 + 2 x_{i+1}^2 - 0.3 \cos(3 \pi x_i) - 0.4 \cos(4 \pi x_{i+1}) + 0.7 \right].
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Unknown


### bohachevsky2: Standard {#bohachevsky2-standard}
- **Formula**: f(x) = x_1^2 + 2x_2^2 - 0.3\cos(3\pi x_1)\cos(4\pi x_2) + 0.3
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, non-convex
- **Reference**: Unknown


### bohachevsky3: Standard {#bohachevsky3-standard}
- **Formula**: f(\mathbf{x}) = x_1^2 + 2x_2^2 - 0.3 \cos(3\pi x_1 + 4\pi x_2) + 0.3.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### boxbetts: Standard {#boxbetts-standard}
- **Formula**: \sum_{i=1}^{10} \left( e^{-0.1i x_1} - e^{-0.1i x_2} - (e^{-0.1i} - e^{-i}) x_3 \right)^2
- **Bounds/Minimum**: Bounds: [0.9, 9.0, 0.9]; Min: 0.0 at [1.0, 10.0, 1.0]
- **Properties**: multimodal, differentiable, continuous
- **Reference**: MVF - Multivariate Test Functions Library in C, Ernesto P. Adorio, Revised January 14, 2005


### brad: Standard {#brad-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{15} \left( y_i - x_1 - \frac{u_i}{v_i x_2 + w_i x_3} \right)^2, \quad u_i = i, \ v_i = 16 - i, \ w_i = \min(u_i, v_i), \ \mathbf{y} = [0.14, 0.18, 0.22, 0.25, 0.29, 0.32, 0.35, 0.39, 0.37, 0.58, 0.73, 0.96, 1.34, 2.10, 4.39]^\top.
- **Bounds/Minimum**: Bounds: [-0.25, 0.01, 0.01]; Min: 0.008214877306578994 at [0.0824105597447766, 1.1330360919212203, 2.343695178745316]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### branin: Standard {#branin-standard}
- **Formula**: f(x) = a (x_2 - b x_1^2 + c x_1 - r)^2 + s (1 - t) \cos(x_1) + s, a=1, b=5.1/(4\pi^2), c=5/\pi, r=6, s=10, t=1/(8\pi)
- **Bounds/Minimum**: Bounds: [-5.0, 0.0]; Min: 0.39788735772973816 at [-3.141592653589793, 12.275]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### braninrcos2: Standard {#braninrcos2-standard}
- **Formula**: f(\mathbf{x}) = \left( x_2 - \frac{5.1 x_1^2}{4\pi^2} + \frac{5 x_1}{\pi} - 6 \right)^2 + 10 \left( 1 - \frac{1}{8\pi} \right) \cos(x_1) \cos(x_2) \ln(x_1^2 + x_2^2 + 1) + 10.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -39.19565391797774 at [-3.1721041516027824, 12.58567479697034]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### bukin2: Standard {#bukin2-standard}
- **Formula**: f(x) = 100 (x_2 - 0.01 x_1^2 + 1)^2 + 0.01 (x_1 + 10)^2
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 0.0]
- **Properties**: multimodal, bounded, differentiable, continuous
- **Reference**: Unknown


### bukin4: Standard {#bukin4-standard}
- **Formula**: f(\mathbf{x}) = 100 x_2^2 + 0.01 |x_1 + 10|
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 0.0]
- **Properties**: multimodal, separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### bukin6: Standard {#bukin6-standard}
- **Formula**: 100 \sqrt{|x_2 - 0.01 x_1^2|} + 0.01 |x_1 + 10|
- **Bounds/Minimum**: Bounds: [-15.0, -3.0]; Min: 0.0 at [-10.0, 1.0]
- **Properties**: multimodal, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### carromtable: Standard {#carromtable-standard}
- **Formula**: f(\mathbf{x}) = -\frac{\left[ \left( \cos(x_1) \cos(x_2) \exp \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right)^2 \right]}{30}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.156815547391208 at [9.646167670438874, 9.646167670438874]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### chen: Standard {#chen-standard}
- **Formula**: -\left(\frac{0.001}{0.000001 + (x_1 - 0.4 x_2 - 0.1)^2} + \frac{0.001}{0.000001 + (2 x_1 + x_2 - 1.5)^2}\right)
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -2000.0 at [0.388888888888889, 0.722222222222222]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### chenv: Standard {#chenv-standard}
- **Formula**: f(\mathbf{x}) = -\frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 1)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 + x_2^2 - 0.5)^2} - \frac{0.001}{(0.001)^2 + (x_1^2 - x_2^2)^2}
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -2000.0039999840005 at [0.500000000004, 0.500000000004]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### chichinadze: Standard {#chichinadze-standard}
- **Formula**: f(\mathbf{x}) = x_1^2 - 12 x_1 + 11 + 10 \cos\left(\frac{\pi x_1}{2}\right) + 8 \sin\left(\frac{5 \pi x_1}{2}\right) - \sqrt{\frac{1}{5}} \exp\left(-0.5 (x_2 - 0.5)^2 \right) 
- **Bounds/Minimum**: Bounds: [-30.0, -30.0]; Min: -42.944387018991 at [6.18986658696568, 0.5]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Unknown


### cola: Standard {#cola-standard}
- **Formula**: f(\mathbf{u}) = \sum_{1 \le j < i \le 10} (r_{i,j} - d_{i,j})^2, \quad r_{i,j} = \sqrt{(x_i - x_j)^2 + (y_i - y_j)^2} 
- **Bounds/Minimum**: Bounds: [0.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0]; Min: 10.533719093221547 at [0.6577179521834655, 1.3410086494718647, 0.0621925866606903, -0.9215843284021408, -0.8587539108194528, 0.0398894904746407, -3.3508073710903923, 0.6714854553331792, -3.3960325842653383, 2.381549919707253, -1.3565015163235619, 1.3510478875312162, -3.3405083834260405, 1.8923144784852317, -2.7015951415440593, -0.9050732332838868, -1.677429264374116]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### corana: Standard {#corana-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \begin{cases} 0.15 d_i (z_i - 0.05 \sgn(z_i))^2 & |x_i - z_i| < 0.05 \\ d_i x_i^2 & \text{otherwise} \end{cases}, \\ z_i = 0.2 \left\lfloor \frac{|x_i|}{0.2} + 0.49999 \right\rfloor \sgn(x_i), \\ d_i \text{ cycles over } [1, 1000, 10, 100].
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, scalable
- **Reference**: Unknown


### cosinemixture: Standard {#cosinemixture-standard}
- **Formula**: f(\mathbf{x}) = -0.1 \sum_{i=1}^n \cos(5 \pi x_i) - \sum_{i=1}^n x_i^2
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -0.2 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Unknown


### crossintray: Standard {#crossintray-standard}
- **Formula**: -0.0001 \left( \left| \sin(x_1) \sin(x_2) \exp\left( \left| 100 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right| + 1 \right)^{0.1}
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -2.062611870822739 at [1.349406575769872, 1.349406575769872]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### csendes: Standard {#csendes-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n x_i^2 (2 + \sin x_i). 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### damavandi: Standard {#damavandi-standard}
- **Formula**: f(\mathbf{x}) = \left[1 - \left| \frac{\sin[\pi (x_1 - 2)]\sin[\pi (x_2 - 2)]}{\pi^2 (x_1 - 2)(x_2 - 2)} \right|^5 \right] \left[ 2 + (x_1 - 7)^2 + 2(x_2 - 7)^2 \right] 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [2.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### deb1: Standard {#deb1-standard}
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^{6}(5 \pi x_i) 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [-0.9, -0.9]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### deb3: Standard {#deb3-standard}
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} \sin^6 \left(5 \pi (x_i^{3/4} - 0.05)\right) 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: -1.0 at [0.07969939268869583, 0.07969939268869583]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable
- **Reference**: Unknown


### dejongf4: Standard {#dejongf4-standard}
- **Formula**: \sum_{i=1}^n i x_i^4 + \text{Gaussian noise}
- **Bounds/Minimum**: Bounds: [-1.28, -1.28]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, unimodal, partially differentiable, scalable, continuous, has_noise
- **Reference**: Unknown


### dejongf5modified: Standard {#dejongf5modified-standard}
- **Formula**: -\left( \frac{1}{500} + \sum_{i=1}^{25} \frac{1}{i + (x_1 - a_{1i})^6 + (x_2 - a_{2i})^6} \right)^{-1}
- **Bounds/Minimum**: Bounds: [-65.536, -65.536]; Min: 0.9980038377944507 at [-31.97833, -31.97833]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Unknown


### dejongf5original: Standard {#dejongf5original-standard}
- **Formula**: f(x) = \left( 0.002 + \sum_{j=1}^{25} \frac{1}{j + (x_1 - a_{1j})^6 + (x_2 - a_{2j})^6} \right)^{-1}
- **Bounds/Minimum**: Bounds: [-65.536, -65.536]; Min: 0.9980038378086058 at [-31.97987349299719, -31.979873489712844]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Unknown


### dekkersaarts: Standard {#dekkersaarts-standard}
- **Formula**: 10^5 x_1^2 + x_2^2 - (x_1^2 + x_2^2)^2 + 10^{-5} (x_1^2 + x_2^2)^4
- **Bounds/Minimum**: Bounds: [-20.0, -20.0]; Min: -24776.518342317686 at [0.0, 14.945112151891959]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### devilliersglasser1: Standard {#devilliersglasser1-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \sin(x_3 t_i + x_4) - y_i \right]^2, \quad t_i = 0.1(i-1), \quad y_i = 60.137 \times 1.371^{t_i} \sin(3.112 t_i + 1.761).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [60.137, 1.371, 3.112, 1.761]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### devilliersglasser2: Standard {#devilliersglasser2-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \tanh\left(x_3 t_i + \sin(x_4 t_i)\right) \cos\left(t_i e^{x_5}\right) - y_i \right]^2 \\
\text{where } t_i = 0.1(i-1), \\
y_i = 53.81 \cdot 1.27^{t_i} \tanh(3.012 t_i + \sin(2.13 t_i)) \cos(e^{0.507} t_i).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0]; Min: 0.0 at [53.81, 1.27, 3.012, 2.13, 0.507]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### dolan: Standard {#dolan-standard}
- **Formula**: f(\mathbf{x}) = (x_1 + 1.7 x_2) \sin(x_1) - 1.5 x_3 - 0.1 x_4 \cos(x_4 + x_5 - x_1) + 0.2 x_5^2 - x_2 - 1
- **Bounds/Minimum**: Bounds: [-100.0, -100.0, -100.0, -100.0, -100.0]; Min: -529.8714387324576 at [98.9642583122371, 100.0, 100.0, 99.2243236725547, -0.249987527588471]
- **Properties**: multimodal, controversial, non-separable, bounded, differentiable, continuous
- **Reference**: Unknown


### dropwave: Standard {#dropwave-standard}
- **Formula**: -\frac{1 + \cos(12 \sqrt{x_1^2 + x_2^2})}{0.5 (x_1^2 + x_2^2) + 2}
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### easom: Standard {#easom-standard}
- **Formula**: -\cos(x_1)\cos(x_2)\exp(-((x_1-\pi)^2 + (x_2-\pi)^2))
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -1.0 at [π, π]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### eggcrate: Standard {#eggcrate-standard}
- **Formula**: f(\mathbf{x}) = x_1^2 + x_2^2 + 25 (\sin^2 x_1 + \sin^2 x_2).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### eggholder: Standard {#eggholder-standard}
- **Formula**: - (x_2 + 47) \sin\left(\sqrt{\left|x_2 + \frac{x_1}{2} + 47\right|}\right) - x_1 \sin\left(\sqrt{\left|x_1 - (x_2 + 47)\right|}\right)
- **Bounds/Minimum**: Bounds: [-512.0, -512.0]; Min: -959.6406627208506 at [512.0, 404.2318058008512]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### freudensteinroth: Standard {#freudensteinroth-standard}
- **Formula**: f(x) = \left( x_1 - 13 + \left( (5 - x_2)x_2 - 2 \right)x_2 \right)^2 + \left( x_1 - 29 + \left( (x_2 + 1)x_2 - 14 \right)x_2 \right)^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [5.0, 4.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### giunta: Standard {#giunta-standard}
- **Formula**: 0.6 + \sum_{i=1}^2 \left[ \sin\left(\frac{16}{15}x_i - 1\right) + \sin^2\left(\frac{16}{15}x_i - 1\right) + \frac{1}{50} \sin\left(4 \left(\frac{16}{15}x_i - 1\right)\right) \right]
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 0.06447042053690566 at [0.46732002530945826, 0.46732002530945826]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### goldsteinprice: Standard {#goldsteinprice-standard}
- **Formula**: (1 + (x_1 + x_2 + 1)^2 (19 - 14x_1 + 3x_1^2 - 14x_2 + 6x_1x_2 + 3x_2^2)) \cdot (30 + (2x_1 - 3x_2)^2 (18 - 32x_1 + 12x_1^2 + 48x_2 - 36x_1x_2 + 27x_2^2))
- **Bounds/Minimum**: Bounds: [-2.0, -2.0]; Min: 3.0 at [0.0, -1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### griewank: Standard {#griewank-standard}
- **Formula**: f(x) = \sum_{i=1}^n \frac{x_i^2}{4000} - \prod_{i=1}^n \cos\left(\frac{x_i}{\sqrt{i}}\right) + 1
- **Bounds/Minimum**: Bounds: [-600.0, -600.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### gulfresearch: Standard {#gulfresearch-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{99} \left[ \exp\left( -\frac{(u_i - x_2)^{x_3}}{x_1} \right) - 0.01 i \right]^2, \quad u_i = 25 + \left[-50 \ln(0.01 i)\right]^{2/3}.
- **Bounds/Minimum**: Bounds: [0.1, 0.0, 0.0]; Min: 0.0 at [50.0, 25.0, 1.5]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hansen: Standard {#hansen-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=0}^{4} (i+1)\cos(i x_1 + i+1) \sum_{j=0}^{4} (j+1)\cos((j+2) x_2 + j+1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -176.5417931367457 at [-7.589893010800888, -7.708313735499348]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hartman6: Standard {#hartman6-standard}
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{4} c_i \exp\left( -\sum_{j=1}^{6} a_{ij} (x_j - p_{ij})^2 \right).
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]; Min: -3.3223680114155147 at [0.20168951265373836, 0.15001069271431358, 0.4768739727643224, 0.2753324306183083, 0.31165161653706114, 0.657300534163256]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### hartmanf3: Standard {#hartmanf3-standard}
- **Formula**: -\sum_{i=1}^4 \alpha_i \exp\left(-\sum_{j=1}^3 A_{ij} (x_j - P_{ij})^2\right), \quad \alpha=[1,1.2,3,3.2], \quad A=\begin{bmatrix}3 & 10 & 30 \\ 0.1 & 10 & 35 \\ 3 & 10 & 30 \\ 0.1 & 10 & 35\end{bmatrix}, \quad P=\begin{bmatrix}0.3689 & 0.1170 & 0.2673 \\ 0.4699 & 0.4387 & 0.7470 \\ 0.1091 & 0.8732 & 0.5547 \\ 0.03815 & 0.5743 & 0.8828\end{bmatrix}
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: -3.862782147820755 at [0.1146143386186895, 0.5556488499736022, 0.8525469535210816]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### helicalvalley: Standard {#helicalvalley-standard}
- **Formula**: f(\mathbf{x}) = 100 \left[ (x_2 - 10\theta)^2 + \left(\sqrt{x_1^2 + x_2^2} - 1\right)^2 \right] + x_3^2, \quad \theta = \frac{1}{2\pi} \atantwo(x_2, x_1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### himmelblau: Standard {#himmelblau-standard}
- **Formula**: (x_1^2 + x_2 - 11)^2 + (x_1 + x_2^2 - 7)^2
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [3.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### holder_table1: table1 {#holder_table1-table1}
- **Formula**: f(\mathbf{x}) = -\left| \sin(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -19.208502567886743 at [8.05502347573655, -9.664590019241274]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### holder_table2: table2 {#holder_table2-table2}
- **Formula**: f(\mathbf{x}) = -\left| \sin(x_1) \sin(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -11.683926748430029 at [8.051008722128277, -9.999999999999]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### holdertable: Standard {#holdertable-standard}
- **Formula**: -\left| \sin(x_1) \cos(x_2) \exp\left(\left|1 - \sqrt{x_1^2 + x_2^2}/\pi\right|\right) \right|
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -19.2085025678845 at [8.055023, 9.66459]
- **Properties**: multimodal, separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### hosaki: Standard {#hosaki-standard}
- **Formula**: f(\mathbf{x}) = \left(1 - 8x_1 + 7x_1^2 - \frac{7}{3}x_1^3 + \frac{1}{4}x_1^4\right) x_2^2 e^{-x_2}.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.345811576101292 at [4.0, 2.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### jennrichsampson: Standard {#jennrichsampson-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left(2 + 2i - (e^{i x_1} + e^{i x_2})\right)^2 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0]; Min: 124.36218235561489 at [0.2578252136705121, 0.2578252136701835]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jennrich and Sampson (1968)


### keane: Standard {#keane-standard}
- **Formula**: -\frac{\sin^2(x_1 - x_2) \sin^2(x_1 + x_2)}{\sqrt{x_1^2 + x_2^2}}
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -0.6736675211468548 at [0.0, 1.3932490753257145]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### kearfott: Standard {#kearfott-standard}
- **Formula**: (x_1^2 + x_2^2 - 2)^2 + (x_1^2 + x_2^2 - 0.5)^2
- **Bounds/Minimum**: Bounds: [-3.0, -3.0]; Min: 1.125 at [0.7905694150420949, -0.7905694150420949]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### langermann: Standard {#langermann-standard}
- **Formula**: -\sum_{i=1}^m c_i \exp \left[-\frac{1}{\pi} \sum_{j=1}^n (x_j - a_{ij})^2 \right] \cos \left[ \pi \sum_{j=1}^n (x_j - a_{ij})^2 \right]
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -5.162126159963982 at [2.002992119907532, 1.0060959403343601]
- **Properties**: multimodal, controversial, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### levyjamil: Standard {#levyjamil-standard}
- **Formula**: \sin^2(3\pi x_1) + \sum_{i=1}^{n-1} (x_i - 1)^2 [1 + \sin^2(3\pi x_{i+1})] + (x_n - 1)^2 [1 + \sin^2(2\pi x_n)]
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### mccormick: Standard {#mccormick-standard}
- **Formula**: \sin(x_1 + x_2) + (x_1 - x_2)^2 - 1.5 x_1 + 2.5 x_2 + 1
- **Bounds/Minimum**: Bounds: [-1.5, -3.0]; Min: -1.9132229549810367 at [-0.54719755, -1.54719755]
- **Properties**: multimodal, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### michalewicz: Standard {#michalewicz-standard}
- **Formula**: f(x) = -\sum_{i=1}^n \sin(x_i) \sin^{2m}(i x_i^2 / \pi), m=10
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -1.8013034100985528 at [2.2029055201726, 1.5707963267949]
- **Properties**: multimodal, non-separable, bounded, differentiable, scalable, continuous
- **Reference**: Unknown


### mielcantrell: Standard {#mielcantrell-standard}
- **Formula**: f(\mathbf{x}) = (e^{x_1} - x_2)^4 + 100 (x_2 - x_3)^6 + [\tan(x_3 - x_4)]^4 + x_1^8 
- **Bounds/Minimum**: Bounds: [-1.0, -1.0, -1.0, -1.0]; Min: 0.0 at [0.0, 1.0, 1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Cragg and Levy (1969)


### mishra1: Standard {#mishra1-standard}
- **Formula**: f(\mathbf{x}) = \left(1 + g_n\right)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} x_i 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 2.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Mishra (2006a)


### mishra10: Standard {#mishra10-standard}
- **Formula**: f(\mathbf{x}) = \left[ \lfloor x_1 x_2 \rfloor - \lfloor x_1 \rfloor - \lfloor x_2 \rfloor \right]^2.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f83


### mishra11: Standard {#mishra11-standard}
- **Formula**: f(\mathbf{x}) = \left[ \frac{1}{n} \sum_{i=1}^n |x_i| - \left( \prod_{i=1}^n |x_i| \right)^{1/n} \right]^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f84


### mishra2: Standard {#mishra2-standard}
- **Formula**: f(\mathbf{x}) = (1 + g_n)^{g_n}, \quad g_n = n - \sum_{i=1}^{n-1} \frac{x_i + x_{i+1}}{2} 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 2.0 at [1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Mishra (2006a)


### mishra3: Standard {#mishra3-standard}
- **Formula**: f(\mathbf{x}) = \left| \cos \left( \sqrt{ | x_1^2 + x_2 | } \right) \right|^{0.5} + 0.01 (x_1 + x_2) 
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.184651333342989 at [-8.466613775046579, -9.998521309]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra4: Standard {#mishra4-standard}
- **Formula**: f(\mathbf{x}) = \sqrt{ \left| \sin \sqrt{ |x_1^2 + x_2| } \right| } + 0.01(x_1 + x_2) 
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.19941146886776687 at [-9.94114880716358, -9.999999996365672]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra5: Standard {#mishra5-standard}
- **Formula**: f(\mathbf{x}) = \left[ \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) + \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right]^2 + 0.01(x_1 + x_2)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -0.11982951993 at [-1.98682, -10.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra6: Standard {#mishra6-standard}
- **Formula**: f(\mathbf{x}) = -\ln \left[ \left( \sin^2 \left( (\cos x_1 + \cos x_2)^2 \right) - \cos^2 \left( (\sin x_1 + \sin x_2)^2 \right) + x_1 \right)^2 \right] + 0.1 \left( (x_1 - 1)^2 + (x_2 - 1)^2 \right)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -2.28394983847 at [2.88630721544, 1.82326033142]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006)


### mishra7: Standard {#mishra7-standard}
- **Formula**: f(\mathbf{x}) = \left[ x_1 x_2 - 2! \right]^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [1.0, 2.0]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra8: Standard {#mishra8-standard}
- **Formula**: f(\mathbf{x}) = 0.001 \left[ \left| x_1^{10} - 20 x_1^9 + 180 x_1^8 - 960 x_1^7 + 3360 x_1^6 - 8064 x_1^5 + 13340 x_1^4 - 15360 x_1^3 + 11520 x_1^2 - 5120 x_1 + 2624 \right| \cdot \left| x_2^4 + 12 x_2^3 + 54 x_2^2 + 108 x_2 + 81 \right| \right]^2
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [2.0, -3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishra9: Standard {#mishra9-standard}
- **Formula**: f(\mathbf{x}) = \left[ f_1 f_2^2 f_3 + f_1 f_2 f_3^2 + f_2^2 + (x_1 + x_2 - x_3)^2 \right]^2 \\ where \\ f_1 = 2x_1^3 + 5x_1 x_2 + 4x_3 - 2x_1^2 x_3 - 18, \\ f_2 = x_1 + x_2^3 + x_1 x_2^2 + x_1 x_3^2 - 22, \\ f_3 = 8x_1^2 + 2x_2 x_3 + 2x_2^2 + 3x_2^3 - 52.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 2.0, 3.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Mishra (2006f)


### mishrabird: Standard {#mishrabird-standard}
- **Formula**: f(x, y) = \sin(y) e^{(1 - \cos(x))^2} + \cos(x) e^{(1 - \sin(y))^2} + (x - y)^2
- **Bounds/Minimum**: Bounds: [-10.0, -6.5]; Min: -106.76453674926466 at [-3.1302468034308637, -1.5821421769356672]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### mvf_shubert: shubert {#mvf_shubert-shubert}
- **Formula**: f(\mathbf{x}) = -\sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.062498884334282 at [-0.4913908362396234, 5.791794471580817]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Adorio (2005, p. 12)


### mvf_shubert2: shubert2 {#mvf_shubert2-shubert2}
- **Formula**: f(\mathbf{x}) = \sum_{i=0}^{1}\sum_{j=0}^{4}(j+1)\cos((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.74177099545137 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Adorio (2005, p. 13)


### mvf_shubert3: shubert3 {#mvf_shubert3-shubert3}
- **Formula**: f(\mathbf{x}) = -\sum_{i=0}^{n-1}\sum_{j=0}^{4}(j+1)\sin((j+2)x_i+(j+1)).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -24.062498884334275 at [-0.4913908340773322, -0.4913908340773322]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Adorio (2005, p. 13)


### parsopoulos: Standard {#parsopoulos-standard}
- **Formula**: f(\mathbf{x}) = \cos^2(x_1) + \sin^2(x_2).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [1.5707963267948966, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, non-convex
- **Reference**: Parsopoulos et al., via Jamil & Yang (2013): f85


### pathological: Standard {#pathological-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left( 0.5 + \frac{\sin^2 \sqrt{100 x_i^2 + x_{i+1}^2} - 0.5}{1 + 0.001 (x_i^2 - 2 x_i x_{i+1} + x_{i+1}^2)^2} \right).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Rahnamayan et al. (2007a), via Jamil & Yang (2013): f87


### paviani: Standard {#paviani-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{10} \left[ \left(\ln (x_i - 2)\right)^2 + \left(\ln (10 - x_i)\right)^2 \right] - \left( \prod_{i=1}^{10} x_i \right)^{0.2}. 
- **Bounds/Minimum**: Bounds: [2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001, 2.001]; Min: -45.77846970744629 at [9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052, 9.350265833069052]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Himmelblau (1972), via Jamil & Yang (2013): f88


### penholder: Standard {#penholder-standard}
- **Formula**: f(\mathbf{x}) = -\exp\left( -\frac{1}{\left| \cos(x_1) \cos(x_2) \exp\left( \left| 1 - \frac{\sqrt{x_1^2 + x_2^2}}{\pi} \right| \right) \right|} \right).
- **Bounds/Minimum**: Bounds: [-11.0, -11.0]; Min: -0.9635348327265058 at [9.6461676710434, 9.6461676710434]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2006f), via Jamil & Yang (2013): f86


### periodic: Standard {#periodic-standard}
- **Formula**: f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1 e^{-(x_1^2 + x_2^2)}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.9 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Ali et al. (2005)


### pinter: Standard {#pinter-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n i x_i^2 + \sum_{i=1}^n 20 i \sin^2 A + \sum_{i=1}^n i \log_{10} (1 + i B^2), \\ A = x_{i-1} \sin x_i + \sin x_{i+1}, \\ B = x_{i-1}^2 - 2 x_i + 3 x_{i+1} - \cos x_i + 1 \\ (cyclic: x_0 = x_n, x_{n+1} = x_1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Pintér (1996), via Jamil & Yang (2013): f89


### price1: Standard {#price1-standard}
- **Formula**: f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [5.0, 5.0]
- **Properties**: multimodal, separable, continuous
- **Reference**: Price (1977)


### price2: Standard {#price2-standard}
- **Formula**: f(\mathbf{x}) = 1 + \sin^2(x_1) + \sin^2(x_2) - 0.1e^{-x_1^2 - x_2^2}.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.9 at [0.0, 0.0]
- **Properties**: multimodal, differentiable, continuous
- **Reference**: Price (1977)


### price4: Standard {#price4-standard}
- **Formula**: f(\mathbf{x}) = (2x_1^3 x_2 - x_2^3)^2 + (6x_1 - x_2^2 + x_2)^2
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013), https://arxiv.org/abs/1308.4008


### qing: Standard {#qing-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 - i)^2.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: 0.0 at [1.0, 1.4142135623730951]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Qing (2006)


### quartic: Standard {#quartic-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n} i x_i^4 + \text{random}[0, 1).
- **Bounds/Minimum**: Bounds: [-1.28, -1.28]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, bounded, unimodal, differentiable, continuous, scalable, has_noise
- **Reference**: Jamil & Yang (2013)


### quintic: Standard {#quintic-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D |x_i^5 - 3x_i^4 + 4x_i^3 + 2x_i^2 - 10x_i - 4|.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: 0.0 at [-1.0, -1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013)


### rana: Standard {#rana-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{D-1} (x_{i+1} + 1) \cos(t_2) \sin(t_1) + x_i \cos(t_1) \sin(t_2), \\
t_1 = \sqrt{|x_{i+1} + x_i + 1|}, \quad t_2 = \sqrt{|x_{i+1} - x_i + 1|}. 
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -464.27392770239135 at [-500.0, -500.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, scalable
- **Reference**: Price et al. (2005). Differential Evolution: A Practical Approach to Global Optimization. Springer; Naser et al. (2024). A Review of 315 Benchmark and Test Functions.


### rastrigin: Standard {#rastrigin-standard}
- **Formula**: f(x) = 10n + \sum_{i=1}^n [x_i^2 - 10 \cos(2\pi x_i)]
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### ripple1: Standard {#ripple1-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \left(\sin^6(5 \pi x_i) + 0.1 \cos^2(500 \pi x_i)\right). 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.2 at [0.1, 0.1]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.


### ripple25: Standard {#ripple25-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} -e^{-2 \ln 2 \left(\frac{x_i - 0.1}{0.8}\right)^2} \sin^6(5 \pi x_i). 
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: -2.0 at [0.1, 0.1]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil, M. & Yang, X.-S. A Literature Survey of Benchmark Functions For Global Optimization Problems Int. Journal of Mathematical Modelling and Numerical Optimisation, 2013, 4, 150-194.


### rosenbrock_modified: modified {#rosenbrock_modified-modified}
- **Formula**: f(\mathbf{x}) = 74 + 100(x_2 - x_1^2)^2 + (1 - x_1)^2 - 400 e^{-\frac{(x_1 + 1)^2 + (x_2 + 1)^2}{0.1}}.
- **Bounds/Minimum**: Bounds: [-2.0, -2.0]; Min: 34.04024310664062 at [-0.9095537365025769, -0.9505717126589607]
- **Properties**: multimodal, deceptive, controversial, non-separable, bounded, differentiable, continuous, ill-conditioned
- **Reference**: Jamil & Yang (2013), Benchmark Function #106


### salomon: Standard {#salomon-standard}
- **Formula**: f(\mathbf{x}) = 1 - \cos\left(2\pi \sqrt{\sum_{i=1}^D x_i^2}\right) + 0.1 \sqrt{\sum_{i=1}^D x_i^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 27)


### sargan: Standard {#sargan-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^D (x_i^2 + 0.4 \sum_{j \neq i} x_i x_j).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 27)


### schaffer1: Standard {#schaffer1-standard}
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 + x_2^2) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 136, Function 112)


### schaffer6: Standard {#schaffer6-standard}
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{[1 + 0.001(x_1^2 + x_2^2)]^2}, \quad D=2.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous
- **Reference**: Al-Roomi (2015, Schaffer's Function No. 06)


### schafferf6: Standard {#schafferf6-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \frac{\sin^2 \sqrt{x_i^2 + x_{i+1}^2}}{(1 + 0.001 (x_i^2 + x_{i+1}^2))^2}, \quad x_{n+1} = x_1.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 32)


### schaffern2: Standard {#schaffern2-standard}
- **Formula**: f(\mathbf{x}) = 0.5 + \frac{\sin^2(x_1^2 - x_2^2) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}.
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Mishra (2007, p. 4)


### schaffern4: Standard {#schaffern4-standard}
- **Formula**: f(x) = 0.5 + \frac{\cos^2(\sin(|x_1^2 - x_2^2|)) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.29257863203598033 at [0.0, 1.253131828792882]
- **Properties**: multimodal, non-separable, bounded, partially differentiable, continuous, non-convex
- **Reference**: Unknown


### schmidtvetters: Standard {#schmidtvetters-standard}
- **Formula**: f(\mathbf{x}) = \frac{1}{1 + (x_1 - x_2)^2} + \sin\left( \frac{\pi x_2 + x_3}{2} \right) + e^{\left( \frac{x_1 + x_2}{x_2} - 2 \right)^2}. 
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0]; Min: 0.19397252244395102 at [7.07083412, 10.0, 3.14159293]
- **Properties**: multimodal, controversial, non-separable, partially differentiable
- **Reference**: Jamil & Yang (2013, p. 116)


### schwefel225: Standard {#schwefel225-standard}
- **Formula**: f(\mathbf{x}) = (x_2 - 1)^2 + (x_1 - x_2^2)^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 127)


### schwefel226: Standard {#schwefel226-standard}
- **Formula**: f(\mathbf{x}) = -\frac{1}{D} \sum_{i=1}^{D} x_i \sin \sqrt{|x_i|}.
- **Bounds/Minimum**: Bounds: [-500.0, -500.0]; Min: -418.9828872724338 at [420.96874357691473, 420.96874357691473]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 30)


### schwefel24: Standard {#schwefel24-standard}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{2} (x_i - 1)^2 + (x_1 - x_i^2)^2.
- **Bounds/Minimum**: Bounds: [0.0, 0.0]; Min: 0.0 at [1.0, 1.0]
- **Properties**: multimodal, separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 30)


### shekel: Standard {#shekel-standard}
- **Formula**: f(x) = -\sum_{i=1}^{10} \frac{1}{\sum_{j=1}^4 (x_j - a_{ij})^2 + c_i}
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.536409816692043 at [4.000746531592147, 4.000592934138629, 3.9996633980404135, 3.9995098005868956]
- **Properties**: multimodal, non-separable, bounded, differentiable, finite_at_inf, continuous, non-convex
- **Reference**: Unknown


### shekel5: Standard {#shekel5-standard}
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{5} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4].
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.15319967905822 at [4.00003715, 4.00013327, 4.00003715, 4.00013327]
- **Properties**: multimodal, controversial, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 130)


### shekel7: Standard {#shekel7-standard}
- **Formula**: f(\mathbf{x}) = -\sum_{i=1}^{7} \frac{1}{\sum_{j=1}^{4} (x_j - a_{ij})^2 + c_i}, \quad \mathbf{a}_i \in A = \begin{bmatrix} 4 & 4 & 4 & 4 \\ 1 & 1 & 1 & 1 \\ 8 & 8 & 8 & 8 \\ 6 & 6 & 6 & 6 \\ 3 & 7 & 3 & 7 \\ 2 & 9 & 2 & 9 \\ 5 & 5 & 3 & 3 \end{bmatrix}, \quad \mathbf{c} = [0.1, 0.2, 0.2, 0.4, 0.4, 0.6, 0.3].
- **Bounds/Minimum**: Bounds: [0.0, 0.0, 0.0, 0.0]; Min: -10.402940566818653 at [4.00057291, 4.00068936, 3.99948971, 3.99960616]
- **Properties**: multimodal, controversial, non-separable, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 131)


### shubert_additive_cosine: cosine {#shubert_additive_cosine-cosine}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.74177099545136 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_additive_sine: sine {#shubert_additive_sine-sine}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 j \sin((j+1)x_i + j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -29.675900051421173 at [-7.397285, -7.397285]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_generalized: generalized {#shubert_generalized-generalized}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n \sum_{j=1}^5 a_j \cos(b_j x_i + c_j).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -25.741770995451372 at [-1.42512843, -1.42512843]
- **Properties**: multimodal, separable, differentiable, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_hybrid_rastrigin: rastrigin {#shubert_hybrid_rastrigin-rastrigin}
- **Formula**: f(\mathbf{x}) = 0.5 \cdot \text{Shubert}(\mathbf{x}) + 0.5 \cdot \text{Rastrigin}(\mathbf{x}).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -79.36953021020285 at [-0.8130518668176654, -1.4178774389880957]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, ill-conditioned
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_noisy: noisy {#shubert_noisy-noisy}
- **Formula**: f(\mathbf{x}) = \left( \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)x_i + j) \right) + \varepsilon, \quad \varepsilon \sim U[0,1).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.7309088310239 at [4.85805687893418, 5.482864207318173]
- **Properties**: multimodal, non-separable, differentiable, continuous, has_noise
- **Reference**: Jamil & Yang (2013, p.55)


### shubert_shifted_rotated: rotated {#shubert_shifted_rotated-rotated}
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^2 \sum_{j=1}^5 j \cos((j+1)[\mathbf{Q}(\mathbf{x}-\mathbf{o})]_i + j).
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -186.730908831 at [55.82260356132168, -69.31153726530631]
- **Properties**: multimodal, non-separable, differentiable, continuous
- **Reference**: CEC 2014; Jamil & Yang (2013, extended transformations)


### sineenvelope: Standard {#sineenvelope-standard}
- **Formula**: -0.5 + \frac{\sin^2(\sqrt{x_1^2 + x_2^2}) - 0.5}{(1 + 0.001(x_1^2 + x_2^2))^2}
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: -1.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### sixhumpcamelback: Standard {#sixhumpcamelback-standard}
- **Formula**: f(x) = \left(4 - 2.1 x_1^2 + \frac{x_1^4}{3}\right) x_1^2 + x_1 x_2 + (-4 + 4 x_2^2) x_2^2
- **Bounds/Minimum**: Bounds: [-3.0, -2.0]; Min: -1.031628453489877 at [0.08984201368301331, -0.7126564032704135]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### sphere_noisy: noisy {#sphere_noisy-noisy}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^n x_i^2 + \epsilon, \epsilon \sim U[0,1].
- **Bounds/Minimum**: Bounds: [-100.0, -100.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, differentiable, continuous, scalable, has_noise
- **Reference**: BBOB f101 / Nevergrad


### styblinski_tang: tang {#styblinski_tang-tang}
- **Formula**: f(\mathbf{x}) = \frac{1}{2} \sum_{i=1}^D (x_i^4 - 16x_i^2 + 5x_i).
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -78.33233140754282 at [-2.903534027771177, -2.903534027771177]
- **Properties**: multimodal, separable, bounded, differentiable, continuous, scalable, non-convex
- **Reference**: Jamil & Yang (2013, function 144)


### styblinskitang: Standard {#styblinskitang-standard}
- **Formula**: \frac{1}{2} \sum_{i=1}^n (x_i^4 - 16 x_i^2 + 5 x_i)
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: -78.33233140754282 at [-2.9035340276126953, -2.9035340276126953]
- **Properties**: multimodal, bounded, differentiable, scalable, continuous, non-convex
- **Reference**: Unknown


### testtubeholder: Standard {#testtubeholder-standard}
- **Formula**: f(\mathbf{x}) = -4 \sin(x_1) \cos(x_2) \exp\left( \left| \cos\left( \frac{x_1^2 + x_2^2}{200} \right) \right| \right).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -10.872300105622745 at [1.5706026141696665, 4.534236385313213e-12]
- **Properties**: multimodal, non-separable, bounded, continuous
- **Reference**: Jamil & Yang (2013, p. 34)


### threehumpcamel: Standard {#threehumpcamel-standard}
- **Formula**: 2x_1^2 - 1.05x_1^4 + \frac{x_1^6}{6} + x_1 x_2 + x_2^2
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [0.0, 0.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


### trecanni: Standard {#trecanni-standard}
- **Formula**: f(\mathbf{x}) = x_1^4 + 4x_1^3 + 4x_1^2 + x_2^2.
- **Bounds/Minimum**: Bounds: [-5.0, -5.0]; Min: 0.0 at [-2.0, 0.0]
- **Properties**: multimodal, separable, bounded, differentiable, continuous
- **Reference**: Jamil & Yang (2013, p. 35)


### wood: Standard {#wood-standard}
- **Formula**: f(x) = 100(x_1^2 - x_2)^2 + (x_1 - 1)^2 + (x_3 - 1)^2 + 90(x_3^2 - x_4)^2 + 10.1((x_2 - 1)^2 + (x_4 - 1)^2) + 19.8(x_2 - 1)(x_4 - 1)
- **Bounds/Minimum**: Bounds: [-10.0, -10.0, -10.0, -10.0]; Min: 0.0 at [1.0, 1.0, 1.0, 1.0]
- **Properties**: multimodal, non-separable, bounded, differentiable, continuous, non-convex
- **Reference**: Unknown


## Other Benchmarks {#other-benchmarks}

### ackley4: Standard {#ackley4-standard}
- **Formula**: \sum_{i=1}^{D-1} \left[ e^{-0.2 \sqrt{x_i^2 + x_{i+1}^2}} + 3 (\cos(2x_i) + \sin(2x_{i+1})) \right]
- **Bounds/Minimum**: Bounds: [-35.0, -35.0]; Min: -5.297009385988958 at [-1.5812643986108843, -0.7906319137820829]
- **Properties**: controversial, non-separable, bounded, differentiable, highly multimodal, continuous
- **Reference**: Unknown


### axisparallelhyperellipsoid: Standard {#axisparallelhyperellipsoid-standard}
- **Formula**: \sum_{i=1}^n i x_i^2
- **Bounds/Minimum**: Bounds: [-5.12, -5.12]; Min: 0.0 at [0.0, 0.0]
- **Properties**: separable, convex, bounded, differentiable, scalable, continuous
- **Reference**: Unknown


### shubert_classic: classic {#shubert_classic-classic}
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^{2} \left( \sum_{j=1}^{5} j \cos((j+1) x_i + j) \right).
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: controversial, non-separable, differentiable, highly multimodal, continuous
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_coupled: coupled {#shubert_coupled-coupled}
- **Formula**: f(\mathbf{x}) = \sum_{i=1}^{n-1} \left[\sum_{j=1}^5 j \cos((j+1)x_i + j)\right] \left[\sum_{j=1}^5 j \cos((j+1)x_{i+1} + j)\right].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 56)


### shubert_rotated: rotated {#shubert_rotated-rotated}
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(Q\mathbf{x})_i + j), \ Q \ orthogonal.
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


### shubert_shifted: shifted {#shubert_shifted-shifted}
- **Formula**: f(\mathbf{x}) = \prod_{i=1}^n \sum_{j=1}^5 j \cos((j+1)(x_i - o_i) + j), \ o_i \sim U[-10,10].
- **Bounds/Minimum**: Bounds: [-10.0, -10.0]; Min: -186.73090883102375 at [4.858056878468046, 5.482864206944743]
- **Properties**: non-separable, differentiable, highly multimodal, continuous, scalable
- **Reference**: Jamil & Yang (2013, p. 55)


## Generation
Run `julia --project=. examples/generate_functions_md.jl` to update from TEST_FUNCTIONS.
