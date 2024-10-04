import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerDialog extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String? mp3FilePath;
  final Function resetPlayer;

  const AudioPlayerDialog({
    super.key,
    required this.audioPlayer,
    required this.mp3FilePath,
    required this.resetPlayer,
  });

  @override
  _AudioPlayerDialogState createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog> {
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    widget.audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    widget.audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero; // Reset progress when complete
      });
    });
  }

  @override
  void dispose() {
    // Stop the player if it's still playing
    if (isPlaying) {
      widget.audioPlayer.stop();
    }
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return [
      if (hours > 0) twoDigits(hours),
      twoDigits(minutes),
      twoDigits(seconds),
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.resetPlayer(); // Reset player when dialog is closed
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      widget
                          .resetPlayer(); // Reset player when close button is pressed
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.blueAccent),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "lib/assets/images/news.jpg",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blueAccent.withOpacity(0.3),
                ),
                child: Slider(
                  min: 0,
                  max: totalDuration.inSeconds.toDouble(),
                  value: currentPosition.inSeconds.toDouble(),
                  onChanged: (value) async {
                    await widget.audioPlayer
                        .seek(Duration(seconds: value.toInt()));
                    setState(() {
                      currentPosition = Duration(seconds: value.toInt());
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(currentPosition),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      formatTime(totalDuration - currentPosition),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.blueAccent),
                    iconSize: 32,
                    onPressed: () {
                      final newPosition = currentPosition.inSeconds - 10;
                      if (newPosition >= 0) {
                        widget.audioPlayer.seek(Duration(seconds: newPosition));
                      }
                    },
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          await widget.audioPlayer.pause();
                        } else {
                          if (widget.mp3FilePath != null &&
                              File(widget.mp3FilePath!).existsSync()) {
                            await widget.audioPlayer
                                .play(DeviceFileSource(widget.mp3FilePath!));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No MP3 file available.')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.forward_10, color: Colors.blueAccent),
                    iconSize: 32,
                    onPressed: () {
                      final newPosition = currentPosition.inSeconds + 10;
                      if (newPosition <= totalDuration.inSeconds) {
                        widget.audioPlayer.seek(Duration(seconds: newPosition));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
