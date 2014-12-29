import random
from Tkinter import *
from time import sleep
from time import time
from time import gmtime
#Evolution game
#2d grid, address by map[x][y]
mapx = 100
mapy = 60
stacklen = 10
sight_dist = 10 #max dist it can see
cell_size = 10
food_per_turn = 100
food_drop_per_turn = 10.0
#each cell contains:
	#org = org[n] (ie instance of organism())
	#food = instance of food()
	#no org = -1
		#to identify food/org, use map[x][y].id (1=org, 0=food)
map = [[-1 for y in range(mapy)]for x in range(mapx)]

class organism():
	def __init__(self, code=[], nrg=0, x=0, y=0, dir=0):
		self.code = code
		self.nrg = nrg
		self.x = x
		self.y = y
		self.dir = dir
		
		self.ptr = 0 #current position in it's code
		self.sptr = 0 #current position in it's stack
		self.stack = []
		global stacklen
		for n in range(stacklen): self.stack.append(0)
		self.id = 1
		self.col = get_col(code)

class food():
	def __init__(self, nrg=0):
		self.nrg = nrg
		self.id = 0

#list of orgs, ie org[org1,org2,...orgn]
org=[]
#KILLING ORG
def kill_org(org_number):
	global org; global map
	map[org[n].x][org[n].y] = -1
	del org[n]

#CREATING A NEW ORG
def create_org(code=[], nrg=0, x=0, y=0, dir=0):
	global org; global map
	org.append(organism(code, nrg, x, y, dir))
	map[x][y] = org[len(org) - 1]

#ADDING FOOD
def create_food(nrg=0, x=0, y=0):
	global map
	map[x][y] = food(nrg)
	
#RETURN TARGET CELL FROM THAT DIRECTION
def get_target(x, y, dir):
	global mapx; global mapy
	if dir == 0: x+=1
	elif dir == 1: y+=1
	elif dir == 2: x-=1
	elif dir == 3: y-=1
	if x >= mapx: x = 0
	elif x < 0: x = mapx - 1
	if y >= mapy: y = 0
	elif y < 0: y = mapy - 1
	return x,y

def random_cmd():
	#return random command
	rnd = random.random()
	if rnd < .25:
		return random.randint(-250,250)
	elif rnd < .45:
		rnd = random.randint(0,2)
		if rnd == 0:
			rnd = random.random() * 6
			if rnd < 1:
				return '+'
			elif rnd < 2:
				return '-'
			elif rnd < 3:
				return '/'
			elif rnd < 4:
				return '*'
			elif rnd < 5:
				return '%'
			else:
				return '**'
		elif rnd == 1:
			rnd = random.random() * 3
			if rnd < 1:
				return '&'
			elif rnd < 2:
				return '|'
			else:
				return '^'
		else:
			rnd = random.random() * 3
			if rnd < 1:
				return '<'
			elif rnd < 2:
				return '>'
			else:
				return '='
	elif rnd < .65:
		rnd = random.randint(0,2)
		if rnd == 0:
			return 'sptr++'
		elif rnd == 1:
			return 'sptr--'
		else:
			return 'rotate'
	elif rnd < .85:
		rnd = random.randint(0,2)
		if rnd == 0:
			return 'what'
		elif rnd == 1:
			return 'where'
		else:
			return 'nrg'
	else:
		rnd = random.randint(0,2)
		if rnd == 0:
			return 'move'
		elif rnd == 1:
			return 'eat'
		else:
			return 'repro'
	

def mutate(cde, max_mut=20, mut_chance=0.005):
	code = []; code += cde
	for n in range(max_mut):
		rnd = random.random()
		if rnd < mut_chance:
			rnd = random.random() * 4
			index = int(random.random() * len(code))
			if rnd < 2 and len(code)>1:
				del code[index]
			elif rnd < 3:
				code.insert(index, random_cmd())
			else:
				code[index] = random_cmd()
	return code
	

#Create canvas
universe=Canvas(width=mapx * cell_size,height=mapy * cell_size,background='#ffffff')
universe.pack()
#Create cells
drawmap = [[0 for y in range(mapy)]for x in range(mapx)]
for x in range(mapx):
	for y in range(mapy):
		drawmap[x][y] = universe.create_rectangle(x*cell_size,y*cell_size,x*cell_size+cell_size,y*cell_size+cell_size, \
		fill='#ffffff',outline='#00ffff')
		
def get_col(code):
	maths = code.count('+') + code.count('-') + code.count('*') + \
			code.count('/') + code.count('**') + code.count('%')
	logic = code.count('&') + code.count('|') + code.count('^')
	compa = code.count('<') + code.count('>') + code.count('+')
	infor = code.count('where') + code.count('what') + code.count('nrg')
	think = code.count('sptr++') + code.count('sptr--') + code.count('rotate')
	actio = code.count('move') + code.count('eat') + code.count('repro')
	
	r = maths*0 + logic*0 + compa*0 + infor*0 + think*0 + actio*5
	g = maths*0 + logic*0 + compa*0 + infor*3 + think*3 + actio*0
	b = maths*2 + logic*2 + compa*2 + infor*0 + think*0 + actio*0
	
	total = r + g + b
	factor = 255 / total
	r *= factor; g *= factor; b *= factor
	
	return "#%02x%02x%02x" % (r, g, b)
	

def redraw(map):
	mapx = len(map); mapy = len(map[0])
	global drawmap; global redraw_list
	for x,y in redraw_list:
		if map[x][y] == -1: col = '#ffffff'
		elif map[x][y].id == 0: col = '#00ff00'
		elif map[x][y].id == 1: col = map[x][y].col
		else: col = '#000000'
		universe.itemconfigure(drawmap[x][y], fill = col, outline = col)
	#for x in range(mapx):
	#	for y in range(mapy):
	#		if map[x][y] == -1: col = '#ffffff'
	#		elif map[x][y].id == 0: col = '#00ff00'
	#		elif map[x][y].id == 1: col = map[x][y].col
	#		else: col = '#000000'
	#		universe.itemconfigure(drawmap[x][y], fill = col, outline = col)
	universe.update()
	redraw_list = []
	
newcode = ['move','move','sptr+','eat','sptr-','sptr-',1,'-','rotate',50,'repro']
create_org(newcode, nrg=25000, x=mapx*25/100, y=mapy*25/100, dir=0)
ewcode = [-60, 'move', 'sptr--', 'sptr--', 'move', 'move', 'move', 'rotate', 'what', '<', '%', 'eat', 50, 'repro']#lv86
create_org(newcode, nrg=25000, x=mapx*75/100, y=mapy*75/100, dir=1)
newcode = [159, 'rotate', 'where', 'what', '<', 'what', '*', 'move', 'sptr--', -61, 'eat', 'rotate', 'repro']#nights evo
create_org(newcode, nrg=25000, x=mapx*25/100, y=mapy*75/100, dir=2)
newcode = ['move', 'move', 'eat', 'rotate', 50, 'repro'] #lv62
create_org(newcode, nrg=25000, x=mapx*75/100, y=mapy*25/100, dir=3)
#every turn
simid2 = gmtime(time())
simid = str(simid2[0])+'-'+str(simid2[1])+'-'+str(simid2[2])+'-'+str(simid2[2])+'-'+str(simid2[3])+'-'+str(simid2[4])+'-'+str(simid2[5])
redraw_list = []
for m in range(9999999):
	for n in range(len(org)):
		remaining = 20
		while remaining > 0:
			#go through code and perform actions
			cmd = org[n].code[org[n].ptr]
			#print cmd
			b = org[n].stack[(org[n].sptr + 1) % stacklen]
			
			if isinstance(cmd, int):
				remaining -= 1
				org[n].stack[org[n].sptr] = cmd
				
				#ARITHMETIC / LOGICAL / COMPARATIVE COMMANDS
			#stack[sptr] += stack[(sptr + 1) % stacklen]
				#MATHS
			elif cmd == '+':
				remaining -= 1
				org[n].stack[org[n].sptr] += b
			elif cmd == '-':
				remaining -= 1
				org[n].stack[org[n].sptr] -= b
			elif cmd == '/':
				remaining -= 1
				if b == 0: b = 1
				org[n].stack[org[n].sptr] /= b
			elif cmd == '*':
				remaining -= 1
				org[n].stack[org[n].sptr] *= b
			elif cmd == '%':
				remaining -= 1
				if b == 0: b = 1
				org[n].stack[org[n].sptr] %= b
			elif cmd == '**':
				remaining -= 1
				if b < 0: b = 0
				org[n].stack[org[n].sptr] **= b
				#LOGIC
			elif cmd == '&':
				remaining -= 1
				org[n].stack[org[n].sptr] &= b
			elif cmd == '|':
				remaining -= 1
				org[n].stack[org[n].sptr] |= b
			elif cmd == '^':
				remaining -= 1
				org[n].stack[org[n].sptr] ^= b
				#COMPARATIVE
			elif cmd == '<':
				remaining -= 1
				org[n].stack[org[n].sptr] = int(org[n].stack[org[n].sptr]<b)
			elif cmd == '>':
				remaining -= 1
				org[n].stack[org[n].sptr] = int(org[n].stack[org[n].sptr]>b)
			elif cmd == '=':
				remaining -= 1
				org[n].stack[org[n].sptr] = int(org[n].stack[org[n].sptr]==b)
				
				#INFORMATION GETTING COMMANDS
			#where, what, my_nrg
			elif cmd == 'where':
				remaining -= 3
				#returns dist to closest thing in front
				tx,ty = org[n].x, org[n].y
				for dist in range(1,sight_dist):
					tx,ty = get_target(tx, ty, org[n].dir)
					if map[tx][ty] != -1: break
				org[n].stack[org[n].sptr] = dist
				
			elif cmd == 'what':
				remaining -= 3
				#returns id of closest thing in front
				tx,ty = org[n].x, org[n].y
				org[n].stack[org[n].sptr] = -1
				for dist in range(1,sight_dist):
					tx,ty = get_target(tx, ty, org[n].dir)
					if map[tx][ty] != -1: org[n].stack[org[n].sptr] = map[tx][ty].id; break
				
			elif cmd == 'my_nrg':
				remaining -= 2
				org[n].stack[org[n].sptr] = org[n].nrg
				#THINKING COMMANDS
			#mod_sptr, rotate,
			elif cmd == 'sptr+':
				remaining -= 2
				org[n].sptr += 1
				org[n].sptr %= stacklen
				
			elif cmd == 'sptr-':
				remaining -= 2
				org[n].sptr -= 1
				org[n].sptr %= stacklen
				
			elif cmd == 'rotate':
				remaining -= 1
				org[n].dir += org[n].stack[org[n].sptr]
				org[n].dir %= 4
				#ACTION COMMANDS
			#move, eat, repro
			elif cmd == 'move':
				remaining -= 20
				tx,ty = get_target(org[n].x, org[n].y, org[n].dir)
				if map[tx][ty] == -1:
					if (org[n].x,org[n].y) not in redraw_list: redraw_list.append((org[n].x,org[n].y))
					if (tx,ty) not in redraw_list: redraw_list.append((tx,ty))
					map[org[n].x][org[n].y] = -1
					org[n].x = tx; org[n].y = ty
					map[org[n].x][org[n].y] = org[n]
					org[n].stack[org[n].sptr] = 1
				else: org[n].stack[org[n].sptr] = 0
				org[n].nrg -= 1
					
			elif cmd == 'eat':
				remaining -= 20
				tx,ty = get_target(org[n].x, org[n].y, org[n].dir)
				eaten = 10000 #max nrg we'll take
				if map[tx][ty] != -1: 
					#if eaten < map[tx][ty].nrg: 
					#	org[n].nrg += eaten
					#	map[tx][ty].nrg -= eaten
					#	org[n].stack[org[n].sptr] = eaten
					#else: 
					org[n].nrg += map[tx][ty].nrg
					org[n].stack[org[n].sptr] = map[tx][ty].nrg
					map[tx][ty].nrg = 0
					if map[tx][ty].id == 0: map[tx][ty] = -1
				else: org[n].stack[org[n].sptr] = 0
				org[n].nrg -= 1
				
			elif cmd == 'repro':
				remaining -= 20
				newdir = (org[n].dir + 2) % 4
				tx,ty = get_target(org[n].x, org[n].y, newdir)
				if map[tx][ty] == -1 and org[n].nrg > 1 and org[n].stack[org[n].sptr] > 0: 
					if org[n].nrg > org[n].stack[org[n].sptr]: newnrg = org[n].stack[org[n].sptr]
					else: newnrg = org[n].nrg / 2
					
					create_org(mutate(org[n].code), nrg = newnrg, x=tx, y=ty, dir=newdir)
					#mutate(org[len(org)-1].code,mut_chance=0.5)
					org[n].stack[org[n].sptr] = 1
					org[n].nrg -= newnrg
					if (tx,ty) not in redraw_list: redraw_list.append((tx,ty))
				else: org[n].stack[org[n].sptr] = 0
				org[n].nrg -= 1
			
			#print 'n',n,'|x',org[n].x,'|y',org[n].y,'|dir',org[n].dir,'|nrg',org[n].nrg
			#print org[n].stack
			
			org[n].ptr += 1
			org[n].ptr %= len(org[n].code)
	if food_drop_per_turn >= 1:
		for food_item in range(int(food_drop_per_turn)):
			food_x = random.randint(0, mapx-1)
			food_y = random.randint(0, mapy-1)
			if map[food_x][food_y] == -1: 
				create_food(int(food_per_turn / food_drop_per_turn), food_x, food_y)
				if (food_x,food_y) not in redraw_list: redraw_list.append((food_x,food_y))
	else:
		if m % int(1/food_drop_per_turn) == 0:
			food_x = random.randint(0, mapx-1)
			food_y = random.randint(0, mapy-1)
			if map[food_x][food_y] == -1: 
				create_food(int(food_per_turn / food_drop_per_turn), food_x, food_y)
				if (food_x,food_y) not in redraw_list: redraw_list.append((food_x,food_y))
	
	#killed = 1
	#while killed:
	#	killed = 0
	#	for n in range(len(org)): 
	#		if org[n].nrg < 1: kill_org(n);killed = 1;break
	kill_list = []
	tnrg = 0
	for n in range(len(org)): 
		tnrg += org[n].nrg
		if org[n].nrg < 1:
			if (org[n].x,org[n].y) not in redraw_list: redraw_list.append((org[n].x,org[n].y))
			kill_list.append(n)
	kill_list.sort(); kill_list.reverse()
	for n in kill_list: kill_org(n)
	if tnrg > 100000 or len(org)>200: food_drop_per_turn *= .99
	if tnrg < 15000 and len(org)<50 and food_drop_per_turn < 10: food_drop_per_turn /= .9
	if m % 250 == 0:
		redraw(map)
		print 'Turn',m
		print 'Total energy :',tnrg
		print 'Total orgs   :',len(org)
		print 'Av energy/org:',tnrg/len(org)
		print org[len(org)*7/10].code
		print food_drop_per_turn
		file=open('C:\Documents and Settings\User\My Documents\Programming\Python\Evolvetxt'+str(simid)+'.txt','a')
		output = 'Turn '+str(m)+'\n'+'Total energy :'+str(tnrg)+'\n'+'Total orgs   :'+str(len(org))+'\n'+'Av energy/org:'+str(tnrg/len(org))+'\n'
		output = output+str(org[len(org)*7/10].code)+'\n'+'====================================='+'\n'
		file.write(output)
		file.close
