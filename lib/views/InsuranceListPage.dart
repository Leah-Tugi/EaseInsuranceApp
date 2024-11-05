import 'dart:io';

import 'package:ease_insurance_app/views/userProfilePage.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/InsuranceData.dart';
import '../network/insurance_service.dart';
import 'AddInsurancePage.dart';
import 'InsuranceEditPage.dart';
import 'PremiumCalculationPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InsuranceListScreen extends StatefulWidget {
  final String userId;

  InsuranceListScreen({required this.userId}); // Constructor to receive userId

  @override
  _InsuranceListScreenState createState() => _InsuranceListScreenState();
}

class _InsuranceListScreenState extends State<InsuranceListScreen> {
  Future<List<Insurance>>? _insuranceList;
  String? _userId;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchInsurance();
  }

  Future<void> _loadUserIdAndFetchInsurance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _profileImage = prefs.getString('profileImage');
    if (_userId != null) {
      int userIdInt = int.parse(_userId!);
      setState(() {
        _insuranceList = InsuranceService().getInsurancesForUser(userIdInt);
      });
    } else {
      print('User ID not found in SharedPreferences');
      setState(() {
        _insuranceList = Future.value([]);
      });
    }
  }

  Future<void> _downloadInsuranceList(List<Insurance> insurances) async {
    // Request storage permissions
    await Permission.storage.request();

    // Create a new Excel document
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Insurance'];

    // Define column headers
    List<String> columnHeaders = [
      "Insurance Name",
      "Country",
      "Hospitals",
      "Annual Price",
      "Created On"
    ];
    sheetObject.appendRow(
        columnHeaders.map((header) => TextCellValue(header)).toList());

    // Append insurance data to the sheet
    for (var insurance in insurances) {
      List<CellValue> rowData = [
        TextCellValue(insurance.insuranceName ?? ''),
        TextCellValue(insurance.country ?? ''),
        TextCellValue(insurance.hospitals.isNotEmpty
            ? insurance.hospitals.join(', ')
            : 'No Hospitals'),
        TextCellValue(insurance.annualPrice?.toStringAsFixed(2) ?? 'N/A'),
        TextCellValue(insurance.createdAt?.toIso8601String() ?? ''),
      ];
      sheetObject.appendRow(rowData);
    }


    Directory? directory;
    String filePath;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      filePath = '${directory!.path}/InsuranceData.xlsx';
    } else {
      directory = await getApplicationDocumentsDirectory();
      filePath = '${directory.path}/InsuranceData.xlsx';
    }


    File file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(excel.encode()!);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Insurance list downloaded to $filePath')),
    );

    _launchURL(filePath);
  }

  void _launchURL(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }




  Future<void> _downloadInsuranceListAsPdf(List<Insurance> insurances) async {
    await Permission.storage.request();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Insurance Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: insurances.length,
            itemBuilder: (context, index) {
              final insurance = insurances[index];
              return pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 10),
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Insurance Name: ${insurance.insuranceName ?? 'No Name'}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Country: ${insurance.country ?? 'Unknown'}'),
                    pw.Text(
                        'Hospitals: ${insurance.hospitals.isNotEmpty ? insurance.hospitals.join(', ') : 'No Hospitals'}'),
                    pw.Text(
                        'Annual Price: KES ${insurance.annualPrice?.toStringAsFixed(2) ?? 'N/A'}'),
                    pw.Text(
                        'Created On: ${insurance.createdAt?.toIso8601String() ?? 'N/A'}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    Directory? directory;
    String filePath;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      filePath = '${directory!.path}/InsuranceReport.pdf';
    } else {
      directory = await getApplicationDocumentsDirectory();
      filePath = '${directory.path}/InsuranceReport.pdf';
    }

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Insurance report downloaded to $filePath')),
    );

    _launchURL(filePath);
  }
  void _refreshInsuranceList() {
    setState(() {
      _loadUserIdAndFetchInsurance(); // Refresh the insurance list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PremiumCalculationScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final insurances = await _insuranceList;
              if (insurances != null) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.file_download),
                          title: Text('Export as Excel'),
                          onTap: () async {
                            Navigator.pop(context);
                            _downloadInsuranceList(insurances);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.picture_as_pdf),
                          title: Text('Export as PDF'),
                          onTap: () async {
                            Navigator.pop(context);
                            _downloadInsuranceListAsPdf(insurances);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          IconButton(
            icon: _profileImage != null && _profileImage!.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(_profileImage!),
              radius: 20,
            )
                : const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: _userId.toString())),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Insurance>>(
        future: _insuranceList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No insurance data available'));
          } else {
            final insurances = snapshot.data!;
            return ListView.builder(
              itemCount: insurances.length,
              itemBuilder: (context, index) {
                final insurance = insurances[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      insurance.insuranceName ?? 'No Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text('Country: ${insurance.country ?? 'Unknown'}'),
                        SizedBox(height: 5),
                        Text(
                            'Hospitals: ${insurance.hospitals.isNotEmpty ? insurance.hospitals.join(', ') : 'No Hospitals'}'),
                        SizedBox(height: 5),
                        Text(
                            'Annual Price: KES ${insurance.annualPrice?.toStringAsFixed(2) ?? 'N/A'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, ),
                      onPressed: () async {
                        final updatedInsurance = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InsuranceEditScreen(insurance: insurance),
                          ),
                        );
                        if (updatedInsurance != null) {
                          setState(() {
                            insurances[index] = updatedInsurance;
                          });
                        }
                      },
                    ),
                    onTap: () async {
                      final updatedInsurance = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InsuranceEditScreen(insurance: insurance),
                        ),
                      );
                      if (updatedInsurance != null) {
                        setState(() {
                          insurances[index] = updatedInsurance;
                        });
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newInsurance = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsuranceAddScreen(
                  userId: _userId!,
                refreshList: _refreshInsuranceList,),
            ),
          );

          if (newInsurance != null) {
            _loadUserIdAndFetchInsurance();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Add Insurance',
      ),
    );
  }
}
