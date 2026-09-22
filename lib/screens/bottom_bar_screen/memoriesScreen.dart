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
        title: const Text(
          "Memories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                  Icons.auto_awesome,
                  color: Colors.amber,
                ),
                tooltip: "Generate Memory Video",
                onPressed: () => controller.generateMemory(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB4DCF1),
              Colors.white,
              Color(0xFFF1C6D4),
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
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 48,
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refreshMemories,
                          child: const Text('Retry'),
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
                            "No Memories Found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Create short recap videos from your diaries!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text(
                              "Generate First Memory",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => controller.generateMemory(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: memories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopGeneratorCard(context, controller);
                  }

                  final memory = memories[index - 1];
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
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF81D4FA).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFF0288D1),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Memory Recap Videos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Generate a highlight reel video from your diaries",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81D4FA),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.isGenerating.value
                  ? null
                  : () => controller.generateMemory(),
              child: controller.isGenerating.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black54),
                      ),
                    )
                  : const Text(
                      "Generate",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MEMORY ITEM CARD
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
        : 'Memory Recap #${memory.id ?? ""}';

    final status = (memory.status ?? 'ready').toLowerCase();
    final isReady = status == 'completed' ||
        status == 'ready' ||
        (memory.videoUrl != null && memory.videoUrl!.isNotEmpty);
    final isProcessing = status == 'processing' ||
        status == 'generating' ||
        status == 'pending';
    final isFailed = status == 'failed';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                  height: 200,
                  width: double.infinity,
                  child: SmartMediaWidget(
                    mediaPath: mediaUrl,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB4DCF1), Color(0xFFF1C6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: Colors.white70,
                    ),
                  ),
                ),

              // Play button overlay if video is available
              if (memory.videoUrl != null &&
                  memory.videoUrl!.isNotEmpty &&
                  !isProcessing)
                Positioned.fill(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _playVideo(context, memory.videoUrl!),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),

              // Status badge on top right
              Positioned(
                top: 10,
                right: 10,
                child: _buildStatusBadge(status, isProcessing, isFailed),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14.0),
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
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text("Details"),
                      onPressed: () => _showMemoryDetails(
                        context,
                        memory,
                        controller,
                      ),
                    ),
                  ],
                ),

                if (memory.description != null &&
                    memory.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    memory.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],

                if (isFailed && memory.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    memory.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          color: Color(0xFFF48FB1),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (isReady &&
                        memory.videoUrl != null &&
                        memory.videoUrl!.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81D4FA),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.play_circle_fill, size: 18),
                        label: const Text("Watch Video"),
                        onPressed: () =>
                            _playVideo(context, memory.videoUrl!),
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

  // ============================================
  // STATUS BADGE
  // ============================================

  Widget _buildStatusBadge(
    String status,
    bool isProcessing,
    bool isFailed,
  ) {
    Color bg;
    Color fg;
    String label;

    if (isProcessing) {
      bg = Colors.amber.shade700;
      fg = Colors.white;
      label = "Processing...";
    } else if (isFailed) {
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProcessing) ...[
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<Memories?>(
          future: memory.id != null
              ? controller.fetchMemoryById(memory.id!)
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
                      Text(
                        current.title?.isNotEmpty == true
                            ? current.title!
                            : 'Memory #${current.id ?? ""}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh Status",
                        onPressed: current.id != null
                            ? () => controller.fetchMemoryById(current.id!)
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
                      style: const TextStyle(fontSize: 15),
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
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  if (current.videoUrl?.isNotEmpty == true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81D4FA),
                          foregroundColor: Colors.black87,
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}