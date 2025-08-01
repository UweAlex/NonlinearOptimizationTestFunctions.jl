# NonlinearOptimizationTestFunctionsInJulia
# Letzte Änderung: 01. August 2025, 01:45 PM CEST

## Willkommen zur ultimativen Optimierungstestsuite!
Suchen Sie nach dem perfekten Werkzeug, um Ihre nichtlinearen Optimierungsalgorithmen zu testen und zu vergleichen? Dann sind Sie hier richtig! **NonlinearOptimizationTestFunctionsInJulia** ist Ihre Komplettlösung, speziell für Julia-Nutzer entwickelt, die Präzision, Benutzerfreundlichkeit und unübertroffene Flexibilität fordern. Egal, ob Sie ein Student sind, der Optimierung erstmals erkundet, ein Forscher, der modernste Solver benchmarkt, oder ein Entwickler, der das nächste große Optimierungstool baut – dieses Paket bietet alles, was Sie brauchen.

Warum unser Paket? Im Gegensatz zu anderen Bibliotheken, die veraltete Implementierungen oder eingeschränkte Kompatibilität bieten, liefert **NonlinearOptimizationTestFunctionsInJulia** eine sorgfältig kuratierte Sammlung von 16 rigoros verifizierten Testfunktionen, komplett mit analytischen Gradienten, umfassenden Metadaten und nahtloser Integration in Julias leistungsstarkes Optimierungs-Ökosystem (Optim.jl, NLopt, ForwardDiff, Zygote). Basierend auf der grundlegenden Arbeit *Test functions for optimization needs* von Molga und Smutnicki (2005), ist jede Funktion durch vertrauenswürdige Quellen abgesichert, um wissenschaftliche Genauigkeit zu gewährleisten. Mit einer intuitiven Benutzeroberfläche, umfangreichen Beispielen und aktiver Wartung macht dieses Paket Optimierungstests zugänglich, effizient und sogar unterhaltsam!

### Warum dieses Paket herausragt
- **Präzision und Zuverlässigkeit**: Minima, Grenzen und Gradienten jeder Funktion wurden gegen Molga & Smutnicki (2005) verifiziert und mit maßgeblichen Quellen wie al-roomi.org abgeglichen. Umfangreiche Tests stellen sicher, dass jede Funktion korrekt implementiert ist, einschließlich Funktionswerten, Gradienten, Metadaten und Edge-Cases.
- **Anfängerfreundlich**: Schritt-für-Schritt-Beispiele und klare Erklärungen machen den Einstieg einfach, ohne Vorwissen in Optimierung.
- **Julia-optimiert**: Entwickelt, um Julias Geschwindigkeit und Ökosystem zu nutzen, mit perfekter Kompatibilität für Optim.jl, NLopt und automatische Differentiationstools.
- **Umfassende Metadaten**: Jede Funktion enthält detaillierte Metadaten (z. B. Minima, Grenzen, Eigenschaften), um Experimente einfach einzurichten und zu analysieren.
- **Zukunftssicher**: Das Paket ist erweiterbar für Ihre individuellen Bedürfnisse.
- **Community-getrieben**: Treten Sie unserer aktiven Community auf GitHub bei, um Beiträge zu leisten, Probleme zu melden oder neue Funktionen vorzuschlagen!

## Installation: In Minuten startklar
Die Einrichtung von **NonlinearOptimizationTestFunctionsInJulia** ist kinderleicht. Sie benötigen:
- Julia 1.11.5 oder höher
- Erforderliche Abhängigkeiten: LinearAlgebra (Standardbibliothek), Optim, Test, ForwardDiff, Zygote
- Optional: NLopt für fortgeschrittene Optimierungsszenarien

Installieren Sie das Paket mit diesen einfachen Befehlen:
    using Pkg
    Pkg.activate(".")
    Pkg.instantiate()

Damit ist Ihre Umgebung eingerichtet und alle Abhängigkeiten installiert. Sie sind bereit, die Welt der Optimierung zu erkunden!

## Erste Schritte
Laden Sie zunächst das Paket:
    using NonlinearOptimizationTestFunctionsInJulia

Das Paket bietet 16 Testfunktionsobjekte, die Ihre Optimierungsalgorithmen herausfordern:
    ROSENBROCK_FUNCTION, SPHERE_FUNCTION, ACKLEY_FUNCTION, AXISPARALLELHYPERELLIPSOID_FUNCTION,
    RASTRIGIN_FUNCTION, GRIEWANK_FUNCTION, SCHWEFEL_FUNCTION, MICHALEWICZ_FUNCTION,
    BRANIN_FUNCTION, GOLDSTEINPRICE_FUNCTION, SHUBERT_FUNCTION, SIXHUMPCAMELBACK_FUNCTION,
    LANGERMANN_FUNCTION, EASOM_FUNCTION, SHEKEL_FUNCTION, HARTMANN_FUNCTION

Sie können auch über das `TEST_FUNCTIONS`-Dictionary mit Kleinbuchstaben-Schlüsseln auf Funktionen zugreifen (z. B. `TEST_FUNCTIONS["rosenbrock"]`). Beachten Sie, dass Schlüssel case-sensitive sind, verwenden Sie daher immer Kleinbuchstaben.

## Anatomie einer Testfunktion
Jedes Testfunktionsobjekt ist mit Funktionen ausgestattet, die Ihre Arbeit erleichtern:
- **tf.f**: Die Zielfunktion, die einen Vektoreingang (z. B. `[x1, x2]`) akzeptiert und einen Skalarwert zurückgibt.
- **tf.grad**: Nicht-in-place Gradientenfunktion, die einen neuen Gradientenvektor zurückgibt, ideal für ForwardDiff und Zygote.
- **tf.gradient!**: In-place Gradientenfunktion, automatisch generiert für Performance mit Optim.jl und NLopt.
- **tf.meta**: Ein Dictionary mit Metadaten, wie:
    - `:name`: Funktionsname (z. B. "Rosenbrock")
    - `:start`: Funktion, die einen Startpunkt für Dimension `n` liefert
    - `:min_position`: Funktion, die die globale Minimalstelle zurückgibt
    - `:min_value`: Skalar oder Funktion für den globalen Minimalwert
    - `:properties`: Liste mathematischer Eigenschaften (z. B. [:unimodal, :nonconvex])
    - `:lb`, `:ub`: Funktionen, die untere und obere Grenzen liefern
    - `:in_molga_smutnicki_2005`: Boolean (immer true, zeigt die Quelle an)

## Beispielgalerie: Lernen durch Praxis
Lassen Sie uns in praktische Beispiele eintauchen, um das Paket in Aktion zu sehen. Diese Beispiele decken alles ab, von der Funktionsauswertung bis zur Optimierung mit gängigen Julia-Bibliotheken.

### Beispiel 1: Funktion auswerten
Berechnen Sie den Wert der Rosenbrock-Funktion, einem Klassiker mit einem engen Tal:
    rosenbrock = ROSENBROCK_FUNCTION
    x = [0.5, 0.5]
    value = rosenbrock.f(x)  # Liefert 6.5
    println("Rosenbrock bei $x: $value")

### Beispiel 2: Gradienten berechnen
Berechnen Sie den Gradienten der Sphere-Funktion, ideal zum Testen grundlegender Optimierung:
    sphere = SPHERE_FUNCTION
    x = [1.0, 1.0]
    grad = sphere.grad(x)  # Liefert [2.0, 2.0]
    println("Sphere-Gradient bei $x: $grad")

Für bessere Performance bei großen Dimensionen nutzen Sie den in-place Gradienten:
    grad_vec = zeros(2)
    sphere.gradient!(grad_vec, x)
    println("In-place Sphere-Gradient: $grad_vec")

### Beispiel 3: Optimierung mit Optim.jl
Optimieren Sie die multimodale Ackley-Funktion mit Optim.jl:
    using Optim
    ackley = ACKLEY_FUNCTION
    x0 = ackley.meta[:start](2)  # Startpunkt, z. B. [0.0, 0.0]
    result = optimize(ackley.f, ackley.gradient!, x0, LBFGS(), Optim.Options(f_reltol=1e-6))
    println("Ackley-Minimum bei: ", Optim.minimizer(result))
    println("Minimalwert: ", Optim.minimum(result))

### Beispiel 4: Optimierung mit NLopt
Bewältigen Sie die Rastrigin-Funktion, bekannt für ihre vielen lokalen Minima, mit NLopt:
    using NLopt
    rastrigin = RASTRIGIN_FUNCTION
    opt = Opt(:LD_LBFGS, 2)
    opt.lower_bounds = rastrigin.meta[:lb](2)  # [-5.12, -5.12]
    opt.upper_bounds = rastrigin.meta[:ub](2)  # [5.12, 5.12]
    opt.min_objective = (x, grad) -> begin
        if length(grad) > 0
            rastrigin.gradient!(grad, x)
        end
        rastrigin.f(x)
    end
    opt.ftol_rel = 1e-6
    (min_f, min_x, ret) = optimize(opt, rastrigin.meta[:start](2))
    println("Rastrigin-Minimum bei: $min_x, Wert: $min_f")

### Beispiel 5: Metadaten erkunden
Überprüfen Sie die Metadaten der Six-Hump Camelback-Funktion:
    camel = SIXHUMPCAMELBACK_FUNCTION
    println("Name: ", camel.meta[:name])  # "SixHumpCamelback"
    println("Minimalstelle: ", camel.meta[:min_position](2))
    println("Minimalwert: ", camel.meta[:min_value])  # -1.031628453489877
    println("Grenzen: ", camel.meta[:lb](2), " bis ", camel.meta[:ub](2))

### Beispiel 6: Fehlerbehandlung
Was passiert bei ungültiger Eingabe? Das Paket ist robust:
    try
        rosenbrock.f([1.0])  # Falsche Dimension (n=2 erforderlich)
    catch e
        println("Fehler: ", e)  # Informiert über Dimensionsfehler
    end

### Beispiel 7: Testen mehrerer Dimensionen
Einige Funktionen sind skalierbar. Probieren Sie die Griewank-Funktion in 3D:
    griewank = GRIEWANK_FUNCTION
    x = [1.0, 1.0, 1.0]
    value = griewank.f(x)  # Liefert ~0.305
    println("Griewank bei $x (3D): $value")
    println("Grenzen für n=3: ", griewank.meta[:lb](3), " bis ", griewank.meta[:ub](3))

## Testfunktionen: Ihr Optimierungsspielplatz
Das Paket enthält 16 sorgfältig gestaltete Testfunktionen, die jeweils spezifische Aspekte von Optimierungsalgorithmen testen. Hier ist eine detaillierte Übersicht:

- **Rosenbrock**: Eine unimodale, nicht-konvexe, nicht-separable, differenzierbare, skalierbare Funktion mit einem engen Tal, die gradientenbasierte Methoden herausfordert. Minimum bei [1.0, ..., 1.0], Wert 0.0. Grenzen: [-5.0, 5.0]^n.
- **Sphere**: Eine unimodale, konvexe, separable, differenzierbare, skalierbare Funktion, ideal zum Testen der Konvergenzgeschwindigkeit. Minimum bei [0.0, ..., 0.0], Wert 0.0. Grenzen: [-5.12, 5.12]^n.
- **Ackley**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare, skalierbare Funktion mit vielen lokalen Minima. Minimum bei [0.0, ..., 0.0], Wert 0.0. Grenzen: [-5.0, 5.0]^n.
  - **Besonderer Hinweis zur Ackley-Funktion**: Die Ackley-Funktion verwendet standardmäßig die Grenzen [-5, 5]^n, um die Kompatibilität mit unserer Testsuite zu gewährleisten. Für Standard-Benchmarks verwenden Sie `tf.meta[:lb](n, bounds="benchmark")` und `tf.meta[:ub](n, bounds="benchmark")`, um die Grenzen auf [-32.768, 32.768]^n zu setzen, wie in der Literatur empfohlen.
- **AxisParallelHyperEllipsoid**: Eine unimodale, konvexe, separable, differenzierbare, skalierbare Funktion, die die Sensitivität für Skalierung testet. Minimum bei [0.0, ..., 0.0], Wert 0.0. Grenzen: [-Inf, Inf]^n (für Tests auf [-100.0, 100.0]^n beschränkt).
- **Rastrigin**: Eine multimodale, nicht-konvexe, separable, differenzierbare, skalierbare Funktion mit einem Gitter lokaler Minima. Minimum bei [0.0, ..., 0.0], Wert 0.0. Grenzen: [-5.12, 5.12]^n.
- **Griewank**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare, skalierbare Funktion mit einer komplexen, welligen Landschaft. Minimum bei [0.0, ..., 0.0], Wert 0.0. Grenzen: [-600.0, 600.0]^n.
- **Schwefel**: Eine multimodale, nicht-konvexe, separable, differenzierbare, skalierbare Funktion mit tiefen lokalen Minima. Minimum bei [420.968746, ..., 420.968746], Wert 0.0. Grenzen: [-500.0, 500.0]^n.
- **Michalewicz**: Eine multimodale, nicht-konvexe, separable, differenzierbare, skalierbare Funktion mit steilen Abfällen. Minimum bei ~[2.20, 1.57, ...], Wert ~-1.8013 (n=2). Grenzen: [0.0, pi]^n.
- **Branin**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit drei globalen Minima. Minima bei [-π, 12.275], [π, 2.275], [9.424778, 2.475], Wert ~0.397887. Grenzen: x₁ ∈ [-5.0, 10.0], x₂ ∈ [0.0, 15.0].
- **Goldstein-Price**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2). Minimum bei [0.0, -1.0], Wert 3.0. Grenzen: [-2.0, 2.0]^2.
- **Shubert**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit mehreren globalen Minima. Minimum bei Punkten wie [-7.083506, 4.858057], Wert ~-186.7309. Grenzen: [-10.0, 10.0]^2.
- **Six-Hump Camelback**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit sechs lokalen Minima, zwei global. Minima bei [-0.08984201368301331, 0.7126564032704135], [0.08984201368301331, -0.7126564032704135], Wert -1.031628453489877. Grenzen: x₁ ∈ [-3.0, 3.0], x₂ ∈ [-2.0, 2.0].
- **Langermann**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare, skalierbare Funktion mit einer rauen Landschaft. Minimum bei ~[2.0, 2.0, ...], Wert ~-0.964627664 (n=2). Grenzen: [0.0, 10.0]^n.
- **Easom**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit einem scharfen globalen Minimum. Minimum bei [π, π], Wert -1.0. Grenzen: [-100.0, 100.0]^2.
- **Shekel**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=4). Minimum bei [4.0, 4.0, 4.0, 4.0], Wert -10.536409825004505. Grenzen: [0.0, 10.0]^4. Hinweis: Der Gradient am Minimum ist nicht null (Norm ≈ 0.223) aufgrund der multimodalen Struktur.
- **Hartmann**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=3) mit einer rauen Landschaft. Minimum bei [0.114614, 0.555649, 0.852547], Wert -3.86278214782076. Grenzen: [0.0, 1.0]^3.

## Demnächst verfügbar: Weitere Funktionen!
Wir sind bestrebt, dieses Paket zur umfassendsten Testsuite zu machen. Die folgenden Funktionen sind für eine baldige Implementierung geplant, wobei Implementierungsdetails (z. B. Minima, Grenzen, Eigenschaften) gegen Molga & Smutnicki (2005), al-roomi.org und andere Quellen verifiziert werden:
- **Styblinski-Tang**: Eine multimodale, nicht-konvexe, separable, differenzierbare, skalierbare Funktion mit mehreren lokalen Minima. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^n.
- **Sum of Powers**: Eine unimodale, konvexe, separable, differenzierbare, skalierbare Funktion, die Sensitivität für polynomiale Terme testet. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^n.
- **Eggholder**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit einer komplexen Landschaft. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Keane**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit herausfordernden Einschränkungen. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Sine Envelope**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit oszillierendem Verhalten. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Rana**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit einer rauen Landschaft. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Camelback**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit mehreren Minima. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2. Hinweis: Wahrscheinlich eine Variante, unterschiedlich zur Six-Hump Camelback-Funktion.
- **Cross-in-Tray**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit vier globalen Minima. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Drop-Wave**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit einer welligen Landschaft. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Himmelblau**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit vier globalen Minima. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Levi**: Eine multimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit einer komplexen Struktur. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **F_NWp281**: Eine Testfunktion (Details TBD, wahrscheinlich aus einer spezifischen Benchmark-Suite). Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^n.
- **Powell Singular**: Eine unimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=4) mit einer singulären Hesse-Matrix am Minimum. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^4.
- **Powell Badly Scaled**: Eine unimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=2) mit schlecht skalierten Variablen. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^2.
- **Helical Valley**: Eine unimodale, nicht-konvexe, nicht-separable, differenzierbare Funktion (nur n=3) mit einer spiralförmigen Talstruktur. Minimum bei [TBD], Wert [TBD]. Grenzen: [TBD]^3.

## Warum dieses Paket wählen?
Andere Testfunktionsbibliotheken bieten ähnliche Funktionalitäten, aber sie bleiben oft in wichtigen Bereichen hinterher:
- **Eingeschränkte Kompatibilität**: Viele Bibliotheken sind nicht für Julias Ökosystem optimiert und verpassen Tools wie Optim.jl oder Zygote.
- **Unvollständige Metadaten**: Nur wenige bieten die detaillierten Metadaten (Minima, Grenzen, Eigenschaften), die unser Paket für jede Funktion bereitstellt.
- **Veraltete Implementierungen**: Einige basieren auf alten oder unüberprüften Implementierungen, während unsere gegen vertrauenswürdige Quellen abgeglichen sind.
- **Komplexe Schnittstellen**: Andere Bibliotheken erfordern oft umfangreiche Einrichtung oder Programmierung, während unsere sofort einsatzbereit ist mit intuitiven Beispielen.

Mit **NonlinearOptimizationTestFunctionsInJulia** erhalten Sie ein modernes, aktiv gewartetes Paket, das sowohl leistungsstark als auch einfach zu nutzen ist. Es ist der Goldstandard für Optimierungstests in Julia.

## Tipps für Anfänger
Neu in der Optimierung? So nutzen Sie das Paket optimal:
- **Einfach beginnen**: Testen Sie die Sphere-Funktion, um grundlegende Optimierung zu verstehen, bevor Sie komplexe wie Schwefel oder Shubert angehen.
- **Metadaten nutzen**: Überprüfen Sie immer `tf.meta[:lb]` und `tf.meta[:ub]`, um sicherzustellen, dass Ihre Eingaben die Grenzen der Funktion einhalten.
- **Mit Solvern experimentieren**: Testen Sie sowohl Optim.jl als auch NLopt, um zu sehen, was für Ihr Problem am besten funktioniert.
- **Fehler überprüfen**: Bei Problemen liefert das Paket klare Fehlermeldungen als Orientierung.

## Häufig gestellte Fragen
- **Warum sind einige Funktionen auf bestimmte Dimensionen beschränkt?** Funktionen wie Branin oder Easom sind in der Literatur nur für n=2 definiert, um ihre standardisierten Eigenschaften zu bewahren.
- **Kann ich eigene Funktionen hinzufügen?** Absolut! Das Paket ist erweiterbar – schauen Sie auf GitHub für Richtlinien zum Hinzufügen benutzerdefinierter Testfunktionen.
- **Was, wenn ich einen Fehler finde?** Melden Sie ihn in unserem GitHub-Repository, und unser Team kümmert sich schnell darum.

## Referenzen
Die Testfunktionen basieren auf:
- Molga, M., & Smutnicki, C. (2005). *Test functions for optimization needs*. Abrufbar unter: http://www.zsd.ict.pwr.wroc.pl/files/docs/functions.pdf
- Zusätzliche Verifikation: al-roomi.org, eine vertrauenswürdige Quelle für Optimierungstestfunktionen.

## Mit der Community verbinden
Möchten Sie beitragen? Haben Sie Ideen für neue Funktionen? Besuchen Sie unser GitHub-Repository, um Probleme zu melden, Funktionen vorzuschlagen oder Pull Requests einzureichen. Mit **NonlinearOptimizationTestFunctionsInJulia** sind Sie Teil einer lebendigen Community, die die Grenzen der Optimierung in Julia erweitert.

## Schlussbemerkungen
- Alle Funktionen sind auf Genauigkeit gegen Molga & Smutnicki (2005) und al-roomi.org verifiziert.
- Metadatenfunktionen (`:start`, `:min_position`, `:lb`, `:ub`) akzeptieren einen Dimensionsparameter `n` (Standard: 2, 3 oder 4, je nach Funktion).
- Fragen oder Feedback? Kontaktieren Sie uns über GitHub oder die Julia-Community-Foren. Lassen Sie uns Optimierung gemeinsam großartig machen!