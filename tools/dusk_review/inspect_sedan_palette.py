from PIL import Image
from collections import Counter
im=Image.open("assets/art/street_detail/burgundy_sedan.png").convert("RGBA")
print("SIZE",im.size)
print("PALETTE",Counter(im.getdata()).most_common(18))
for p in [(50,16),(51,39),(82,49),(64,54),(92,45),(31,21),(92,18),(26,51),(43,46),(75,48),(75,50),(50,4),(50,2),(51,31),(51,35)]:
    print(p,im.getpixel(p))
