---test program for the loadreq API. Will write to dir /Q.

if not loadreq then os.loadAPI('APIS/loadreq') end
require=loadreq.require
local function getFile(n,p)
	if not fs.exists(p) then
		fs.makeDir(p)
	end
	local f=fs.open(p..'/'..n,'w')
	return f
end
local function writeFile(s,n,p)
	f=getFile(n,p)
	f.write(s)
	f.close()
end
local function benchmark(f,...)
	local ta=os.clock()
	local r=f(...)
	print(r,' retrieved in ', os.clock()-ta,' s')
end
local bc=benchmark
local vars=loadreq.vars
vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil

writeFile('a=1','t1','Q/W/E')

--simple usage here
t1=require('t1')
print(t1.a)

--utilities test
writeFile('print(1,2,...)','t2','Q/W/E')
loadreq.run('Q/W/E/t2',{3,4,5})
loadreq.str('print(1,2,...)')(3,4,5)
writeFile('print(0,0,...)','t2','Q/W/E')
loadreq.file('Q/W/E/t2')(3,4,5) --utilities always reload


--serious testing
vars.required['t1']=nil --reseting required table for testing purposes
t1=require('t1',nil,{b=1})
print(t1.b)

vars.required['t1']=nil
t1=require('t1',nil,nil,{})
print(t1.string)

vars.required['t1']=nil
t1=require('t1','?;Q/?;#/*/E/t[1-9]')
print(t1.a)

REQUIRE_PATH='Q/W/E' --optional; must be on the environment, can't be local, in order to work;
vars.required['t1']=nil
t1=require('t1')
print(t1.a)
print('press enter')
read()

vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil
rq=require
REQUIRE_PATH=''
print('full search')
bc(rq,'t1')
vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil

print('search in Q')
bc(rq,'t1','Q')
vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil

REQUIRE_PATH='*/W/#/t[1-9]'
print('search by glob')
bc(rq,'t1')
vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil

print('check to see if already ran files are reused')
REQUIRE_PATH=''
print('full search')
bc(rq,'t1')

REQUIRE_PATH='*/W/#/t[1-9]'
print('search by glob')
bc(rq,'t1')
vars.loaded['Q/W/E/t1']=nil
vars.required['t1']=nil

print('check to see if already loaded files are reused')
bc(loadreq.loadFile,'Q/W/E/t1')
bc(loadreq.loadFile,'Q/W/E/t1')



--reset experiments
fs.delete('Q')