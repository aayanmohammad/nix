local M = {
	url = "http://127.0.0.1:11434",
	model = nil,
}

local SYSTEM = [[
You are a strict source-code replacement engine running inside Neovim.

Your output is inserted directly into a source buffer.

OUTPUT ONLY SOURCE CODE.

Never output explanations.
Never output reasoning.
Never output markdown.
Never output code fences.
Never output JSON.
Never output XML.
Never output YAML.
Never output line numbers.
Never output natural language.
Never describe the change.
Never say "here is".
Never say "here's".
Never say "updated code".
Never say "replacement".
Never add text before the source.
Never add text after the source.

The complete source file is READ-ONLY CONTEXT.

You may inspect the complete file to understand:
- surrounding code
- imports
- functions
- variables
- types
- dependencies
- diagnostics
- LSP information
- formatting
- scope

Context is NOT output.

EDIT MODE:

The selected scope is the ONLY editable region.

Return ONLY the final source that replaces that scope.

Do not return anything before the scope.
Do not return anything after the scope.
Do not return surrounding functions.
Do not return surrounding code.
Do not return the complete file.

DIAGNOSTIC MODE:

Use the target diagnostic as the primary problem.

Use:
- the target diagnostic
- all buffer diagnostics
- raw LSP hover responses
- LSP type information
- LSP documentation
- the complete source file

The raw LSP hover response is authoritative information from the language server.

Determine the actual root cause before changing code.

Make the smallest necessary fix.

Do not modify unrelated code.
Do not refactor working code.
Do not rename things unless required.
Do not invent APIs.
Do not invent dependencies.
Do not change formatting unnecessarily.

Return ONLY the replacement source for the requested diagnostic scope.

GENERATE MODE:

The cursor is an insertion boundary.

Return ONLY NEW source lines that must be inserted after the cursor.

Do not repeat the cursor line.
Do not repeat existing source.
Do not repeat surrounding source.
Do not regenerate the surrounding function.
Do not return the complete file.

DUPLICATION RULE:

Context exists only to help you understand the requested change.

Context is NOT output.

Before emitting the result, internally verify:

1. Every output line belongs to the requested replacement.
2. No surrounding source is repeated.
3. No existing context is duplicated.
4. No old code is followed by duplicated old code.
5. No markdown fence exists.
6. No explanation exists.
7. No line numbers exist.
8. The output can be inserted directly into the source buffer.

If there is nothing to change, return the original requested source scope exactly.

STYLE:

Preserve the existing:
- indentation
- formatting
- naming
- quoting
- syntax style

Do not reformat unrelated code.

FINAL OUTPUT:

Return ONLY the source-code payload.

Nothing else.
]]

local MAX_RESPONSE_LINES = 1000
local MAX_RESPONSE_CHARS = 50000

local function notify(msg, level)
	vim.notify("[ollama] " .. msg, level or vim.log.levels.INFO)
end

local function decode(text)
	local ok, result = pcall(vim.json.decode, text)

	if not ok then
		return nil
	end

	return result
end

local function strip_outer_fence(text)
	text = vim.trim(text)

	if text == "" then
		return ""
	end

	local language, content = text:match("^```([%w_+%-]*)\n(.*)$")

	if language ~= nil and content ~= nil then
		content = content:gsub("\n```%s*$", "")

		return vim.trim(content)
	end

	content = text:match("^```[^\n]*\n(.*)\n```%s*$")

	if content then
		return vim.trim(content)
	end

	return text
end

local function validate_response(text)
	if type(text) ~= "string" then
		return nil, "Ollama returned invalid content"
	end

	text = vim.trim(text)

	if text == "" then
		return nil, "Ollama returned empty source"
	end

	if #text > MAX_RESPONSE_CHARS then
		return nil, "Ollama response is unexpectedly large"
	end

	text = strip_outer_fence(text)

	if text == "" then
		return nil, "Ollama returned empty source"
	end

	if text:find("```", 1, true) then
		return nil, "Ollama returned invalid code fences"
	end

	local lines = vim.split(text, "\n", {
		plain = true,
		trimempty = false,
	})

	if #lines == 0 then
		return nil, "Ollama returned empty source"
	end

	if #lines > MAX_RESPONSE_LINES then
		return nil, "Ollama response is unexpectedly large"
	end

	return lines
end

local function show_generating()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"  Generating...  ",
	})

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].readonly = true

	local width = 22
	local height = 1

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		focusable = true,
		zindex = 100,
	})

	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].cursorline = false
	vim.wo[win].winfixwidth = true
	vim.wo[win].winfixheight = true

	local namespace = vim.api.nvim_create_namespace("ollama_generating")

	vim.on_key(function()
		if vim.api.nvim_get_current_win() == win then
			return ""
		end
	end, namespace)

	return buf, win, namespace
end

local function hide_generating(buf, win, namespace)
	if namespace then
		vim.on_key(nil, namespace)
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

function M.models(select, callback)
	vim.system({
		"curl",
		"-sS",
		"--max-time",
		"10",
		M.url .. "/api/tags",
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				notify("Ollama is not running", vim.log.levels.ERROR)

				if callback then
					callback(nil)
				end

				return
			end

			local data = decode(result.stdout)

			if not data or type(data.models) ~= "table" then
				notify("could not read Ollama models", vim.log.levels.ERROR)

				if callback then
					callback(nil)
				end

				return
			end

			local names = {}

			for _, model in ipairs(data.models) do
				if type(model.name) == "string" then
					names[#names + 1] = model.name
				end
			end

			if #names == 0 then
				notify("no Ollama models found", vim.log.levels.ERROR)

				if callback then
					callback(nil)
				end

				return
			end

			if select then
				vim.ui.select(names, {
					prompt = "Ollama model:",
				}, function(choice)
					if not choice then
						if callback then
							callback(nil)
						end

						return
					end

					M.model = choice

					notify("model: " .. choice)

					if callback then
						callback(choice)
					end
				end)
			else
				M.model = M.model or names[1]

				if callback then
					callback(M.model)
				end
			end
		end)
	end)
end

function M.select_model()
	M.models(true)
end

local function predict_limit(mode)
	if mode == "generate" then
		return 512
	end

	if mode == "diagnostic" then
		return 768
	end

	return 1024
end

function M.ask(prompt, mode, callback)
	local function request()
		local loading_buf
		local loading_win
		local loading_ns

		loading_buf, loading_win, loading_ns = show_generating()

		local body = vim.json.encode({
			model = M.model,

			stream = false,

			think = false,

			keep_alive = "10m",

			messages = {
				{
					role = "system",
					content = SYSTEM,
				},
				{
					role = "user",
					content = prompt,
				},
			},

			options = {
				temperature = 0,
				top_p = 0.1,
				repeat_penalty = 1.05,
				seed = 0,
				num_predict = predict_limit(mode),
			},
		})

		vim.system({
			"curl",
			"-sS",
			"--max-time",
			"180",
			"-X",
			"POST",
			M.url .. "/api/chat",
			"-H",
			"Content-Type: application/json",
			"-d",
			body,
		}, {
			text = true,
		}, function(result)
			vim.schedule(function()
				hide_generating(loading_buf, loading_win, loading_ns)

				if result.code ~= 0 then
					notify("Ollama request failed", vim.log.levels.ERROR)

					return
				end

				local data = decode(result.stdout)

				if not data or not data.message or type(data.message.content) ~= "string" then
					notify("invalid Ollama response", vim.log.levels.ERROR)

					return
				end

				callback(data.message.content)
			end)
		end)
	end

	if M.model then
		request()
		return
	end

	M.models(false, function(model)
		if model then
			request()
		else
			notify("no Ollama model available", vim.log.levels.ERROR)
		end
	end)
end

local function preview(buf, proposed)
	local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local preview_buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, proposed)

	vim.bo[preview_buf].buftype = "nofile"
	vim.bo[preview_buf].bufhidden = "wipe"
	vim.bo[preview_buf].swapfile = false
	vim.bo[preview_buf].modifiable = false
	vim.bo[preview_buf].readonly = true

	local original_win = vim.api.nvim_get_current_win()

	local original_cursor = vim.api.nvim_win_get_cursor(original_win)

	vim.cmd("vsplit")

	local preview_win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(preview_win, preview_buf)

	vim.cmd("wincmd h")
	vim.cmd("diffthis")

	vim.cmd("wincmd l")
	vim.cmd("diffthis")

	local old_original_statusline = vim.wo[original_win].statusline

	local old_preview_statusline = vim.wo[preview_win].statusline

	vim.wo[original_win].statusline = ""
	vim.wo[preview_win].statusline = ""

	local finished = false

	local function finish()
		if finished then
			return
		end

		finished = true

		if vim.api.nvim_win_is_valid(preview_win) then
			vim.api.nvim_set_current_win(preview_win)

			pcall(vim.cmd, "diffoff!")
		end

		if vim.api.nvim_win_is_valid(original_win) then
			vim.api.nvim_set_current_win(original_win)

			pcall(vim.cmd, "diffoff!")

			vim.wo[original_win].statusline = old_original_statusline
		end

		if vim.api.nvim_win_is_valid(preview_win) then
			vim.wo[preview_win].statusline = old_preview_statusline
		end

		if vim.api.nvim_buf_is_valid(preview_buf) then
			vim.api.nvim_buf_delete(preview_buf, {
				force = true,
			})
		end
	end

	vim.keymap.set("n", "y", function()
		local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

		if not vim.deep_equal(current, original) then
			notify("buffer changed; not applying", vim.log.levels.ERROR)

			finish()
			return
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, proposed)

		if vim.api.nvim_win_is_valid(original_win) then
			local line_count = vim.api.nvim_buf_line_count(buf)

			local row = math.min(original_cursor[1], line_count)

			local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""

			local col = math.min(original_cursor[2], #line)

			vim.api.nvim_set_current_win(original_win)

			vim.api.nvim_win_set_cursor(original_win, {
				row,
				col,
			})
		end

		notify("applied")

		finish()
	end, {
		buffer = preview_buf,
		silent = true,
		desc = "Apply Ollama change",
	})

	vim.keymap.set("n", "n", function()
		notify("rejected")
		finish()
	end, {
		buffer = preview_buf,
		silent = true,
		desc = "Reject Ollama change",
	})

	vim.keymap.set("n", "q", function()
		notify("rejected")
		finish()
	end, {
		buffer = preview_buf,
		silent = true,
		desc = "Reject Ollama change",
	})
end

local function code_context(buf)
	local source = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local diagnostic_lines = {}

	for _, d in ipairs(vim.diagnostic.get(buf)) do
		diagnostic_lines[#diagnostic_lines + 1] = string.format(
			"%d:%d-%d:%d %s%s",
			d.lnum + 1,
			(d.col or 0) + 1,
			(d.end_lnum or d.lnum) + 1,
			(d.end_col or d.col or 0) + 1,
			d.message,
			d.source and (" [" .. d.source .. "]") or ""
		)
	end

	return table.concat({
		"FILE:",
		vim.api.nvim_buf_get_name(buf),

		"",
		"FILETYPE:",
		vim.bo[buf].filetype,

		"",
		"ALL BUFFER DIAGNOSTICS:",
		#diagnostic_lines > 0 and table.concat(diagnostic_lines, "\n") or "None",

		"",
		"COMPLETE SOURCE FILE:",
		table.concat(source, "\n"),
	}, "\n")
end

local function diagnostic_summary(diagnostic)
	return {
		message = diagnostic.message,
		source = diagnostic.source,
		code = diagnostic.code,
		severity = diagnostic.severity,

		range = {
			start = {
				line = diagnostic.lnum + 1,
				column = (diagnostic.col or 0) + 1,
			},

			["end"] = {
				line = (diagnostic.end_lnum or diagnostic.lnum) + 1,

				column = (diagnostic.end_col or diagnostic.col or 0) + 1,
			},
		},

		tags = diagnostic.tags,
	}
end

local function all_diagnostic_summaries(buf)
	local result = {}

	for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
		result[#result + 1] = diagnostic_summary(diagnostic)
	end

	return result
end

local function get_lsp_hover_raw(buf, diagnostic, callback)
	local clients = vim.lsp.get_clients({
		bufnr = buf,
	})

	local hover_clients = {}

	for _, client in ipairs(clients) do
		if client.supports_method and client:supports_method("textDocument/hover") then
			hover_clients[#hover_clients + 1] = client
		end
	end

	if #hover_clients == 0 then
		callback({})

		return
	end

	local pending = #hover_clients
	local results = {}

	local function done()
		pending = pending - 1

		if pending == 0 then
			callback(results)
		end
	end

	for _, client in ipairs(hover_clients) do
		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

		params.position = {
			line = diagnostic.lnum,
			character = diagnostic.col or 0,
		}

		client:request("textDocument/hover", params, function(err, result)
			if not err and result then
				results[#results + 1] = {
					client = client.name,
					client_id = client.id,
					result = result,
				}
			end

			done()
		end, buf)
	end
end

function M.edit()
	local buf = vim.api.nvim_get_current_buf()

	local start_mark = vim.api.nvim_buf_get_mark(buf, "<")

	local end_mark = vim.api.nvim_buf_get_mark(buf, ">")

	if start_mark[1] == 0 or end_mark[1] == 0 then
		notify("No visual selection", vim.log.levels.WARN)

		return
	end

	local start_row = math.min(start_mark[1], end_mark[1]) - 1

	local end_row = math.max(start_mark[1], end_mark[1])

	local selected = vim.api.nvim_buf_get_lines(buf, start_row, end_row, false)

	vim.ui.input({
		prompt = "edit: ",
	}, function(request)
		if not request or request == "" then
			return
		end

		local prompt = table.concat({
			"MODE: EDIT",

			"",
			"USER REQUEST:",
			request,

			"",
			"EDITABLE SCOPE:",
			"Source lines " .. (start_row + 1) .. "-" .. end_row,

			"",
			"CURRENT EDITABLE SOURCE:",
			table.concat(selected, "\n"),

			"",
			code_context(buf),

			"",
			"FINAL INSTRUCTION:",
			"Return ONLY the replacement for the editable scope.",
			"Do not return surrounding source.",
			"Do not return the complete file.",
			"Do not repeat context.",
		}, "\n")

		M.ask(prompt, "edit", function(result)
			local replacement, err = validate_response(result)

			if not replacement then
				notify(err, vim.log.levels.ERROR)

				return
			end

			local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

			local proposed = {}

			for i = 1, start_row do
				proposed[#proposed + 1] = current[i]
			end

			for _, line in ipairs(replacement) do
				proposed[#proposed + 1] = line
			end

			for i = end_row + 1, #current do
				proposed[#proposed + 1] = current[i]
			end

			if vim.deep_equal(current, proposed) then
				notify("Ollama made no changes", vim.log.levels.WARN)

				return
			end

			preview(buf, proposed)
		end)
	end)
end

function M.generate()
	local buf = vim.api.nvim_get_current_buf()

	local cursor = vim.api.nvim_win_get_cursor(0)

	local cursor_row = cursor[1] - 1

	vim.ui.input({
		prompt = "generate: ",
	}, function(request)
		if not request or request == "" then
			return
		end

		local prompt = table.concat({
			"MODE: GENERATE",

			"",
			"USER REQUEST:",
			request,

			"",
			"INSERTION POINT:",
			"After source line " .. cursor_row,

			"",
			code_context(buf),

			"",
			"FINAL INSTRUCTION:",
			"Return ONLY NEW source lines.",
			"Do not repeat existing source.",
			"Do not repeat the cursor line.",
			"Do not return surrounding source.",
			"Do not return the complete file.",
		}, "\n")

		M.ask(prompt, "generate", function(result)
			local generated, err = validate_response(result)

			if not generated then
				notify(err or "Ollama returned no new lines", vim.log.levels.ERROR)

				return
			end

			local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

			local proposed = vim.deepcopy(current)

			for i = #generated, 1, -1 do
				table.insert(proposed, cursor_row + 2, generated[i])
			end

			preview(buf, proposed)
		end)
	end)
end

function M.fix_diagnostic(diagnostic)
	local buf = vim.api.nvim_get_current_buf()

	if not diagnostic then
		local cursor = vim.api.nvim_win_get_cursor(0)

		local diagnostics = vim.diagnostic.get(buf, {
			lnum = cursor[1] - 1,
		})

		if #diagnostics == 0 then
			notify("No diagnostic under cursor", vim.log.levels.WARN)

			return
		end

		diagnostic = diagnostics[1]
	end

	local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local start_row = diagnostic.lnum

	local end_row = diagnostic.end_lnum or diagnostic.lnum

	local original_scope = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)

	get_lsp_hover_raw(buf, diagnostic, function(hover_results)
		local hover_json = vim.json.encode(hover_results)

		local diagnostics_json = vim.json.encode(all_diagnostic_summaries(buf))

		local prompt = table.concat({
			"MODE: DIAGNOSTIC FIX",

			"",
			"TARGET DIAGNOSTIC:",
			vim.json.encode(diagnostic_summary(diagnostic)),

			"",
			"RAW LSP HOVER RESPONSES:",
			"The following is the raw textDocument/hover response returned by the attached language servers at the diagnostic position.",
			"This is the underlying information Neovim uses for K.",
			hover_json,

			"",
			"ALL BUFFER DIAGNOSTICS:",
			diagnostics_json,

			"",
			"TARGET SOURCE SCOPE:",
			"Source lines " .. (start_row + 1) .. "-" .. (end_row + 1),

			"",
			"CURRENT TARGET SOURCE:",
			table.concat(original_scope, "\n"),

			"",
			code_context(buf),

			"",
			"DIAGNOSTIC FIX RULES:",
			"Determine the actual root cause.",
			"Use the target diagnostic.",
			"Use the complete raw LSP hover response.",
			"Use all buffer diagnostics.",
			"Use the complete source file.",
			"Use LSP type information and documentation when available.",
			"Do not blindly fix only the reported token.",
			"Make the smallest necessary fix.",
			"Do not modify unrelated code.",
			"Do not refactor working code.",
			"Do not invent APIs or dependencies.",

			"",
			"OUTPUT RULE:",
			"Return ONLY the replacement source for the target source scope.",
			"Return raw source only.",
			"Never return explanations.",
			"Never return markdown.",
			"Never return code fences.",
			"Never return surrounding source.",
			"Never return the complete file.",
			"Never repeat context.",
		}, "\n")

		M.ask(prompt, "diagnostic", function(result)
			local replacement, err = validate_response(result)

			if not replacement then
				notify(err or "Ollama returned empty source", vim.log.levels.ERROR)

				return
			end

			if vim.deep_equal(original_scope, replacement) then
				notify("Ollama made no changes", vim.log.levels.WARN)

				return
			end

			local proposed = {}

			for i = 1, start_row do
				proposed[#proposed + 1] = original[i]
			end

			for _, line in ipairs(replacement) do
				proposed[#proposed + 1] = line
			end

			for i = end_row + 2, #original do
				proposed[#proposed + 1] = original[i]
			end

			preview(buf, proposed)
		end)
	end)
end

local native_code_action = vim.lsp.buf.code_action

local function action_title(action)
	if action.title then
		return action.title
	end

	if action.command then
		if type(action.command) == "table" then
			return action.command.title or action.command.command or "Code Action"
		end

		return tostring(action.command)
	end

	return "Code Action"
end

local function apply_action(action, client_id)
	local client

	if client_id then
		client = vim.lsp.get_client_by_id(client_id)
	end

	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, client and client.offset_encoding or "utf-16")
	end

	if action.command then
		if type(action.command) == "table" then
			if client and client.exec_cmd then
				client:exec_cmd(action.command)
			else
				vim.lsp.buf.execute_command(action.command)
			end
		else
			vim.lsp.buf.execute_command({
				command = action.command,
			})
		end
	end
end

function M.code_action(opts)
	opts = opts or {}

	local buf = vim.api.nvim_get_current_buf()

	local win = vim.api.nvim_get_current_win()

	local clients = vim.lsp.get_clients({
		bufnr = buf,
		method = "textDocument/codeAction",
	})

	if #clients == 0 then
		return native_code_action(opts)
	end

	local diagnostics = opts.context and opts.context.diagnostics or vim.diagnostic.get(buf)

	local cursor_line = vim.api.nvim_win_get_cursor(win)[1] - 1

	local target_diagnostic

	for _, diagnostic in ipairs(diagnostics) do
		local start_line = diagnostic.lnum

		local end_line = diagnostic.end_lnum or diagnostic.lnum

		if cursor_line >= start_line and cursor_line <= end_line then
			target_diagnostic = diagnostic

			break
		end
	end

	local actions = {}
	local pending = #clients

	local function finish()
		pending = pending - 1

		if pending ~= 0 then
			return
		end

		if target_diagnostic then
			actions[#actions + 1] = {
				title = "AI: Fix with Ollama",
				ollama = true,
				diagnostic = target_diagnostic,
			}
		end

		if #actions == 0 then
			notify("No code actions available", vim.log.levels.WARN)

			return
		end

		vim.ui.select(actions, {
			prompt = "Code Action:",

			format_item = function(action)
				if action.ollama then
					return "AI: Fix with Ollama"
				end

				local title = action_title(action)

				if action.client_id then
					local client = vim.lsp.get_client_by_id(action.client_id)

					if client then
						return string.format("%s [%s]", title, client.name)
					end
				end

				return title
			end,
		}, function(action)
			if not action then
				return
			end

			if action.ollama then
				M.fix_diagnostic(action.diagnostic)

				return
			end

			apply_action(action, action.client_id)
		end)
	end

	for _, client in ipairs(clients) do
		local params = vim.lsp.util.make_range_params(win, client.offset_encoding)

		params.context = {
			diagnostics = diagnostics,
			triggerKind = opts.context and opts.context.triggerKind or 1,
		}

		if opts.only then
			params.context.only = opts.only
		elseif opts.context and opts.context.only then
			params.context.only = opts.context.only
		end

		client:request("textDocument/codeAction", params, function(err, result)
			if not err and result then
				for _, action in ipairs(result) do
					if not action.disabled then
						action.client_id = client.id

						actions[#actions + 1] = action
					end
				end
			end

			finish()
		end, buf)
	end
end

vim.lsp.buf.code_action = M.code_action

vim.keymap.set("v", "oe", M.edit, {
	desc = "Ollama edit selection",
})

vim.keymap.set("n", "og", M.generate, {
	desc = "Ollama generate after cursor",
})

vim.keymap.set("n", "om", M.select_model, {
	desc = "Ollama select model",
})

vim.defer_fn(function()
	M.models(false)
end, 500)

_G.Ollama = M

