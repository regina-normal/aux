#!/usr/bin/regina-python

nCrossings = 14
types = [ ('hyp', 'Hyperbolic'), ('torus', 'Torus knots'), ('satellite', 'Satellites') ]
alt = [ ('a', 'alternating'), ('n', 'non-alternating') ]

root = Container()

desc = Text()
desc.setLabel('Description')

desc.setText('This is an initial portion of the census of all prime non-trivial knots with ≤ 19 crossings, as tabulated using Regina [1].\n\n' +
    'This file covers only ≤ ' + str(nCrossings) + ' crossings, since the full census is too large to ship with a default Regina installation.  You can download the full 19-crossing census from http://regina.sourceforge.net/data.html .\n\n' +
    'The census is split into sections according to number of crossings, and then by knot type.\n\n' +
    'The name of each knot is of the form \'9nh_2 (DT: 9n_5)\'. Here 9nh_2 is the name from Regina\'s larger 19-crossing knot tables, and 9n_5 is the Dowker-Thistlethwaite name that appears in other online sources such as Knotinfo or Knotscape. For knots with ≥ 13 crossings, only Regina\'s name is listed.\n\n' +
    'For more information on Regina, see http://regina-normal.github.io/ .\n\n' +
    '1. Benjamin A. Burton, "The next 350 million knots", 36th International Symposium on Computational Geometry (SoCG 2020), Leibniz Int. Proc. Inform., vol. 164, Dagstuhl, Germany, 2020, pp. 25:1–25:17.\n')
root.insertChildLast(desc)

for i in range(3, nCrossings + 1):
    cr = Container()
    cr.setLabel(str(i) + ' crossings')
    root.insertChildLast(cr)

    for t in types:
        for a in alt:
            filename = str(i) + a[0] + '-' + t[0] + '.csv'
            try:
                f = open(filename, 'r')

                sec = Container()
                sec.setLabel(t[1] + ', ' + a[1])
                cr.insertChildLast(sec)

                header = f.readline()
                line = f.readline()
                while line:
                    line = line.strip()
                    bits = line.split(',')
                    name = bits[0]
                    if i <= 12:
                        name = name + ' (DT: ' + bits[3] + ')'
                    sig = bits[1]

                    knot = Link.fromKnotSig(sig)
                    knot.setLabel(name)
                    sec.insertChildLast(knot)

                    line = f.readline()
            except:
                pass

root.save('knot-census.rga')
