class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
  });

  // convert Message object to Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
