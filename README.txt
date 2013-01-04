loadreq is a CC API that emulates the require Lua function behavior, like so:

require(s,paths,...)
	@paths is a string of paths separated by ';' where there can be '?'
	-acquires @paths variable, by the following order;
		0-arg @paths
			Example (FILE_PATH='myFolder/myFolder2/myAPI.lua'):
			myAPI=require('myFolder2.myAPI','myFolder/?.lua') 
		1-REQUIRE_PATH in the caller's path, if existent
			Example (FILE_PATH='myFolder/myFolder2/myAPI.lua'):
			REQUIRE_PATH='myFolder/?.lua'
			myAPI=require'myFolder2.myAPI'
		2-directory named PACKAGE_NAME in FILE_PATH, if defined in the caller's environment
		with sufixes appended by @sufix and concatenated with @vars.paths.
		FILE_PATH is set, for instance, by lua_loader in the files it loads.
			Example (FILE_PATH='myFolder/myFolder3/myFolder/runningFile'):
			PACKAGE_NAME='myFolder'
			myAPI=require'myAPI' --@paths is 'myFolder/?;myFolder/?.lua;myFolder/?/init.lua;myFolder/?/?.lua;myFolder/?/?;myFolder'
		3-directory of FILE_PATH, if defined
		with sufixes appended by @sufix and concatenated with @vars.paths.
			Example (FILE_PATH='myFolder/runningFile'):
			myAPI=require'myAPI' --@paths is 'myFolder/?;myFolder/?.lua;myFolder/?/init.lua;myFolder/?/?.lua;myFolder/?/?;myFolder'
		4-@vars.paths as set in loadreq.vars.paths
	-replaces '.' in @s by '/' and '..' by '.'
	--for all search_path in @paths
	 -	for all iterators in loadreq.vars.finders, iterates over the paths returned;
		default iterator:	
			@direct: replaces '?' in the search_path by @s and returns the resulting path if it is a file.
	-for the first valid path, calls the loaders in loadreq.vars.requirers sequentially until one succeds,
	in which case it returns the first value that the loader returns, else if it returns nil,e it accumulates e as an error message
	if all loaders fail, errors immediatly, printing all error messages
	-in case of failure finding the path, errors with the searched paths.

It is easy to define custom search functions and path loaders (which I call requirers), by altering loadreq.vars.finders and loadreq.vars.requirers .
For instance, one could add a .json requirer.
Also, if you also install my search API (see signature), loadreq uses the glob search function from it as default.
loadreq comes with a lua_requirer function, that handles lua files:

lua_requirer(path,cenv,env,renv,rerun,args)
	Accepts empty or .lua extensions.
	if the rerun flag is true, reloads the file even if it done it before;
	if the file has been loaded already returns previous value;
	if the file is being loaded returns nil, error_message
	else:
	loads file in @path;
	sets it's env to @env, default {} with metatable with __index set to @renv, default _G;
	calls the function with unpack(@args) and returns and saves either
		the function return value;
		if the function returns nil, a shallow copy of the functions environment.