import pygame,sys

pygame.init()

img=pygame.image.load(sys.argv[1])
out=pygame.Surface((img.get_width(),img.get_height()*2))

for y in range(img.get_height()):
 for x in range(img.get_width()):
  color=img.get_at((x,y))
  val=(color.r+color.g+color.b)/3
  if val<64:
   out.set_at((x,y*2),(0,0,0))
   out.set_at((x,y*2+1),(0,0,0))
  elif val<128:
   out.set_at((x,y*2),(255,255,255))
   out.set_at((x,y*2+1),(0,0,0))
  elif val<192:
   out.set_at((x,y*2),(0,0,0))
   out.set_at((x,y*2+1),(255,255,255))
  else:
   out.set_at((x,y*2),(255,255,255))
   out.set_at((x,y*2+1),(255,255,255))

pygame.image.save(out,sys.argv[1][:-4]+".png")
output=open(sys.argv[1][:-4]+".bin","wb")

for yt in range(out.get_height()/16):
 for xt in range(out.get_width()/8):
  for y in range(16):
   byte=0
   for x in range(8):
    byte<<=1
    color=out.get_at((xt*8+x,yt*16+y))
    if color.r+color.g+color.b<384:
     byte|=1
   output.write(chr(byte))
