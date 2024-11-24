include("karaskel.lua")
script_autor = KaraLaura
script_name = "fx LuaTest"
script_version = 1.0
script_description = "FX simples, version 1.0"

function do_fx(subs, meta, line, config)
	for i = 1, line.kara.n do
		local syl = line.kara[i]
		local x = syl.center + line.left
		local y = line.middle

		--================== Before_Syl =================--
		l = table.copy(line)
		l.start_time = line.start_time + 50*(syl.i-line.kara.n)
		l.end_time = line.start_time + syl.start_time
		l.dur = l.end_time - l.start_time
		l.layer = 0
		if config.fxentry == "Classic Fade" then
			entry_syl = string.format("{\\an5\\pos(%s,%s)\\fad(300,0)}%s",x,y,syl.text_stripped)
		elseif config.fxentry == "Move Fade" then
			entry_syl = string.format("{\\an5\\move(%s,%s,%s,%s,0,400)\\fad(300,0)}%s",x+3*syl.height,y,x,y,syl.text_stripped)
		elseif config.fxentry == "Simple Screw" then
			entry_syl = string.format("{\\an5\\pos(%s,%s)\\fad(300,0)\\frx90\\t(0,300,0.8,\\frx0)}%s",x,y,syl.text_stripped)
		elseif config.fxentry == "Move Random" then
			entry_syl = string.format("{\\an5\\move(%s,%s,%s,%s,0,400)\\frx%s\\fry%s\\frz%s\\t(0,300,0.8,\\frx0\\fry0\\frz0)\\fad(300,0)}%s",x+2*syl.height,y+(-1)^math.random(2)*2*syl.height,x,y,math.random(-360,360),math.random(-360,360),math.random(-360,360),syl.text_stripped)
		end
		l.text = entry_syl
		subs.append(l)
		
		--================== During_Syl =================--
		l = table.copy(line)
		l.delay = 200
		l.start_time = line.start_time + syl.start_time
		l.end_time = l.start_time + syl.duration + l.delay
		l.dur = l.end_time - l.start_time
		l.layer = 1
		if syl.i == line.kara.n then
			if syl.duration < 300 then
				last_syl_fad = syl.duration
			else
				last_syl_fad = 300
			end
		else
			last_syl_fad = 0
		end
		if config.fxduring == "Simple Shine" then
			during_syl = string.format("{\\an5\\pos(%s,%s)\\t(0,60,\\fscx120\\fscy120\\3c&HFFFFFF&\\blur3)\\t(60,%d,\\fscx100\\fscy100\\3c%s\\1c%s\\blur0)\\fad(0,%s)}%s",x,y,l.dur,line.styleref.color3,line.styleref.color1,last_syl_fad,syl.text_stripped)
		elseif config.fxduring == "Jumping Syl" then
			during_syl = string.format("{\\an5\\pos(%s,%s)\\org(-10000,%s)\\t(0,60,\\frz0.06)\\t(60,%d,\\frz0)\\fad(0,%s)}%s",x,y,y,l.dur,last_syl_fad,syl.text_stripped)
		elseif config.fxduring == "Jitter Syl" then
			during_syl = string.format("{\\an5\\pos(%s,%s)\\jitter(%s,%s,%s,%s,50,1000)\\fad(0,%s)}%s",x,y,math.ceil(syl.height/15),math.ceil(syl.height/15),math.ceil(syl.height/15),math.ceil(syl.height/15),last_syl_fad,syl.text_stripped)
		end
		l.text = during_syl
		subs.append(l)
		
		--================== After_Syl =================--
		l = table.copy(line)
		l.delay = 200
		l.start_time = line.start_time + syl.end_time + l.delay
		l.end_time = line.end_time + 50*(syl.i-line.kara.n) + l.delay
		l.dur = l.end_time - l.start_time
		l.layer = 0
		if config.fxexit == "Classic Fade" then
			exit_syl = string.format("{\\an5\\pos(%s,%s)\\fad(0,300)}%s",x,y,syl.text_stripped)
		elseif config.fxexit == "Move Fade" then
			exit_syl = string.format("{\\an5\\move(%s,%s,%s,%s,%s,%s)\\fad(0,300)}%s",x,y,x-3*syl.height,y,l.dur-400,l.dur,syl.text_stripped)
		elseif config.fxexit == "Move Random" then
			exit_syl = string.format("{\\an5\\move(%s,%s,%s,%s,%s,%s)\\frx0\\fry0\\frz0\\t(%s,%s,0.8,\\frx%s\\fry%s\\frz%s)\\fad(0,300)}%s",x,y,x-2*syl.height,y+(-1)^math.random(2)*2*syl.height,l.dur-400,l.dur,l.dur-400,l.dur,math.random(-360,360),math.random(-360,360),math.random(-360,360),syl.text_stripped)
		end
		l.text = exit_syl
		subs.append(l)
		
	end
end

function fx_lua(subs, config, index)
	aegisub.progress.task("Getting header data...")
	local meta, styles = karaskel.collect_head(subs)
	aegisub.progress.task("Applying effect...")
	local maxi = #index
	for _, i in ipairs(index) do
		aegisub.progress.task(string.format("Applying effect (%d/%d)...", i, maxi))
		aegisub.progress.set((i-1)/maxi*100)
		local l = subs[i]
		karaskel.preproc_line(subs, meta, styles, l)
		do_fx(subs, meta, l, config)
		maxi = maxi - 1
		l.comment = true
		subs[i] = l
	end
	aegisub.progress.task("Finished!")
	aegisub.progress.set(100)
end

Lua_fx_conf = {
	[1] = { name = "applyto"; class = "dropdown"; x = 5; y = 0; height = 2; width = 4; items = { }; value = "" },
	[2] = { class = "label"; x = 0; y = 0; height = 1; width = 4; label = "Apply to" },
	[3] = { class = "label"; x = 0; y = 2; height = 1; width = 4; label = "FX Entry Syl"},
	[4] = { name = "fxentry"; class = "dropdown"; x = 5; y = 2; height = 2; width = 4; items = {"Classic Fade","Move Fade","Simple Screw","Move Random"}; value = "Classic Fade"},
	[5] = { class = "label"; x = 0; y = 4; height = 1; width = 4; label = "FX During Syl"},
	[6] = { name = "fxduring"; class = "dropdown"; x = 5; y = 4; height = 2; width = 4; items = {"Simple Shine","Jumping Syl","Jitter Syl"}; value = "Simple Shine"},
	[7] = { class = "label"; x = 0; y = 6; height = 1; width = 4; label = "FX Exit Syl"},
	[8] = { name = "fxexit"; class = "dropdown"; x = 5; y = 6; height = 2; width = 4; items = {"Classic Fade","Move Fade","Move Random"}; value = "Classic Fade"}
}

function Lua_fx_preprosses_macro(subtitles, config, selected_lines)
	local subs = {}
	if config.applyto == "Selected lines" then
		for _, i in ipairs(selected_lines) do
			table.insert(subs, i)
		end
	elseif config.applyto == "SelectAll" then
		for i = 1, #subtitles do
			if subtitles[i].class == "dialogue" and subtitles[i].effect ~= "FX" and not subtitles[i].comment then
				table.insert(subs, i)
			end
		end
	else
		for i = 1, #subtitles do
			if subtitles[i].class == "dialogue" and subtitles[i].effect ~= "FX" and not subtitles[i].comment and config.applyto == subtitles[i].style then
				table.insert(subs, i)
			end
		end
	end
	fx_lua(subtitles, config, subs)
end

function Lua_fx_prepareconfig(styles, subtitles, has_selected_lines)
	Lua_fx_conf[1].items = {}
	local astyles = {}
	for i = 1, #subtitles do
		if subtitles[i].class == "dialogue" and subtitles[i].effect ~= "FX" and
			not subtitles[i].comment then
			if subtitles[i].style ~= "" and not astyles[subtitles[i].style] then 
				astyles[subtitles[i].style] = true
				applytostyle = subtitles[i].style
				table.insert(Lua_fx_conf[1].items, applytostyle)
			end
		end 
	end
	if  #Lua_fx_conf[1].items > 0 then 
		Lua_fx_conf[1].value = "SelectAll"
		table.insert(Lua_fx_conf[1].items, Lua_fx_conf[1].value) 
	end
	if has_selected_lines and #Lua_fx_conf[1].items > 0 then 
		table.insert(Lua_fx_conf[1].items,"Selected lines")
	end
end

function Lua_fx_macro(subtitles, selected_lines, active_line)
	local meta, styles = karaskel.collect_head(subtitles)
	Lua_fx_prepareconfig(styles, subtitles, #selected_lines > 0)
	local cfg_res, config = aegisub.dialog.display(Lua_fx_conf)
	if cfg_res then
		Lua_fx_preprosses_macro(subtitles, config, selected_lines)
		aegisub.set_undo_point(script_name)
		aegisub.progress.task("Finished!") 
	else
		aegisub.progress.task("Cancelled");	
	end
end

aegisub.register_macro(script_name,script_description, Lua_fx_macro)