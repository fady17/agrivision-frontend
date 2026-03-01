import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/analysis_result.dart';
import '../models/scan_summary.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanSummary>> _historyFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getUserHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _apiService.getUserHistory();
    });
  }

  Future<void> _navigateToDetail(String scanId, String imageUrl) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 1. Fetch full details from API
    final AnalysisResult fullResult = await _apiService.getScanDetail(scanId);
    
    // 2. Close loading dialog
    if (mounted) Navigator.pop(context);

    // 3. Navigate to ResultScreen using the Network Image mode
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: fullResult,
            networkImageUrl: imageUrl, // Pass the URL here
            // localImage is null by default
          ),
        ),
      );
    }
  } catch (e) {
    // Close loading dialog
    if (mounted) Navigator.pop(context);
    
    // Show error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan History")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ScanSummary>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No scans recorded yet."),
                  ],
                ),
              );
            }

            final scans = snapshot.data!;
            return ListView.builder(
              itemCount: scans.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return _buildHistoryCard(scan);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanSummary scan) {
    Color severityColor = scan.severityScore < 30 ? Colors.green 
        : scan.severityScore < 60 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: scan.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(
          scan.diagnosisName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat.yMMMd().add_jm().format(scan.createdAt.toLocal())),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text("Severity: ${scan.severityScore}/100"),
              ],
            )
          ],
        ),
       onTap: () {
          _navigateToDetail(scan.id, scan.imageUrl);
        },
      ),
    );
  }
}