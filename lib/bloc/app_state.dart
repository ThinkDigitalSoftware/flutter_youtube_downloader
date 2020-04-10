part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}

class VideoDetailsState extends AppState {
  final Video video;
  final MediaStreamInfoSet mediaStreamInfoSet;

  VideoDetailsState({@required this.video, @required this.mediaStreamInfoSet});
}
