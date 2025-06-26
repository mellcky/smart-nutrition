// connect_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/gemini_service.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final ImagePicker _imagePicker = ImagePicker();

  // Voice recording
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderInitialized = false;
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _recordingStartTime;

  // Scroll to bottom button
  bool _showScrollToBottomButton = false;

  String _selectedRecipient = 'Nutrition AI';
  bool _isTyping = false;

  final Map<String, List<ChatMessage>> _chatHistories = {
    'Nutrition AI': [],
    'Dietician': [],
  };

  // Store conversation history for Gemini
  final Map<String, List<Map<String, dynamic>>> _conversationHistories = {
    'Nutrition AI': [],
    'Dietician': [],
  };

  List<ChatMessage> get _messages => _chatHistories[_selectedRecipient]!;

  @override
  void initState() {
    super.initState();
    _initRecorder();

    // Add scroll listener to detect when user scrolls up
    _scrollController.addListener(_scrollListener);

    // Scroll to bottom when chat is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollListener() {
    // Show scroll to bottom button when not at the bottom
    if (_scrollController.hasClients) {
      final isAtBottom =
          _scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent - 50); // 50px threshold

      if (isAtBottom != !_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = !isAtBottom;
        });
      }
    }
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    _recorderInitialized = true;
    setState(() {});
  }

  @override
  void dispose() {
    // Remove scroll listener before disposing the controller
    _scrollController.removeListener(_scrollListener);

    _messageController.dispose();
    _scrollController.dispose();

    // Close the recorder
    if (_recorderInitialized) {
      _recorder.closeRecorder();
    }

    super.dispose();
  }

  void _scrollToBottom() {
    // Ensure this runs after the frame is rendered and layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // First jump to end without animation for immediate response
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

        // Then animate for a smooth finish
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 300,
          ), // Slightly longer for smoother animation
          curve: Curves.easeOutQuart, // Smoother curve
        );
      }
    });
  }

  Future<void> _sendMessage({
    String? text,
    File? imageFile,
    String? voiceFilePath,
    Duration? voiceDuration,
  }) async {
    // At least one of text, imageFile, or voiceFilePath must be provided
    if ((text == null || text.trim().isEmpty) &&
        imageFile == null &&
        voiceFilePath == null) {
      return;
    }

    final trimmedText = text?.trim() ?? '';

    // Create a unique ID for this message
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    // Determine message type
    MessageType messageType = MessageType.text;
    if (imageFile != null) {
      messageType = MessageType.image;
    } else if (voiceFilePath != null) {
      messageType = MessageType.voice;
    }

    final message = ChatMessage(
      id: messageId,
      text: trimmedText,
      isSentByUser: true,
      time: DateTime.now(),
      messageType: messageType,
      imageUrl: imageFile?.path,
      voiceUrl: voiceFilePath,
      voiceDuration: voiceDuration,
    );

    // Batch state updates to reduce rebuilds
    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    // Scroll after adding the message
    _scrollToBottom();

    if (_selectedRecipient == 'Nutrition AI') {
      // Set typing indicator
      setState(() => _isTyping = true);

      try {
        // Add user message to conversation history
        _conversationHistories[_selectedRecipient]?.add({
          'role': 'user',
          'content': trimmedText,
        });

        String response;
        if (messageType == MessageType.image && imageFile != null) {
          // For image messages, include both image and text
          response = await GeminiService.handleNutritionQuery(
            trimmedText.isNotEmpty ? trimmedText : "What's in this image?",
            _conversationHistories[_selectedRecipient]!,
          );
        } else {
          response = await GeminiService.handleNutritionQuery(
            trimmedText,
            _conversationHistories[_selectedRecipient]!,
          );
        }

        // Add AI response to conversation history
        _conversationHistories[_selectedRecipient]?.add({
          'role': 'assistant',
          'content': response,
        });

        // Only update state if the widget is still mounted
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: '${messageId}_response',
                text: response,
                isSentByUser: false,
                time: DateTime.now(),
              ),
            );
          });
          // Scroll after response is added
          _scrollToBottom();
        }
      } catch (e) {
        // Only update state if the widget is still mounted
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: '${messageId}_error',
                text:
                    "Sorry, I couldn't process your question. / Samahani, sikuweza kuchakata swali lako. Tafadhali jaribu tena.",
                isSentByUser: false,
                time: DateTime.now(),
              ),
            );
          });
          // Scroll after error message is added
          _scrollToBottom();
        }
      }
    } else if (_selectedRecipient == 'Dietician') {
      // Simulate network delay
      await Future.delayed(
        const Duration(milliseconds: 400),
      ); // Reduced delay for better UX

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: '${messageId}_response',
              text:
                  'Thank you for your message. A registered dietician will review it and respond shortly. 👩‍⚕️',
              isSentByUser: false,
              time: DateTime.now(),
            ),
          );
        });
        // Scroll after response is added
        _scrollToBottom();
      }
    }
  }

  // Image picking methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Reduce image quality to save space
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        _sendMessage(imageFile: imageFile, text: _messageController.text);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Voice recording methods
  Future<void> _startRecording() async {
    if (!_recorderInitialized) return;

    // Get the temporary directory
    final Directory tempDir = await getTemporaryDirectory();
    _recordingPath =
        '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _recordingPath, codec: Codec.aacADTS);

    _recordingStartTime = DateTime.now();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_recorderInitialized || !_isRecording) return;

    await _recorder.stopRecorder();

    final now = DateTime.now();
    final duration = now.difference(_recordingStartTime!);

    setState(() {
      _isRecording = false;
    });

    if (_recordingPath != null) {
      _sendMessage(voiceFilePath: _recordingPath, voiceDuration: duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add floating action button for scrolling to bottom
      floatingActionButton:
          _showScrollToBottomButton
              ? FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                onPressed: _scrollToBottom,
                child: Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
              : null,
      body: Column(
        children: [
          _buildRecipientSelector(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface.withOpacity(0.4),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TypingIndicator(),
                      ),
                    );
                  }

                  final message = _messages[index];
                  // Use message id as key for efficient list rendering
                  return Padding(
                    key: ValueKey(message.id),
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildMessageBubble(message),
                  );
                },
                // Ensure messages overlay down properly
                reverse: false,
                // Add physics for better scrolling performance
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // Add cacheExtent to improve performance
                cacheExtent: 100.0,
                // Add clipBehavior for better performance
                clipBehavior: Clip.hardEdge,
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // Cache the segments for better performance
  static const _segments = [
    ButtonSegment(value: 'Nutrition AI', label: Text('AI bot')),
    ButtonSegment(value: 'Dietician', label: Text('Dietician')),
  ];

  Widget _buildRecipientSelector() {
    // Use RepaintBoundary to optimize rendering
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 230,
            child: SegmentedButton<String>(
              segments: _segments,
              selected: {_selectedRecipient},
              // Optimize selection change
              onSelectionChanged: (Set<String> newSelection) {
                if (newSelection.first != _selectedRecipient) {
                  setState(() {
                    _selectedRecipient = newSelection.first;
                  });
                  // Ensure messages are properly displayed after switching
                  _scrollToBottom();
                }
              },
              // Add style for better performance
              style: ButtonStyle(
                // Use MaterialStateProperty.all for better performance
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSentByUser = message.isSentByUser;
    final time = _timeFormat.format(message.time);

    // Create a cached bubble style for better performance
    final bubbleDecoration = BoxDecoration(
      color:
          isSentByUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft:
            isSentByUser ? const Radius.circular(20) : const Radius.circular(4),
        bottomRight:
            isSentByUser ? const Radius.circular(4) : const Radius.circular(20),
      ),
    );

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color:
          isSentByUser
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final timeStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 10,
      fontWeight: FontWeight.w300,
    );

    // Use RepaintBoundary to optimize rendering
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment:
              isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: bubbleDecoration,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(message, textStyle),
                    const SizedBox(height: 4),
                    Text(time, style: timeStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, TextStyle? textStyle) {
    switch (message.messageType) {
      case MessageType.text:
        return Text(message.text ?? '', style: textStyle);
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null && message.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(message.text!, style: textStyle),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.imageUrl!),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: textStyle?.color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (message.voiceDuration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${message.voiceDuration!.inMinutes}:${(message.voiceDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: textStyle?.copyWith(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }

  // Cached decorations and styles for better performance
  late final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide.none,
  );

  late final _contentPadding = const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 1,
  );

  Widget _buildInputArea() {
    // Use RepaintBoundary to optimize rendering
    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Main input area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Text input field with camera and gallery buttons inside
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      // Optimize text field for better performance
                      decoration: InputDecoration(
                        hintText:
                            _selectedRecipient == 'Nutrition AI'
                                ? 'Ask about nutrition in English or Swahili...'
                                : 'Type your message...',
                        helperText:
                            _selectedRecipient == 'Nutrition AI'
                                ? 'Unaweza kuuliza kwa Kiswahili pia (You can ask in Swahili too)'
                                : null,
                        helperStyle: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        border: _inputBorder,
                        enabledBorder: _inputBorder,
                        focusedBorder: _inputBorder,
                        contentPadding: _contentPadding,
                        // Add camera button inside the text field (left side)
                        prefixIcon: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _pickImage(ImageSource.camera),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        // Add gallery button inside the text field (right side)
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.photo,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                      // Optimize text input
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.text,
                      onSubmitted: (text) => _sendMessage(text: text),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (_, value, __) {
                      final bool isEnabled = value.text.trim().isNotEmpty;
                      return IconButton(
                        icon: Icon(
                          Icons.send,
                          color:
                              isEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade500,
                        ),
                        // Optimize touch target
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed:
                            isEnabled
                                ? () => _sendMessage(text: value.text.trim())
                                : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MessageType { text, image, voice }

class ChatMessage {
  final String id;
  final String? text;
  final bool isSentByUser;
  final DateTime time;
  final MessageType messageType;
  final String? imageUrl;
  final String? voiceUrl;
  final Duration? voiceDuration;

  const ChatMessage({
    required this.id,
    this.text,
    required this.isSentByUser,
    required this.time,
    this.messageType = MessageType.text,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
  });
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to optimize animation rendering
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            // Use const for children that don't change
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Dot(key: ValueKey('dot1')),
                Dot(key: ValueKey('dot2'), delay: 100),
                Dot(key: ValueKey('dot3'), delay: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatefulWidget {
  final int delay;
  const Dot({super.key, this.delay = 0});

  @override
  State<Dot> createState() => _DotState();
}

class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // Cache the decoration for better performance
  late final BoxDecoration _dotDecoration;

  @override
  void initState() {
    super.initState();
    // Optimize animation controller
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ), // Slightly faster for better performance
      vsync: this,
    );

    // Use a more efficient curve
    _animation = Tween<double>(
      begin: 4,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Cache the decoration
    _dotDecoration = BoxDecoration(
      color: Colors.grey.shade700,
      borderRadius: BorderRadius.circular(3),
    );

    // Start animation with delay
    if (widget.delay > 0) {
      Future.microtask(() {
        Future.delayed(Duration(milliseconds: widget.delay), () {
          if (mounted) {
            _controller.repeat(reverse: true);
          }
        });
      });
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      // Use a more efficient builder pattern
      builder: (_, __) {
        return SizedBox(
          width: 6,
          height: _animation.value,
          child: DecoratedBox(decoration: _dotDecoration),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
