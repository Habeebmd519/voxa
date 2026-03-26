import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

RTCPeerConnection? peerConnection;
MediaStream? localStream;
String? currentCallId;
MediaStream? remoteStream;

class VoiceCallRepository {
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
    ],
  };
  //// PeerConnection
  Future<void> initCall(String callId) async {
    currentCallId = callId;
    peerConnection = await createPeerConnection(configuration);

    peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        FirebaseFirestore.instance
            .collection('calls')
            .doc(currentCallId) // you need to store this
            .collection('candidates')
            .add(candidate.toMap());
      }
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    peerConnection!.onTrack = (event) {
      remoteStream = event.streams[0];
      print("Remote stream attached");
    };
  }

  ////. Create Offer (Caller)

  Future<void> createOffer(String callId) async {
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    FirebaseFirestore.instance.collection('calls').doc(callId).set({
      'offer': offer.toMap(),
    });
  }

  ///Answer Call (Receiver)

  Future<void> answerCall(String callId) async {
    var doc = await FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .get();

    var data = doc.data();

    RTCSessionDescription offer = RTCSessionDescription(
      data!['offer']['sdp'],
      data['offer']['type'],
    );

    await peerConnection!.setRemoteDescription(offer);

    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'answer': answer.toMap(),
    });
  }

  /// Listen for Answer (Caller side)

  void listenForAnswer(String callId) {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.data() != null &&
              snapshot.data()!.containsKey('answer')) {
            var answer = snapshot['answer'];

            RTCSessionDescription desc = RTCSessionDescription(
              answer['sdp'],
              answer['type'],
            );

            peerConnection!.setRemoteDescription(desc);
          }
        });
  }

  ////listenForCandidates
  Set<String> addedCandidates = {};
  void listenForCandidates(String callId) {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            if (addedCandidates.contains(doc.id)) continue;
            addedCandidates.add(doc.id);
            var data = doc.data();
            RTCIceCandidate candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );

            peerConnection?.addCandidate(candidate);
          }
        });
  }
}
