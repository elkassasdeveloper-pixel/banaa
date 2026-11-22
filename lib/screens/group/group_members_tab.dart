import 'package:educ_core/data/models/group_member.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/error_message_card.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/brand_colors.dart';
import 'package:educ_student/screens/group/group_members_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupMembersTab extends StatelessWidget {
  const GroupMembersTab({super.key});

  Color getModeratorColor(BuildContext context) => context.colorScheme.tertiary;

  Color getUserColor(BuildContext context) => context.colorScheme.primary;

  Color getColor(BuildContext context, bool isMod) {
    if (isMod) {
      return getModeratorColor(context);
    } else {
      return getUserColor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupMembersCubit, GroupMembersState>(
      listener: (context, state) {
        if (state is GroupMembersFollowError) {
          context.showFailureSnackBar(state.failure);
        }
      },
      builder: (context, state) {
        final cubit = context.read<GroupMembersCubit>();
        final members = cubit.filteredMembers;

        if (state is GroupMembersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GroupMembersError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ErrorMessageCard.failure(
              failure: state.failure,
              onRetry: cubit.fetch,
            ),
          );
        } else if (members.isEmpty) {
          return Center(child: Text("errors.empty_data".tr()));
        }

        return RefreshIndicator(
          onRefresh: cubit.fetch,
          child: ListView.separated(
            itemCount: members.length,
            padding: const EdgeInsets.only(top: 16.0, bottom: 64.0),
            itemBuilder: (context, index) {
              final member = members[index];
              final color = getColor(context, member.isModerator);
              return ListTile(
                minTileHeight: 40.0,
                minVerticalPadding: 0.0,
                leading: Container(
                  height: 40.0,
                  width: 40.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color:
                        (member.isModerator ? getModeratorColor(context) : BrandColors.primary1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (member.isModerator ? getModeratorColor(context) : BrandColors.primary1),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:Uri.encodeFull(member.avatarFileName),
                    memCacheWidth: 300,
                    imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                    errorWidget: (context, url, error) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                title: Text('${member.firstName} ${member.lastName}'),
                subtitle: !member.isModerator
                    ? null
                    : Row(
                      children: [
                        SvgPicture.asset(
                          Svgs.moderatorShield,
                          colorFilter: color.withValues(alpha: 0.8).toColorFilter(),
                          width: 16.0,
                          height: 16.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "moderator".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                titleTextStyle: Omnes.w700.getStyle(
                  color: color,
                  fontSize: 16,
                ),
                subtitleTextStyle: Omnes.w700.getStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
                trailing: _buildTrailing(context, member),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16.0);
            },
          ),
        );
      },
    );
  }

  Widget _buildTrailing(BuildContext context, GroupMember member) {
    final userColor = getUserColor(context);
    final moderatorColor = getModeratorColor(context);

    final cubit = context.read<GroupMembersCubit>();

    if (member.isModerator) {
      return FilledButton.icon(
        onPressed: () {},
        icon: SvgPicture.asset(
          Svgs.chat,
          colorFilter: moderatorColor.toColorFilter(),
          width: 18.0,
          height: 18.0,
        ),
        label: Text(
          'message'.tr(),
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(
          foregroundColor: moderatorColor,
          backgroundColor: moderatorColor.alphaBlend(
            context.colorScheme.surface,
            0.15,
          ),
          fixedSize: const Size(120, 40),
          padding: const EdgeInsets.all(8.0),
        ),
      );
    }
    /*else if (member.isRequesting) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(),
      );
    }*/
    else if (member.isFollowing) {
      return FilledButton.icon(
        onPressed: member.isRequesting ? null : () => cubit.unfollowUser(member.userId),
        icon: member.isRequesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(),
              )
            : SvgPicture.asset(
                Svgs.twoUsers,
                colorFilter: userColor.toColorFilter(),
                width: 18.0,
                height: 18.0,
              ),
        label: Text(
          'friend'.tr(),
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(
          foregroundColor: userColor,
          backgroundColor: userColor.alphaBlend(
            context.colorScheme.surface,
            0.15,
          ),
          fixedSize: const Size(120, 40),
          padding: const EdgeInsets.all(8.0),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: member.isRequesting ? null : () => cubit.followUser(member.userId),
        icon: member.isRequesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(),
              )
            : SvgPicture.asset(
                Svgs.addOutlined,
                colorFilter: userColor.toColorFilter(),
                width: 18.0,
                height: 18.0,
              ),
        label: Text(
          'add_friend'.tr(),
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: userColor),
          fixedSize: const Size(120, 40),
          padding: const EdgeInsets.all(8.0),
        ),
      );
    }
  }
}
