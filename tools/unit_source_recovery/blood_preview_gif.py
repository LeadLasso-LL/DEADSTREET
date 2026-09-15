from pathlib import Path
from PIL import Image
R=Path(__file__).parents[2]/'tools/dusk_review/results'
frames=[Image.open(R/f'blood_preview_{i:02}.png').convert('RGB') for i in range(24)]
frames[0].save(R/'blood_style.gif',save_all=True,append_images=frames[1:],duration=58,loop=0,disposal=2)
print('Preview GIF saved')
