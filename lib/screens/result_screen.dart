import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final File? localImage;      // Make nullable
  final String? networkImageUrl; // Add this


  const ResultScreen({
    super.key,
    required this.result,
    this.localImage,
    this.networkImageUrl,
  }) : assert(localImage != null || networkImageUrl != null, 
         "Either localImage or networkImageUrl must be provided");


  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(result.severity.score);

    return Scaffold(
      // Change title based on context
      appBar: AppBar(title: Text(localImage != null ? "Analysis Result" : "Historical Record")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE DISPLAY LOGIC
            SizedBox(
              height: 250,
              child: _buildImage(),
            ),

            // Analysis Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: severityColor),
                    ),
                    child: Text(
                      result.diagnosis.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: 8),
                  
                  // Confidence
                  Text(
                    "Confidence: ${(result.diagnosis.confidence * 100).toStringAsFixed(1)}%",
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 24),

                  // Severity Meter
                  const Text("Severity Assessment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: result.severity.score / 100,
                    backgroundColor: Colors.grey[200],
                    color: severityColor,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ).animate().shimmer(duration: 1500.ms),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Level: ${result.severity.level}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${result.severity.score}/100", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const Divider(height: 40),

                  // Visual Indicators
                  if (result.severity.visualIndicators.isNotEmpty) ...[
                    const Text("Visual Indicators", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...result.severity.visualIndicators.map((indicator) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: severityColor),
                              const SizedBox(width: 8),
                              Expanded(child: Text(indicator)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  _buildCard(
                    context, 
                    title: "Diagnosis Detail", 
                    content: result.diagnosis.description,
                    icon: Icons.info_outline
                  ),

                  const SizedBox(height: 16),

                  // Recommendation
                  _buildCard(
                    context, 
                    title: "Recommended Action", 
                    content: result.recommendation,
                    icon: Icons.medical_services_outlined,
                    isHighlight: true
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   // Helper to choose between File Image and Network Image
  Widget _buildImage() {
    if (localImage != null) {
      return Image.file(localImage!, fit: BoxFit.cover);
    } else {
      return CachedNetworkImage(
        imageUrl: networkImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    }
  }
  Widget _buildCard(BuildContext context, {required String title, required String content, required IconData icon, bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Color _getSeverityColor(int score) {
    if (score < 30) return Colors.green;
    if (score < 60) return Colors.orange;
    return Colors.red;
  }
}