import 'package:freezed_annotation/freezed_annotation.dart';

part 'last_message.freezed.dart';
part 'last_message.g.dart';

@freezed
class LastMessage with _$LastMessage {
  factory LastMessage({
    required String content,
    required String idFrom,
    required String idTo,
    required String type,
    required int createdAt,
  }) = _LastMessage;

  factory LastMessage.fromJson(Map<String, dynamic> json) =>
      _$LastMessageFromJson(json);
}
