import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/widgets/custom_video_player_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomVideoPlayer extends StatelessWidget {
  final String url;

  const CustomVideoPlayer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
        );
        return CustomVideoPlayerCubit(controller)..initialize();
      },
      child: BlocBuilder<CustomVideoPlayerCubit, CustomVideoPlayerState>(
        builder: (context, state) {
          final cubit = context.read<CustomVideoPlayerCubit>();
          if (state is CustomVideoPlayerError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.redAccent,
                ),
                Text(
                  "video_initialization_error".tr(),
                  style: Omnes.w400
                      .getStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ],
            );
          } else if (state is CustomVideoPlayerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomVideoPlayerInitialized) {
            return cubit.controller.value.isInitialized
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: GestureDetector(
                      onTap: () => _togglePlay(cubit.controller),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(cubit.controller),
                          _ControlsOverlay(controller: cubit.controller),
                        ],
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

void _togglePlay(VideoPlayerController controller) {
  if (controller.value.isPlaying) {
    controller.pause();
  } else {
    controller.play();
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (controller.value.isBuffering)
          const Positioned(
            top: 8,
            left: 8,
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          ),
        if (!controller.value.isPlaying)
          Center(
            child: IconButton.filled(
              onPressed: () => _togglePlay(controller),
              icon: const Icon(
                Icons.play_arrow,
              ),
              style: IconButton.styleFrom(
                elevation: 5,
                shadowColor: context.colorScheme.shadow,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: context.colorScheme.primary,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
