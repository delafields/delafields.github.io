# resizes screenshots from 1440x1800 to 512x512

from PIL import Image
import os, sys
from tqdm import tqdm

path = "screenshots_compressed/"
dirs = os.listdir( path )

im_size = 512 # overwrite image to 512x512

def resize():
  for item in tqdm(dirs):
    if os.path.isfile(path+item):
      im = Image.open(path+item)
      f, e = os.path.splitext(path+item)
      imResize = im.resize((im_size, im_size), Image.ANTIALIAS)
      imResize.save(f + '.png', 'PNG', quality=90)

resize()
