import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String reportTitle;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.reportTitle,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'PDF file not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'PDF Preview',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (_pdfBytes != null)
            IconButton(
              onPressed: () => _downloadPdf(context),
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Download PDF',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Report info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reportTitle,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'File: ${widget.filePath.split('/').last}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // PDF viewer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPdfContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildPdfContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_pdfBytes == null) {
      return _buildErrorView();
    }

    return PdfPreview(
      build: (format) async => _pdfBytes!,
      allowSharing: false,
      allowPrinting: false,
      canChangePageFormat: false,
      canDebug: false,
      maxPageWidth: double.infinity,
      pdfFileName: widget.filePath.split('/').last,
      previewPageMargin: const EdgeInsets.all(8),
      scrollViewDecoration: const BoxDecoration(
        color: Colors.white,
      ),
      pages: null, // Show all pages
      onError: (context, error) => _buildErrorView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load PDF',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The PDF file may have been moved or deleted.',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadPdf();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_pdfBytes != null) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download),
                label: Text(
                  'Download PDF',
                  style: AppTextStyles.button,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.close),
              label: Text(
                'Close',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    if (_pdfBytes == null) {
      if (mounted) {
        _showErrorMessage(context, 'PDF not loaded');
      }
      return;
    }

    String? successMessage;
    String? errorMessage;

    try {
      if (Platform.isAndroid) {
        final fileName = widget.filePath.split('/').last;
        
        try {
          // Get external storage directory
          final Directory? externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Navigate to the public Downloads folder
            final String externalPath = externalDir.path;
            final String downloadsPath = externalPath.replaceAll('/Android/data/com.example.rtlapena/files', '/Download');
            
            final downloadsDir = Directory(downloadsPath);
            if (!downloadsDir.existsSync()) {
              downloadsDir.createSync(recursive: true);
            }
            
            final downloadFile = File('${downloadsDir.path}/$fileName');
            await downloadFile.writeAsBytes(_pdfBytes!);
            
            successMessage = 'PDF downloaded to Downloads folder: $fileName';
          } else {
            throw Exception('Could not access external storage');
          }
        } catch (e) {
          // Fallback: use Gal package to save file to gallery as image
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(_pdfBytes!);
          
          await Gal.putImage(tempFile.path, album: 'Downloads');
          successMessage = 'PDF saved to Downloads folder: $fileName';
        }
      } else {
        // For other platforms, use sharing
        final fileName = widget.filePath.split('/').last;
        await Printing.sharePdf(
          bytes: _pdfBytes!,
          filename: fileName,
        );
        successMessage = 'PDF shared successfully';
      }
    } catch (e) {
      errorMessage = 'Error downloading PDF: $e';
    }

    if (mounted) {
      if (successMessage != null) {
        _showSuccessMessage(context, successMessage);
      } else if (errorMessage != null) {
        _showErrorMessage(context, errorMessage);
      }
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
