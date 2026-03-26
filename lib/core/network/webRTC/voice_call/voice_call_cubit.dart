import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxa/core/network/webRTC/voice_call/voice_call_repository.dart';

class CallCubit extends Cubit<String> {
  final VoiceCallRepository repo;

  CallCubit(this.repo) : super("idle");

  Future<void> startCall(String callId) async {
    await repo.initCall(callId);
    repo.listenForCandidates(callId);
    await repo.createOffer(callId);
    repo.listenForAnswer(callId);
    emit("calling");
  }

  Future<void> joinCall(String callId) async {
    await repo.initCall(callId);
    repo.listenForCandidates(callId);
    await repo.answerCall(callId);
    emit("connected");
  }
}
