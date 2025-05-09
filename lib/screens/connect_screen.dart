import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '/services/nutrition_service.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  String _selectedRecipient = 'AI Bot';
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Listen for keyboard focus to scroll to bottom
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage({String? text, String? filePath, String? fileType}) async {
    if ((text?.trim().isEmpty ?? true) && filePath == null) return;

    final now = DateTime.now();
    final time = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _messages.add({
        'recipient': _selectedRecipient,
        'text': text,
        'filePath': filePath,
        'fileType': fileType,
        'time': time,
        'isSentByUser': true,
      });
    });

    _scrollToBottom();
    _messageController.clear();

    if (_selectedRecipient == 'AI Bot' && text != null) {
      setState(() {
        _isLoading = true;
      });

      final response = await NutritionService.searchFood(text.trim());

      setState(() {
        _isLoading = false;
        _messages.add({
          'recipient': 'AI Bot',
          'text': response,
          'time':
              "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          'isSentByUser': false,
        });
      });

      _scrollToBottom();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String fileType = result.files.single.extension ?? "unknown";
      _sendMessage(filePath: path, fileType: fileType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: DropdownButton<String>(
                value: _selectedRecipient,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRecipient = newValue!;
                  });
                },
                items:
                    ['AI Bot', 'Dietician']
                        .map(
                          (recipient) => DropdownMenuItem(
                            value: recipient,
                            child: Text(recipient),
                          ),
                        )
                        .toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text("Fetching data..."),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = _messages[index];
                  final isSentByUser = msg['isSentByUser'] as bool? ?? false;

                  return Align(
                    alignment:
                        isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isSentByUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Card(
                          color:
                              isSentByUser
                                  ? Colors.blue.shade100
                                  : Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment:
                                  isSentByUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                if (msg['text'] != null)
                                  Text(" ${msg['text']}"),
                                if (msg['filePath'] != null)
                                  Text("📎 Sent a ${msg['fileType']} file"),
                              ],
                            ),
                          ),
                        ),
                        if (!isSentByUser)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              msg['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            _buildMessageInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey, size: 24),
              onPressed: _pickFile,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: value.text.isEmpty ? Colors.grey : Colors.green,
                    size: 26,
                  ),
                  onPressed:
                      value.text.isEmpty
                          ? null
                          : () {
                            _sendMessage(text: value.text);
                            _messageController.clear();
                          },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
