import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

import 'custom_audio_player_cubit.dart';

class CustomAudioPlayer extends StatelessWidget {
  final String url;

  const CustomAudioPlayer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final player = AudioPlayer();
        final cubit = CustomAudioPlayerCubit(player);
        cubit.initialize(url);
        return cubit;
      },
      child: _AudioPlayerUI(),
    );
  }
}

class _AudioPlayerUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomAudioPlayerCubit>();
    final player = cubit.player;

    return BlocBuilder<CustomAudioPlayerCubit, CustomAudioPlayerState>(
      builder: (context, state) {
        if (state is CustomAudioPlayerError) {
          return const Icon(Icons.error, color: Colors.red);
        }

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = player.duration ?? Duration.zero;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      player.playing ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: cubit.togglePlayPause,
                  ),
                  Text(
                    "${_formatDuration(position)} / ${_formatDuration(duration)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),

                  // Icon(Icons.volume_up),
                  // const SizedBox(width: 8),
                  // Icon(Icons.more_vert),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    return DateFormat.ms().format(DateTime(0).add(d));
  }
}
