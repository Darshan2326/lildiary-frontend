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

    final childName = memory.childName?.isNotEmpty == true
        ? memory.childName!
        : "Child's";
    final mood = memory.mood ?? 'happy';

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
              Row(
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
                  Text(
                    "$childName's Recap",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                "Mood: ${mood.capitalizeFirst}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
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
        : (memory.childName?.isNotEmpty == true
            ? "${memory.childName}'s Memory Recap"
            : 'Memory Recap #${memory.id ?? ""}');

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
                        if (memory.mood?.isNotEmpty == true) ...[
                          const SizedBox(width: 10),
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
                              _moodEmoji(memory.mood!) + " " + memory.mood!,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isReady &&
                        memory.videoUrl != null &&
                        memory.videoUrl!.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.play_circle_fill, size: 18),
                        label: const Text("Watch"),
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
  ) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    String selectedMood = "happy";
    String selectedTheme = "classic";
    double maxMemories = 40;

    final List<Map<String, String>> moods = [
      {"key": "happy", "label": "Happy 😊"},
      {"key": "emotional", "label": "Emotional 🥹"},
      {"key": "childhood", "label": "Childhood 🎈"},
      {"key": "celebration", "label": "Celebration 🎉"},
      {"key": "calm", "label": "Calm 🍃"},
    ];

    showModalBottomSheet(
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
                      "Generate a personalized Google Photos style highlight video.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Child Name Input
                    const Text(
                      "Child's Name (Optional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "e.g. Emma",
                        prefixIcon: const Icon(Icons.child_care_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Date Range Pickers
                    const Text(
                      "Date Range (Optional)",
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

                    // Music Mood Selector
                    const Text(
                      "Background Music Mood",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moods.map((m) {
                        final isSel = selectedMood == m["key"];
                        return ChoiceChip(
                          label: Text(m["label"]!),
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
                              setStateModal(() => selectedMood = m["key"]!);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

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
                          Navigator.pop(modalCtx);

                          final req = RecapGenerateRequest(
                            childName: nameController.text,
                            startDate: startDate != null
                                ? DateFormat('yyyy-MM-dd').format(startDate!)
                                : null,
                            endDate: endDate != null
                                ? DateFormat('yyyy-MM-dd').format(endDate!)
                                : null,
                            mood: selectedMood,
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
                              : (current.childName?.isNotEmpty == true
                                  ? "${current.childName}'s Memory Recap"
                                  : 'Memory Recap #${memoryId ?? ""}'),
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
                  if (current.childName?.isNotEmpty == true) ...[
                    Text(
                      "Child: ${current.childName}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (current.mood?.isNotEmpty == true) ...[
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
                  if (current.videoUrl?.isNotEmpty == true)
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
                ],
              ),
            );
          },
        );
      },
    );
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