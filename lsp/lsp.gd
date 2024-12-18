extends Node

var _socket = null
var _server_address = "localhost:5050"
var _lsp_pid: int;

func _ready():
	_lsp_pid = OS.execute("lsp/lua-language-server-3.13.4-win32-x64/bin/lua-language-server.exe", ['--socket5050 --force-accept-workspace'], false);
	_socket = StreamPeerTCP.new()
	_socket.connect_to_host("localhost", 5050)
	if (!_socket.is_connected_to_host()):
		print("connection failed")
	else:
		print("connected to host!")

func _process(_delta):
	if _socket.is_connected_to_host():
		var data = _socket.get_available_bytes()
		if data:
			var json = parse_json(data)
			if json:
				handle_lsp_message(json)

func handle_lsp_message(message):
	match message["method"]:
		"textDocument/didOpen":
			# Handle didOpen notification
			print("Document opened: ", message["params"]["textDocument"]["uri"])
		"textDocument/didChange":
			# Handle didChange notification
			print("Document changed: ", message["params"]["textDocument"]["uri"])
		"textDocument/completion":
			# Handle completion request
			print("Completion request: ", message["params"]["textDocument"]["uri"])
			# Send completion response
			var response = {
				"jsonrpc": "2.0",
				"id": message["id"],
				"result": [
					{"label": "Hello", "kind": 1},
					{"label": "World", "kind": 1}
				]
			}
			_socket.put_data(to_json(response))
		_:
			print("Unknown method: ", message["method"])

func send_lsp_request(method, params):
	var request = {
		"jsonrpc": "2.0",
		"method": method,
		"params": params,
		"id": 1
	}
	_socket.put_data(to_json(request))

func _exit_tree():
	_socket.disconnect_from_host()
	OS.kill(_lsp_pid);
