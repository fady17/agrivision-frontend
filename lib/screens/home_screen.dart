import 'dart:io';
import 'package:agrivision/screens/history_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/scan_summary.dart';
import '../services/api_service.dart';
import '../models/analysis_result.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  List<ScanSummary> _recentScans = [];


  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    try {
      final scans = await _apiService.getUserHistory();
      if (mounted) {
        setState(() {
          _recentScans = scans.take(5).toList(); // Only show top 5
        });
      }
    } catch (e) {
      // Silently fail for recent scans on home, user can check history tab
    }
  }

  // Future<void> _pickImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   final XFile? photo = await picker.pickImage(source: source);

  //   if (photo != null) {
  //     File rawFile = File(photo.path);
  //     // Optimize immediately
  //     File? compressedFile = await ImageService.compressImage(rawFile);
      
  //     setState(() {
  //       _selectedImage = compressedFile ?? rawFile; // Fallback if fails
  //     });
  //   }
  // }

  Future<void> _handleScanRequest(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    if (photo != null) {
      File rawFile = File(photo.path);
      File? compressed = await ImageService.compressImage(rawFile);
      
      setState(() {
        _selectedImage = compressed ?? rawFile;
        _isLoading = true;
      });

      try {
        final AnalysisResult result = await _apiService.analyzeImage(_selectedImage!);
        if (!mounted) return;
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: result, 
              localImage: _selectedImage!
            ),
          ),
        );
        // Refresh recents when coming back
        _loadRecentScans(); 
      } catch (e) {
        _showErrorDialog("Analysis Failed", e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Future<void> _analyzeImage() async {
  //   if (_selectedImage == null) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     final AnalysisResult result = await _apiService.analyzeImage(_selectedImage!);

  //     if (!mounted) return;
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ResultScreen(result: result, localImage: _selectedImage!),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
      
  //     // PARSE ERROR MESSAGE
  //     String errorMessage = e.toString();
  //     String title = "Analysis Failed";
      
  //     if (errorMessage.contains("Connection Error")) {
  //       title = "No Internet";
  //       errorMessage = "Please check your Wi-Fi or data connection.";
  //     } else if (errorMessage.contains("AI_SERVICE_UNAVAILABLE")) {
  //       title = "Server Busy";
  //       errorMessage = "The AI is momentarily overloaded. Please try again.";
  //     }

  //     _showErrorDialog(title, errorMessage.replaceAll("Exception: ", ""));
      
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Good Morning,", style: Theme.of(context).textTheme.bodyLarge),
                      Text("AgriVision", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF2E7D32))),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black54),
                      onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              // 2. Hero Action Card (Scan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  children: [
                    const Icon(Icons.document_scanner_outlined, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text("Identify Plant Disease", 
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    const Text("Snap a photo to get instant AI diagnosis", 
                      style: TextStyle(color: Colors.white70, fontSize: 14)
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleScanRequest(ImageSource.camera),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text("Camera")],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleScanRequest(ImageSource.gallery),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.photo_library), SizedBox(width: 8), Text("Gallery")],
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: 32),

              // 3. Recent Scans Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Scans", style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    child: const Text("View All"),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // 4. Recent List
              if (_recentScans.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text("No scans yet. Start analyzing!", style: TextStyle(color: Colors.grey)),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentScans.length,
                    itemBuilder: (context, index) {
                      final scan = _recentScans[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())), // In real app, go to detail
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: CachedNetworkImage(
                                    imageUrl: scan.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (c,u) => Container(color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(scan.diagnosisName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    _buildSeverityBadge(scan.severityScore),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideX();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(int score) {
    Color color = score < 30 ? Colors.green : score < 60 ? Colors.orange : Colors.red;
    String label = score < 30 ? "Healthy" : score < 60 ? "Warning" : "Critical";
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}