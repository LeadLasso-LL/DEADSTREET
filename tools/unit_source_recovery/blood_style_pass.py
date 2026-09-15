from pathlib import Path
R=Path(__file__).parent
def edit(name,old,new):
 p=R/name;s=p.read_text();assert old in s,name;p.write_text(s.replace(old,new))
edit('src/build.py','"stroke-width","1.25"','"stroke-width","1.8"')
edit('src/build.py',"skin,'#090f12',.95)","skin,'#090f12',1.2)")
edit('src/directions.py',"skin,'#090f12',.95)","skin,'#090f12',1.2)")
edit('src/build.py',"M37 28 L43 33 47 28 45 46Z","M36 28 L43 32 48 28 49 55 Q43 58 36 55Z")
edit('src/build.py',"M33 28 L37 28 42 43 36 38 37 34Z","M32 28 L36 28 39 40 36 48 34 57 29 55 31 39Z")
edit('src/build.py',"M48 28 L50 30 46 37 47 40 42 46Z","M48 28 L51 31 53 55 49 57 46 43 45 37Z")
edit('src/build.py',"M42 47 L42 57 M31 51 L37 51","M31 51 L34 51")
edit('src/directions.py',"M4 -30 L6 -30 5 -22Z","M3 -31 L6 -30 6 -13 4 1 0 1 2 -16Z")
edit('src/directions.py',"M-4 -31 L0 -27 4 -31 1 -17Z","M-4 -31 L0 -27 4 -31 5 -5 Q0 -2 -5 -5Z")
edit('src/directions.py',"M-6 -31 L-1 -20 -6 -24 -4 -27Z M5 -31 L1 -20 6 -24 4 -27Z","M-7 -31 L-4 -31 -2 -22 -4 -15 -5 -4 -9 -5Z M5 -31 L8 -28 9 -5 5 -4 3 -18 2 -23Z")
edit('src/build.py','if wounded:up.remove(far);up.append(far)',"if wounded:\n  E.SubElement(up,N+'circle',{'id':'abdomen_anchor','cx':str((origin+rot@grips[1])[0]),'cy':str((origin+rot@grips[1])[1]+3),'r':'0'})\n  up.remove(far);up.append(far)")
edit('src/directions.py',"if flip:out.set('transform','scale(-1 1)')","if wounded:E.SubElement(g,N+'circle',{'id':'abdomen_anchor','cx':str(left[0]),'cy':str(left[1]+3),'r':'0'})\n if flip:out.set('transform','scale(-1 1)')")
source=(R/'update_sw_muzzles.py').read_text().replace("'muzzle_anchor'","'abdomen_anchor'").replace("muzzles.json","abdomen.json").replace("data=json.loads(p.read_text())","data={}").replace("equipment.draw=mark","")
(R/'export_abdomen.py').write_text(source)
print('Thicker ink, open suit fronts, abdomen anchors authored')
