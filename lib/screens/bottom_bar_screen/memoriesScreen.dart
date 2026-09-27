import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/controllers/memories_controller.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/screens/FullScreenMediaViewer.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:lottie/lottie.dart';

class Memoriesscreen extends StatelessWidget {
  const Memoriesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MemoriesController controller = Get.put(MemoriesController());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text(
              "Memory Recaps",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Obx(
            () {
              if (controller.isGenerating.value) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF81D4FA),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF0288D1),
                ),
                tooltip: "Custom Memory Recap",
                onPressed: () => _showCustomRecapModal(context, controller),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Colors.white,
              Color(0xFFFCE4EC),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: controller.refreshMemories,
          child: Obx(
            () {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value
                              .replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81D4FA),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          onPressed: controller.refreshMemories,
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final memories = controller.memories;

              if (memories.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildTopGeneratorCard(context, controller),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animation/empty.json',
                            width: 220,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "No Memory Recaps Yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Create Google Photos style recap videos from your child's moments!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0288D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text(
                              "Create First Memory Recap",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () =>
                                _showCustomRecapModal(context, controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: memories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopGeneratorCard(context, controller);
                  }

                  final memory = memories[index - 1];
                  final status = (memory.status ?? '').toLowerCase();

                  if (status == 'processing' || status == 'generating') {
                    return _buildProcessingCard(context, memory, controller);
                  }

                  return _buildMemoryCard(context, memory, controller);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================
  // TOP GENERATOR CARD
  // ============================================

  Widget _buildTopGeneratorCard(
    BuildContext context,
    MemoriesController controller,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1F5FE), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF81D4FA).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF81D4FA).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF0288D1),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Memory Recap Engine ✨",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Google Photos style AI memory video generator",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0288D1),
                    side: const BorderSide(color: Color(0xFF81D4FA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text(
                    "Quick Recap",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: controller.isGenerating.value
                      ? null
                      : () => controller.generateMemory(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text(
                    "Custom Recap",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: controller.isGenerating.value
                      ? null
                      : () => _showCustomRecapModal(context, controller),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // REAL-TIME PROCESSING CARD (POLLING 0% - 100%)
  // ============================================

  Widget _buildProcessingCard(
    BuildContext context,
    Memories memory,
    MemoriesController controller,
  ) {
    final progress = memory.progress ?? 5;
    final statusMessage = memory.statusMessage?.isNotEmpty == true
        ? memory.statusMessage!
        : 'Creating your memory recap...';

    final musicBadge = _musicCategoryBadge(
      memory.musicCategory,
      songTitle: memory.songTitle,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.amber.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Memory Recap",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            musicBadge,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$progress%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Obx(() {
                final isDel = controller.deletingMemoryId.value ==
                    (memory.recapId ?? memory.id);
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: isDel
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black45,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.xmark_circle,
                          size: 20,
                          color: Colors.black38,
                        ),
                  tooltip: "Cancel / Delete",
                  onPressed: isDel
                      ? null
                      : () => _confirmAndDeleteMemory(
                            context,
                            memory,
                            controller,
                          ),
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Status message step
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusMessage,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100.0,
              minHeight: 8,
              backgroundColor: Colors.amber.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                musicBadge,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const Text(
                "Updating in real-time...",
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // COMPLETED / FAILED MEMORY CARD
  // ============================================

  Widget _buildMemoryCard(
    BuildContext context,
    Memories memory,
    MemoriesController controller,
  ) {
    final mediaUrl = memory.thumbnailUrl?.isNotEmpty == true
        ? memory.thumbnailUrl!
        : (memory.videoUrl ?? '');

    final createdAt = DateTime.tryParse(memory.createdAt ?? '');
    final formattedDate = createdAt != null
        ? DateFormat('dd MMM, yyyy').format(createdAt)
        : 'Recently';

    final title = memory.title?.isNotEmpty == true
        ? memory.title!
        : (memory.songTitle?.isNotEmpty == true
            ? "Memory Recap • ${memory.songTitle}"
            : (memory.musicCategory?.isNotEmpty == true
                ? "${_musicCategoryBadge(memory.musicCategory)} Recap"
                : (memory.id != null
                    ? 'Memory Recap #${memory.id}'
                    : 'Memory Recap')));

    final status = (memory.status ?? 'ready').toLowerCase();
    final isReady = status == 'completed' ||
        status == 'ready' ||
        (memory.videoUrl != null && memory.videoUrl!.isNotEmpty);
    final isFailed = status == 'failed';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media / Video Preview
          Stack(
            children: [
              if (mediaUrl.isNotEmpty)
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: SmartMediaWidget(
                    mediaPath: mediaUrl,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 210,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFailed
                          ? [Colors.red.shade100, Colors.red.shade50]
                          : [
                              const Color(0xFFB4DCF1),
                              const Color(0xFFF1C6D4)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isFailed
                          ? Icons.error_outline_rounded
                          : Icons.movie_filter_outlined,
                      size: 64,
                      color: isFailed ? Colors.redAccent : Colors.white70,
                    ),
                  ),
                ),

              // Play button overlay if video is available
              if (memory.videoUrl != null &&
                  memory.videoUrl!.isNotEmpty &&
                  isReady)
                Positioned.fill(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _playVideo(context, memory.videoUrl!),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(14),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),

              // Badges overlay top left (Duration & Count)
              if (isReady)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      if (memory.durationSeconds != null) ...[
                        _buildGlassChip(
                          icon: Icons.timer_outlined,
                          text: "${memory.durationSeconds}s",
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (memory.memoriesCount != null)
                        _buildGlassChip(
                          icon: Icons.collections_outlined,
                          text: "${memory.memoriesCount} moments",
                        ),
                    ],
                  ),
                ),

              // Status badge on top right
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(status, isFailed),
              ),
            ],
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      tooltip: "Recap Details",
                      onPressed: () => _showMemoryDetails(
                        context,
                        memory,
                        controller,
                      ),
                    ),
                    Obx(() {
                      final isDel = controller.deletingMemoryId.value ==
                          (memory.recapId ?? memory.id);
                      return IconButton(
                        icon: isDel
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(
                                CupertinoIcons.trash,
                                size: 19,
                                color: Colors.black45,
                              ),
                        tooltip: "Delete Recap",
                        onPressed: isDel
                            ? null
                            : () => _confirmAndDeleteMemory(
                                  context,
                                  memory,
                                  controller,
                                ),
                      );
                    }),
                  ],
                ),


                if (memory.description != null &&
                    memory.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    memory.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13.5,
                    ),
                  ),
                ],

                if (isFailed) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            memory.errorMessage ??
                                memory.statusMessage ??
                                "Failed to generate recap video",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                color: Color(0xFFF48FB1),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          if (memory.musicCategory?.isNotEmpty == true ||
                              memory.mood?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _musicCategoryBadge(
                                  memory.musicCategory ?? memory.mood,
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isReady &&
                        memory.videoUrl != null &&
                        memory.videoUrl!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() {
                            final isSharing = controller.sharingMemoryId.value ==
                                (memory.recapId ?? memory.id);
                            return OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0288D1),
                                side: const BorderSide(
                                  color: Color(0xFF81D4FA),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: isSharing
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0288D1),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.share_rounded,
                                      size: 16,
                                    ),
                              label: Text(
                                isSharing ? "Sharing..." : "Share",
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: isSharing
                                  ? null
                                  : () => controller.shareMemory(
                                        context,
                                        memory,
                                      ),
                            );
                          }),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0288D1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 16,
                            ),
                            label: const Text(
                              "Watch",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () =>
                                _playVideo(context, memory.videoUrl!),
                          ),
                        ],
                      ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATUS BADGE
  // ============================================

  Widget _buildStatusBadge(String status, bool isFailed) {
    Color bg;
    Color fg;
    String label;

    if (isFailed) {
      bg = Colors.redAccent;
      fg = Colors.white;
      label = "Failed";
    } else {
      bg = Colors.green.shade600;
      fg = Colors.white;
      label = "Ready";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================
  // CUSTOM RECAP GENERATION MODAL SHEET
  // ============================================

  void _showCustomRecapModal(
    BuildContext context,
    MemoriesController controller,
  ) async {
    DateTime? startDate;
    DateTime? endDate;
    String selectedCategory = "calm";
    MusicTrack? selectedSong;
    String selectedTheme = "classic";
    double maxMemories = 40;
    bool isDropdownOpen = false;

    // Fetch initial tracks for default category
    controller.stopTrackPreview();
    controller.fetchMusicCatalog(category: selectedCategory);

    final List<Map<String, String>> categories = [
      {"key": "calm", "label": "🌿 Calm"},
      {"key": "happy", "label": "☀️ Happy"},
      {"key": "emotional", "label": "🥹 Emotional"},
      {"key": "childhood", "label": "🧸 Childhood"},
      {"key": "celebration", "label": "🎉 Celebration"},
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF0288D1),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Custom Memory Recap",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Generate a personalized recap highlight video with background music.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 18),

                    // Date Range Pickers (Start Date & End Date)
                    const Text(
                      "Date Range",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setStateModal(() => startDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Color(0xFF0288D1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    startDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(startDate!)
                                        : "Start Date",
                                    style: TextStyle(
                                      color: startDate != null
                                          ? Colors.black87
                                          : Colors.black45,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setStateModal(() => endDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 16,
                                    color: Color(0xFF0288D1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    endDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(endDate!)
                                        : "End Date",
                                    style: TextStyle(
                                      color: endDate != null
                                          ? Colors.black87
                                          : Colors.black45,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Music Category Selector
                    const Text(
                      "Background Music Category",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSel = selectedCategory == cat["key"];
                        return ChoiceChip(
                          label: Text(cat["label"]!),
                          selected: isSel,
                          selectedColor: const Color(0xFF81D4FA),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black87 : Colors.black54,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              controller.stopTrackPreview();
                              setStateModal(() {
                                selectedCategory = cat["key"]!;
                                selectedSong = null;
                                isDropdownOpen = false;
                              });
                              controller.fetchMusicCatalog(
                                category: selectedCategory,
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Matching UI Track Selection Dropdown with Instagram-style Audio Preview
                    Obx(() {
                      final filteredTracks = controller.musicTracks
                          .where((t) =>
                              t.category.trim().isEmpty ||
                              t.category.toLowerCase() ==
                                  selectedCategory.toLowerCase())
                          .toList();
                      final tracks = filteredTracks.isNotEmpty
                          ? filteredTracks
                          : controller.musicTracks.toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.library_music_rounded,
                                    size: 16,
                                    color: Color(0xFF0288D1),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Select Track (Optional)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedSong != null)
                                InkWell(
                                  onTap: () {
                                    controller.stopTrackPreview();
                                    setStateModal(() {
                                      selectedSong = null;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      "Reset to Auto",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF0288D1),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (controller.isLoadingMusic.value)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0288D1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Loading sound tracks...",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (tracks.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "✨ Auto (Studio curated default for this mood)",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dropdown Header Button
                                InkWell(
                                  onTap: () {
                                    setStateModal(() {
                                      isDropdownOpen = !isDropdownOpen;
                                    });
                                  },
                                  borderRadius: isDropdownOpen
                                      ? const BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        )
                                      : BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDropdownOpen
                                          ? const Color(0xFFF1F9FE)
                                          : Colors.white,
                                      borderRadius: isDropdownOpen
                                          ? const BorderRadius.vertical(
                                              top: Radius.circular(14),
                                            )
                                          : BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDropdownOpen
                                            ? const Color(0xFF0288D1)
                                            : const Color(0xFFB3E5FC),
                                        width: isDropdownOpen ? 1.5 : 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0288D1)
                                              .withValues(alpha: 0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Left Icon Avatar
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: selectedSong != null
                                                  ? [
                                                      const Color(0xFF81D4FA),
                                                      const Color(0xFF0288D1),
                                                    ]
                                                  : [
                                                      const Color(0xFFFFE082),
                                                      const Color(0xFFFFB300),
                                                    ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            selectedSong != null
                                                ? Icons.music_note_rounded
                                                : Icons.auto_awesome_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Track title & info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedSong != null
                                                    ? selectedSong!.title
                                                    : "✨ Auto (Studio curated default)",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                selectedSong != null
                                                    ? "${selectedSong!.artist}${selectedSong!.durationSeconds != null ? " • ${selectedSong!.durationSeconds!.round()}s" : ""}"
                                                    : "Picks the best background sound for you",
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Inline Play / Pause Preview Button if a track is selected
                                        if (selectedSong != null) ...[
                                          Obx(() {
                                            final isPlaying =
                                                controller.playingTrackId.value ==
                                                        selectedSong!.id &&
                                                    controller.isPreviewPlaying.value;
                                            final isBuffering =
                                                controller.playingTrackId.value ==
                                                        selectedSong!.id &&
                                                    controller.isPreviewBuffering.value;

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isPlaying) ...[
                                                  const InstagramEqualizerBars(
                                                    color: Color(0xFF0288D1),
                                                    height: 14,
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                InkWell(
                                                  onTap: () =>
                                                      controller.toggleTrackPreview(
                                                    selectedSong!,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: isPlaying
                                                          ? const Color(0xFF0288D1)
                                                          : const Color(0xFFE1F5FE),
                                                      shape: BoxShape.circle,
                                                      boxShadow: isPlaying
                                                          ? [
                                                              BoxShadow(
                                                                color: const Color(0xFF0288D1)
                                                                    .withValues(
                                                                        alpha: 0.35),
                                                                blurRadius: 6,
                                                                offset: const Offset(
                                                                    0, 2),
                                                              )
                                                            ]
                                                          : [],
                                                    ),
                                                    child: isBuffering
                                                        ? const Center(
                                                            child: SizedBox(
                                                              width: 14,
                                                              height: 14,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<Color>(
                                                                  Color(0xFF0288D1),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Icon(
                                                            isPlaying
                                                                ? Icons.pause_rounded
                                                                : Icons.play_arrow_rounded,
                                                            color: isPlaying
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF0288D1),
                                                            size: 20,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                              ],
                                            );
                                          }),
                                        ],

                                        // Dropdown Chevron Indicator
                                        AnimatedRotation(
                                          turns: isDropdownOpen ? 0.5 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(0xFF0288D1),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dropdown Menu (Opened state)
                                if (isDropdownOpen)
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        bottom: Radius.circular(14),
                                      ),
                                      border: const Border(
                                        left: BorderSide(
                                          color: Color(0xFF0288D1),
                                          width: 1.5,
                                        ),
                                        right: BorderSide(
                                          color: Color(0xFF0288D1),
                                          width: 1.5,
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFF0288D1),
                                          width: 1.5,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0288D1)
                                              .withValues(alpha: 0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        itemCount: tracks.length + 1,
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          thickness: 0.8,
                                          color: Colors.grey.shade100,
                                          indent: 52,
                                        ),
                                        itemBuilder: (context, idx) {
                                          // Option 0: Auto
                                          if (idx == 0) {
                                            final isSelected =
                                                selectedSong == null;
                                            return InkWell(
                                              onTap: () {
                                                controller.stopTrackPreview();
                                                setStateModal(() {
                                                  selectedSong = null;
                                                  isDropdownOpen = false;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFFFFF8E1)
                                                            : Colors
                                                                .grey.shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .auto_awesome_rounded,
                                                        color: isSelected
                                                            ? Colors
                                                                .amber.shade800
                                                            : Colors.black45,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "✨ Auto (Studio curated default)",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            "Recommended background score",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      const Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color:
                                                            Color(0xFF0288D1),
                                                        size: 20,
                                                      )
                                                    else
                                                      Icon(
                                                        Icons.circle_outlined,
                                                        color: Colors
                                                            .grey.shade300,
                                                        size: 20,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          final track = tracks[idx - 1];
                                          final isSelected =
                                              selectedSong?.id == track.id;

                                          return InkWell(
                                            onTap: () {
                                              setStateModal(() {
                                                selectedSong = track;
                                                isDropdownOpen = false;
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Instagram-style Play / Pause Button
                                                  Obx(() {
                                                    final isPlaying = controller
                                                                .playingTrackId
                                                                .value ==
                                                            track.id &&
                                                        controller
                                                            .isPreviewPlaying
                                                            .value;
                                                    final isBuffering =
                                                        controller
                                                                .playingTrackId
                                                                .value ==
                                                            track.id &&
                                                        controller
                                                            .isPreviewBuffering
                                                            .value;

                                                    return InkWell(
                                                      onTap: () => controller
                                                          .toggleTrackPreview(
                                                              track),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      child: Container(
                                                        width: 36,
                                                        height: 36,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isPlaying
                                                              ? const Color(
                                                                  0xFF0288D1)
                                                              : const Color(
                                                                  0xFFE1F5FE),
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: isPlaying
                                                              ? [
                                                                  BoxShadow(
                                                                    color: const Color(
                                                                            0xFF0288D1)
                                                                        .withValues(
                                                                            alpha:
                                                                                0.35),
                                                                    blurRadius:
                                                                        6,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  )
                                                                ]
                                                              : [],
                                                        ),
                                                        child: isBuffering
                                                            ? const Center(
                                                                child: SizedBox(
                                                                  width: 14,
                                                                  height: 14,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                            Color>(
                                                                      Color(
                                                                          0xFF0288D1),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Icon(
                                                                isPlaying
                                                                    ? Icons
                                                                        .pause_rounded
                                                                    : Icons
                                                                        .play_arrow_rounded,
                                                                color: isPlaying
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xFF0288D1),
                                                                size: 20,
                                                            ),
                                                      ),
                                                    );
                                                  }),
                                                  const SizedBox(width: 12),

                                                  // Track details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          track.title,
                                                          style: TextStyle(
                                                            fontWeight: isSelected
                                                                ? FontWeight.bold
                                                                : FontWeight.w600,
                                                            fontSize: 13,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF0288D1)
                                                                : Colors.black87,
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "${track.artist}${track.durationSeconds != null ? " • ${track.durationSeconds!.round()}s" : ""}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Obx(() {
                                                              final isPlaying =
                                                                  controller
                                                                          .playingTrackId
                                                                          .value ==
                                                                      track.id &&
                                                                  controller
                                                                      .isPreviewPlaying
                                                                      .value;
                                                              if (isPlaying) {
                                                                return const Padding(
                                                                  padding:
                                                                      EdgeInsets.only(
                                                                          left:
                                                                              6.0),
                                                                  child:
                                                                      InstagramEqualizerBars(
                                                                    color: Color(
                                                                        0xFF0288D1),
                                                                    height: 12,
                                                                  ),
                                                                );
                                                              }
                                                              return const SizedBox
                                                                  .shrink();
                                                            }),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),

                                                  // Radio checkmark
                                                  if (isSelected)
                                                    const Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Color(0xFF0288D1),
                                                      size: 20,
                                                    )
                                                  else
                                                    Icon(
                                                      Icons.circle_outlined,
                                                      color:
                                                          Colors.grey.shade300,
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // Maximum Memories Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Max Memories Limit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${maxMemories.round()} moments",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: maxMemories,
                      min: 10,
                      max: 100,
                      divisions: 18,
                      activeColor: const Color(0xFF0288D1),
                      inactiveColor: Colors.blue.shade50,
                      onChanged: (val) {
                        setStateModal(() => maxMemories = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text(
                          "Generate Memory Video ✨",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          controller.stopTrackPreview();
                          Navigator.pop(modalCtx);

                          final req = RecapGenerateRequest(
                            startDate: startDate != null
                                ? DateFormat('yyyy-MM-dd').format(startDate!)
                                : null,
                            endDate: endDate != null
                                ? DateFormat('yyyy-MM-dd').format(endDate!)
                                : null,
                            backgroundMusic: selectedCategory,
                            songId: selectedSong?.id,
                            theme: selectedTheme,
                            maxMemories: maxMemories.round(),
                          );

                          controller.generateCustomRecap(req);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Ensure audio stops when modal is dismissed
    controller.stopTrackPreview();
  }

  // ============================================
  // PLAY VIDEO
  // ============================================

  void _playVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          mediaPath: videoUrl,
        ),
      ),
    );
  }

  // ============================================
  // MEMORY DETAILS BOTTOM SHEET (GET /memories/{id})
  // ============================================

  void _showMemoryDetails(
    BuildContext context,
    Memories memory,
    MemoriesController controller,
  ) {
    final memoryId = memory.recapId ?? memory.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<Memories?>(
          future: memoryId != null
              ? controller.fetchMemoryById(memoryId)
              : Future.value(memory),
          initialData: memory,
          builder: (context, snapshot) {
            final current = snapshot.data ?? memory;
            final createdAt = DateTime.tryParse(current.createdAt ?? '');
            final formattedDate = createdAt != null
                ? DateFormat('dd MMM, yyyy - hh:mm a').format(createdAt)
                : 'Date unavailable';

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          current.title?.isNotEmpty == true
                              ? current.title!
                              : (current.songTitle?.isNotEmpty == true
                                  ? "Memory Recap • ${current.songTitle}"
                                  : (current.musicCategory?.isNotEmpty == true
                                      ? "${_musicCategoryBadge(current.musicCategory)} Recap"
                                      : 'Memory Recap #${memoryId ?? ""}')),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh Details",
                        onPressed: memoryId != null
                            ? () => controller.fetchMemoryById(memoryId)
                            : null,
                      ),
                    ],
                  ),
                  const Divider(),
                  if (current.description?.isNotEmpty == true) ...[
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.description!,
                      style: const TextStyle(fontSize: 14.5),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Text(
                        "Status: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        current.status?.toUpperCase() ?? "READY",
                        style: TextStyle(
                          color: (current.status == 'failed')
                              ? Colors.red
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (current.progress != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${current.progress}%)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (current.musicCategory?.isNotEmpty == true ||
                      current.songTitle?.isNotEmpty == true) ...[
                    Text(
                      "Music: ${_musicCategoryBadge(current.musicCategory ?? current.mood, songTitle: current.songTitle)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else if (current.childName?.isNotEmpty == true) ...[
                    Text(
                      "Child: ${current.childName}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (current.mood?.isNotEmpty == true &&
                      current.musicCategory == null) ...[
                    Text(
                      "Mood: ${current.mood!.capitalizeFirst} ${_moodEmoji(current.mood!)}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    "Created: $formattedDate",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (current.errorMessage?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Error: ${current.errorMessage}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (current.videoUrl?.isNotEmpty == true) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          "Play Memory Video",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _playVideo(context, current.videoUrl!);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final isSharing = controller.sharingMemoryId.value ==
                          (current.recapId ?? current.id);
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0288D1),
                            side: const BorderSide(color: Color(0xFF0288D1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: isSharing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0288D1),
                                  ),
                                )
                              : const Icon(Icons.share_rounded),
                          label: Text(
                            isSharing
                                ? "Preparing Video..."
                                : "Share Video to Social Media",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: isSharing
                              ? null
                              : () => controller.shareMemory(context, current),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                  Obx(() {
                    final isDel = controller.deletingMemoryId.value ==
                        (current.recapId ?? current.id);
                    return SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: isDel
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(CupertinoIcons.trash, size: 18),
                        label: const Text(
                          "Delete Memory Recap",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: isDel
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                await _confirmAndDeleteMemory(
                                  context,
                                  current,
                                  controller,
                                );
                              },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmAndDeleteMemory(
    BuildContext context,
    Memories memory,
    MemoriesController controller,
  ) async {
    final title = memory.title?.isNotEmpty == true
        ? memory.title!
        : 'this memory recap';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(CupertinoIcons.trash, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Delete Memory Recap',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = memory.recapId ?? memory.id;
      if (id != null) {
        await controller.deleteMemory(id);
      }
    }
  }


  String _musicCategoryBadge(String? category, {String? songTitle}) {
    final cat = (category ?? 'calm').toLowerCase();
    String emoji;
    String name;
    switch (cat) {
      case 'calm':
        emoji = '🌿';
        name = 'Calm';
        break;
      case 'happy':
        emoji = '☀️';
        name = 'Happy';
        break;
      case 'emotional':
        emoji = '🥹';
        name = 'Emotional';
        break;
      case 'childhood':
        emoji = '🧸';
        name = 'Childhood';
        break;
      case 'celebration':
        emoji = '🎉';
        name = 'Celebration';
        break;
      default:
        emoji = '🎵';
        name = category ?? 'Music';
    }
    if (songTitle != null && songTitle.isNotEmpty) {
      return "$emoji $name: $songTitle";
    }
    return "$emoji $name";
  }

  String _moodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'emotional':
        return '🥹';
      case 'childhood':
        return '🎈';
      case 'celebration':
        return '🎉';
      case 'calm':
        return '🍃';
      case 'happy':
      default:
        return '😊';
    }
  }
}

// ============================================
// INSTAGRAM-STYLE EQUALIZER SOUND WAVE BARS
// ============================================

class InstagramEqualizerBars extends StatefulWidget {
  final Color color;
  final double height;

  const InstagramEqualizerBars({
    super.key,
    this.color = const Color(0xFF0288D1),
    this.height = 14,
  });

  @override
  State<InstagramEqualizerBars> createState() => _InstagramEqualizerBarsState();
}

class _InstagramEqualizerBarsState extends State<InstagramEqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final t = _animController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar((0.35 + 0.65 * ((t + 0.15) % 1.0)).clamp(0.25, 1.0)),
            const SizedBox(width: 2),
            _buildBar((0.25 + 0.75 * ((1.0 - t + 0.4) % 1.0)).clamp(0.25, 1.0)),
            const SizedBox(width: 2),
            _buildBar((0.50 + 0.50 * ((t * 1.4) % 1.0)).clamp(0.25, 1.0)),
            const SizedBox(width: 2),
            _buildBar((0.30 + 0.70 * ((t * 0.7 + 0.3) % 1.0)).clamp(0.25, 1.0)),
          ],
        );
      },
    );
  }

  Widget _buildBar(double factor) {
    return Container(
      width: 2.5,
      height: (widget.height * factor).clamp(3.0, widget.height),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}