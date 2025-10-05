import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/daily_report.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../widgets/weather_log_widget.dart';
import '../widgets/work_log_widget.dart';
import '../widgets/issue_photo_widget.dart';
import 'reports_list_screen.dart';

class ReportFormScreen extends StatefulWidget {
  final DailyReport? existingReport;

  const ReportFormScreen({super.key, this.existingReport});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  // Form controllers
  late TextEditingController _contractorNameController;
  late TextEditingController _blockNumberController;
  late TextEditingController _lotNumberController;
  late TextEditingController _personnelCountController;
  late TextEditingController _issuesController;
  late TextEditingController _safetyNotesController;

  // Form state
  late DateTime _selectedDate;
  late String _selectedUnitType;
  late List<String> _weatherStates;
  late List<WorkEntry> _workEntries;
  late List<IssuePhoto> _issuePhotos;

  bool _isLoading = false;
  String? _currentReportId;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingReport != null) {
      final report = widget.existingReport!;
      _currentReportId = report.id;
      _selectedDate = DateTime.parse(report.reportDate);
      _selectedUnitType = report.unitType;
      _contractorNameController = TextEditingController(text: report.contractorName);
      _blockNumberController = TextEditingController(text: report.blockNumber);
      _lotNumberController = TextEditingController(text: report.lotNumber);
      _personnelCountController = TextEditingController(text: report.personnelCount.toString());
      _issuesController = TextEditingController(text: report.issues);
      _safetyNotesController = TextEditingController(text: report.safetyNotes);
      _weatherStates = report.weatherLog.map((w) => w.condition).toList();
      _workEntries = report.workLog;
      _issuePhotos = report.issuePhotos;
    } else {
      _selectedDate = DateTime.now();
      _selectedUnitType = UnitTypes.bungalow;
      _contractorNameController = TextEditingController();
      _blockNumberController = TextEditingController();
      _lotNumberController = TextEditingController();
      _personnelCountController = TextEditingController(text: '0');
      _issuesController = TextEditingController();
      _safetyNotesController = TextEditingController();
      _weatherStates = List.filled(TimeSlots.slots.length, WeatherConditions.fair);
      _workEntries = TimeSlots.slots
          .map((slot) => WorkEntry(time: slot.label, group: slot.group, log: '', photos: []))
          .toList();
      _issuePhotos = [];
    }
  }

  @override
  void dispose() {
    _contractorNameController.dispose();
    _blockNumberController.dispose();
    _lotNumberController.dispose();
    _personnelCountController.dispose();
    _issuesController.dispose();
    _safetyNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentReportId != null ? 'Edit Report' : 'New Daily Report',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportsListScreen())),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : _buildForm(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProjectDetailsSection(),
          const SizedBox(height: 24),
          _buildWeatherSection(),
          const SizedBox(height: 24),
          _buildWorkforceSection(),
          const SizedBox(height: 24),
          _buildIssuesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(
            'R.T. LAPEÑA CONSTRUCTION & SUPPLY, INC.',
            style: AppTextStyles.heading2.copyWith(color: AppColors.primary, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _currentReportId != null ? 'Edit Daily Report' : 'New Daily Report',
            style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsSection() {
    return _buildSection(
      title: 'Project Details',
      children: [
        _buildDateField(),
        const SizedBox(height: 16),
        _buildUnitTypeField(),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _contractorNameController,
          label: 'Contractor Name',
          hint: 'e.g., Jane Doe Construction Inc.',
          validator: (value) => value?.isEmpty == true ? 'Please enter contractor name' : null,
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _blockNumberController,
          label: 'Block',
          hint: 'e.g., Block 12',
          validator: (value) => value?.isEmpty == true ? 'Please enter block number' : null,
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _lotNumberController,
          label: 'Lot',
          hint: 'e.g., Lot 45',
          validator: (value) => value?.isEmpty == true ? 'Please enter lot number' : null,
        ),
      ],
    );
  }

  Widget _buildWeatherSection() {
    return _buildSection(
      title: 'Weather Log',
      children: [
        WeatherLogWidget(
          weatherStates: _weatherStates,
          onWeatherChange: (index, condition) {
            setState(() {
              _weatherStates[index] = condition;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWorkforceSection() {
    return _buildSection(
      title: 'Workforce & Progress',
      children: [
        _buildTextFormField(
          controller: _personnelCountController,
          label: 'Total Personnel On Site',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty == true) return 'Please enter personnel count';
            if (int.tryParse(value!) == null) return 'Please enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        WorkLogWidget(
          workEntries: _workEntries,
          onTextChange: (index, text) {
            setState(() {
              _workEntries[index] = _workEntries[index].copyWith(log: text);
            });
          },
          onPhotoAdd: (index, photo) {
            setState(() {
              _workEntries[index] = WorkEntry(
                time: _workEntries[index].time,
                group: _workEntries[index].group,
                log: _workEntries[index].log,
                photos: [..._workEntries[index].photos, photo],
              );
            });
          },
          onPhotoRemove: (index, photoId) {
            setState(() {
              _workEntries[index] = WorkEntry(
                time: _workEntries[index].time,
                group: _workEntries[index].group,
                log: _workEntries[index].log,
                photos: _workEntries[index].photos.where((p) => p.id != photoId).toList(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildIssuesSection() {
    return _buildSection(
      title: 'Issues & Safety',
      children: [
        _buildTextFormField(
          controller: _issuesController,
          label: 'Delays or Issues Encountered',
          hint: 'Note any equipment failures, material shortages, or significant conflicts.',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _safetyNotesController,
          label: 'Safety Observations/Incidents',
          hint: 'Document any safety talks, near-misses, or incidents.',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        IssuePhotoWidget(
          issuePhotos: _issuePhotos,
          onPhotoAdd: (photo) {
            setState(() {
              _issuePhotos.add(photo);
            });
          },
          onPhotoRemove: (photoId) {
            setState(() {
              _issuePhotos.removeWhere((p) => p.id == photoId);
            });
          },
          onPhotoUpdate: (photoId, newUrl) {
            setState(() {
              final index = _issuePhotos.indexWhere((p) => p.id == photoId);
              if (index != -1) {
                _issuePhotos[index] = IssuePhoto(id: photoId, url: newUrl);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.textSecondary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Report', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: AppTextStyles.body),
                const Icon(Icons.calendar_today, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Unit Type', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUnitType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: UnitTypes.allTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(UnitTypes.unitTypeNames[type]!));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedUnitType = value!;
            });
          },
          validator: (value) => value == null ? 'Please select unit type' : null,
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _saveReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_currentReportId != null ? 'Update Report' : 'Save Report', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAndStartNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save & Start New', style: AppTextStyles.button, textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentReportId != null ? _exportToPdf : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Export PDF', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final report = _createReport();
      final id = await _databaseService.saveReport(report);

      setState(() {
        _currentReportId = id;
      });

      _showSuccessMessage('Report saved successfully!');
    } catch (e) {
      _showErrorMessage('Error saving report: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndStartNew() async {
    if (!_formKey.currentState!.validate()) return;

    await _saveReport();

    if (_currentReportId != null) {
      _resetForm();
    }
  }

  Future<void> _exportToPdf() async {
    if (_currentReportId == null) {
      _showErrorMessage('Please save the report before exporting to PDF.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final report = _createReport();
      await PdfService.generateAndSharePdf(report);
      _showSuccessMessage('PDF generated successfully!');
    } catch (e) {
      _showErrorMessage('Error generating PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DailyReport _createReport() {
    final weatherLog = TimeSlots.slots.asMap().entries.map((entry) {
      final index = entry.key;
      final slot = entry.value;
      return WeatherEntry(time: slot.label, group: slot.group, condition: _weatherStates[index]);
    }).toList();

    return DailyReport(
      id: _currentReportId,
      reportDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      unitType: _selectedUnitType,
      contractorName: _contractorNameController.text,
      blockNumber: _blockNumberController.text,
      lotNumber: _lotNumberController.text,
      weatherLog: weatherLog,
      workLog: _workEntries,
      issuePhotos: _issuePhotos,
      personnelCount: int.tryParse(_personnelCountController.text) ?? 0,
      issues: _issuesController.text,
      safetyNotes: _safetyNotesController.text,
      timestamp: DateTime.now(),
    );
  }

  void _resetForm() {
    setState(() {
      _currentReportId = null;
      _selectedDate = DateTime.now();
      _selectedUnitType = UnitTypes.bungalow;
      _contractorNameController.clear();
      _blockNumberController.clear();
      _lotNumberController.clear();
      _personnelCountController.text = '0';
      _issuesController.clear();
      _safetyNotesController.clear();
      _weatherStates = List.filled(TimeSlots.slots.length, WeatherConditions.fair);
      _workEntries = TimeSlots.slots
          .map((slot) => WorkEntry(time: slot.label, group: slot.group, log: '', photos: []))
          .toList();
      _issuePhotos = [];
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.success));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  }
}

extension WorkEntryExtension on WorkEntry {
  WorkEntry copyWith({String? time, String? group, String? log, List<WorkPhoto>? photos}) {
    return WorkEntry(
      time: time ?? this.time,
      group: group ?? this.group,
      log: log ?? this.log,
      photos: photos ?? this.photos,
    );
  }
}
