

import sys

file=open(sys.argv[1],"rb")
output=open(sys.argv[1][:-4]+".asm","wb")

i=0
j=192
k=1
char=file.read(1)
output.write("gSnkAnim"+str(k)+"\n")
output.write("\tld\tHL,\t$9000\n")

while len(char)!=0:
 char=ord(char)
 output.write("\tld\t[HL],\t$"+hex(char)[2:]+"\n")
 output.write("\tinc\tL\n")
 i+=1
 if i>=j:
  i=0
  output.write("\tret\n")
  k+=1
  output.write("gSnkAnim"+str(k)+"\n")
  output.write("\tld\tHL,\t$9000\n")
 char=file.read(1)
print (k-1)*j+i
print k
output.write("\tret\n")
output.close()