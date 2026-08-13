local ollama_url = "http://127.0.0.1:11434"
local ollama_model = nil

local function notify(message, level)
	vim.notify("[ollama] " .. message, level or vim.log.levels.INFO)
end

local function get_models(callback)
	vim.system({
		"curl",
		"-sS",
		"--max-time",
		"10",
		ollama_url .. "/api/tags",
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				notify("Ollama is not running", vim.log.levels.ERROR)
				return
			end

			local ok, data = pcall(vim.json.decode, result.stdout)

			if not ok or type(data.models) ~= "table" then
				notify("Could not read Ollama models", vim.log.levels.ERROR)
				return
			end

			local models = {}

			for _, model in ipairs(data.models) do
				if type(model.name) == "string" then
					models[#models + 1] = model.name
				end
			end

			if #models == 0 then
				notify("No Ollama models installed", vim.log.levels.ERROR)
				return
			end

			callback(models)
		end)
	end)
end

local function select_model(callback)
	if ollama_model then
		callback(ollama_model)
		return
	end

	get_models(function(models)
		if #models == 1 then
			ollama_model = models[1]
			callback(ollama_model)
			return
		end

		vim.ui.select(models, {
			prompt = "Ollama model:",
		}, function(choice)
			if not choice then
				return
			end

			ollama_model = choice
			notify("Using " .. choice)

			callback(choice)
		end)
	end)
end

local function show_loading()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"  Generating...  ",
	})

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false

	local width = 22
	local height = 1

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		focusable = false,
		zindex = 100,
	})

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].cursorline = false
	vim.wo[win].cursorcolumn = false
	vim.wo[win].winfixwidth = true
	vim.wo[win].winfixheight = true

	local dots = 3

	local timer = vim.fn.timer_start(500, function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		dots = dots % 3 + 1

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"  Generating" .. string.rep(".", dots) .. "  ",
		})
	end, {
		["repeat"] = -1,
	})

	return buf, win, timer
end

local function hide_loading(buf, win, timer)
	if timer then
		pcall(vim.fn.timer_stop, timer)
	end

	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end

	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, {
			force = true,
		})
	end
end

local function generate()
	local source_buf = vim.api.nvim_get_current_buf()
	local source_win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(source_win)

	local cursor_row = cursor[1]

	vim.ui.input({
		prompt = "Generate: ",
	}, function(request)
		if not request or vim.trim(request) == "" then
			return
		end

		select_model(function(model)
			if not vim.api.nvim_buf_is_valid(source_buf) then
				return
			end

			local filetype = vim.bo[source_buf].filetype

			if filetype == "" then
				filetype = "source code"
			end

			local system_prompt = [[
You are a strict source-code generation engine running inside Neovim.

Your ONLY task is to generate NEW source code.

OUTPUT ONLY SOURCE CODE.

Never output:
- explanations
- reasoning
- markdown
- code fences
- JSON
- XML
- YAML
- natural language
- introductions
- conclusions
- descriptions
- the user's request

Generate ONLY the code requested by the user.

Do not generate unrelated code.

Do not assume access to the existing source file.

Do not modify or discuss existing code.

The output will be inserted directly into a source buffer.
]]

			local user_prompt = "Generate new "
				.. filetype
				.. " code.\n\n"
				.. "USER REQUEST:\n"
				.. request
				.. "\n\nReturn ONLY the new source code."

			local body = vim.json.encode({
				model = model,
				stream = false,
				think = false,
				keep_alive = "10m",

				messages = {
					{
						role = "system",
						content = system_prompt,
					},
					{
						role = "user",
						content = user_prompt,
					},
				},

				options = {
					temperature = 0,
					top_p = 0.1,
					repeat_penalty = 1.05,
					seed = 0,
					num_predict = 1024,
				},
			})

			local loading_buf
			local loading_win
			local loading_timer

			loading_buf, loading_win, loading_timer = show_loading()

			local cancelled = false
			local process

			local namespace = vim.api.nvim_create_namespace("ollama_generating")

			local function cleanup()
				vim.on_key(nil, namespace)

				hide_loading(loading_buf, loading_win, loading_timer)
			end

			local function cancel()
				if cancelled then
					return
				end

				cancelled = true

				if process then
					process:kill(15)
				end

				cleanup()

				if vim.api.nvim_buf_is_valid(source_buf) then
					vim.api.nvim_set_current_buf(source_buf)
				end

				notify("Generation cancelled")
			end

			vim.on_key(function(key)
				if key == "q" then
					cancel()
				end

				return ""
			end, namespace)

			process = vim.system({
				"curl",
				"-sS",
				"--max-time",
				"180",
				"-X",
				"POST",
				ollama_url .. "/api/chat",
				"-H",
				"Content-Type: application/json",
				"-d",
				body,
			}, {
				text = true,
			}, function(result)
				vim.schedule(function()
					if cancelled then
						return
					end

					cleanup()

					if not vim.api.nvim_buf_is_valid(source_buf) then
						return
					end

					vim.api.nvim_set_current_win(source_win)

					if result.code ~= 0 then
						notify("Ollama request failed", vim.log.levels.ERROR)
						return
					end

					local ok, data = pcall(vim.json.decode, result.stdout)

					if
						not ok
						or type(data) ~= "table"
						or type(data.message) ~= "table"
						or type(data.message.content) ~= "string"
					then
						notify("Invalid Ollama response", vim.log.levels.ERROR)
						return
					end

					local code = vim.trim(data.message.content)

					code = code:gsub("^```[%w_+%-]*\n", "")
					code = code:gsub("\n```%s*$", "")
					code = vim.trim(code)

					if code == "" then
						notify("Ollama returned no code", vim.log.levels.ERROR)
						return
					end

					local lines = vim.split(code, "\n", {
						plain = true,
						trimempty = false,
					})

					vim.api.nvim_buf_set_lines(source_buf, cursor_row, cursor_row, false, lines)

					local new_row = cursor_row + #lines

					local last_line = lines[#lines] or ""

					vim.api.nvim_win_set_cursor(source_win, {
						new_row,
						#last_line,
					})

					notify("Code generated")
				end)
			end)
		end)
	end)
end

vim.keymap.set("n", "<leader>og", generate, {
	desc = "Ollama generate code",
})

vim.keymap.set("n", "<leader>om", function()
	ollama_model = nil

	select_model(function(model)
		notify("Using " .. model)
	end)
end, {
	desc = "Select Ollama model",
})

vim.schedule(function()
	get_models(function(models)
		if #models == 1 then
			ollama_model = models[1]
		end
	end)
end)

