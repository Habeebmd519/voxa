import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synapse/feature/Drop/pressantation/bloc/filterCubit.dart';
import 'package:synapse/feature/Drop/pressantation/bloc/timeLineState.dart';
import 'package:synapse/feature/Drop/pressantation/modes/dropModel.dart';

class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit() : super(TimelineLoading());

  List<DropModel> _allDrops = [];
  DropFilter currentFilter = DropFilter.all;
  void fetchDrops() {
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          _allDrops = snapshot.docs.map((doc) {
            final data = doc.data();

            return DropModel(
              id: doc.id,
              userId: data['userId'] ?? '',
              userName: data['userName'] ?? '',
              userEmail: data['userEmail'] ?? '',
              userAvatar: data['userAvatar'] ?? '',
              text: data['text'] ?? '',
              createdAt: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              likeCount: data['likeCount'] ?? 0,

              /// 🔥 ADD THIS LINE (THIS FIXES EVERYTHING)
              likedBy: List<String>.from(data['likedBy'] ?? []),
            );
          }).toList();

          emit(TimelineLoaded(_allDrops));
        });
  }

  void applyFilter(DropFilter filter, String myId, List<String> friendIds) {
    currentFilter = filter;

    List<DropModel> filtered;

    switch (filter) {
      case DropFilter.friends:
        filtered = _allDrops
            .where((d) => friendIds.contains(d.userId))
            .toList();
        break;

      case DropFilter.mine:
        filtered = _allDrops.where((d) => d.userId == myId).toList();
        break;

      case DropFilter.all:
        filtered = _allDrops;
        break;
    }

    emit(TimelineLoaded(filtered));
  }
}
