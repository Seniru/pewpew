function eventChatCommand(name, cmd)
	local args = stringutils.split(cmd, " ")
	if cmds[args[1]] then
		local cmdArgs = {}
		for i = 2, #args do cmdArgs[#cmdArgs + 1] = args[i] end
		cmds[args[1]](cmdArgs, cmd, name)
	end
end
