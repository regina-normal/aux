#!/usr/bin/regina-python

root = Container()

desc = Text()
desc.setLabel('Description')

desc.setText('This is a census of all non-trivial virtual knots with ≤ 6 crossings, as tabulated using Regina [1].  Classical knots are included also, and all knots in this census have been certified as distinct.\n\n' +
    'You can download this census data in CSV format from http://regina.sourceforge.net/data.html .\n\n' +
    'Most knots have names of the form \'v6_97 (Green: 6.41171)\'. Here v6_97 is the name from Regina\'s tabulation (which is sorted by virtual genus and knot signature), and 6.41171 is the name from Jeremy Green\'s tabulation [3].\n\n' +
    'Classical knots have longer names, of the form \'v6_5 (Green: 6.90227) = 6ah_1 (DT: 6a_3)\'. Here 6ah_1 is the name from Regina\'s tabulation of classical knots [2], and 6a_3 is the Dowker-Thistlethwaite name that appears in other online sources such as Knotinfo or Knotscape.\n\n' +
    'Note that this census is smaller than Green\'s, since Green\'s tables contain a duplicate pair (v6_421 in Regina\'s tabulation, 6.88185 = 6.90058 in Green\'s).\n\n' +
    'For more information on Regina, see http://regina-normal.github.io/ .\n\n' +
    '1. Benjamin A. Burton, "Adventures in tabulating virtual knots", in preparation.\n' +
    '2. Benjamin A. Burton, "The next 350 million knots", 36th International Symposium on Computational Geometry (SoCG 2020), Leibniz Int. Proc. Inform., vol. 164, Dagstuhl, Germany, 2020, pp. 25:1–25:17.\n' +
    '3. Jeremy Green, "A table of virtual knots", https://www.math.toronto.edu/drorbn/Students/GreenJ/ .\n')
root.insertChildLast(desc)

for i in range(2, 7):
    cr = Container()
    cr.setLabel(str(i) + ' crossings')
    root.insertChildLast(cr)

    filename = str(i) + '.csv'
    f = open(filename, 'r')

    header = f.readline()
    line = f.readline()
    while line:
        line = line.strip()
        bits = line.split(',')

        green = bits[4]
        pos = green.find('=')
        if pos >= 0:
            fix = green[:pos] + ' = ' + green[pos+1:]
            print('Renaming: ' + green + ' -> ' + fix)
            green = fix

        name = 'v' + bits[0] + ' (Green: ' + green + ')'
        if bits[5]:
            name = name + ' = ' + bits[5] + ' (DT: ' + bits[6] + ')'
        sig = bits[1]

        knot = make_packet(Link.fromSig(sig))
        knot.setLabel(name)
        cr.insertChildLast(knot)

        line = f.readline()

    f.close()

root.save('virtual-census.rga')
